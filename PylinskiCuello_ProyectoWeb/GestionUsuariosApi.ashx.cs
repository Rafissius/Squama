using System;
using System.Collections.Generic;
using System.IO;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.SessionState;
using BE;
using BLL;
using SERVICIOS;

namespace PylinskiCuello_ProyectoWeb
{
    // Handler .ashx en vez de PageMethods (ScriptManager EnablePageMethods): una llamada a
    // PageMethod usa la URL /Pagina.aspx/NombreMetodo, y Friendly Urls (RouteConfig.cs)
    // intercepta ese patrón y la rompe (devuelve 401 "Error de autenticación." genérico
    // antes de que el método llegue a ejecutar). Un .ashx es una URL plana sin ese sufijo,
    // así que no choca con Friendly Urls — y no hace falta tocar el ruteo del sitio.
    public class GestionUsuariosApi : IHttpHandler, IRequiresSessionState
    {
        public bool IsReusable { get { return false; } }

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";

            BE_Usuario usuario = context.Session["Usuario"] as BE_Usuario;
            if (usuario == null || !SERVICIOS_DigitoVerificador.EsWebmaster(usuario))
            {
                context.Response.StatusCode = 401;
                EscribirJson(context, new { error = "No autorizado." });
                return;
            }

            string accion = context.Request.QueryString["accion"];
            Dictionary<string, object> args = LeerArgs(context);
            BLL_Usuario bll = new BLL_Usuario();

            try
            {
                switch (accion)
                {
                    case "ListarUsuarios":
                        EscribirJson(context, bll.ObtenerUsuarios());
                        break;

                    case "ObtenerRoles":
                        EscribirJson(context, bll.ObtenerRoles());
                        break;

                    case "CrearUsuario":
                        BE_Usuario nuevo = new BE_Usuario
                        {
                            NombreUsuario = (string)args["nombreUsuario"],
                            Email = (string)args["email"],
                            PasswordHash = (string)args["password"]
                        };
                        bll.RegistrarUsuario(nuevo, Convert.ToInt32(args["idRol"]), Convert.ToBoolean(args["activo"]) ? 1 : 0);
                        EscribirJson(context, new { ok = true });
                        break;

                    case "EditarUsuario":
                        bll.EditarUsuario(Convert.ToInt32(args["idUsuario"]), (string)args["nombreUsuario"], (string)args["email"]);
                        EscribirJson(context, new { ok = true });
                        break;

                    case "CambiarEstado":
                        bll.CambiarEstado(Convert.ToInt32(args["idUsuario"]), Convert.ToBoolean(args["activo"]));
                        EscribirJson(context, new { ok = true });
                        break;

                    case "CambiarBloqueo":
                        bll.CambiarBloqueo(Convert.ToInt32(args["idUsuario"]), Convert.ToBoolean(args["bloqueado"]));
                        EscribirJson(context, new { ok = true });
                        break;

                    case "ResetearIntentos":
                        bll.ResetearIntentos(Convert.ToInt32(args["idUsuario"]));
                        EscribirJson(context, new { ok = true });
                        break;

                    case "CambiarRol":
                        bll.CambiarRol(Convert.ToInt32(args["idUsuario"]), Convert.ToInt32(args["idRol"]));
                        EscribirJson(context, new { ok = true });
                        break;

                    default:
                        context.Response.StatusCode = 400;
                        EscribirJson(context, new { error = "Acción desconocida: " + accion });
                        break;
                }
            }
            catch (Exception ex)
            {
                context.Response.StatusCode = 400;
                EscribirJson(context, new { error = ex.Message });
            }
        }

        private static Dictionary<string, object> LeerArgs(HttpContext context)
        {
            string body;
            using (var reader = new StreamReader(context.Request.InputStream))
                body = reader.ReadToEnd();

            if (string.IsNullOrWhiteSpace(body))
                return new Dictionary<string, object>();

            return new JavaScriptSerializer().Deserialize<Dictionary<string, object>>(body);
        }

        private static void EscribirJson(HttpContext context, object data)
        {
            context.Response.Write(new JavaScriptSerializer().Serialize(data));
        }

        public void Dispose() { }
    }
}
