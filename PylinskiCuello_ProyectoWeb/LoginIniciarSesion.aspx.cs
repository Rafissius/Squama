using BE;
using BLL;
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
                pMensaje.InnerText = "Por favor completá todos los campos.";
                return;
            }

            BLL_Usuario bll = new BLL_Usuario();
            BE_Usuario usuario = bll.Login(credencial, clave);

            // Caso 1: usuario no existe
            if (usuario == null)
            {
                SERVICIOS.SERVICIOS_Bitacora.RegistrarEvento(null, 2, Request.UserHostAddress);

                pMensaje.InnerText = "La clave o el email no coinciden.";
                return;
            }

            // Caso 2: bloqueado
            if (usuario.IntentosFallidos >= 3)
            {
                //LUEGO VER DE AGREGAR OTRO EVENTO 
                SERVICIOS.SERVICIOS_Bitacora.RegistrarEvento(usuario.IDUsuario, 2, Request.UserHostAddress);

                pMensaje.InnerText = "Usuario bloqueado por superar intentos fallidos.";
                return;
            }

            // Caso 3: clave incorrecta (IDRol == 0 y PasswordHash == null)
            if (usuario.IDRol == 0)
            {
                SERVICIOS.SERVICIOS_Bitacora.RegistrarEvento(usuario.IDUsuario, 2, Request.UserHostAddress);

                pMensaje.InnerText = "La clave o el email no coinciden.";
                return;
            }

             SERVICIOS.SERVICIOS_Bitacora.RegistrarEvento(usuario.IDUsuario ,1, Request.UserHostAddress);

            Session["Usuario"] = usuario;
            // NUEVO: registra esta sesión como la única válida para este usuario
            SERVICIOS.SesionActivaSingleton.Instancia.RegistrarSesion(usuario.IDUsuario, Session.SessionID);
            

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
                    pMensaje.InnerText = "Rol no reconocido. Contactá al administrador.";
                    break;
            }


        }


        protected void btnRegistrar_Click(object sender, EventArgs e)
        {
            Response.Redirect("RegistrarUsuario.aspx");
        
        }



    }
}