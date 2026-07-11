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

## Bug recurrente sin resolver: falso positivo de DVH en `Bitacora` (2026-07-07) — `BE_Bitacora` sacada temporalmente de `_entidades`

Patrón observado repetidas veces en el historial de `InconsistenciaIntegridad` (2026-07-03, 2026-07-06, 2026-07-07): una fila de `Bitacora` (típicamente un login fallido) queda con un DVH que no matchea en la próxima verificación, bloqueando todo el sistema hasta un "Recálculo manual" — sin que haya habido ningún tamper real de por medio.

Investigado el 2026-07-07 a raíz de un caso concreto (fila `IDBitacora=89`, login fallido de una cuenta ajena a lo que se estaba probando en ese momento). Se descartaron como causa:
- Redondeo de milisegundos en `FechaEvento`: `CanonicalizarValor` trunca a `"yyyy-MM-dd HH:mm:ss"` (sin milisegundos), así que no debería importar.
- Corrupción de encoding en `Descripcion` (tildes): comparados los bytes exactos (`DATALENGTH`) de `Bitacora.Descripcion` vs `TipoEventoBitacora.Descripcion` origen — idénticos, sin mojibake.
- Bug de concurrencia en `DAL_DigitoVerificador.ReemplazarDVH`/`ReemplazarDVV`: revisado, usa `SqlCommand` nuevos por llamada (sin estado compartido mutable) — no se encontró una causa ahí.

Hipótesis más fuerte, **no confirmada**: `SERVICIOS_Bitacora.RegistrarEvento` calcula el DVH con `CalcularYGuardarDVH(bitacora)` usando el objeto en memoria justo después del insert, en vez de releer la fila desde la base. Las filas afectadas históricamente coinciden con ráfagas de logins fallidos muy seguidos en el tiempo (segundos de diferencia), lo que sugiere una condición de carrera puntual — pero no se llegó a reproducir de forma controlada ni a identificar la causa exacta.

**Decisión (2026-07-07):** sacar `typeof(BE_Bitacora)` de `SERVICIOS_DigitoVerificador._entidades` hasta encontrar la causa raíz real. `Bitacora` sigue siendo un log de auditoría (se sigue escribiendo normalmente), simplemente deja de participar en `VerificarIntegridadTotal`/`VerificarIntegridadTabla`/`RecalcularTodosLosDV` — ya no puede volver a bloquear el sistema por un falso positivo. Las llamadas a `CalcularYGuardarDVH`/`RecalcularDVV` dentro de `SERVICIOS_Bitacora.RegistrarEvento` se dejaron intactas a propósito (siguen calculando y guardando el DVH/DVV de cada evento, por si sirve de rastro para investigar la causa raíz más adelante) — simplemente ya no se **verifican**. Revisar y potencialmente re-registrar `BE_Bitacora` el día que se entienda y corrija la causa real.

### Causa raíz encontrada y reproducida (2026-07-10)

La hipótesis de la condición de carrera **no era la causa**; la pista correcta era la del redondeo de milisegundos, pero descartada por el motivo equivocado. Lo que se había chequeado en su momento (2026-07-07) era si la pérdida de milisegundos *dentro del mismo segundo* rompía el hash — correctamente descartado, ya que `CanonicalizarValor` trunca a `"yyyy-MM-dd HH:mm:ss"` sin milisegundos. Lo que no se había probado es el caso borde: **SQL Server redondea el tipo `datetime` legacy a incrementos de ~3.33ms, y cuando el valor cae muy cerca del techo de un segundo (aprox. entre `.9985` y `.9999`), redondea hacia el segundo siguiente completo** (`20:18:37.9990476` → se guarda como `20:18:38.0000000`). Eso sí cambia el string canonicalizado completo (`...:37` → `...:38`), y por lo tanto el hash.

`DAL_Bitacora.cs` guarda `FechaEvento` con `SqlDbType.DateTime` (columna `Bitacora.FechaEvento` es `datetime`, confirmado por `INFORMATION_SCHEMA.COLUMNS`). `CalcularYGuardarDVH(bitacora)` en `SERVICIOS_Bitacora.RegistrarEvento` hashea el objeto en memoria (con el `DateTime.Now` original, antes del redondeo de SQL) — cualquier verificación posterior relee la fila desde la base (ya redondeada) y calcula un hash distinto. Probabilidad de que un insert individual caiga en la ventana de acarreo: ~0.06% (1.5ms de cada 1000ms) — coincide con lo esporádico e imposible de atar a un patrón que reportaba el equipo, y con que se note más en ráfagas de inserts seguidos (varios logins fallidos uno atrás del otro = más chances de pegarle al borde).

**Reproducido de forma aislada y controlada** (proyecto de consola descartable, fuera del repo, referenciando `SERVICIOS.dll`/`DAL.dll`/`BE.dll` compilados): 5000 inserts directos a `Bitacora` vía `DAL_Bitacora.Guardar`, comparando el `DateTime` en memoria contra el releído de la base — 3 mismatches exactos, todos con el mismo patrón de acarreo de segundo. Filas de prueba borradas al terminar (`Descripcion='TEST_STRESS_DV'`, 0 filas remanentes verificado).

**Fix acordado (pendiente de implementar):**
1. Cambiar `CalcularYGuardarDVH<T>` (`SERVICIOS_DigitoVerificador.cs`) para que releea la fila recién insertada desde la base antes de hashear, en vez de usar el objeto en memoria — corrige esta clase entera de bugs "memoria vs. BD" (no solo fechas), aplica a `SERVICIOS_Bitacora.RegistrarEvento` y `BLL_Usuario.RegistrarUsuario`.
2. Migrar `Bitacora.FechaEvento` y `Usuario.FechaRegistro` de `datetime` a `datetime2` (elimina el redondeo de origen, belt-and-suspenders con el punto 1).
3. Una vez aplicado, volver a agregar `typeof(BE_Bitacora)` a `_entidades` (revertir el comentario de la línea 32).

Ver `EntornoLocal.md` para cómo se levantó el sitio localmente (IIS Express + MSBuild) y cómo se armó el proyecto de consola descartable usado para la reproducción.

# Módulo de Combate — plan completo (2026-07-07)

Después de conectar Personaje/Estadísticas/Nivel (ver secciones de arriba: `BE_Personaje`, `BLL_Personaje`, `HomeJugador.aspx`, `SeleccionarRival.aspx` con rivales reales), el siguiente paso lógico es el combate en sí. Esta sección documenta **el plan completo a futuro** (la visión real, más rica) y **qué parte de ese plan se implementa ahora como prototipo** — para poder retomar y mejorar el módulo con contexto completo, en vez de perder de vista el diseño más ambicioso por haber empezado simple.

## Visión completa (futura, no todo implementado hoy)

El repo ya tiene, creadas a mano en SSMS (mismo patrón que `Personaje`/`Clan`), tablas reales pensando en un sistema de combate mucho más rico del que se prototipa hoy:

- **`Combate`**: `IDCombate, IDPersonajeAtacante, IDPersonajeDefensor, IDResultadoCombate, FechaCombate, CopasAtacanteAntes, CopasAtacanteDespues, VariacionCopas, ExperienciaGanada, Estado`.
- **`ResultadoCombate`**: catálogo (`Victoria`/`Derrota`), vacío hoy.
- **`EventoCombate`**: eventos especiales de arena con ventana de tiempo (`FechaInicio`/`FechaFin`), administrados por un `IDUsuarioAdministrador` — sin usar todavía.
- **`RecompensaCombate`**: recompensas adicionales de un combate puntual (`IDTipoRecurso`, `Cantidad`) — sugiere que a futuro un combate puede otorgar más que copas/XP (materiales, monedas, etc. vía un catálogo de recursos que todavía no existe como tabla propia).

Además, ya existen dos pantallas de UI **completamente mockeadas** que muestran cuál es la experiencia final imaginada:

- **`CombateEnCurso.aspx`**: batalla animada **por rondas**, con barra de HP de ambos personajes que baja en tiempo real, slots de equipamiento (arma/armadura/mascota/2 habilidades) por personaje, una "crónica del combate" con texto narrativo generado por golpe (ataques, críticos, buffs de mascota), contador de acciones (ataques básicos/habilidades/críticos/bloqueos), y una barra inferior con recompensas provisionales (XP/puntos de arena/monedas) y un botón "Resultados".
- **`ArenaVictoria.aspx`**: pantalla de resultado con: crónica resumida (lista de highlights del combate), panel comparativo de ambos personajes (HP final, daño infligido/recibido, críticos), recompensas (XP con barra de progreso a next-level, puntos de arena, **monedas de gremio**), una barra de **ranking global** (posición antes→después), y accesos a "Pelear de nuevo", "Ver narración completa", "Ir al inventario", "Volver al inicio".

Ninguno de estos elementos visuales tiene hoy backing real: **no existe** sistema de HP (los personajes no tienen "vida actual" en combate, solo el stat `Vida` como número de poder), **no existe** equipamiento (armas/armaduras/mascotas/habilidades — no hay tablas `Item`/`Equipamiento`/`Habilidad`), **no existen** rondas simuladas turno a turno, **no existe** ninguna moneda/divisa (ni "monedas de gremio" ni ninguna otra), y **no existe** ranking global de jugadores.

### Roadmap sugerido (orden razonable, no comprometido a fechas)
1. **(Hoy) Prototipo instantáneo**: fórmula simple estadísticas+random, sin rondas, sin HP, sin equipo. Ver "Prototipo de hoy" abajo.
2. **Combate por rondas real**: simular N rondas donde en cada una ambos personajes se restan "daño" (función de Fuerza/Agilidad del atacante vs. Vida/algo del defensor) hasta que uno llega a 0 — recién ahí `CombateEnCurso.aspx` tendría sentido wirear de verdad (HP real bajando ronda a ronda, log de texto generado a partir de los golpes reales, no inventado).
3. **Límite de intentos diarios**: el mock ya insinúa "Intentos hoy: 3/5" — necesitaría una columna/tabla de contador diario por personaje (reset a medianoche) antes de conectar el botón "Refrescar (1 intento)" de `SeleccionarRival.aspx`.
4. **Consecuencias para el defensor**: hoy `Combate` solo trackea copas del atacante. Si se quiere que perder como defensor también reste copas/sume derrotas al defensor, hay que decidir esa regla de negocio explícitamente (¿el defensor se entera? ¿hay notificación?) y probablemente agregar columnas `CopasDefensorAntes/Despues` a `Combate`.
5. **Equipamiento**: tablas nuevas (`Item`, `TipoItem`, `PersonajeEquipamiento` o similar) antes de que los slots de arma/armadura/mascota/habilidades de los mocks tengan sentido.
6. **Economía**: si se quiere una "moneda de gremio" o similar, definir su propia tabla/saldo por personaje — hoy no existe ningún concepto de moneda en el modelo.
7. **Ranking global**: una vista o query que ordene todos los `Personaje` por `CopasArena` (o un ranking dedicado) para la barra de posición de `ArenaVictoria.aspx`.
8. **`EventoCombate`/`RecompensaCombate`**: eventos especiales con recompensas extra — sin diseñar todavía, esperar a tener el combate base sólido primero.
9. **Pantalla de derrota dedicada**: hoy el prototipo maneja la derrota con un simple mensaje en `SeleccionarRival.aspx` (ver abajo), sin navegar a ninguna pantalla — se podría crear una `ArenaDerrota.aspx` (no existe hoy) el día que se justifique.

## Prototipo de hoy (lo que se implementa ahora)

Deliberadamente mucho más simple que la visión de arriba — decisión explícita del usuario ("por ahora, súper simple... vamos a hacerlo más simple de lo que realmente va a ser"). Sin rondas, sin HP, sin equipo, sin economía, sin ranking, sin límite de intentos.

**Fórmula:**
```
PoderBase(personaje) = suma de las 5 ValorBase (Vida+Fuerza+Agilidad+Velocidad+Inteligencia)
PoderFinal(personaje) = PoderBase * (1 + aleatorio(-20%, +20%))
Gana el atacante si PoderFinal(atacante) >= PoderFinal(defensor)
```

**Recompensas (constantes en `BLL_Combate`, fáciles de ajustar):**
- Victoria: `+10 copas` (piso en 0), `+30 XP + 5*NivelDefensor` de experiencia (vía `BLL_Personaje.GanarExperiencia`, hereda el sistema de nivel ya construido), `VictoriasArena += 1`.
- Derrota: `-5 copas` (piso en 0), sin XP, `DerrotasArena += 1`.
- El defensor no sufre ningún cambio (ver punto 4 del roadmap).

**UI:** al clickear "Pelear ahora" en `SeleccionarRival.aspx`, se llama al backend real (`ArenaApi.ashx?accion=Pelear`) pero la pantalla espera **~5 segundos simulados** (sin lógica real detrás, solo para que no se sienta instantáneo) antes de mostrar el resultado. Si gana, redirige a `ArenaVictoria.aspx?idCombate=X` (recortada a datos reales: nombres, niveles, poder calculado, XP ganada, copas antes→después — sin HP/equipo/crónica/monedas/ranking inventados). Si pierde, se muestra un mensaje en la misma pantalla de la Arena, sin navegar (no hay pantalla de derrota todavía). `CombateEnCurso.aspx` **no se toca** — queda como mock para el punto 2 del roadmap.

# 3 cambios en `Webmaster/ResolverIntegridad.aspx` (2026-07-10)

Investigación, acuerdo de alcance, e implementación de los 3 puntos — **los 3 completados y verificados el mismo día**. Ver `EntornoLocal.md` para cómo levantar el sitio y reproducir cosas localmente.

## Estado: 1 y 2 implementados y probados en vivo (2026-07-10)

Implementado en una sola pasada (el mockup del usuario ya traía el rediseño visual Y la grilla más legible, así que 1+2 se hicieron juntos):

- `PylinskiCuello_ProyectoWeb/Webmaster/ResolverIntegridad.aspx` + `.aspx.cs` + `.aspx.designer.cs`: reescritos completos con el visual nuevo (paleta dark-fantasy del mockup), navbar **real** del sitio (no el navbar de mockup con links ficticios) con los links reales de `HomeWebmaster.aspx`, más un requisito nuevo del usuario: **mientras `EstadoSistema.Bloqueado` es true, todos los links del navbar salvo "Salir" se deshabilitan de verdad** (se renderizan como `<span>` sin `href`, no solo con CSS — método `NavLink()` en el code-behind), y se rehabilitan solos en el próximo postback una vez resuelto.
- Sección nueva "Estado de tablas verificadas": solo entidades reales de `_entidades` (hoy `Usuario`), con conteo real de filas y si tiene inconsistencias pendientes; agrega una fila aclarando que `Bitacora` está excluida temporalmente (con el motivo) — decisión tomada con el usuario para no inventar tablas que no participan del sistema DV.
- Grilla de inconsistencias: agregadas las columnas "Qué pasó" (Inserción/Eliminación/Modificación/columna-sin-fila, derivado de `ValorEsperado`/`ValorCalculado` sin cambiar esquema) y "Estado" (Pendiente/Resuelto). Botón "Detalle" carga un payload JSON (base64, sin roundtrip al servidor) con los valores actuales del registro y, si hay una inconsistencia DVV pendiente de la misma tabla, la señala como "campo probablemente afectado" — **probado en vivo con un tamper real**: se detectó correctamente el registro y `columnasSospechosas: ["Email"]` matcheó exactamente la columna alterada.
- Detección de **eliminación** (chequeo inverso, antes no existía): `DAL_DigitoVerificador.ObtenerIdsRegistroHuerfanos` + lógica nueva en `SERVICIOS_DigitoVerificador.VerificarIntegridadTablaInterno`.
- Restore embebido: se mantuvo tal cual pedido por el usuario (no se migró a un botón que navegue a `BackUpYRestore.aspx`), solo reestilado con la paleta nueva.
- Nuevos métodos en `DAL_DigitoVerificador`/`SERVICIOS_DigitoVerificador`: `ObtenerCantidadRegistros`, `ObtenerCantidadInconsistenciasPendientes(Tabla)`, `ObtenerCantidadInconsistenciasPendientesPorTipo(DVH/DVV)`, `ObtenerIdsRegistroHuerfanos`, `ObtenerValoresActuales`, `ObtenerEntidadesRegistradas`. Nuevo método en `BLL_Usuario.ObtenerPorId` (la capa Web no referencia `DAL` directamente, pasa por `BLL`/`SERVICIOS` — hubo que agregarlo para mostrar qué webmaster resolvió cada inconsistencia).
- **Bug de encoding encontrado y corregido**: el archivo `.aspx` con caracteres UTF-8 crudos (tildes, guiones largos) se renderizaba como mojibake (`Ã­`, `â€"`) tanto en markup estático como en expresiones `<%= %>` — el parser de ASP.NET no estaba leyendo el archivo como UTF-8. Fix: agregado `<globalization fileEncoding="utf-8" requestEncoding="utf-8" responseEncoding="utf-8" />` a `Web.config` (antes no existía ningún elemento `<globalization>`). Cambio a nivel de proyecto, no solo de esta página — el resto de las páginas no se ven afectadas porque ya evitaban caracteres UTF-8 crudos usando entidades HTML.
- **Verificado en vivo** (no solo compilado): build con MSBuild + IIS Express, login real vía POST simulado, tamper directo en SQL sobre un usuario de prueba (`Email` cambiado por fuera de la app) para forzar un bloqueo real, confirmado que la página se renderiza bloqueada (nav deshabilitado, banner rojo, grilla con "Pendiente"), confirmado que "Recalcular todos los DV" realmente desbloquea (banner vuelve a verde, nav se rehabilita, mensaje de éxito). Cuenta de prueba: `testverif` (Webmaster, `IDUsuario=10`) — **quedó sin borrar** porque su eliminación en cascada tocaba `Bitacora` (log de auditoría, no se quiso borrar); es inofensiva y está claramente identificada, se puede borrar a mano desde Gestión de Usuarios si se quiere.
- **No se probó en un browser real** (sin entorno gráfico disponible): la lógica de los modals (abrir/cerrar, decodificar el payload de Detalle) se verificó leyendo el HTML/JS generado y decodificando el base64 a mano, no ejecutando el JS de verdad. Si algo del lado cliente falla, revisar ahí primero.

## Punto 3 (bug de datetime) — sigue pendiente

## 1. Visual del formulario
El usuario ya tiene HTML+CSS propio para reemplazar el look actual de `ResolverIntegridad.aspx` (hoy con estilos inline). Al integrarlo, respetar los controles `runat="server"` que usa el code-behind (`ResolverIntegridad.aspx.cs`): resumen de bloqueo, botones "Recalcular DV" (`BtnRecalcular_Click`) y "Restaurar backup" (`BtnRestaurar_Click`), y el `rptInconsistencias` (Repeater) de la grilla.

## 2. Grilla de inconsistencias más legible
Hoy (`ResolverIntegridad.aspx` líneas ~265-297) muestra por fila: ID, Tabla, Registro, Atributo, Tipo (DVH/DVV), Valor esperado, Valor calculado, Fecha detección — crudo y técnico. Se acordó:

- **Columna "Qué pasó"**, derivada sin cambiar el esquema de `InconsistenciaIntegridad`:
  - `ValorEsperado` vacío + `ValorCalculado` con valor → **Inserción** (sin línea base)
  - `ValorEsperado` con valor + `ValorCalculado` vacío → **Eliminación** (caso nuevo — hoy no se detecta, ver abajo)
  - Ambos con valor y distintos → **Modificación**
  - Viene de un DVV (columna, no fila puntual) → categoría aparte, aclarando que no se pudo aislar el registro exacto
- **Columna "Estado"**: Pendiente/Resuelto (ya existe en `BE_InconsistenciaIntegridad.Estado`, hoy no se muestra en la grilla — esto además evita confundir incidentes viejos ya resueltos con problemas nuevos, que es parte de lo que generó la duda del punto 3).
- **Botón "Detalle"**: valores actuales del registro (todas las columnas verificables). Para Modificación, si hay una inconsistencia DVV de la misma tabla detectada en la misma pasada de verificación, resaltarla como "campo probablemente afectado" (aproximación — el sistema no guarda un hash por campo individual, así que no es 100% certero si cambiaron varias filas a la vez en la misma corrida). Para Eliminación, solo avisar que se eliminó (sin listar campos — no hay snapshot histórico, decisión explícita del usuario de no agregar esa complejidad ahora).
- **Backend nuevo necesario**: detección de eliminación por chequeo inverso en `VerificarIntegridadTablaInterno` (`SERVICIOS_DigitoVerificador.cs`) — por cada DVH guardado en `{Tabla}DV`, verificar que el `IDRegistro` siga existiendo en la tabla real; si no, es una eliminación. Hoy el código solo recorre las filas que existen en la tabla real y las compara contra su DV, nunca al revés.

## 3. Bug de integridad tras logins fallidos — RESUELTO (2026-07-10)

Causa raíz encontrada y confirmada — ver sección "Causa raíz encontrada y reproducida (2026-07-10)" más arriba, dentro de "Bug recurrente sin resolver: falso positivo de DVH en `Bitacora`". Los 3 puntos del fix acordado, todos implementados y verificados:

1. **`CalcularYGuardarDVH<T>` releé la fila desde la base antes de hashear** (no el objeto en memoria) — nuevo método `DAL_DigitoVerificador.ObtenerFilaPorId`. Aplica automáticamente a todos los callers (`SERVICIOS_Bitacora.RegistrarEvento`, `BLL_Usuario.RegistrarUsuario`, `BLL_Usuario.RecalcularDVDeUsuario`), sin tocar esos call sites.
2. **`Bitacora.FechaEvento` y `Usuario.FechaRegistro` migradas de `datetime` a `datetime2`** (`ALTER TABLE ... ALTER COLUMN`, sin índices/defaults que lo complicaran). Los `SqlParameter` correspondientes (`DAL_Bitacora.cs` `@FechaEvento`, `DAL_Usuario.cs` `@FechaRegistro`) también se cambiaron a `SqlDbType.DateTime2` explícito — con `AddWithValue` o `SqlDbType.DateTime` sobre un `DateTime` de .NET, el driver trunca el valor a la precisión de `datetime` **del lado del cliente**, antes de llegar a la base, sin importar el tipo real de la columna. `DAL_Usuario.Insertar` pasó de `AddWithValue` a `Parameters.Add(..., SqlDbType.DateTime2)` para este campo puntual.
3. **`typeof(BE_Bitacora)` reactivada en `_entidades`** (`SERVICIOS_DigitoVerificador.cs`).

**Gap encontrado y corregido de paso, relacionado con la detección de "Eliminación" del punto 2 de la sección anterior**: `RecalcularDVDeEntidad` (lo que corre "Recalcular todos los DV") nunca purgaba las entradas de DVH huérfanas (registros borrados), así que una "Eliminación" detectada nunca se podía resolver realmente — la próxima verificación la volvía a encontrar y la reportaba de nuevo, sin fin. Encontrado durante la prueba de estrés de abajo (una prueba con 5000 filas insertadas+borradas hizo aparecer "5000 inconsistencias" tras recalcular). Fix: nuevo `DAL_DigitoVerificador.EliminarDVHHuerfanos`, llamado desde `RecalcularDVDeEntidad` antes de recalcular el DVV.

**Verificación**: reproducido el bug original de forma aislada antes del fix (5000 inserts directos vía `DAL_Bitacora.Guardar` → 3 mismatches de acarreo de segundo). Con el fix aplicado, mismo escenario pero por el flujo real (`SERVICIOS_Bitacora.RegistrarEvento`, 5000 veces) → **0 inconsistencias**. Antes de reactivar `Bitacora` en `_entidades` se corrió `RecalcularTodosLosDV` para resincronizar las líneas base viejas (calculadas con el método buggy) — confirmado `VerificarIntegridadTabla<BE_Usuario>` y `<BE_Bitacora>` en 0 después. Probado también en vivo contra el sitio real corriendo en IIS Express (login normal, tabla "Estado de tablas verificadas" en `ResolverIntegridad.aspx` mostrando `Bitacora` como `OK` en vez de `EXCLUIDA`).

Ver `Reglas.md`, nueva sección "Regla de columnas `datetime`/valores que la BD puede normalizar al guardar" para la convención a futuro (no usar `datetime` para columnas verificables nuevas, y por qué `CalcularYGuardarDVH` ya no depende de acordarse de esto).

### Gap encontrado post-fix: reactivar `Bitacora` en `_entidades` no alcanzaba para protegerla en tiempo real (2026-07-10)

El usuario probó el fix borrando un registro real de `Bitacora` a mano — y no saltó nada, mientras que un tamper de `Usuario` sí se detectó normalmente. Causa: `_entidades` solo maneja `VerificarIntegridadTotal` (usado por `Application_Start`) y `RecalcularTodosLosDV` (acción manual del webmaster). El **login** (`LoginIniciarSesion.aspx.cs`) y el **timer periódico** (`Global.asax.cs`) llamaban a `VerificarTablaCritica<BE_Usuario>()`, hardcodeado a esa única entidad — nunca a `Bitacora`, sin importar que estuviera en `_entidades`. Como el app pool de IIS Express venía corriendo sin reiniciarse, nada volvió a chequear `Bitacora` desde que se reactivó, y el borrado quedó invisible.

**Decisión (pedida explícitamente por el usuario):** que `_entidades` sea la única fuente de verdad — agregar/sacar una entidad de esa lista alcanza para que participe (o deje de participar) de TODO: arranque, timer, y login, sin tocar ningún otro archivo. Se cambiaron las llamadas de `LoginIniciarSesion.aspx.cs` y `Global.asax.cs` (`VerificacionPeriodicaCallback`) de `VerificarTablaCritica<BE_Usuario>()` a `VerificarIntegridadTotal(null)` (la misma función que ya usa `Application_Start`, que sí itera `_entidades`). `VerificarTablaCritica<T>()` se deja en `SERVICIOS_DigitoVerificador.cs` como utilidad genérica reusable, pero ya no la llama nadie por defecto.

**Trade-off aceptado a propósito:** el timer y el login ahora recorren TODAS las entidades registradas en cada corrida (antes el timer/login solo tocaban la tabla chica `Usuario`). Hoy (`Usuario` + `Bitacora`) es insignificante, pero si `Bitacora` (log de auditoría, crece sin límite) se vuelve grande, o se agregan más entidades, cada tick del timer y cada login se pone más caro — reevaluar en ese momento (ver `Reglas.md`, paso 6 actualizado).

**Verificado en vivo**: borrado un registro real de `Bitacora` por SQL directo, reiniciado IIS Express (dispara `Application_Start` → `VerificarIntegridadTotal` → detecta el huérfano de inmediato), confirmado que un login siguiente redirige a `ResolverIntegridad.aspx` con la fila mostrando "Eliminación" / "Pendiente" en la grilla. Confirmado que "Recalcular todos los DV" sigue resolviendo todo correctamente (vía el botón real, no solo el harness). Cuenta de prueba (`testverif3`) borrada al final en el orden correcto de FKs (Personaje/PersonajeEstadistica → Bitacora → UsuarioDV → UsuarioRol → Usuario) — a diferencia de un intento anterior en esta misma sesión que la dejó rota a medias.

## Ajustes de UX y bugfix externo al DV (2026-07-10, misma sesión)

Tres pedidos más del usuario sobre `ResolverIntegridad.aspx` y el login, todos implementados y verificados en vivo:

**1. Consolidar filas DVH/DVV en la grilla de inconsistencias.** Antes, un solo cambio real (una modificación, inserción o eliminación) podía aparecer como varias filas sueltas: una por el DVH de la fila y una más por cada DVV de columna que ese mismo cambio dispara (insertar/eliminar una fila invalida el agregado de TODAS las columnas verificables de la tabla, no solo una). Ahora `ResolverIntegridad.aspx.cs` tiene un paso de consolidación (`ConsolidarFilas`): agrupa cada fila DVH con las DVV de la misma tabla+estado, arma UNA fila de grilla por incidente, y solo deja una DVV como fila propia si de verdad no correlaciona con ninguna DVH de la tanda (caso raro, no debería pasar en el uso normal). La grilla ahora muestra una columna **"Columna(s) cambiada(s)"** (reemplaza a las viejas "Atributo" + "Tipo DV"): para Modificación lista la(s) columna(s) correlacionada(s); para Inserción/Eliminación queda en "—" a propósito (no tiene sentido señalar "la columna cambiada" cuando cambiaron todas juntas por alta/baja de la fila entera). El modal Detalle se actualizó al mismo esquema de payload (`columnasCambiadas` en vez de `columnasSospechosas`, sin los campos sueltos `atributo`/`tipoDigito`/`valorEsperado`/`valorCalculado` a nivel de grilla — esos hashes técnicos quedan solo dentro del Detalle, como `valorEsperadoDVH`/`valorCalculadoDVH`).

**2. Restore más visible.** El botón para restaurar backup vivía en una sección aparte, debajo de toda la grilla de inconsistencias — había que scrollear para encontrarlo. Se movió arriba, en `.global-actions`, al lado de "Recalcular DV (general)". Además se consolidó el flujo en un solo modal: antes había una sección inline (file upload + motivo) que abría un modal de confirmación aparte; ahora el file upload y el motivo viven DENTRO del modal (`modalRestoreOverlayRI`), y toda la validación (archivo elegido, motivo no vacío, texto "RESTAURAR" tipeado) se hace junta al confirmar (`prepararRestoreRI`), no en dos pasos. Mismo code-behind sin cambios (`BtnRestaurar_Click`, `fileUploadBAK`, `txtMotivoRestore`, `btnRestaurar` son los mismos controles, solo se reubicó el markup).

**3. Bug externo al DV: los intentos fallidos nunca se reseteaban en un login exitoso.** `BLL_Usuario.Login()` sumaba `IntentosFallidos` en cada clave incorrecta (`DAL_Usuario.SumarIntentoFallido`), pero el branch de login exitoso nunca llamaba a `DAL_Usuario.ResetearIntentosFallidos` — ya existía y se usaba en otros lados (`BLL_Usuario.ResetearIntentos`, `CambiarBloqueo`), pero no en el propio `Login()`. Efecto real: un usuario que se equivocaba de clave un par de veces y después entraba bien quedaba con el contador alto igual, acumulando entre sesiones sin relación entre sí, cada vez más cerca del bloqueo por intentos (`>=3`) aunque nunca hubiera 3 fallos seguidos. Fix: si el login es exitoso y `IntentosFallidos > 0`, se resetea a 0 (`dal.ResetearIntentosFallidos` + reflejarlo en el objeto en memoria). No requiere recalcular DV (`IntentosFallidos` está `[ExcluirDeDV]`).

**Verificado en vivo los tres**: tamper de `Email` en un usuario de prueba con `IntentosFallidos=2` seteado a mano → un login exitoso mostró en la grilla UNA sola fila "Modificación" con "Columna(s) cambiada(s)" = "Email" (no una fila aparte por el DVV), y confirmado por SQL que `IntentosFallidos` volvió a 0 tras ese mismo login. Botón de Restore confirmado arriba, junto a Recalcular, con el modal mostrando los campos de archivo/motivo adentro.

## Verificación end-to-end del Restore real + bug encontrado y corregido (2026-07-10)

El usuario pidió probar el bot&oacute;n de Restore de verdad: backup → cambiar algo → restaurar con ese backup → confirmar que revierte. Se hizo un `BACKUP DATABASE Squama` real (T-SQL directo, ~7.3MB), se tamperó `Usuario.Email` de `naty` por SQL directo, se logueó (dispara el bloqueo), y se envió el restore **por HTTP real** (`HttpClient` + `MultipartFormDataContent` simulando exactamente el POST que mandaría un browser real: `__VIEWSTATE`/`__EVENTVALIDATION`, `txtMotivoRestore`, el archivo `.bak` como `fileUploadBAK`, y `btnRestaurar` como submit) — no se usó el harness de consola para este paso, porque lo que había que probar era el flujo real de UI.

**Resultado del primer intento: la restauración de la base funcionó perfectamente** (confirmado por SQL: el `Email` de `naty` volvió al valor original, y la cuenta de prueba creada después del backup desapareció — prueba contundente de que `RESTORE DATABASE` revirtió todo de verdad), **pero el sistema quedó mostrando "ALERTA" en vez de desbloquearse**, con un error genérico en pantalla ("Error al ejecutar el restore: ... FOREIGN KEY constraint 'FK_Restore_IDUsuarioWebmaster' ...").

**Causa encontrada**: `BLL_RESTORE.EjecutarRestore` ejecuta `RESTORE DATABASE` (paso crítico, ya consumado) y ACTO SEGUIDO inserta una fila de auditoría en la tabla `[Restore]` con `IDUsuarioWebmaster = usuario.IDUsuario` (el webmaster que hizo click). Si ese webmaster fue dado de alta **después** de la fecha del backup que se está restaurando, ya no existe en la BD recién restaurada, y ese INSERT falla por FK — lo mismo le puede pasar al evento de auditoría en `SERVICIOS_Bitacora.RegistrarEvento` dentro de `MarcarSistemaDesbloqueadoPorRestore`. Como ninguna de las dos llamadas tenía manejo de errores propio, la excepción se propagaba hasta el `catch` genérico de `ResolverIntegridad.aspx.cs`, que: (a) muestra un mensaje que hace parecer que el restore en sí falló, cuando en realidad la BD ya estaba arreglada, y (b) — más grave — corta la ejecución ANTES de llegar a `EstadoSistema.Desbloquear()`, dejando el sistema bloqueado indefinidamente a pesar de que el problema de fondo ya no existe.

**Fix**: se envolvió el INSERT de auditoría en `BLL_RESTORE.EjecutarRestore` (`_dal.RegistrarRestore`) y el `SERVICIOS_Bitacora.RegistrarEvento` dentro de `SERVICIOS_DigitoVerificador.MarcarSistemaDesbloqueadoPorRestore` en sus propios `try/catch` — ambos son trazabilidad best-effort, no deben poder impedir que un restore ya ejecutado termine de desbloquear el sistema. `EstadoSistema.Desbloquear()` sigue siendo la primera línea de `MarcarSistemaDesbloqueadoPorRestore`, así que con el fix el desbloqueo ocurre siempre que la `RESTORE DATABASE` haya corrido, sin importar si el webmaster actuante existe en el backup restaurado.

**Verificado de nuevo con el fix**: mismo escenario completo (tamper → login → bloqueo → restore por HTTP real con un webmaster nuevo, creado después del backup) → esta vez `pMensaje` mostró "Restore completado correctamente. BD restaurada desde: squama_test.bak. El sistema fue desbloqueado.", `lblEstadoGeneral` = "ÍNTEGRO", `Email` de `naty` de nuevo en su valor original, 0 inconsistencias pendientes.

**Hallazgo menor, no corregido (fuera de alcance, dormido)**: `DAL_RESTORE.ObtenerTodos()` hace `INNER JOIN Usuarios u ON u.IDUsuario = ...` — la tabla real se llama `Usuario` (singular), `Usuarios` no existe. Este método tiraría error si alguna vez se llama, pero hoy no está cableado a ninguna UI (`CargarBackups()` en `ResolverIntegridad.aspx.cs` está comentado). Revisar si se corrige el día que se conecte esa funcionalidad.

**Archivos:** `BE_Combate`, `BE_ResultadoCombateVista` (nuevos, `BE/`); `DAL_Combate` (nuevo) + `DAL_Personaje.ActualizarStatsArena` (nuevo método); `BLL_Combate.PelearContraRival`/`ObtenerCombateParaMostrar` (nuevo); `ArenaApi.ashx.cs` (acción `Pelear` + helper `LeerArgs`); `SeleccionarRival.aspx` (click de pelear); `ArenaVictoria.aspx`/`.aspx.cs` (recortada y wireada). Seed necesario: `INSERT INTO ResultadoCombate (Nombre, Descripcion, Estado) VALUES ('Victoria', ..., 1), ('Derrota', ..., 1)`.