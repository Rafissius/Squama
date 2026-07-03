# Reglas — Dígito Verificador (mantenimiento continuo)

Complementa a `Contexto.md` y `DV_README.md`. Mientras esos dos documentan el diseño original del módulo, este archivo es la referencia operativa para **no romper la integridad al programar nuevas funcionalidades**: qué llamar, dónde, y los pasos exactos para dar de alta una entidad nueva en el sistema.

## Regla general

Todo INSERT, UPDATE o DELETE sobre una entidad registrada en `SERVICIOS_DigitoVerificador._entidades` (hoy: `BE_Usuario`, `BE_Bitacora`) que toque una **columna verificable** (una columna real, no la PK, sin `[ExcluirDeDV]`) tiene que terminar en una llamada al módulo de DV. Si no se hace, el propio insert/update deja el DV desactualizado y la próxima verificación (`Application_Start`, timer periódico, o el webmaster resolviendo) lo reporta como una inconsistencia — aunque los datos estén perfectamente bien. Esto fue exactamente lo que pasó el 2026-07-03: cada login y cada click de prueba insertaban una fila en `Bitacora` sin actualizar su DV, y el reinicio siguiente detectaba 7 "inconsistencias" que en realidad eran altas legítimas nunca reflejadas en el DV.

**Regla de ubicación: la llamada a `SERVICIOS_DigitoVerificador` va siempre en la capa `SERVICIOS`, nunca en el DAL.** El DAL solo sabe hacer SQL; no conoce el módulo de integridad. El DAL únicamente tiene la responsabilidad de devolver el ID generado en un INSERT (ver más abajo) para que la capa SERVICIOS pueda pasarle la entidad completa (con su PK ya seteada) a `CalcularYGuardarDVH`.

## Checklist por tipo de operación

| Operación sobre una entidad registrada | Qué hacer en el DAL | Qué llamar en SERVICIOS, después del DAL |
|---|---|---|
| INSERT (alta) | Agregar `; SELECT SCOPE_IDENTITY();` al final del `INSERT` y ejecutar con `EjecutarScalar` (no `EjecutarNonQuery`). Convertir el resultado a `int` y setearlo en la propiedad `ID{Entidad}` del objeto BE antes de volver. | `CalcularYGuardarDVH(entidad)` (DVH de la fila nueva) **y** `RecalcularDVV<BE_X>()` (el agregado de cada columna verificable cambia al sumar una fila — no solo la que se insertó, TODAS las columnas verificables de esa tabla). |
| UPDATE de una columna verificable (sin `[ExcluirDeDV]`) | Sin cambios especiales. | Mismas dos llamadas que en el INSERT: `CalcularYGuardarDVH(entidad)` + `RecalcularDVV<BE_X>()`. |
| UPDATE de una columna con `[ExcluirDeDV]` (ej. `Estado`, `Bloqueado`, `IntentosFallidos` en `Usuario`) | Sin cambios. | Ninguna. La columna no entra al hash, así que no puede desactualizar el DV. Ejemplo real ya correcto: `DAL_Usuario.SumarIntentoFallido` (solo toca `IntentosFallidos`). |
| DELETE físico de una fila | **No soportado hoy por el módulo** (no existe un "EliminarDVH"). Si se necesita implementar: agregar un método en `DAL_DigitoVerificador` que borre la fila `{Entidad}DV` con `TipoDigito='DVH'` e `IDRegistro` = el de la fila borrada (o decidir explícitamente dejarla huérfana y documentarlo acá). | `RecalcularDVV<BE_X>()` de todas formas, porque el agregado por columna cambia al perder una fila (aunque se decida no tocar el DVH huérfano). |

## Pasos para excluir una propiedad del DV (`[ExcluirDeDV]`)

1. Abrir el BE correspondiente (`BE/BE_X.cs`).
2. Agregar el atributo `[ExcluirDeDV]` justo encima de la propiedad (mismo namespace `BE`, no hace falta `using` adicional — `ExcluirDeDVAttribute` vive en `BE/ExcluirDeDVAttribute.cs`).
3. Solo se excluyen así columnas **reales** que sean volátiles (cambian por moderación, contadores, timestamps de acceso) — no propiedades inyectadas desde otra tabla (esas se excluyen solas, ver paso 3 de la sección siguiente).
4. Documentar el campo y el motivo en la tabla de `DV_README.md` ("Campos excluidos por entidad").

## Pasos para dar de alta una entidad nueva en el sistema de DV

1. **Confirmar convención**: la clase BE se llama `BE_X`, su PK se llama `IDX`, y existe una tabla `X` real en la BD.
2. **Crear la tabla `XDV`** en la BD con el mismo esquema que `UsuarioDV`/`BitacoraDV` (`ID{X}DV`, `TipoDigito`, `IDRegistro`, `NombreAtributo`, `ValorDigito`, `FechaCalculo`) — esto es DDL. El MCP `sqlserver-squama` configurado en este entorno es de **solo lectura**; cualquier `CREATE TABLE` necesita aprobación explícita antes de ejecutarse.
3. **Contrastar columnas reales vs propiedades del BE** (regla ya usada para `Usuario`/`Bitacora`, ver `Contexto.md` → "Regla permanente — Contraste propiedad/columna"): consultar `INFORMATION_SCHEMA.COLUMNS` para la tabla `X` y clasificar cada columna en:
   - Entra al DV (columna real y estable).
   - Se excluye con `[ExcluirDeDV]` (columna real pero volátil).
   - Queda fuera por no estar mapeada (columna sin propiedad en el BE) o por no ser columna real (propiedad inyectada desde otra tabla, como `IDRol` en `BE_Usuario`).
   Si una columna real y estable no está mapeada en el BE pero debería protegerse, agregar la propiedad al BE (no alcanza con dejarla afuera).
4. **Aplicar `[ExcluirDeDV]`** según la clasificación del paso 3.
5. **Agregar `typeof(BE_X)` a la lista `_entidades`** en `SERVICIOS/SERVICIOS_DigitoVerificador.cs` (línea ~22-26, `private static readonly List<Type> _entidades = new List<Type> { typeof(BE_Usuario), typeof(BE_Bitacora), };`). Esto es lo que hace que la entidad participe de `VerificarIntegridadTotal` (arranque) y de `RecalcularTodosLosDV` (acción del webmaster). Sin este paso, la entidad puede tener DV calculado pero nunca se verifica.
6. **Si la entidad debe chequearse también en el timer periódico liviano** (no solo al arranque): agregar una llamada extra a `SERVICIOS_DigitoVerificador.VerificarTablaCritica<BE_X>()` dentro de `VerificacionPeriodicaCallback` en `PylinskiCuello_ProyectoWeb/Global.asax.cs` (línea ~92), junto a la de `BE_Usuario`. Hoy el timer solo cubre `BE_Usuario`; agregar más tablas ahí aumenta el trabajo de cada tick, evaluar si realmente hace falta o alcanza con la verificación de `Application_Start`.
7. **Cablear las llamadas de mantenimiento del DV en la capa SERVICIOS** que hace el INSERT/UPDATE de la entidad nueva, siguiendo el checklist de la sección anterior. Ejemplo real ya aplicado: `SERVICIOS_Bitacora.RegistrarEvento` (`SERVICIOS/SERVICIOS_Bitacora.cs`), inmediatamente después de `dalBitacora.Guardar(bitacora)`, llama a `CalcularYGuardarDVH(bitacora)` y `RecalcularDVV<BE_Bitacora>()`.
8. **Documentar la entidad en `DV_README.md`**: agregar su fila a la tabla de campos excluidos y a la lista de columnas que entran al DV, igual que están documentadas `Usuario` y `Bitacora`.

## Estado actual

- **`Bitacora`**: implementado (2026-07-03). `DAL_Bitacora.Guardar` devuelve el `IDBitacora` generado vía `SCOPE_IDENTITY()`; `SERVICIOS_Bitacora.RegistrarEvento` llama a `CalcularYGuardarDVH` + `RecalcularDVV<BE_Bitacora>()` después del insert.
- **`Usuario`**: el único punto de escritura hoy es `DAL_Usuario.SumarIntentoFallido` (UPDATE de `IntentosFallidos`, columna excluida — no requiere ninguna llamada, ya está bien como está). El ABM de `Usuario` (alta, edición, baja) **todavía no existe**. Cuando se implemente, aplicar el checklist completo de este archivo antes de darlo por terminado.
