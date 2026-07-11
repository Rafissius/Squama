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
    public partial class ArenaVictoria : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Session["Usuario"] ya está garantizado no-nulo acá: SesionUnicaModule
            // redirige a login antes de que este Page_Load se ejecute.
            BE_Usuario usuarioSesion = Session["Usuario"] as BE_Usuario;

            int idCombate;
            if (!int.TryParse(Request.QueryString["idCombate"], out idCombate))
            {
                Response.Redirect("HomeJugador.aspx");
                return;
            }

            BE_ResultadoCombateVista resultado = new BLL_Combate().ObtenerCombateParaMostrar(idCombate, usuarioSesion.IDUsuario);

            // null si el combate no existe, no es del usuario logueado, o fue una derrota
            // (esta pantalla es solo de victoria en el prototipo — ver Contexto.md).
            if (resultado == null || !resultado.Gano)
            {
                Response.Redirect("HomeJugador.aspx");
                return;
            }

            LblNombreDefensorNav.Text = resultado.NombreDefensor;
            LblNombreDefensor.Text = resultado.NombreDefensor;
            LblNombreAtacante.Text = resultado.NombreAtacante;
            LblNivelAtacante.Text = resultado.NivelAtacante.ToString();
            LblNombreDefensorPanel.Text = resultado.NombreDefensor;
            LblNivelDefensor.Text = resultado.NivelDefensor.ToString();
            LblXPGanada.Text = "+" + resultado.ExperienciaGanada + " XP";
            LblCopas.Text = resultado.CopasAntes + " → " + resultado.CopasDespues;
        }
    }
}