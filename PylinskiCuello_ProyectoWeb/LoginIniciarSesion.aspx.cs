using BE;
using BLL;
using SERVICIOS;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PylinskiCuello_ProyectoWeb
{
    public partial class LoginIniciarSesion : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
       
        protected void btnIngresar_Click(object sender, EventArgs e)
        {
            string credencial = username.Value.Trim();
            string clave = password.Value;

            if (string.IsNullOrEmpty(credencial) || string.IsNullOrEmpty(clave))
            {
                MostrarError("Por favor completá todos los campos.");
                return;
            }

            BLL_Usuario bll = new BLL_Usuario();
            BE_Usuario usuario = bll.Login(credencial, clave);

            // Caso 1: usuario no existe
            if (usuario == null)
            {
                SERVICIOS.SERVICIOS_Bitacora.RegistrarEvento(null, 2, Request.UserHostAddress);

                MostrarError("La clave o el email no coinciden.");
                return;
            }

            // Caso 2: bloqueado manualmente por el webmaster (Usuario.Bloqueado=1)
            if (usuario.Bloqueado)
            {
                SERVICIOS.SERVICIOS_Bitacora.RegistrarEvento(usuario.IDUsuario, 2, Request.UserHostAddress);

                MostrarError("Usuario bloqueado. Contactá al administrador.");
                return;
            }

            // Caso 3: desactivado (Usuario.Estado=0)
            if (usuario.Estado == 0)
            {
                SERVICIOS.SERVICIOS_Bitacora.RegistrarEvento(usuario.IDUsuario, 2, Request.UserHostAddress);

                MostrarError("Usuario desactivado. Contactá al administrador.");
                return;
            }

            // Caso 4: bloqueado por superar intentos fallidos
            if (usuario.IntentosFallidos >= 3)
            {
                //LUEGO VER DE AGREGAR OTRO EVENTO
                SERVICIOS.SERVICIOS_Bitacora.RegistrarEvento(usuario.IDUsuario, 2, Request.UserHostAddress);

                MostrarError("Usuario bloqueado por superar intentos fallidos.");
                return;
            }

            // Caso 5: clave incorrecta (IDRol == 0 y PasswordHash == null)
            if (usuario.IDRol == 0)
            {
                SERVICIOS.SERVICIOS_Bitacora.RegistrarEvento(usuario.IDUsuario, 2, Request.UserHostAddress);

                MostrarError("La clave o el email no coinciden.");
                return;
            }

             SERVICIOS.SERVICIOS_Bitacora.RegistrarEvento(usuario.IDUsuario ,1, Request.UserHostAddress);

            Session["Usuario"] = usuario;
            // NUEVO: registra esta sesión como la única válida para este usuario
            SERVICIOS.SesionActivaSingleton.Instancia.RegistrarSesion(usuario.IDUsuario, Session.SessionID);

            // Verificación de integridad en cada login (además de Application_Start y el timer
            // periódico), de TODAS las entidades en _entidades — no solo BE_Usuario, así que
            // agregar/sacar una entidad de esa lista alcanza para que empiece/deje de
            // participar también acá. Si encuentra inconsistencias, setea EstadoSistema.Bloqueado
            // acá adentro; el redirect de abajo sigue igual y BloqueoIntegridadModule
            // intercepta la request siguiente y reparte a SistemaBloqueado/ResolverIntegridad
            // según el rol. No hace falta lógica de redirect nueva acá.
            SERVICIOS_DigitoVerificador.VerificarIntegridadTotal(null);

            string nombreRol = bll.ObtenerNombreRol(usuario.IDUsuario);

            switch (nombreRol)
            {
                case "Webmaster":
                    Response.Redirect("HomeWebMaster.aspx");
                    break;
                case "Administrador":
                    Response.Redirect("HomeAdministrador.aspx");
                    break;
                case "Jugador":
                    Response.Redirect("HomeJugador.aspx");
                    break;
                default:
                    MostrarError("Rol no reconocido. Contactá al administrador.");
                    break;
            }


        }

        // Todos los mensajes que pasan por acá son de error (no hay caso de éxito:
        // un login OK redirige antes de llegar a mostrar nada) — se pinta en rojo
        // con la clase msg-error, ya preparada en Styles/login-form.css.
        private void MostrarError(string mensaje)
        {
            pMensaje.InnerText = mensaje;
            pMensaje.Attributes["class"] = "card-desc msg-error";
        }

        protected void btnRegistrar_Click(object sender, EventArgs e)
        {
            Response.Redirect("RegistrarUsuario.aspx");

        }



    }
}