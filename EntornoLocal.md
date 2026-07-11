# Entorno local — cómo levantar el sitio y reproducir cosas (2026-07-10)

Esta máquina no tiene la instancia de SQL Server `MSI\SQLEXPRESS01` que asume `Web.config` (nombre de la máquina original del proyecto). Acá hay una instancia default (`.`/`MSSQLSERVER`) con la base `Squama` ya restaurada. La connection string en `PylinskiCuello_ProyectoWeb\Web.config` se corrigió a mano para apuntar a esa instancia:

```xml
<connectionStrings>
  <add name="ConexionPrincipal"
       connectionString="Data Source=.;Initial Catalog=Squama;Integrated Security=True;"
       providerName="System.Data.SqlClient" />
</connectionStrings>
```

Si en otra máquina/sesión esto vuelve a fallar (`Cannot open database "Squama"` o `No se encontró el servidor o instancia especificado`), primero confirmar qué instancias de SQL hay corriendo (`Get-Service -Name "MSSQL*"`) y en cuál vive la base (`SELECT name FROM sys.databases WHERE name='Squama'` contra cada instancia candidata), y ajustar `Data Source` en consecuencia. No asumir que `MSI\SQLEXPRESS01` existe.

## Compilar

No hay `msbuild`/`iisexpress` en el PATH de la shell (bash). Rutas absolutas encontradas en esta máquina (Visual Studio 2022 Community):

```powershell
& "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" `
  "C:\Users\rafis\Desktop\SquamaJuego\Squama-master\PylinskiCuello_ProyectoWeb.slnx" `
  /p:Configuration=Debug /t:Build /m /v:minimal /nologo
```

**Importante:** usar PowerShell para esto, no la Bash tool (Git Bash) — Git Bash reinterpreta `/p:`, `/t:`, `/m`, `/v:` como paths estilo Unix y rompe la línea de comandos de MSBuild (`MSB1008: Sólo puede especificarse un proyecto`).

## Levantar IIS Express

El proyecto ya tiene un `applicationhost.config` generado por Visual Studio (se genera al abrir la solución, no está en el repo por sí mismo mientras no exista `.vs/`):

```
C:\Users\rafis\Desktop\SquamaJuego\Squama-master\.vs\PylinskiCuello_ProyectoWeb.slnx\config\applicationhost.config
```

Ahí el sitio real se llama `PylinskiCuello_ProyectoWeb` (el `WebSite1` que también aparece es un sitio vacío de plantilla, ignorar), sirviendo en:
- `http://localhost:57404` (HTTP)
- `https://localhost:44370` (HTTPS)

Para levantarlo:

```powershell
Start-Process -FilePath "C:\Program Files\IIS Express\iisexpress.exe" `
  -ArgumentList '/site:PylinskiCuello_ProyectoWeb','/config:"C:\Users\rafis\Desktop\SquamaJuego\Squama-master\.vs\PylinskiCuello_ProyectoWeb.slnx\config\applicationhost.config"' `
  -PassThru
```

Verificar que respondió: `Invoke-WebRequest -Uri "http://localhost:57404/Login.aspx" -UseBasicParsing` (200 esperado).

Si no existe todavía la carpeta `.vs\...\config\applicationhost.config` (primera vez en una máquina nueva), hay que abrir la solución una vez en Visual Studio para que se genere, o crear uno manualmente — no se documentó ese caso porque no hizo falta acá.

## OJO: Friendly URLs — un POST a `NombrePagina.aspx` no funciona igual que a `NombrePagina`

El proyecto usa ASP.NET Friendly URLs (`RouteConfig.cs`, `AutoRedirectMode=Permanent`): cualquier request a una URL con extensión `.aspx` se redirige 301 a la forma sin extensión. Un cliente HTTP que siga redirecciones automáticamente (como `Invoke-WebRequest`, y como la mayoría de los HTTP clients) **convierte el POST en GET al seguir un 301** — con lo cual un POST de postback a `LoginIniciarSesion.aspx` termina siendo, en la práctica, un GET fresco a `LoginIniciarSesion`, y el evento de servidor (`btnIngresar_Click`) nunca se dispara. No tira error, no hay excepción visible: la página simplemente responde con el contenido default, como si nunca hubieras mandado nada.

**Fix:** apuntar directamente a la URL amigable sin extensión desde el principio (`http://localhost:57404/LoginIniciarSesion`, no `.../LoginIniciarSesion.aspx`), tanto para el GET inicial (que trae `__VIEWSTATE`/`__EVENTVALIDATION`) como para el POST del postback.

## Simular un postback de Web Forms por HTTP (sin browser)

Los controles de esta página (`username`, `password`, botón con `onserverclick`) no llevan naming container (no hay master page), así que los nombres de campo son literales y el botón dispara `__doPostBack('ctl00','')` (Ingresar) / `'ctl01'` (Registrar). Patrón en PowerShell:

```powershell
$Server = "http://localhost:57404/LoginIniciarSesion"   # SIN .aspx, ver arriba
$session = $null

function Get-Tokens($html) {
  [PSCustomObject]@{
    vs  = [regex]::Match($html, 'id="__VIEWSTATE" value="([^"]*)"').Groups[1].Value
    vsg = [regex]::Match($html, 'id="__VIEWSTATEGENERATOR" value="([^"]*)"').Groups[1].Value
    ev  = [regex]::Match($html, 'id="__EVENTVALIDATION" value="([^"]*)"').Groups[1].Value
  }
}

$r = Invoke-WebRequest -Uri $Server -SessionVariable session -UseBasicParsing
$t = Get-Tokens $r.Content

$body = @{
  __EVENTTARGET = "ctl00"; __EVENTARGUMENT = ""
  __VIEWSTATE = $t.vs; __VIEWSTATEGENERATOR = $t.vsg; __EVENTVALIDATION = $t.ev
  username = "juan"; password = "malaClave1"
}
$resp = Invoke-WebRequest -Uri $Server -WebSession $session -Method Post -Body $body -UseBasicParsing
```

Cada nuevo POST necesita tokens frescos (`__VIEWSTATE`/`__EVENTVALIDATION` de la *respuesta anterior*, no de la primera carga), reutilizando la misma `$session` (`-WebSession $session`) para mantener cookies.

`Invoke-WebRequest -UseBasicParsing`'s `.Forms` no funciona en PowerShell 5.1 sin el motor de IE instalado (tira `No se puede indizar en una matriz nula`) — hay que parsear los campos ocultos a mano con regex como arriba, no confiar en `.Forms[0].Fields`.

## Consultar la base directamente

`Invoke-Sqlcmd` (módulo `SqlServer`, ya disponible) apuntando a la instancia correcta:

```powershell
Invoke-Sqlcmd -ServerInstance "." -Database "Squama" -Query "SELECT TOP 5 * FROM Usuario"
```

## Probar el módulo de Dígito Verificador de forma aislada (sin pasar por el sitio web)

Para reproducir el bug de redondeo de `datetime` (ver `Contexto.md`, sección "Causa raíz encontrada y reproducida") se armó un proyecto de consola descartable **fuera del repo** (en el scratchpad de la sesión, no versionado) que referencia directamente los `.dll` ya compilados:

- `TestDV.csproj` (SDK-style, `net472`) con `<Reference>` por `HintPath` a `BE\bin\Debug\BE.dll`, `DAL\bin\Debug\DAL.dll`, `SERVICIOS\bin\Debug\SERVICIOS.dll` (compilados por el `MSBuild` de arriba) + referencia a `System.Configuration`.
- `App.config` propio con la misma `connectionString` que `Web.config` (un proyecto de consola no hereda el `Web.config` del sitio).
- **Nota de C#:** con `TargetFramework=net472`, el SDK moderno de `dotnet` sigue usando `LangVersion` 7.3 por default — instrucciones de nivel superior (top-level statements) no compilan (`CS8370`), hace falta un `Main` explícito.
- Corrido con `dotnet run` (el SDK de .NET moderno puede compilar y ejecutar contra `net472` sin problema, siempre que los `.dll` referenciados sean compatibles con Framework, que es el caso).

Esto permitió insertar miles de filas en `Bitacora` directamente vía `DAL_Bitacora.Guardar` (mucho más rápido que por HTTP) y comparar el `DateTime` en memoria contra el releído de la base para aislar el bug, sin depender de golpear la ventana de 0.06% de probabilidad a través de logins reales uno por uno. Las filas de prueba se insertaron con `Descripcion = 'TEST_STRESS_DV'` para poder identificarlas y borrarlas al final (`DELETE FROM Bitacora WHERE Descripcion = 'TEST_STRESS_DV'`) — cualquier prueba similar en el futuro debería seguir el mismo patrón (marcar los datos de prueba de forma reconocible y limpiarlos después).

## Estado del sitio al cierre de esta sesión

`iisexpress.exe` puede haber quedado corriendo en background (proceso lanzado con `Start-Process -PassThru`, no se garantiza que siga vivo en la próxima sesión). Si hace falta, matarlo con `Stop-Process` por el `Id` devuelto, o simplemente lanzar uno nuevo (dos instancias en el mismo puerto van a chocar — revisar con `Get-Process iisexpress` antes de levantar otro).
