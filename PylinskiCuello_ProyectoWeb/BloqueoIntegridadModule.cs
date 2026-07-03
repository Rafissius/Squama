using BE;
using SERVICIOS;
using System;
using System.Web;

namespace PylinskiCuello_ProyectoWeb
{
    public class BloqueoIntegridadModule : IHttpModule
    {
        public void Init(HttpApplication context)
        {
            // PostAcquireRequestState, NO BeginRequest: en BeginRequest el SessionStateModule
            // todavía no cargó la sesión y ctx.Session siempre es null.
            context.PostAcquireRequestState += OnPostAcquireRequestState;
        }

        private void OnPostAcquireRequestState(object sender, EventArgs e)
        {
            HttpApplication app = (HttpApplication)sender;
            HttpContext ctx = app.Context;

            if (!EstadoSistema.Bloqueado) return;

            string path = ctx.Request.AppRelativeCurrentExecutionFilePath.ToLowerInvariant();
            if (EsPathPermitido(path)) return;

            // Guarda defensiva: si no hay sesión disponible, ir a la pantalla segura sin acciones.
            if (ctx.Session == null)
            {
                ctx.Response.Redirect("~/SistemaBloqueado.aspx");
                ctx.ApplicationInstance.CompleteRequest();
                return;
            }

            BE_Usuario usuario = ctx.Session["Usuario"] as BE_Usuario;

            if (usuario != null && SERVICIOS_DigitoVerificador.EsWebmaster(usuario))
            {
                // Es webmaster: conserva la sesión, la necesita para operar en el panel.
                ctx.Response.Redirect("~/Webmaster/ResolverIntegridad.aspx");
            }
            else
            {
                // No es webmaster (o no se pudo identificar): matar la sesión activa.
                // Abandon() (no Clear()) para que quede realmente sin sesión, no solo
                // vacía con el mismo SessionID. Se llama DESPUÉS de leer/evaluar el rol,
                // nunca antes (si no, se pierde la posibilidad de reconocer al webmaster).
                ctx.Session.Abandon();
                ctx.Response.Redirect("~/SistemaBloqueado.aspx");
            }

            ctx.ApplicationInstance.CompleteRequest();
        }

        private static bool EsPathPermitido(string path)
        {
            // Sin ".aspx": FriendlyUrls (RouteConfig.cs, AutoRedirectMode=Permanent) redirige
            // 301 cualquier URL con extensión ".aspx" a su forma amigable sin extensión. Si acá
            // se comparara incluyendo ".aspx", una request ya reescrita a la forma amigable no
            // matchea, el módulo vuelve a redirigir a la forma "~/Pagina.aspx", FriendlyUrls la
            // vuelve a convertir en la forma sin extensión, y así en bucle infinito
            // (ERR_TOO_MANY_REDIRECTS). Comparar sin extensión matchea ambas formas.
            string[] paginasPermitidas =
            {
                "/logininiciarsesion",
                "/sistemabloqueado",
                "/webmaster/resolverintegridad"
            };

            foreach (string pagina in paginasPermitidas)
                if (path.Contains(pagina)) return true;

            string[] extensionesEstaticas =
                { ".css", ".js", ".png", ".jpg", ".jpeg", ".gif", ".ico", ".woff", ".woff2" };

            foreach (string ext in extensionesEstaticas)
                if (path.EndsWith(ext)) return true;

            return false;
        }

        public void Dispose() { }
    }
}
