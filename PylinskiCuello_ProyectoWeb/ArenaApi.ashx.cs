using System;
using System.Collections.Generic;
using System.IO;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.SessionState;
using BE;
using BLL;

namespace PylinskiCuello_ProyectoWeb
{
    // Mismo patrón que GestionUsuariosApi.ashx: un .ashx no choca con Friendly Urls
    // (a diferencia de un PageMethod vía /Pagina.aspx/NombreMetodo).
    public class ArenaApi : IHttpHandler, IRequiresSessionState
    {
        public bool IsReusable { get { return false; } }

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";

            BE_Usuario usuario = context.Session["Usuario"] as BE_Usuario;
            if (usuario == null)
            {
                context.Response.StatusCode = 401;
                EscribirJson(context, new { error = "No autorizado." });
                return;
            }

            string accion = context.Request.QueryString["accion"];

            try
            {
                switch (accion)
                {
                    case "ListarRivales":
                        BLL_Personaje bll = new BLL_Personaje();
                        EscribirJson(context, bll.ObtenerRivales(usuario.IDUsuario, usuario.NombreUsuario));
                        break;

                    case "Pelear":
                        Dictionary<string, object> args = LeerArgs(context);
                        int idPersonajeDefensor = Convert.ToInt32(args["idPersonajeDefensor"]);
                        BLL_Combate bllCombate = new BLL_Combate();
                        EscribirJson(context, bllCombate.PelearContraRival(usuario.IDUsuario, idPersonajeDefensor));
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
