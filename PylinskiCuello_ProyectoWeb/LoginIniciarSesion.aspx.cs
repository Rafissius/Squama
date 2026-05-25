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
                pMensaje.InnerText = "La clave o el email no coinciden.";
                return;
            }

            // Caso 2: bloqueado
            if (usuario.IntentosFallidos >= 3)
            {
                pMensaje.InnerText = "Usuario bloqueado por superar intentos fallidos.";
                return;
            }

            // Caso 3: clave incorrecta (IDRol == 0 y PasswordHash == null)
            if (usuario.IDRol == 0)
            {
                pMensaje.InnerText = "La clave o el email no coinciden.";
                return;
            }

            // Caso 4: login exitoso → redirigir según rol
            switch (usuario.IDRol)
            {
                case 1:
                    Response.Redirect("HomeAdministrador.aspx");
                    break;
                case 2:
                    Response.Redirect("HomeWebMaster.aspx");
                    break;
                case 3:
                    Response.Redirect("HomeJugador.aspx");
                    break;
                default:
                    pMensaje.InnerText = "Rol no reconocido. Contactá al administrador.";
                    break;
            }
        }
    }
}