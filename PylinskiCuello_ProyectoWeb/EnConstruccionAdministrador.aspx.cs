using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PylinskiCuello_ProyectoWeb
{
    public partial class EnConstruccionAdministrador : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void BtnLogout_Click(object sender, EventArgs e)
        {

            // Session.Clear();
            //Response.Redirect("LoginIniciarSesion.aspx");

            BE.BE_Usuario usuario = Session["Usuario"] as BE.BE_Usuario;

            if (usuario != null)
            {
                // Libera el "candado" del singleton para ese usuario
                SERVICIOS.SesionActivaSingleton.Instancia.CerrarSesion(usuario.IDUsuario);
            }

            Session.Abandon();
            Response.Redirect("~/LoginIniciarSesion.aspx");
        }

        //SESION UNICA
        protected void TimerSesion_Tick(object sender, EventArgs e)
        {
            // Vacío a propósito: el postback generado por el Timer
            // es interceptado por SesionUnicaModule. Si la sesión
            // ya no es válida, el módulo redirige solo antes de llegar acá.
        }

    }
}