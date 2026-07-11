# Módulo de Dígito Verificador (DV) — SQUAMA

## Algoritmo

Para cada entidad registrada (`BE_Usuario`, `BE_Bitacora`, ...), el módulo calcula dos tipos de dígito con **SHA256** (hex lowercase, 64 caracteres): el **DVH** (dígito por fila — hash de todas las columnas verificables de un registro concreto) y el **DVV** (dígito por columna — hash agregado de todos los valores de una columna a lo largo de toda la tabla). Las "columnas verificables" de una entidad son sus propiedades públicas, ordenadas alfabéticamente, excluyendo la PK (`ID{Entidad}`), excluyendo las marcadas con `[ExcluirDeDV]`, e intersectadas contra las columnas reales de la tabla en la BD (así una propiedad inyectada desde otra tabla, como `BE_Usuario.IDRol`, nunca entra al cálculo). Cada valor se canonicaliza antes de concatenar con `|` (`null`/`DBNull` → `""`, `DateTime` → `"yyyy-MM-dd HH:mm:ss"` invariant, `decimal`/`double` → invariant sin separador de miles, `bool` → `"1"`/`"0"`) para que el hash sea determinístico sin importar la cultura del servidor. El resultado se guarda en la tabla `{Entidad}DV` (`TipoDigito` = `'DVH'` o `'DVV'`) reemplazando cualquier valor previo del mismo tipo/clave en una única transacción (DELETE + INSERT).

## Campos excluidos por entidad

| Entidad | Campo | Motivo | Cómo se excluye |
|---|---|---|---|
| `BE_Usuario` | `Estado` | Volátil (cambia por moderación, no por alteración fraudulenta) | `[ExcluirDeDV]` |
| `BE_Usuario` | `Bloqueado` | Volátil (cambia por intentos fallidos de login) | `[ExcluirDeDV]` |
| `BE_Usuario` | `IntentosFallidos` | Contador volátil | `[ExcluirDeDV]` |
| `BE_Usuario` | `IDRol` | No es columna real de `Usuario` (viene de `UsuarioRol`/`Rol` vía `BLL_Usuario`) | Automática, por filtro de columnas reales — **no** lleva `[ExcluirDeDV]` |
| `BE_Usuario` | `UltimoAcceso` | Volátil; además ni siquiera está mapeada como propiedad del BE | Automática, por no-ser-propiedad |
| `BE_Bitacora` | — | Ninguna: todas sus propiedades son columnas reales y estables | — |

Entran al DV de `BE_Usuario`: `Email`, `FechaRegistro`, `NombreUsuario`, `PasswordHash`.
Entran al DV de `BE_Bitacora`: `Descripcion`, `FechaEvento`, `IDTipoEventoBitacora`, `IDUsuario`, `IPOrigen`.

**Regla permanente al agregar una entidad nueva:** antes de sumarla a `_entidades` en `SERVICIOS_DigitoVerificador`, comparar sus columnas reales (`INFORMATION_SCHEMA.COLUMNS`) contra las propiedades del BE y clasificar cada una en: entra al DV / se excluye con `[ExcluirDeDV]` / queda fuera por no estar mapeada. Si una columna real y estable no está mapeada en el BE pero debería protegerse, hay que agregar la propiedad (no alcanza con dejarla afuera por default). Ver detalle completo en `Contexto.md`.

## Concurrencia

- `ConcurrentDictionary<string, object>` con un lock por tabla (`SERVICIOS_DigitoVerificador._locks`). Lo toman: `CalcularYGuardarDVH`, `RecalcularDVV`, `RecalcularTodosLosDV` (escritura) y también `VerificarIntegridadTablaInterno` (lectura), así una verificación nunca lee un DV a mitad de una escritura concurrente sobre la misma tabla. Tablas distintas no se bloquean entre sí.
- El lock es **in-process**: alcanza para un solo servidor (single-server). Si la app se despliega en más de una instancia (farm/load balancer), este mecanismo no coordina entre procesos.
- El timer periódico (ver más abajo) usa además un flag `Interlocked` propio para no solaparse consigo mismo si una corrida tarda más que el intervalo configurado — es una protección distinta y complementaria al lock por tabla.

## Flujo completo del gating

**Modelo de detección — quién detecta, quién solo reacciona (regla explícita, no confundir):**

| | Detecta (corre verificación, puede setear `EstadoSistema.Bloqueado=true`) | Reacciona (lee el flag ya seteado) |
|---|---|---|
| `Application_Start` (`Global.asax.cs`) | ✅ `VerificarIntegridadTotal` (todas las entidades) | |
| Timer periódico (`Global.asax.cs`, cada N min) | ✅ `VerificarIntegridadTotal` (todas las entidades) | |
| Login (`LoginIniciarSesion.aspx.cs`, tras autenticar) | ✅ `VerificarIntegridadTotal` (todas las entidades) | |
| `BloqueoIntegridadModule` | | ✅ solo lee `EstadoSistema.Bloqueado` y reparte por rol |
| `BLL_Usuario.Login()` | | Ninguno de los dos — solo autentica |

**Cambio 2026-07-10:** el timer y el login llamaban antes a `VerificarTablaCritica<BE_Usuario>()` (hardcodeada a una sola entidad). Se cambió a `VerificarIntegridadTotal(null)` en los tres puntos (arranque, timer, login) para que `_entidades` sea la **única fuente de verdad**: agregar o sacar una entidad de esa lista alcanza para que empiece o deje de participar en los tres a la vez, sin tocar `Global.asax.cs` ni `LoginIniciarSesion.aspx.cs`. Motivo real: se reactivó `BE_Bitacora` en `_entidades` pero, con el código viejo, una eliminación directa en `Bitacora` solo se detectaba en el próximo `Application_Start` (reinicio del app pool) — ni el timer ni el login la veían, porque ambos apuntaban a `BE_Usuario` nada más. `VerificarTablaCritica<T>` se deja en el código como utilidad genérica reusable (por si algún día hace falta un chequeo puntual de una sola entidad), pero ya no la llama nadie por defecto.

1. **`Application_Start`**: corre `VerificarIntegridadTotal(null)` sobre todas las entidades de `_entidades`. Si encuentra inconsistencias, `EstadoSistema.Bloqueado` queda en `true` y se registra cada una en `InconsistenciaIntegridad`. Si la verificación en sí tira una excepción (no que encuentre inconsistencias, sino que falle), se bloquea igual por seguridad vía `SERVICIOS_DigitoVerificador.BloquearPorFallaDeVerificacion(...)`. Al final arranca el timer periódico.
2. **Timer periódico**: cada `IntervaloVerificacionMinutos` (`Web.config`, default 5 si falta/inválido), corre `VerificarIntegridadTotal(null)` en background (`System.Threading.Timer`) sobre todas las entidades de `_entidades`. Si falla con una excepción, no la deja escapar (mataría el proceso), pero deja registro en `App_Data\dv-verificacion-periodica.log` antes de descartarla — para que la falla no pase desapercibida. Protegido contra solapamiento consigo mismo (`Interlocked`). Ojo: como recorre todas las entidades registradas (no solo una tabla chica como `Usuario`), el costo por tick crece con la cantidad de entidades y el tamaño de sus tablas — hoy (`Usuario` + `Bitacora`) es insignificante, pero si `Bitacora` crece mucho como log de auditoría, o se agregan más entidades pesadas, reevaluar si conviene alguna optimización (paginar el DVV, bajar la frecuencia, o volver a una verificación más liviana para el timer).
3. **Login**: `BLL_Usuario.Login()` sigue sin verificar nada — solo autentica, obtiene rol, devuelve el usuario. La detección se agregó un nivel más arriba, en `LoginIniciarSesion.aspx.cs` (`btnIngresar_Click`), justo después de `Session["Usuario"] = usuario` y antes del redirect por rol: llama a `SERVICIOS_DigitoVerificador.VerificarIntegridadTotal(null)` (todas las entidades, misma función que usan `Application_Start` y el timer). Si encuentra inconsistencias, deja `EstadoSistema.Bloqueado = true` seteado ahí mismo; el `Response.Redirect` a la home según rol sigue ejecutándose sin cambios, y es la request siguiente (a `HomeXXX.aspx`) la que `BloqueoIntegridadModule` intercepta y redirige según corresponda — no hace falta lógica de redirect adicional en el login.
   - **Gap ya resuelto:** `BLL_Usuario.RegistrarUsuario` ahora llama a `CalcularYGuardarDVH(usuario)` + `RecalcularDVV<BE_Usuario>()` justo después del insert (ver "Ejemplos de integración", punto 1) — antes no calculaba ningún DV para el usuario nuevo, y `ObtenerDVH`/`ObtenerDVV` devolviendo `null` se trataba igual que un mismatch, bloqueando el sistema en el primer login de cualquier usuario recién registrado.
4. **`BloqueoIntegridadModule`** (enganchado en `PostAcquireRequestState`, no `BeginRequest`, porque recién ahí `Session` está disponible): en cada request, si `EstadoSistema.Bloqueado` es `false`, no hace nada. Si es `true`, deja pasar sin más chequeo el login, las dos pantallas de destino (`SistemaBloqueado.aspx`, `Webmaster/ResolverIntegridad.aspx`) y los recursos estáticos. Para el resto: si `Session["Usuario"]` es un webmaster, redirige a `ResolverIntegridad.aspx` conservando la sesión; si no (o no hay sesión), llama a `Session.Abandon()` (sesión realmente terminada, no solo vaciada) y redirige a `SistemaBloqueado.aspx`.
5. **El webmaster resuelve**, desde `Webmaster/ResolverIntegridad.aspx` (que valida por su cuenta que quien entra sea webmaster, vía `Session["Usuario"]` + `EsWebmaster`, independientemente de si el sistema está bloqueado): "Recalcular todos los DV" llama a `RecalcularTodosLosDV(idWebmaster, ip)`, que recalcula DVH+DVV de todas las entidades asumiendo que los datos están bien, limpia el cache de columnas, desbloquea y audita `SISTEMA_DESBLOQUEADO_RECALCULO` (ID=8). "Restaurar desde backup" está cableado a `SERVICIOS_Restore.RestaurarDesdeBackup`, que hoy tira `NotImplementedException` (la funcionalidad de restore real todavía no existe); cuando se implemente, debe terminar llamando a `MarcarSistemaDesbloqueadoPorRestore(idWebmaster, ip)`, que audita `SISTEMA_DESBLOQUEADO_RESTORE` (ID=9).

**Gap conocido y aceptado:** si el app pool de IIS se recicla por inactividad, el timer muere con el proceso; no hay detección hasta la próxima request (que dispara un nuevo `Application_Start`). No hay tráfico en ese lapso, así que tampoco hay uso del sistema. Una garantía de detección continua e incondicional requeriría un job externo al proceso de IIS (SQL Agent, servicio Windows), fuera de alcance.

## Ejemplos de integración

**1. Insert de Usuario** (`BLL_Usuario.RegistrarUsuario`, implementado)
```csharp
// Después del INSERT en DAL_Usuario:
SERVICIOS.SERVICIOS_DigitoVerificador.CalcularYGuardarDVH(nuevoUsuario);
// Y también el DVV: el DVH cubre solo la fila nueva, pero el DVV es un hash
// agregado de TODA la columna a lo largo de la tabla — la fila nueva invalida
// el DVV guardado de cada columna verificable, no solo su propio DVH.
SERVICIOS.SERVICIOS_DigitoVerificador.RecalcularDVV<BE.BE_Usuario>();
```

**2. Update de Usuario**
```csharp
// Después del UPDATE en DAL_Usuario:
SERVICIOS.SERVICIOS_DigitoVerificador.CalcularYGuardarDVH(usuarioActualizado);
```

**3. Insert de Personaje (otra entidad, mismo patrón genérico)**
```csharp
// Igual que Usuario, sin duplicar código: la función es genérica por T.
SERVICIOS.SERVICIOS_DigitoVerificador.CalcularYGuardarDVH(nuevoPersonaje);
```

**4. Detección — `Application_Start` y timer periódico (`Global.asax.cs`)**
```csharp
// Al arrancar la app:
SERVICIOS.SERVICIOS_DigitoVerificador.VerificarIntegridadTotal(null);

// Cada N minutos (timer en background, ver Global.asax.cs) y también en cada login
// (LoginIniciarSesion.aspx.cs) — misma llamada, todas las entidades de _entidades:
SERVICIOS.SERVICIOS_DigitoVerificador.VerificarIntegridadTotal(null);
```

**5. Webmaster resuelve (`Webmaster/ResolverIntegridad.aspx.cs`)**
```csharp
// Opción A: recalcular asumiendo que los datos están bien
SERVICIOS.SERVICIOS_DigitoVerificador.RecalcularTodosLosDV(idWebmaster, Request.UserHostAddress);

// Opción B: restaurar desde backup (hoy NotImplementedException)
SERVICIOS.SERVICIOS_Restore.RestaurarDesdeBackup(idBackup, idWebmaster, Request.UserHostAddress);
SERVICIOS.SERVICIOS_DigitoVerificador.MarcarSistemaDesbloqueadoPorRestore(idWebmaster, Request.UserHostAddress);
```

## Tabla — cuándo llamar a qué

| Situación | Qué llamar |
|---|---|
| Se insertó o actualizó una fila de una entidad registrada | `CalcularYGuardarDVH(entidad)` |
| Se quiere saber si una fila puntual está intacta | `VerificarDVH(entidad)` |
| Se recalculó manualmente el valor de una columna completa (sin haber tocado filas) | `RecalcularDVV<T>()` |
| Se quiere saber si una columna entera está intacta | `VerificarDVV<T>(nombreAtributo)` |
| Se quiere verificar una tabla completa (DVH de todas las filas + DVV de todas las columnas) y registrar inconsistencias | `VerificarIntegridadTabla<T>(idUsuarioWebmaster)` |
| Arranque de la app, timer periódico, o login (las 3 verifican TODAS las entidades registradas) | `VerificarIntegridadTotal(null)` |
| Chequeo puntual de una sola entidad (utilidad genérica, hoy sin caller por defecto) | `VerificarTablaCritica<T>()` |
| El webmaster asume que los datos están bien y los DV desactualizados | `RecalcularTodosLosDV(idWebmaster, ip)` |
| Se completó un restore de backup exitoso | `MarcarSistemaDesbloqueadoPorRestore(idWebmaster, ip)` |
| La verificación en sí falló (excepción, no inconsistencias) desde fuera del assembly `SERVICIOS` | `BloquearPorFallaDeVerificacion(motivo)` |
| Se necesitan las últimas N inconsistencias para mostrarlas en el panel | `ObtenerUltimasInconsistencias(cantidad)` |
| Se necesita saber si un usuario es webmaster | `EsWebmaster(usuario)` |

## Gaps conocidos (documentados, no resueltos en este alcance)

1. **Reciclado de app pool**: ver "Flujo completo del gating" arriba.
2. **Restore real**: `SERVICIOS_Restore.RestaurarDesdeBackup` tira `NotImplementedException`. La UI ya está cableada (dropdown de backups disponibles + botón), pero la operación de restore de base de datos en sí no está implementada.
3. **Sin coordinación multi-servidor**: los locks de concurrencia son in-process; no sirven si la app corre en más de una instancia simultánea.
