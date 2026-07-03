# Contexto del proyecto

Proyecto: SQUAMA — ASP.NET WebForms, C#, .NET Framework, SQL Server.
Arquitectura existente: `BE` (entidades POCO) / `DAL` (ADO.NET, SqlConnection/SqlCommand) / `SERVICIOS` (lógica de negocio). Todo en español. Cadena de conexión vía `ConfigurationManager.ConnectionStrings["SquamaConnection"]`.

Cada entidad de negocio tiene asociada una tabla DV con esta estructura uniforme (ya creada en la DB):

```sql
CREATE TABLE {Entidad}DV (
    ID{Entidad}DV int IDENTITY(1,1) PRIMARY KEY,
    TipoDigito varchar(3) NOT NULL,      -- 'DVH' o 'DVV'
    IDRegistro int NULL,                  -- usado en DVH
    NombreAtributo varchar(100) NULL,     -- usado en DVV
    ValorDigito varchar(255) NOT NULL,    -- hash SHA256 hex
    FechaCalculo datetime NOT NULL
);
```

También existe:
- `InconsistenciaIntegridad`: `IDInconsistenciaIntegridad, NombreTabla, IDRegistro, NombreAtributo, TipoDigito, ValorEsperado, ValorCalculado, FechaDeteccion, IDUsuarioWebmaster, AccionTomada, Estado`.
- `Bitacora` + `TipoEventoBitacora`: ya tiene seed cargado con los eventos `SISTEMA_BLOQUEADO_INTEGRIDAD` (ID=7), `SISTEMA_DESBLOQUEADO_RECALCULO` (ID=8), `SISTEMA_DESBLOQUEADO_RESTORE` (ID=9).
- Existe `SERVICIOS_Bitacora.RegistrarEvento(int? idUsuario, int idEvento, string ip)` para auditar.

# Tarea

Crear un módulo de Dígito Verificador **genérico y reutilizable** desde cualquier servicio, para cualquier entidad. La misma función debe funcionar para `Usuario`, `Personaje`, `Objeto`, etc., sin duplicar código.

Además, implementar un **gating de arranque por integridad**: el sistema valida la integridad de la BD al iniciar y en cada login. Si detecta inconsistencias, **bloquea el acceso a todos los usuarios excepto al rol Webmaster**, hasta que un webmaster resuelva manualmente la situación (recalculando los DV o restaurando un backup).

# Convenciones

- La PK de cada BE se llama `ID{NombreClase}` (ej: `IDUsuario` en `BE.Usuario`).
- La tabla DV asociada se llama `{NombreClase}DV` (ej: `UsuarioDV`).
- Todo se deriva con reflection: `typeof(T).Name`, propiedades públicas.

# Algoritmo

- Hash: **SHA256**, salida en **hex lowercase** de 64 caracteres.
- Canonicalización del valor antes de hashear:
  - Orden de propiedades: **alfabético por nombre** (no por orden de declaración).
  - `null` → string vacío.
  - `DateTime` → `"yyyy-MM-dd HH:mm:ss"` con `CultureInfo.InvariantCulture`.
  - `decimal`/`double` → invariant culture, sin separador de miles.
  - `bool` → `"1"` o `"0"`.
  - Separador entre valores: `|`.
- Atributo `[ExcluirDeDV]` aplicable a propiedades. La PK siempre se excluye del DVH.

# Exclusiones obligatorias

Marcar con `[ExcluirDeDV]` en los BE (columnas reales que SÍ existen en la tabla pero no se quieren hashear por ser volátiles):
- `BE.Usuario`: `UltimoAcceso`, `IntentosFallidos`, `Bloqueado`, `Estado`.
- Regla general: cualquier `Estado`, `Fecha*Modificacion`, `Fecha*Acceso`, contadores volátiles.

`[ExcluirDeDV]` es solo para columnas reales que no queremos hashear. Las propiedades del BE que **no son columnas reales de la tabla** (ej. `IDRol` en `BE_Usuario`, inyectado desde `UsuarioRol`) se excluyen automáticamente por el filtro de intersección contra `INFORMATION_SCHEMA.COLUMNS` en `ColumnasVerificables` — no se marcan (ni deben marcarse) con `[ExcluirDeDV]`. Ver análisis completo en "Columnas reales vs propiedades BE" más abajo.

Listar en el README qué campos se excluyeron en cada entidad procesada y por qué (distinguiendo exclusión manual vía `[ExcluirDeDV]` de exclusión automática por no-ser-columna).

# Columnas reales vs propiedades BE (verificado vía MCP sqlserver-squama, 2026-07-01)

Consulta usada: `SELECT TABLE_NAME, COLUMN_NAME, ORDINAL_POSITION, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME IN ('Usuario','Bitacora') ORDER BY TABLE_NAME, ORDINAL_POSITION`.

## `Usuario` (tabla) vs `BE_Usuario`

Columnas reales: `IDUsuario, NombreUsuario, Email, PasswordHash, FechaRegistro, UltimoAcceso, Estado, Bloqueado, IntentosFallidos`.
Propiedades de `BE_Usuario` (tras aplicar la regla de contraste — ver sección siguiente): `IDUsuario, NombreUsuario, Email, PasswordHash, FechaRegistro, Estado, Bloqueado, IntentosFallidos, IDRol`.

- **`IDRol`: NO es columna real de `Usuario`** (la carga `BLL_Usuario` desde `UsuarioRol`/`Rol`). Queda excluida de `ColumnasVerificables` vía el filtro de intersección contra columnas reales, no vía `[ExcluirDeDV]`.
- **`FechaRegistro`: columna real y estable** (no cambia tras el alta), que NO estaba mapeada en `BE_Usuario`. Por la regla de contraste (caso 4: columna real+estable sin mapear pero que debe protegerse), se agregó la propiedad `FechaRegistro` (DateTime) al BE. Ya aplicado en `BE/BE_Usuario.cs`.
- El resto (`NombreUsuario`, `Email`, `PasswordHash`, `Estado`, `Bloqueado`, `IntentosFallidos`) son columnas reales.

`ColumnasVerificables(BE_Usuario)` final (PK excluida, `[ExcluirDeDV]` excluye `UltimoAcceso`/`Estado`/`Bloqueado`/`IntentosFallidos`, `IDRol` excluida por no-ser-columna): **`Email`, `FechaRegistro`, `NombreUsuario`, `PasswordHash`**.

## `Bitacora` (tabla) vs `BE_Bitacora`

Columnas reales: `IDBitacora, IDUsuario, IDTipoEventoBitacora, FechaEvento, Descripcion, EntidadAfectada, IDRegistroAfectado, IPOrigen`.
Propiedades de `BE_Bitacora`: `IDBitacora, IDUsuario, IDTipoEventoBitacora, FechaEvento, Descripcion, IPOrigen`.

- Todas las propiedades de `BE_Bitacora` son columnas reales — **no hay ninguna a excluir por no-ser-columna**.
- `EntidadAfectada` e `IDRegistroAfectado` son columnas reales sin mapear en el BE — nunca entran al cálculo (no requiere acción).
- `BE_Bitacora` no tiene (ni necesita por ahora) ninguna propiedad marcada con `[ExcluirDeDV]`.

`ColumnasVerificables(BE_Bitacora)` final (solo PK excluida): **`Descripcion`, `FechaEvento`, `IDTipoEventoBitacora`, `IDUsuario`, `IPOrigen`**.

**Conclusión:** el filtro de intersección contra columnas reales es indispensable para `BE_Usuario` (excluye `IDRol`) y no cambia nada para `BE_Bitacora` (ya estaba limpio), pero se aplica igual a todas las entidades por consistencia y para blindar futuras entidades que agreguen propiedades inyectadas.

# Regla permanente — Contraste propiedad/columna al incorporar una entidad al DV

Antes de dar por lista cualquier entidad nueva agregada a `_entidades` (lista interna de `SERVICIOS_DigitoVerificador`), checklist obligatorio:

1. Traer vía MCP las columnas reales de su tabla: `SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '{Entidad}'`.
2. Comparar contra las propiedades públicas del BE.
3. Clasificar cada columna/propiedad en uno de tres grupos y documentarlo explícitamente (acá o en `DV_README.md`):
   - **Entra al DV**: columna real, estable, con valor de integridad.
   - **Se excluye con `[ExcluirDeDV]`**: columna real pero volátil (`Estado`, contadores, `Fecha*Acceso`/`*Modificacion`).
   - **Queda fuera por no estar mapeada / no ser columna**: propiedad inyectada (no es columna real) o columna sin propiedad en el BE.
4. Si una columna real y estable **no está mapeada en el BE pero debería protegerse por integridad**, hay que **agregar la propiedad al BE** (aunque sea solo para el dígito) para que entre tanto al DVH como al DVV. No alcanza con dejarla "fuera por default".

Este checklist ya se aplicó a `BE_Usuario` y `BE_Bitacora` (ver "Columnas reales vs propiedades BE" arriba): se detectó que `FechaRegistro` caía en el caso 4 y se mapeó en `BE_Usuario`.

# Concurrencia

Operaciones thread-safe via `ConcurrentDictionary<string, object>` con un lock por tabla. Documentar en README que el lock es in-process (single-server alcanza).

# Estado del sistema (bloqueo por integridad)

Crear `SERVICIOS.EstadoSistema` estática:

```csharp
public static class EstadoSistema
{
    private static volatile bool _bloqueado = false;
    private static string _motivoBloqueo = null;
    private static DateTime? _fechaBloqueo = null;
    private static int _cantidadInconsistencias = 0;

    public static bool Bloqueado => _bloqueado;
    public static string MotivoBloqueo => _motivoBloqueo;
    public static DateTime? FechaBloqueo => _fechaBloqueo;
    public static int CantidadInconsistencias => _cantidadInconsistencias;

    internal static void Bloquear(string motivo, int cantidadInconsistencias) { ... }
    internal static void Desbloquear() { ... }
}
```

El flag es **en memoria** (no persiste entre reinicios — al reiniciar, `Application_Start` corre la verificación nuevamente y reestablece el estado correcto). Volatile + interlocked para thread-safety.

# Funciones requeridas

## `SERVICIOS.SERVICIOS_DigitoVerificador` (estática)

```csharp
// USO:
//    SERVICIOS.SERVICIOS_DigitoVerificador.CalcularYGuardarDVH(usuario);
//    (llamar después de cualquier Insert/Update sobre la entidad)
public static void CalcularYGuardarDVH<T>(T entidad)

// USO:
//    bool ok = SERVICIOS.SERVICIOS_DigitoVerificador.VerificarDVH(usuario);
public static bool VerificarDVH<T>(T entidad)

// USO:
//    SERVICIOS.SERVICIOS_DigitoVerificador.RecalcularDVV<BE.Usuario>();
public static void RecalcularDVV<T>()

// USO:
//    bool ok = SERVICIOS.SERVICIOS_DigitoVerificador.VerificarDVV<BE.Usuario>("Email");
public static bool VerificarDVV<T>(string nombreAtributo)

// USO:
//    int inconsistencias = SERVICIOS.SERVICIOS_DigitoVerificador.VerificarIntegridadTabla<BE.Usuario>(idUsuarioWebmaster);
//    (idUsuarioWebmaster: null en verificaciones automáticas de arranque/login)
public static int VerificarIntegridadTabla<T>(int? idUsuarioWebmaster = null)

// USO:
//    int totales = SERVICIOS.SERVICIOS_DigitoVerificador.VerificarIntegridadTotal(idUsuarioWebmaster);
//    (verifica todas las entidades registradas. Si encuentra inconsistencias,
//     llama automáticamente a EstadoSistema.Bloquear y registra en Bitacora.
//     Devuelve el total de inconsistencias detectadas.)
public static int VerificarIntegridadTotal(int? idUsuarioWebmaster = null)

// USO:
//    bool ok = SERVICIOS.SERVICIOS_DigitoVerificador.VerificarTablaCritica<BE.Usuario>();
//    (verificación liviana usada en cada login: solo DVV de la tabla indicada.
//     Si falla, llama a EstadoSistema.Bloquear. Devuelve true si la integridad está OK.)
public static bool VerificarTablaCritica<T>()

// USO:
//    SERVICIOS.SERVICIOS_DigitoVerificador.RecalcularTodosLosDV(idUsuarioWebmaster, ip);
//    (acción del webmaster: recalcula TODOS los DV de TODAS las entidades desde cero,
//     asumiendo que los datos están bien y los DV estaban mal. Al terminar exitosamente
//     llama a EstadoSistema.Desbloquear, registra evento SISTEMA_DESBLOQUEADO_RECALCULO
//     y llama a LimpiarCacheColumnas().)
public static void RecalcularTodosLosDV(int idUsuarioWebmaster, string ip)

// USO:
//    SERVICIOS.SERVICIOS_DigitoVerificador.MarcarSistemaDesbloqueadoPorRestore(idUsuarioWebmaster, ip);
//    (acción del webmaster: llamar DESPUÉS de completar un restore exitoso desde el panel.
//     Llama a EstadoSistema.Desbloquear, registra evento SISTEMA_DESBLOQUEADO_RESTORE
//     y llama a LimpiarCacheColumnas() — el esquema pudo haber cambiado con el restore.)
public static void MarcarSistemaDesbloqueadoPorRestore(int idUsuarioWebmaster, string ip)

// USO:
//    SERVICIOS.SERVICIOS_DigitoVerificador.BloquearPorFallaDeVerificacion(mensaje);
//    (caso defensivo: la verificación en sí falló con una excepción -p.ej. en
//     Application_Start-, no que haya detectado inconsistencias. Único wrapper público
//     para setear EstadoSistema.Bloqueado desde fuera del assembly SERVICIOS.)
public static void BloquearPorFallaDeVerificacion(string motivo)
```

Cada método público debe tener el bloque `// USO:` con el ejemplo concreto. Para `VerificarIntegridadTotal`, mantené una lista interna (`List<Type>`) con las entidades conocidas. Para `VerificarTablaCritica` el caller decide qué tabla considerar crítica (típicamente `BE.Usuario` en el login).

## `DAL.DAL_DigitoVerificador`

```csharp
public void ReemplazarDVH(string nombreTabla, int idRegistro, string valorDigito)
public void ReemplazarDVV(string nombreTabla, string nombreAtributo, string valorDigito)
public string ObtenerDVH(string nombreTabla, int idRegistro)
public string ObtenerDVV(string nombreTabla, string nombreAtributo)
public DataTable ObtenerTodosLosRegistros(string nombreTabla)
public DataTable ObtenerValoresDeColumna(string nombreTabla, string nombreColumna)
public void RegistrarInconsistencia(string nombreTabla, int? idRegistro, string nombreAtributo,
                                    string tipoDigito, string valorEsperado, string valorCalculado,
                                    int? idUsuarioWebmaster)
```

`Reemplazar*` hace DELETE + INSERT en transacción, pero **no abre conexión propia**: arma los `SqlCommand` y delega la ejecución atómica a `DAL_General.EjecutarEnTransaccion(List<SqlCommand>)` (método nuevo). Ver detalle en "Conexión en `Reemplazar*`" en el plan de implementación.

# Gating de arranque y login

## `Global.asax` — modificar `Application_Start`

```csharp
protected void Application_Start(object sender, EventArgs e)
{
    // ... código existente ...

    try
    {
        int inconsistencias = SERVICIOS.SERVICIOS_DigitoVerificador.VerificarIntegridadTotal(null);
        if (inconsistencias > 0)
        {
            // Ya fue marcado como bloqueado por VerificarIntegridadTotal.
            // Loguear en log de aplicación.
        }
    }
    catch (Exception ex)
    {
        // Si la verificación misma falla, bloquear por seguridad.
        SERVICIOS.EstadoSistema.Bloquear("Error en verificacion de arranque: " + ex.Message, -1);
    }
}
```

## En el login (`SERVICIOS_Usuario.Login` o equivalente)

Después de validar credenciales correctamente, **antes de crear la sesión**:

```csharp
bool integridadOK = SERVICIOS.SERVICIOS_DigitoVerificador.VerificarTablaCritica<BE.Usuario>();

if (!integridadOK)
{
    // El sistema ya fue marcado como bloqueado dentro de VerificarTablaCritica.
    // Si el usuario que intenta entrar NO es webmaster, denegar.
    if (!EsWebmaster(usuario))
        throw new Exception("El sistema esta en mantenimiento por una inconsistencia de integridad.");
    // Si es webmaster, dejar pasar al panel de resolución.
}
```

## `BloqueoIntegridadModule` — HttpModule

**Corrección (post-implementación steps 7-9):** el diseño original enganchaba en `BeginRequest`, pero `HttpContext.Session` es `null` en ese punto del pipeline (el `SessionStateModule` todavía no cargó la sesión; recién está disponible desde `PostAcquireRequestState` en adelante). Con `BeginRequest`, el chequeo `ctx.Session?["Usuario"]` siempre daba `null` y el reconocimiento del webmaster nunca funcionaba. Se corrigió a `PostAcquireRequestState` y se simplificó el paradigma a **dos pantallas de destino, repartidas por rol**, en vez de un allowlist amplio tipo `/Webmaster/*`:

- Con el sistema bloqueado, nadie navega libremente.
- El webmaster es redirigido siempre a `~/Webmaster/ResolverIntegridad.aspx` (el panel de resolución).
- Cualquier otro caso (no logueado, o logueado pero no webmaster) es redirigido a `~/SistemaBloqueado.aspx` (pantalla de mantenimiento, sin acciones).
- El login (`LoginIniciarSesion.aspx`) sigue funcionando estando bloqueado, para que cualquiera pueda autenticarse; el módulo se encarga del reparto en la siguiente request (la del `Response.Redirect` post-login).

```csharp
public class BloqueoIntegridadModule : IHttpModule
{
    public void Init(HttpApplication context)
    {
        // PostAcquireRequestState, NO BeginRequest: en BeginRequest la sesión
        // todavía no cargó y ctx.Session siempre es null.
        context.PostAcquireRequestState += OnPostAcquireRequestState;
    }

    private void OnPostAcquireRequestState(object sender, EventArgs e)
    {
        var app = (HttpApplication)sender;
        var ctx = app.Context;

        if (!SERVICIOS.EstadoSistema.Bloqueado) return;

        // Allowlist reducida: login, y las dos pantallas de destino. Este return
        // temprano pasa ANTES que cualquier redirect, evitando loops infinitos
        // (una request a SistemaBloqueado.aspx o ResolverIntegridad.aspx no se
        // vuelve a redirigir a sí misma).
        string path = ctx.Request.AppRelativeCurrentExecutionFilePath.ToLowerInvariant();
        if (EsPathPermitido(path)) return;

        // Guarda defensiva: si no hay sesión disponible, ir a la pantalla segura sin acciones.
        if (ctx.Session == null)
        {
            ctx.Response.Redirect("~/SistemaBloqueado.aspx");
            ctx.ApplicationInstance.CompleteRequest();
            return;
        }

        var usuario = ctx.Session["Usuario"] as BE.Usuario;

        if (usuario != null && SERVICIOS.SERVICIOS_DigitoVerificador.EsWebmaster(usuario))
        {
            // Conserva la sesión: el webmaster la necesita para operar en el panel.
            ctx.Response.Redirect("~/Webmaster/ResolverIntegridad.aspx");
        }
        else
        {
            // No es webmaster: Session.Abandon() (no Clear()) para que quede sin sesión
            // activa de verdad, no solo vacía con el mismo SessionID. SIEMPRE después de
            // leer/evaluar el rol, nunca antes.
            ctx.Session.Abandon();
            ctx.Response.Redirect("~/SistemaBloqueado.aspx");
        }

        ctx.ApplicationInstance.CompleteRequest();
    }

    public void Dispose() { }
}
```

**`Session.Abandon()` vs `Session.Clear()` en la rama no-webmaster:** `Clear()` vacía los valores pero deja la misma sesión (mismo `SessionID`) viva; `Abandon()` termina la sesión de verdad (nuevo `SessionID` en la próxima request del cliente). Acá se busca "sin sesión activa", así que corresponde `Abandon()`, no `Clear()`. Los `BtnLogout_Click` de los Home siguen usando `Clear()` (logout voluntario, caso distinto, sin necesidad de unificar).

Registrar en `Web.config`:
```xml
<system.webServer>
  <modules>
    <add name="BloqueoIntegridadModule" type="PylinskiCuello_ProyectoWeb.BloqueoIntegridadModule"/>
  </modules>
</system.webServer>
```
(el `type` original decía `SquamaWeb.BloqueoIntegridadModule`; el namespace real del proyecto web es `PylinskiCuello_ProyectoWeb`)

## `SistemaBloqueado.aspx`

Página pública que muestra: "El sistema detectó una inconsistencia de integridad y está en mantenimiento. Contacte al webmaster." Sin links a nada más. Implementada primero como placeholder mínimo (paso 9); se puede rediseñar visualmente después sin tocar el módulo.

## Acciones del webmaster — `~/Webmaster/ResolverIntegridad.aspx`

Página visible solo para rol Webmaster. Dos botones:

- **"Recalcular todos los DV"** → confirma con un diálogo modal ("Esta acción asume que los datos están correctos y los DV estaban desactualizados. ¿Continuar?"). Si confirma, llama a `SERVICIOS_DigitoVerificador.RecalcularTodosLosDV(idWebmasterLogueado, Request.UserHostAddress)`.

- **"Restaurar desde backup"** → muestra lista de backups disponibles (`SELECT FROM Backup`). Al elegir uno y confirmar, dispara el restore (asumiendo que ya existe la funcionalidad de restore en el panel; si no, dejá el botón cableado a un método `SERVICIOS_Restore.RestaurarDesdeBackup(idBackup, idWebmaster, ip)` con `throw new NotImplementedException` y un comentario). Tras el restore exitoso, llamar a `MarcarSistemaDesbloqueadoPorRestore(idWebmaster, ip)`.

Mostrar también en la página un resumen del problema: cantidad de inconsistencias detectadas (`EstadoSistema.CantidadInconsistencias`), fecha del bloqueo (`EstadoSistema.FechaBloqueo`), motivo (`EstadoSistema.MotivoBloqueo`), y una grilla con las últimas N filas de `InconsistenciaIntegridad`.

**Implementado.** Detalle no especificado originalmente en el plan y agregado por necesidad: `Page_Load` valida `Session["Usuario"] as BE_Usuario` + `EsWebmaster(usuario)` en CADA request (incluidos postbacks) y redirige a `LoginIniciarSesion.aspx` si no es webmaster. Es necesario porque `BloqueoIntegridadModule` solo actúa mientras `EstadoSistema.Bloqueado == true`; sin este guard en la página, cualquiera podría entrar a `ResolverIntegridad.aspx` directamente cuando el sistema NO está bloqueado (nada más en la app arma control de acceso por rol a nivel de página hoy). `BtnRestaurar_Click` captura específicamente `NotImplementedException` (no un catch genérico) y muestra un mensaje, ya que `SERVICIOS_Restore.RestaurarDesdeBackup` todavía no está implementado — ver tabla de archivos nuevos.

## Auditoría en Bitácora

- Cuando `EstadoSistema.Bloquear` se invoca: registrar evento `SISTEMA_BLOQUEADO_INTEGRIDAD` (ID=7) en `Bitacora` con `IDUsuario = null` (porque suele ser automático) o el ID del webmaster que disparó la verificación si vino con parámetro.
- Cuando `RecalcularTodosLosDV` desbloquea: registrar `SISTEMA_DESBLOQUEADO_RECALCULO` (ID=8) con el ID del webmaster.
- Cuando `MarcarSistemaDesbloqueadoPorRestore` desbloquea: registrar `SISTEMA_DESBLOQUEADO_RESTORE` (ID=9) con el ID del webmaster.

# Entregables

1. `SERVICIOS/SERVICIOS_DigitoVerificador.cs`
2. `SERVICIOS/EstadoSistema.cs`
3. `DAL/DAL_DigitoVerificador.cs`
4. `BE/ExcluirDeDVAttribute.cs`
5. Modificaciones a `BE.Usuario` (y a otros BE listados) aplicando `[ExcluirDeDV]`.
6. `BloqueoIntegridadModule.cs` (raíz del proyecto web).
7. `SistemaBloqueado.aspx` + `.cs`.
8. `Webmaster/ResolverIntegridad.aspx` + `.cs`.
9. Modificaciones a `Global.asax` (`Application_Start`) y a `SERVICIOS_Usuario.Login`.
10. Modificación a `Web.config` registrando el HttpModule.
11. `DV_README.md` con:
    - Algoritmo en 1 párrafo.
    - Tabla de campos excluidos por entidad y motivo.
    - Estrategia de concurrencia y sus límites.
    - **Flujo completo del gating**: qué pasa al `Application_Start`, qué pasa en cada login, qué pasa cuando el HttpModule intercepta una request en estado bloqueado, qué pasa cuando el webmaster resuelve.
    - 5 ejemplos de integración (**corregido**: el ejemplo 4 original decía "Login normal → `VerificarTablaCritica`", pero esa llamada se sacó del login — ver "Modelo de detección"):
      1. Insert de Usuario → `CalcularYGuardarDVH`.
      2. Update de Usuario → `CalcularYGuardarDVH`.
      3. Insert de Personaje (otra entidad) → misma función.
      4. `Application_Start` + timer periódico → `VerificarIntegridadTotal` / `VerificarTablaCritica<BE.Usuario>` (único lugar donde se detecta, junto al timer).
      5. Webmaster resuelve → `RecalcularTodosLosDV` o `MarcarSistemaDesbloqueadoPorRestore`.
    - Tabla "cuándo llamar a qué".

# Restricciones

- **No usar triggers SQL.**
- **No usar ORM/Entity Framework.** Solo ADO.NET.
- **No hardcodear nombres de tabla en SERVICIOS.** Todo derivado de `typeof(T).Name`.
- Manejo de errores: try/catch con `throw;`. No swallowear excepciones.
- Cerrar `SqlConnection`/`SqlCommand` con `using`.

# Antes de empezar

Si algo de la convención no cierra (alguna entidad rompe `ID{NombreClase}`, no existe `EsWebmaster()` o tiene otra firma, `SERVICIOS_Bitacora.RegistrarEvento` tiene otra firma, etc.), preguntá antes de inventar.

---

# Plan de implementación (decisiones cerradas — no preguntar de nuevo)

## Inconsistencias resueltas

| Tema | Decisión |
|---|---|
| Cadena de conexión | Usar `"ConexionPrincipal"` (el Contexto tiene un typo con `"SquamaConnection"`; el real es `"ConexionPrincipal"` en Web.config y DAL_General.cs) |
| Prefijo `BE_` en clases | Todas las clases BE tienen prefijo `BE_` (`BE_Usuario`, `BE_Bitacora`). `typeof(BE_Usuario).Name` = `"BE_Usuario"`. Usar helper `NombreEntidad(Type t)` que stripea el prefijo: `t.Name.StartsWith("BE_") ? t.Name.Substring(3) : t.Name`. Usarlo en TODO el módulo en lugar de `typeof(T).Name` directo. |
| Login location | Modificar `BLL/BLL_Usuario.cs` → `Login()`. No existe `SERVICIOS_Usuario`. |
| `EsWebmaster()` | `public static bool EsWebmaster(BE_Usuario u)` en `SERVICIOS_DigitoVerificador`. Consulta `UsuarioRol JOIN Rol WHERE Nombre='Webmaster' AND Estado=1 AND IDUsuario=X`. DAL support en `DAL_DigitoVerificador.ObtenerEsWebmaster(int idUsuario)`. |
| Session | El login actual NO guarda nada en Session. Agregar `Session["Usuario"] = usuario` en `LoginIniciarSesion.aspx.cs` antes del switch de redirect. `Session.Clear()` en `BtnLogout_Click` de cada home. |
| HttpModule Session check | Corregido: `ctx.Session["Usuario"] as BE_Usuario` → pasar a `EsWebmaster()`. Requiere enganchar en `PostAcquireRequestState`, no `BeginRequest` (ver sección "BloqueoIntegridadModule" abajo). |
| Webmaster IDRol | IDRol = 1 (corregido — ver Hallazgo B: la tabla `Rol` real tiene `IDRol=1 → Webmaster`, `IDRol=2 → Administrador`; el switch de `LoginIniciarSesion.aspx.cs` tiene esos dos casos invertidos, bug preexistente fuera de alcance). |
| `ColumnasVerificables` | Helper único que devuelve propiedades ordenadas alfab., sin PK (`ID{NombreEntidad}`), sin `[ExcluirDeDV]`, **e intersectadas contra las columnas reales de la tabla** (`INFORMATION_SCHEMA.COLUMNS`, vía `DAL_DigitoVerificador.ObtenerColumnasReales`, cacheado en `ConcurrentDictionary<string, HashSet<string>>`). Mismo filtro para DVH y DVV. Ver "Columnas reales vs propiedades BE". |
| Conexión en `Reemplazar*` | `ReemplazarDVH`/`ReemplazarDVV` NO abren `SqlConnection` propia. Arman `List<SqlCommand>` (DELETE+INSERT parametrizados, SIN `.Connection` asignada) y llaman a `DAL_General.EjecutarEnTransaccion(comandos)` (método nuevo agregado a `DAL_General`; asigna `.Connection`/`.Transaction` a cada comando igual que `EjecutarNonQuery`). Respeta el punto único de conexión: `BLL → DAL_DigitoVerificador → DAL_General → BD`. **Aprobado e integrado.** |
| Invalidación de cache de columnas | Manual y explícita, **sin TTL**: `LimpiarCacheColumnas()` limpia `_columnasPorTabla` y se llama solo al final de `RecalcularTodosLosDV` y `MarcarSistemaDesbloqueadoPorRestore`. El esquema no cambia en runtime salvo tras un restore de backup. |
| `VerificarIntegridadTotal` | Lista manual de tipos (evita view-models como `BE_EventoBitacoraVista`). Agregar nuevas entidades ahí al crearlas. |
| `BE_EventoBitacoraVista` | View-model, sin tabla real. Excluida del sistema DV. |
| Verificación en el login | **Sacada.** El login no detecta ni discrimina por integridad; ver "Modelo de detección". |
| Detección de corrupción en runtime | Cubierta por un timer periódico en `Global.asax.cs` (además de `Application_Start`), NO por el login. Intervalo configurable vía `appSettings["IntervaloVerificacionMinutos"]`. Gap conocido y aceptado: si el app pool se recicla por inactividad, no hay detección hasta la próxima request. Ver "Timer de verificación periódica". |
| `Session.Abandon()` vs `Clear()` en el módulo | La rama no-webmaster de `BloqueoIntegridadModule` usa `Abandon()` (sesión realmente terminada), no `Clear()` (sesión vacía pero viva). Los logouts voluntarios de los Home siguen con `Clear()`, sin cambios. |
| `EstadoSistema.Bloquear` desde otro assembly | Es `internal`; `Global.asax.cs` (proyecto web) no puede llamarlo directo. Se agregó `SERVICIOS_DigitoVerificador.BloquearPorFallaDeVerificacion(string motivo)` como wrapper público, solo para el caso defensivo de que la verificación en sí falle con excepción. |
| Lock por tabla en verificación | `VerificarIntegridadTablaInterno` ahora toma el mismo lock por tabla (`ConcurrentDictionary<string,object> _locks`) que las operaciones de escritura, para no leer un DV a mitad de un `Calcular/Recalcular` concurrente sobre la misma tabla. |

## Archivos a crear / modificar

### Nuevos
| Archivo | Descripción |
|---|---|
| `BE/ExcluirDeDVAttribute.cs` | Atributo `[ExcluirDeDV]` |
| `SERVICIOS/EstadoSistema.cs` | Flag in-memory `volatile bool _bloqueado` + `Bloquear`/`Desbloquear` internal |
| `SERVICIOS/SERVICIOS_DigitoVerificador.cs` | 8 métodos genéricos + `EsWebmaster` |
| `DAL/DAL_DigitoVerificador.cs` | 7 métodos DV + `ObtenerEsWebmaster` |
| `PylinskiCuello_ProyectoWeb/BloqueoIntegridadModule.cs` | IHttpModule (`PostAcquireRequestState`, corregido desde `BeginRequest`) |
| `PylinskiCuello_ProyectoWeb/SistemaBloqueado.aspx` + `.cs` | Página pública de mantenimiento |
| `PylinskiCuello_ProyectoWeb/Webmaster/ResolverIntegridad.aspx` + `.cs` + `.designer.cs` | Panel webmaster — implementado |
| `BE/BE_InconsistenciaIntegridad.cs` | POCO de `InconsistenciaIntegridad`, no estaba en el plan original; hizo falta para la grilla de `ResolverIntegridad.aspx` |
| `BE/BE_Backup.cs` | POCO de `Backup`, no estaba en el plan original; hizo falta para el dropdown de restore |
| `DAL/DAL_Backup.cs` | `ObtenerBackupsDisponibles()` (`SELECT ... FROM Backup WHERE Estado=1`) |
| `SERVICIOS/SERVICIOS_Restore.cs` | `ObtenerBackupsDisponibles()` (delega en `DAL_Backup`) + `RestaurarDesdeBackup(idBackup, idWebmaster, ip)` — **`throw new NotImplementedException`**, tal como preveía el plan; el botón "Restaurar desde backup" del panel lo captura y muestra un mensaje en vez de crashear |
| `DAL/DAL_DigitoVerificador.cs` | + `ObtenerUltimasInconsistencias(int cantidad)` (no estaba en la lista original de 7 métodos) |
| `SERVICIOS/SERVICIOS_DigitoVerificador.cs` | + `ObtenerUltimasInconsistencias(int cantidad)` (wrapper) |
| `DV_README.md` | Documentación completa |

### Modificados
| Archivo | Cambio |
|---|---|
| `BE/BE_Usuario.cs` | `[ExcluirDeDV]` sobre `UltimoAcceso`, `IntentosFallidos`, `Bloqueado`, `Estado` |
| `BLL/BLL_Usuario.cs` | `VerificarTablaCritica<BE_Usuario>()` en `Login()` post-validación |
| `PylinskiCuello_ProyectoWeb/LoginIniciarSesion.aspx.cs` | `Session["Usuario"] = usuario` antes del switch de redirect |
| `PylinskiCuello_ProyectoWeb/HomeWebmaster.aspx.cs` (y otros homes) | `Session.Clear()` en `BtnLogout_Click` |
| `PylinskiCuello_ProyectoWeb/Global.asax.cs` | `VerificarIntegridadTotal(null)` en `Application_Start` + arranque del timer periódico (`VerificarTablaCritica<BE_Usuario>` cada N min, no-solapamiento vía `Interlocked`) — **ya implementado, adelantado desde el paso 13** |
| `PylinskiCuello_ProyectoWeb/Web.config` | Registrar `BloqueoIntegridadModule` en `<system.webServer><modules>` + `appSettings["IntervaloVerificacionMinutos"]` — **ya implementado** |
| `DAL/DAL_General.cs` | Agregar `EjecutarEnTransaccion(List<SqlCommand> comandos)` (abre conexión+transacción, ejecuta todos, commit/rollback, cierra) |

## Helpers privados en SERVICIOS_DigitoVerificador

```csharp
// Stripea prefijo BE_ para derivar nombre de entidad, tabla DV y PK
private static string NombreEntidad(Type t) =>
    t.Name.StartsWith("BE_") ? t.Name.Substring(3) : t.Name;

// DAL para lecturas de esquema (columnas reales) y para Reemplazar* (vía DAL_General)
private static readonly DAL.DAL_DigitoVerificador _dal = new DAL.DAL_DigitoVerificador();

// Cache de columnas reales por tabla, para no consultar INFORMATION_SCHEMA en cada cálculo
private static readonly ConcurrentDictionary<string, HashSet<string>> _columnasPorTabla
    = new ConcurrentDictionary<string, HashSet<string>>();

private static HashSet<string> ColumnasRealesDe(string nombreTabla) =>
    _columnasPorTabla.GetOrAdd(nombreTabla, t => new HashSet<string>(_dal.ObtenerColumnasReales(t)));

// Invalidación MANUAL explícita (sin TTL, sin recarga por lectura).
// El esquema no cambia en runtime salvo tras un restore de backup; por eso el cache
// se invalida solo en las acciones del webmaster (RecalcularTodosLosDV y
// MarcarSistemaDesbloqueadoPorRestore) y no por tiempo.
public static void LimpiarCacheColumnas() => _columnasPorTabla.Clear();

// Lista de propiedades a hashear en DVH y DVV (mismo filtro para ambos):
// sin PK, sin [ExcluirDeDV], e intersectadas contra las columnas reales de la tabla
// (evita hashear props inyectadas como BE_Usuario.IDRol, que viene de UsuarioRol y no de Usuario)
private static IEnumerable<PropertyInfo> ColumnasVerificables(Type t)
{
    string nombreTabla = NombreEntidad(t);
    HashSet<string> columnasReales = ColumnasRealesDe(nombreTabla);
    return t.GetProperties()
     .Where(p => !Attribute.IsDefined(p, typeof(ExcluirDeDVAttribute)))
     .Where(p => p.Name != "ID" + nombreTabla)
     .Where(p => columnasReales.Contains(p.Name))
     .OrderBy(p => p.Name);
}

// Canonicalización antes de hashear
private static string CanonicalizarValor(object val) {
    if (val == null) return "";
    if (val is DateTime dt) return dt.ToString("yyyy-MM-dd HH:mm:ss", CultureInfo.InvariantCulture);
    if (val is decimal || val is double) return ((IFormattable)val).ToString(null, CultureInfo.InvariantCulture);
    if (val is bool b) return b ? "1" : "0";
    return val.ToString();
}

// Lock por tabla para concurrencia (in-process)
private static readonly ConcurrentDictionary<string, object> _locks = new ConcurrentDictionary<string, object>();

// Lista manual de entidades con tablas DV reales (agregar nuevas aquí)
private static readonly List<Type> _entidades = new List<Type> {
    typeof(BE_Usuario),
    typeof(BE_Bitacora),
};
```

## Modificación en BLL_Usuario.Login() — REVERTIDA

**Corrección posterior:** se probó insertar `VerificarTablaCritica<BE_Usuario>()` + throw acá (ver historial), pero se revirtió. El login **NO verifica integridad ni discrimina por rol**: valida credenciales, obtiene `IDRol`, limpia `PasswordHash` y devuelve. Punto. La verificación de integridad no vive en el login bajo ningún concepto — ver "Modelo de detección" más abajo.

La referencia de proyecto `BLL → SERVICIOS` se mantiene igual (declarada en `BLL.csproj` con un comentario explicando que es intencional para uso futuro), aunque hoy `BLL_Usuario.cs` no invoque nada de `SERVICIOS`.

## Modelo de detección — quién detecta, quién reacciona

Regla explícita para no confundir responsabilidades:

- **Detectan** inconsistencias (corren `VerificarIntegridadTotal`/`VerificarIntegridadTabla` y pueden setear `EstadoSistema.Bloqueado = true`) **solo dos lugares**:
  1. `Application_Start` (`Global.asax.cs`) — verificación completa (`VerificarIntegridadTotal`) al arrancar la app.
  2. El timer periódico (`Global.asax.cs`, mismo arranque) — verificación liviana (`VerificarTablaCritica<BE_Usuario>`) cada N minutos mientras la app sigue corriendo.
- **NO detectan, solo reaccionan al flag ya seteado**:
  - `BloqueoIntegridadModule` — lee `EstadoSistema.Bloqueado` en cada request y reparte por rol. Nunca dispara una verificación.
  - `BLL_Usuario.Login()` — solo autentica. No verifica, no bloquea, no discrimina por rol.

**Gap conocido y aceptado (no resuelto en este alcance):** si el app pool de IIS se recicla por inactividad, el timer muere con el proceso. Mientras no entra ninguna request, no hay detección — pero tampoco hay uso del sistema en ese lapso. La primera request tras el reciclado dispara un nuevo `Application_Start`, que vuelve a verificar todo. Una garantía de detección continua e incondicional (incluso sin tráfico) requeriría un job externo al proceso IIS (SQL Agent, servicio Windows), fuera de alcance actual.

## Timer de verificación periódica (`Global.asax.cs`)

- Intervalo configurable sin recompilar, vía `appSettings` en `Web.config`:
  ```xml
  <appSettings>
    <add key="IntervaloVerificacionMinutos" value="2" />
  </appSettings>
  ```
  Leído con `ConfigurationManager.AppSettings["IntervaloVerificacionMinutos"]`; si falta la key o no parsea a un entero positivo, fallback a 5 minutos (`IntervaloMinutosPorDefecto`).
- `System.Threading.Timer` (no `System.Timers.Timer`): el callback corre directo en un hilo de ThreadPool, sin el overhead de `SynchronizingObject`/modelo de componente que trae `System.Timers.Timer` (pensado para marshalling a un hilo de UI en WinForms/WPF, que acá no aplica).
- Corre `SERVICIOS_DigitoVerificador.VerificarTablaCritica<BE_Usuario>()` (liviana: solo la tabla crítica, NO `VerificarIntegridadTotal` sobre las 54 entidades). Esa llamada ya bloquea internamente si detecta algo; no se duplica esa lógica en el timer.
- **No-solapamiento (punto crítico):** un flag `int _verificacionEnCurso` con `Interlocked.CompareExchange`/`Interlocked.Exchange` asegura que, si un tick tarda más que el intervalo configurado, el siguiente tick se saltea en lugar de correr en paralelo. Esto es *además* del lock por tabla ya existente en `SERVICIOS_DigitoVerificador` — son dos protecciones distintas y complementarias:
  - El flag `Interlocked` evita que **el timer se solape consigo mismo** (dos ticks corriendo a la vez).
  - El lock por tabla (`ConcurrentDictionary<string, object> _locks`, ya usado por `CalcularYGuardarDVH`/`RecalcularDVV`/`RecalcularTodosLosDV`) evita que **una verificación lea el DV de una tabla a mitad de una escritura** sobre esa misma tabla. Se agregó ese mismo lock también dentro de `VerificarIntegridadTablaInterno` (antes solo lo tomaban las operaciones de escritura), así lectura y escritura de DV para una tabla dada quedan mutuamente excluyentes.
- Manejo de excepciones en el callback: el `try/catch` **no deja escapar** la excepción (una no observada en un hilo de ThreadPool puede tumbar el proceso completo en .NET Framework), pero **tampoco la traga en silencio** — antes de descartarla, `RegistrarFallaVerificacionPeriodica(ex)` deja registro persistente en `App_Data\dv-verificacion-periodica.log` (timestamp + excepción completa). Sin esto, el detector periódico se podía apagar solo y nadie se enteraba.
  - **Por qué archivo en `App_Data` y no Event Log ni Bitácora:**
    - *Event Log de Windows* (`EventLog.WriteEntry`) requiere una "fuente" registrada en el registro de Windows; crearla necesita permisos de administrador que la identidad del app pool normalmente no tiene — puede fallar en silencio según cómo esté hosteado.
    - *Bitácora* pasa por la misma conexión a la BD que la propia verificación acaba de usar. Si la falla es justamente de conectividad a la BD (el escenario más probable), intentar loguear el fallo ahí fallaría por la misma razón que se quiere registrar — no sirve de red de contención para ese caso.
    - Un archivo plano no depende de la BD ni de permisos especiales de SO. `HostingEnvironment.MapPath` (a diferencia de `Server.MapPath`/`HttpContext.Current.Server`) funciona sin `HttpContext` activo, que es justo la situación del timer (sin `Session` ni `Request`).
  - El propio `File.AppendAllText` va en su try/catch anidado, silencioso: si ni siquiera se puede escribir el log (disco lleno, permisos), se pierde ese tick sin registro, pero el callback del timer sigue sin poder crashear el proceso.
- `EstadoSistema.Bloquear`/`Desbloquear` son `internal` (solo visibles dentro del assembly `SERVICIOS`). Como `Global.asax.cs` vive en el proyecto web (otro assembly), el `catch` de `Application_Start` no puede llamar a `EstadoSistema.Bloquear` directo — se agregó `SERVICIOS_DigitoVerificador.BloquearPorFallaDeVerificacion(string motivo)` como único wrapper público para ese caso defensivo puntual (falla la verificación en sí, no que haya encontrado inconsistencias). Mantiene el encapsulamiento original: los mutadores de `EstadoSistema` solo se disparan a través de la fachada pública de `SERVICIOS_DigitoVerificador`.

## DAL_DigitoVerificador — métodos

```csharp
public void ReemplazarDVH(string nombreTabla, int idRegistro, string valorDigito)   // DELETE+INSERT en tx
public void ReemplazarDVV(string nombreTabla, string nombreAtributo, string valorDigito) // DELETE+INSERT en tx
public string ObtenerDVH(string nombreTabla, int idRegistro)         // null si no existe
public string ObtenerDVV(string nombreTabla, string nombreAtributo)  // null si no existe
public DataTable ObtenerTodosLosRegistros(string nombreTabla)
public DataTable ObtenerValoresDeColumna(string nombreTabla, string nombreColumna)
public void RegistrarInconsistencia(string nombreTabla, int? idRegistro, string nombreAtributo,
                                    string tipoDigito, string valorEsperado, string valorCalculado,
                                    int? idUsuarioWebmaster)
public bool ObtenerEsWebmaster(int idUsuario)
// SELECT 1 FROM UsuarioRol ur JOIN Rol r ON ur.IDRol=r.IDRol
// WHERE ur.IDUsuario=@id AND r.Nombre='Webmaster' AND ur.Estado=1 AND r.Estado=1
public List<string> ObtenerColumnasReales(string nombreTabla)
// SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @nombreTabla
// (usa _dal.EjecutarDataTable; resultado cacheado por SERVICIOS_DigitoVerificador)
```

`DAL_DigitoVerificador` usa **composición** (`private readonly DAL_General _dal = new DAL_General()`) para todo acceso a datos — nunca ve ni maneja una `SqlConnection` directamente.
`ReemplazarDVH`/`ReemplazarDVV` arman `List<SqlCommand>` (DELETE + INSERT parametrizados) y llaman a `_dal.EjecutarEnTransaccion(comandos)`. El único punto que abre `SqlConnection`/`SqlTransaction` es `DAL_General`.

## BloqueoIntegridadModule — paths permitidos siempre (allowlist reducida, corregido)

`/logininiciarsesion.aspx`, `/sistemabloqueado.aspx`, `/webmaster/resolverintegridad.aspx`, `.css`, `.js`, `.png`, `.jpg`, `.jpeg`, `.gif`, `.ico`, `.woff`, `.woff2`.

**Ya NO es un allowlist genérico `/webmaster/*`**: con el paradigma de reparto por rol, el webmaster solo necesita acceso directo a `ResolverIntegridad.aspx` (a esa página lo manda el propio módulo); no hace falta dejar pasar el resto del panel webmaster sin chequeo.

Lógica final (enganchada en `PostAcquireRequestState`, ver código completo en "Gating de arranque y login" arriba):
```csharp
if (!SERVICIOS.EstadoSistema.Bloqueado) return;

string path = ctx.Request.AppRelativeCurrentExecutionFilePath.ToLowerInvariant();
if (EsPathPermitido(path)) return; // login + las 2 pantallas de destino + estáticos

if (ctx.Session == null)
{
    ctx.Response.Redirect("~/SistemaBloqueado.aspx");
    ctx.ApplicationInstance.CompleteRequest();
    return;
}

var usuario = ctx.Session["Usuario"] as BE_Usuario;

if (usuario != null && SERVICIOS.SERVICIOS_DigitoVerificador.EsWebmaster(usuario))
    ctx.Response.Redirect("~/Webmaster/ResolverIntegridad.aspx");
else
    ctx.Response.Redirect("~/SistemaBloqueado.aspx");

ctx.ApplicationInstance.CompleteRequest();
```

**Nota sobre el login y el reparto:** el login (`LoginIniciarSesion.aspx.cs`) sigue redirigiendo normalmente a la home según rol (sin cambios de esa lógica). Si el sistema está bloqueado, el módulo intercepta la request SIGUIENTE (la que dispara ese `Response.Redirect` a la home) y ahí redirige de nuevo según corresponda: al panel si es webmaster, a la pantalla de mantenimiento si no. Es decir, un webmaster que loguea estando bloqueado pasa brevemente por su home antes de terminar en `ResolverIntegridad.aspx` — comportamiento esperado, no es un bug.

**Gap RESUELTO (ya no aplica):** este párrafo describía un problema de una versión anterior del diseño, donde `BLL_Usuario.Login()` podía tirar una excepción de mantenimiento que `LoginIniciarSesion.aspx.cs` no capturaba. Esa verificación se sacó por completo del login (ver "Modificación en BLL_Usuario.Login() — REVERTIDA" y "Modelo de detección" más arriba) — el login ya no tira esa excepción bajo ningún escenario, así que no hace falta ningún `try/catch` alrededor de `bll.Login(...)`.

## Orden de implementación

1. `BE/ExcluirDeDVAttribute.cs`
2. `BE/BE_Usuario.cs` — agregar `[ExcluirDeDV]`
3. `SERVICIOS/EstadoSistema.cs`
4. `DAL/DAL_General.cs` — agregar `EjecutarEnTransaccion(List<SqlCommand> comandos)`
5. `DAL/DAL_DigitoVerificador.cs` (incluye `ObtenerColumnasReales`, y `Reemplazar*` delegando en `DAL_General.EjecutarEnTransaccion`)
6. `SERVICIOS/SERVICIOS_DigitoVerificador.cs` (incluye `EsWebmaster` y el cache de columnas reales)
7. `BLL/BLL_Usuario.cs` — modificar `Login()`
8. `LoginIniciarSesion.aspx.cs` — agregar `Session["Usuario"]`
9. Homes `.aspx.cs` — `Session.Clear()` en logout
10. `BloqueoIntegridadModule.cs` + `Web.config`
11. `SistemaBloqueado.aspx` + `.cs`
12. `Webmaster/ResolverIntegridad.aspx` + `.cs`
13. `Global.asax` — agregar `VerificarIntegridadTotal`
14. `DV_README.md`

---

# CHECKPOINT — sesión en pausa (retomar desde acá)

Todo el código del módulo DV (pasos 1→14 de arriba + archivos extra que hicieron falta y no estaban en el plan original: `BE_Backup.cs`, `BE_InconsistenciaIntegridad.cs`, `DAL_Backup.cs`, `SERVICIOS_Restore.cs`, `ObtenerUltimasInconsistencias` en `DAL_DigitoVerificador`/`SERVICIOS_DigitoVerificador`) está **implementado y compila limpio**: último build de la solución completa con `MSBuild.exe` (VS2022 Community, no `dotnet build` — el proyecto web usa `Microsoft.WebApplication.targets` que el SDK de `dotnet` no trae) devolvió exit code 0 con los 6 proyectos (BE, DAL, SERVICIOS, BLL, LOGICA, PylinskiCuello_ProyectoWeb). `DV_README.md` también está escrito y completo.

Faltaba la prueba end-to-end en navegador real, que el usuario quería correr él mismo guiado paso a paso. Quedó a mitad de camino, en la preparación previa al Paso 1. Nada de lo que sigue se ejecutó todavía — es 100% análisis y preparación, cero ejecución real (ni SQL corrido, ni sitio levantado, ni ningún test hecho).

## Plan de prueba de 5 pasos acordado con el usuario (ir de a uno, esperando confirmación antes de avanzar)

1. **Arranque limpio**: levantar el sitio con la base íntegra (DV ya calculados y correctos). Confirmar que `Application_Start` no bloquea, login funciona normal, se puede navegar.
2. **Happy path DV**: loguear, disparar `CalcularYGuardarDVH` sobre un Usuario, confirmar vía MCP (`read_query`) que se escribió la fila en `UsuarioDV`.
3. **Tamper (el test clave)**: `UPDATE` manual en SSMS que altere un campo verificable de `Usuario` (ej. `Email`) sin recalcular su DV. Forzar verificación (reiniciar sitio o esperar tick del timer). Confirmar: (a) se detecta, (b) se registra en `InconsistenciaIntegridad`, (c) `EstadoSistema` queda bloqueado.
4. **Gating**: sistema bloqueado, entrar como NO webmaster → `SistemaBloqueado.aspx` + sesión abandonada (`Session.Abandon()`). Entrar como webmaster → `ResolverIntegridad.aspx` conservando sesión.
5. **Resolución**: en `ResolverIntegridad.aspx`, "Recalcular todos los DV" → recalcula, desbloquea, sitio vuelve a la normalidad.

## Hallazgo A — la BD está vacía, hace falta un "Paso 0" antes del Paso 1 del usuario

Verificado por MCP (solo lectura, `read_query`): `Usuario`, `UsuarioDV`, `UsuarioRol`, `InconsistenciaIntegridad` y `[Backup]` tienen **0 filas**. `Bitacora` tiene 5 filas pero `BitacoraDV` tiene **0**. Conclusión: nunca se calculó ningún DV, ni de Usuario (no hay usuarios) ni de los 5 eventos de Bitácora existentes. La premisa "base íntegra con DV ya calculados" del Paso 1 todavía no existe en esta BD.

Si se arranca el sitio tal cual está ahora, `VerificarIntegridadTotal` en `Application_Start` va a encontrar "inconsistencias" (en realidad: DV nunca calculados — `ObtenerDVV`/`ObtenerDVH` devuelven `null`, y el código trata un `null` guardado igual que un mismatch) y va a bloquear el sistema de entrada. No es un bug del módulo, es la ausencia de línea base.

**Solución acordada (no ejecutada):** usar la propia función "Recalcular todos los DV" del panel webmaster (`ResolverIntegridad.aspx`) para generar la primera línea base — hoy no existe otro mecanismo, no hay ningún INSERT de Usuario real en el código (`DAL_Usuario` solo tiene `SELECT`/`UPDATE` de intentos fallidos). Hacen falta usuarios de prueba insertados a mano por SQL, porque `Usuario` está vacía y no hay alta de usuario implementada en la app: 4 usuarios reales con nombre propio (2 Webmaster, 1 Administrador, 1 Jugador — ver tabla abajo), no los 2 genéricos originalmente previstos.

### SQL preparado para el Paso 0 (el usuario lo corre en SSMS, no yo)

**Descubrimiento (2026-07-02): el login SQL usado por el MCP `sqlserver-squama` no tiene permiso de escritura a nivel de motor** (`INSERT` denegado tanto en `Usuario` como en `UsuarioRol` — confirmado con un intento real que hizo rollback completo, 0 filas afectadas). No es solo la política de "solo lectura" que me impuso el usuario ([[mcp_sqlserver_squama_readonly]]): aunque el usuario apruebe explícitamente una escritura puntual, el propio GRANT de la cuenta lo bloquea. Conclusión operativa: cualquier INSERT/UPDATE/DELETE/DDL en esta base **tiene que correrlo el usuario en SSMS**, sin excepción, más allá de lo que diga la aprobación en el momento.

Se reemplazaron los 2 usuarios de prueba genéricos (`jugador_test`/`webmaster_test`) por 4 usuarios reales pedidos por el usuario, con nombre propio: 2 Webmaster (rafa, naty), 1 Administrador (maxi), 1 Jugador (juan). Hashes calculados con el mismo algoritmo que `BLL_Usuario.HashSHA256` (SHA256 hex lowercase, sin salt, verificados en 64 caracteres).

| Usuario | Rol | Email | Password |
|---|---|---|---|
| rafa | Webmaster | rafa@squama.local | `Rafa2026!` |
| naty | Webmaster | naty@squama.local | `Naty2026!` |
| maxi | Administrador | maxi@squama.local | `Maxi2026!` |
| juan | Jugador | juan@squama.local | `Juan2026!` |

```sql
-- Webmaster — rafa — password: Rafa2026!
INSERT INTO Usuario (NombreUsuario, Email, PasswordHash, FechaRegistro, UltimoAcceso, Estado, Bloqueado, IntentosFallidos)
VALUES ('rafa', 'rafa@squama.local',
        '8674febd743feaa98c96ba0edde8b2448a5fb2f903a815848ac9202b0609df71',
        GETDATE(), NULL, 1, 0, 0);

-- Webmaster — naty — password: Naty2026!
INSERT INTO Usuario (NombreUsuario, Email, PasswordHash, FechaRegistro, UltimoAcceso, Estado, Bloqueado, IntentosFallidos)
VALUES ('naty', 'naty@squama.local',
        '6f77db3f5c7201c646a95666f082a2fbf6d84806e6a1f58bd0df145c9da8eccf',
        GETDATE(), NULL, 1, 0, 0);

-- Administrador — maxi — password: Maxi2026!
INSERT INTO Usuario (NombreUsuario, Email, PasswordHash, FechaRegistro, UltimoAcceso, Estado, Bloqueado, IntentosFallidos)
VALUES ('maxi', 'maxi@squama.local',
        '2474a76e7a12521fcdc0cfad978af9b5e3f38f0db9c799c00b2549ff161f8199',
        GETDATE(), NULL, 1, 0, 0);

-- Jugador — juan — password: Juan2026!
INSERT INTO Usuario (NombreUsuario, Email, PasswordHash, FechaRegistro, UltimoAcceso, Estado, Bloqueado, IntentosFallidos)
VALUES ('juan', 'juan@squama.local',
        '05657cc94178ba43982d04ec3784bc7d86eb32c95e2c40b6e722fe854cc34581',
        GETDATE(), NULL, 1, 0, 0);

-- Roles (IDRol: 1=Webmaster, 2=Administrador, 3=Jugador)
INSERT INTO UsuarioRol (IDUsuario, IDRol, FechaAsignacion, Estado)
VALUES
((SELECT IDUsuario FROM Usuario WHERE NombreUsuario='rafa'), 1, GETDATE(), 1),
((SELECT IDUsuario FROM Usuario WHERE NombreUsuario='naty'), 1, GETDATE(), 1),
((SELECT IDUsuario FROM Usuario WHERE NombreUsuario='maxi'), 2, GETDATE(), 1),
((SELECT IDUsuario FROM Usuario WHERE NombreUsuario='juan'), 3, GETDATE(), 1);
```

**Ojo: `IDRol=1` es Webmaster, `IDRol=2` es Administrador y `IDRol=3` es Jugador** según la tabla `Rol` real (ver Hallazgo B).

## Hallazgo B — bug preexistente (no introducido por el módulo DV, pero afecta el test y una entrada de este mismo archivo)

Tabla `Rol` real (verificado por MCP): `IDRol=1 → "Webmaster"`, `IDRol=2 → "Administrador"`, `IDRol=3 → "Jugador"`.
Switch de `LoginIniciarSesion.aspx.cs`: `case 1 → HomeAdministrador.aspx`, `case 2 → HomeWebMaster.aspx`, `case 3 → HomeJugador.aspx`.

Los casos 1 y 2 están **invertidos** respecto a la tabla `Rol` real (el caso 3/Jugador coincide, sin problema ahí). Es anterior a este trabajo. **La entrada "Webmaster IDRol = 2" en la tabla "Inconsistencias resueltas" de este mismo archivo (sección "Plan de implementación") quedó desactualizada/incorrecta a la luz de este hallazgo — en realidad es `IDRol = 1`.** Pendiente corregir esa entrada si el usuario lo confirma.

**Por qué no rompe el gating igual:** `SERVICIOS_DigitoVerificador.EsWebmaster(usuario)` consulta la BD directo (`Rol.Nombre='Webmaster'`), no usa el switch — es correcto pase lo que pase con ese bug.
- Sistema bloqueado: el módulo reconoce bien a un Webmaster real (por `EsWebmaster`, no por el switch) y lo manda a `ResolverIntegridad.aspx`, aunque el login lo haya mandado primero (cosméticamente mal) a `HomeAdministrador.aspx`.
- Sistema no bloqueado: un Webmaster real aterriza en `HomeAdministrador.aspx` tras loguear (en vez de `HomeWebMaster.aspx`) — confuso visualmente, no afecta la lógica de integridad/gating. Puede navegar manualmente a `Webmaster/ResolverIntegridad.aspx` sin problema.

No se corrigió: está fuera del alcance pedido (no se pidió tocar el login más allá de lo ya cerrado). Si se quiere arreglar más adelante: invertir `case 1`/`case 2` en el switch, o mejor, dejar de hardcodear IDs y comparar por `Rol.Nombre` como ya hace `EsWebmaster`.

## Qué falta al retomar (en orden)

1. Decidir con el usuario si corregir la entrada "Webmaster IDRol = 2" (Hallazgo B) en la tabla de decisiones cerradas — no se tocó código todavía por esto.
2. Ejecutar el Paso 0: el usuario corre el SQL de arriba en SSMS (yo no, por la regla de solo-lectura del MCP).
3. Retomar el plan de 5 pasos del usuario, empezando por su Paso 1 real (arranque limpio) — **recién después de que el Paso 0 haya generado la línea base de DV vía "Recalcular todos los DV" en `ResolverIntegridad.aspx`**.
4. Ir de a un paso por vez, esperando confirmación explícita del usuario antes de avanzar al siguiente (pedido explícito de esta sesión).
5. El sitio corre vía IIS Express integrado en Visual Studio (el `.csproj` tiene `UseIISExpress=true`, `IISUrl=https://localhost:44370/`) — no se levantó todavía en esta sesión.

---






# CHECKPOINT 2 — prueba end-to-end completada, módulo validado funcionalmente (2026-07-02)

Todo lo de "Qué falta al retomar" de arriba **ya se hizo**. El Paso 0 se ejecutó con 4 usuarios reales en vez de los 2 genéricos (ver tabla de credenciales más abajo). El plan de 5 pasos se corrió completo contra el sitio real (IIS Express) y quedó validado, con varios bugs reales encontrados y corregidos en el camino. Hallazgo B se corrigió en la tabla de decisiones (arriba: "Webmaster IDRol = 1").

## Usuarios de prueba reales (reemplazan a jugador_test/webmaster_test)

| Usuario | Rol | Email | Password |
|---|---|---|---|
| rafa | Webmaster | rafa@squama.local | `Rafa2026!` |
| naty | Webmaster | naty@squama.local | `Naty2026!` |
| maxi | Administrador | maxi@squama.local | `Maxi2026!` |
| juan | Jugador | juan@squama.local | `Juan2026!` |

El login del MCP `sqlserver-squama` no tiene permiso de escritura a nivel de motor SQL (no solo la política propia): cualquier INSERT/UPDATE/DDL en esta base lo corre el usuario en SSMS, siempre.

## Bugs reales encontrados y corregidos en esta sesión (todos ya aplicados al código)

1. **`BloqueoIntegridadModule.EsPathPermitido` con `.aspx` hardcodeado + FriendlyUrls** (`RouteConfig.cs`, `AutoRedirectMode=Permanent`) → bucle infinito de redirects (`ERR_TOO_MANY_REDIRECTS`). Fix: comparar sin extensión (`"/sistemabloqueado"` en vez de `"/sistemabloqueado.aspx"`), matchea ambas formas (con/sin extensión amigable).
2. **`DAL_Backup.ObtenerBackupsDisponibles`: `FROM Backup` sin corchetes** — `BACKUP` es palabra reservada T-SQL (statement `BACKUP DATABASE`), rompía con `SqlException` al cargar `ResolverIntegridad.aspx`. Fix: `FROM [Backup]`.
3. **`TipoEventoBitacora` sin los eventos 7/8/9** que `Contexto.md` asumía ya seedeados — la tabla real solo tenía 1-6. `RecalcularTodosLosDV` fallaba con FK violation al loguear evento 8. Fix: el usuario insertó los 3 eventos faltantes vía SSMS con `IDENTITY_INSERT` (columna es IDENTITY). Gap aparte, no bloqueante, anotado pero no resuelto: el evento 7 (`SISTEMA_BLOQUEADO_INTEGRIDAD`) nunca se registra en ningún lado del código — solo 8 y 9 se disparan.
4. **Mojibake ("â€”") en placeholders de "sin dato"** en `ResolverIntegridad.aspx`/`.aspx.cs` y `BitacoraEventos.aspx`: el carácter literal "—" (em dash) sin BOM UTF-8 es propenso a corromperse. Fix: reemplazado por texto plano `"N/D"` en los 4+9 puntos afectados (ASCII puro, inmune a cualquier problema de encoding).
5. **`RecalcularTodosLosDV`/`MarcarSistemaDesbloqueadoPorRestore`: orden de operaciones con `Bitacora`.** Ambos métodos recalculaban el DV de todas las entidades y **después** registraban su propio evento de auditoría en `Bitacora` (INSERT) — esa fila nueva quedaba fuera de la línea base recién creada, autogenerando una inconsistencia falsa de inmediato (1 DVH + 5 DVV de `Bitacora`). Fix: se extrajo `RecalcularDVDeEntidad(Type t, string accion)` y se llama una segunda vez sobre `BE_Bitacora` después de registrar el evento, en ambos métodos.
6. **`InconsistenciaIntegridad` crecía sin límite**: cada verificación (timer cada 2 min, o reinicio de `Application_Start`) que encontraba la misma inconsistencia sin resolver insertaba una fila nueva, sin chequear si ya existía. Fix en dos pasos:
   - Primero: chequeo de "ya existe pendiente" (`Estado=1`) por clave `(NombreTabla, IDRegistro, NombreAtributo, TipoDigito)` antes de insertar.
   - Corregido después: ese primer fix solo no alcanzaba — una fila pendiente vieja bloqueaba para siempre la detección de un valor **nuevo y distinto** con la misma clave (el DVV es tabla-completa, así que un cambio de email de `maxi` choca con la misma clave que un viejo hallazgo de `juan`). Fix final: **upsert real** (`DAL_DigitoVerificador.RegistrarInconsistencia`/`ObtenerIdInconsistenciaPendiente`) — si hay una fila pendiente con el mismo `ValorCalculado`, no se toca; si el valor cambió, se actualiza esa misma fila (`ValorCalculado`+`FechaDeteccion`) en vez de insertar o ignorar.
   - Complemento: `RecalcularDVDeEntidad` ahora llama a `DAL_DigitoVerificador.MarcarInconsistenciasResueltas(nombreTabla, accion)` (nuevo método, `UPDATE ... SET Estado=2` sobre lo pendiente de esa tabla) al final de cada recálculo, así lo resuelto deja de bloquear detecciones futuras.
7. **Logo e imágenes rotas (no arregladas, a propósito):** varias páginas (`LoginIniciarSesion.aspx`, `Login.aspx`) usan URLs efímeras de Figma MCP (`https://www.figma.com/api/mcp/asset/...`) en vez de archivos reales — no hay ningún PNG/SVG/JPG en el proyecto. `Login.aspx` es una pantalla de **landing/bienvenida** separada (no un formulario de login — tiene un botón que lleva a `LoginIniciarSesion`), con 5 imágenes rotas (vs. 1 en `LoginIniciarSesion.aspx`), por eso se ve mucho más "bugueada". El usuario va a agregar los assets reales más adelante; no tocar hasta entonces.

## Validación funcional completa (los 5 pasos del plan original, todos confirmados en esta sesión)

1. **Arranque limpio**: confirmado (tras generar línea base).
2. **Happy path DV**: confirmado (`UsuarioDV`=8 filas, `BitacoraDV` correctas tras recálculo).
3. **Tamper**: confirmado repetidas veces (`Usuario.Email` de `juan` y `maxi`, `Bitacora.IPOrigen`) — detecta, loguea en `InconsistenciaIntegridad` sin duplicar, bloquea el sistema.
4. **Gating**: confirmado — `juan` (Jugador, no-webmaster) bloqueado → `SistemaBloqueado.aspx`; `rafa` (Webmaster) → `ResolverIntegridad.aspx` conservando sesión.
5. **Resolución**: confirmado — "Recalcular todos los DV" desbloquea y limpia inconsistencias pendientes correctamente.

**No probado en esta sesión:** el botón "Restaurar desde backup" (`SERVICIOS_Restore.RestaurarDesdeBackup` sigue siendo `throw new NotImplementedException` a propósito, según el plan original).

## Pendiente / próximos pasos posibles

- Polish visual (HTML/CSS/JS) — explícitamente fuera de alcance por ahora, el usuario lo pidió dejar para después.
- Assets de imágenes reales (logo, ornamentos, dragones) — el usuario los va a agregar él mismo.
- Registrar el evento `SISTEMA_BLOQUEADO_INTEGRIDAD` (ID=7) en `EstadoSistema.Bloquear` o donde corresponda — gap detectado, no bloqueante, no resuelto.
- Implementar `SERVICIOS_Restore.RestaurarDesdeBackup` de verdad (hoy `NotImplementedException` a propósito).