using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using BE;
using SERVICIOS;

namespace PylinskiCuello_ProyectoWeb
{
    public partial class GestionUsuarios : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            BE_Usuario usuario = Session["Usuario"] as BE_Usuario;

            if (usuario == null || !SERVICIOS_DigitoVerificador.EsWebmaster(usuario))
            {
                Response.Redirect("~/LoginIniciarSesion.aspx");
                return;
            }
        }
    }
}
