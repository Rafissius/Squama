using BE;
using System;
using System.Web;

namespace SERVICIOS
{
    public class SesionUnicaModule : IHttpModule
    {
        public void Init(HttpApplication context)
        {
            context.PreRequestHandlerExecute += ValidarSesion;
        }

        private void ValidarSesion(object sender, EventArgs e)
        {
            HttpApplication app = (HttpApplication)sender;
            HttpContext ctx = app.Context;

            string pagina = ctx.Request.Url.AbsolutePath.ToLower();

            // Ignorar archivos estáticos y handlers (por extensión real)
            string[] extensionesIgnoradas = { ".css", ".js", ".axd", ".png", ".jpg", ".jpeg", ".gif", ".svg", ".ico", ".woff", ".woff2", ".ttf", ".map", "registrarusuario" };
            foreach (string ext in extensionesIgnoradas)
            {
                if (pagina.EndsWith(ext))
                    return;
            }

            // Páginas públicas: no requieren sesión, no se validan
            // (con Friendly URLs, contemplamos con y sin extensión .aspx)
            if (pagina.EndsWith("logininiciarsesion") || pagina.EndsWith("logininiciarsesion.aspx")
                || pagina.EndsWith("login") || pagina.EndsWith("login.aspx")
                || pagina.EndsWith("squama-landing") || pagina.EndsWith("squama-landing.html")
                || pagina == "/")
                return;

            if (ctx.Session == null) return;

            BE_Usuario usuario = ctx.Session["Usuario"] as BE_Usuario;

            if (usuario == null)
            {
                ctx.Response.Redirect("~/LoginIniciarSesion.aspx");
                return;
            }

            bool valida = SesionActivaSingleton.Instancia.EsSesionValida(usuario.IDUsuario, ctx.Session.SessionID);

            if (!valida)
            {
                ctx.Session.Abandon();
                ctx.Response.Redirect("~/LoginIniciarSesion.aspx");
            }
        }

        public void Dispose() { }
    }
}