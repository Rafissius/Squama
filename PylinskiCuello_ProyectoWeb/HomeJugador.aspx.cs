using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PylinskiCuello_ProyectoWeb
{
    public partial class HomeJugador : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Session["Usuario"] ya está garantizado no-nulo acá: SesionUnicaModule
            // redirige a login antes de que este Page_Load se ejecute para cualquier
            // página fuera de su lista de páginas públicas (HomeJugador no está ahí).
            BE.BE_Usuario usuarioSesion = Session["Usuario"] as BE.BE_Usuario;
            var bllPersonaje = new BLL.BLL_Personaje();
            BE.BE_Personaje personaje = bllPersonaje.ObtenerOCrearPorUsuario(usuarioSesion.IDUsuario, usuarioSesion.NombreUsuario);

            if (!IsPostBack)
                CargarDatosPersonaje(personaje, bllPersonaje);
        }

        protected void BtnGanarXPPrueba_Click(object sender, EventArgs e)
        {
            BE.BE_Usuario usuarioSesion = Session["Usuario"] as BE.BE_Usuario;
            var bllPersonaje = new BLL.BLL_Personaje();
            BE.BE_Personaje personaje = bllPersonaje.ObtenerPorUsuario(usuarioSesion.IDUsuario);

            bllPersonaje.GanarExperiencia(personaje.IDPersonaje, 50);

            CargarDatosPersonaje(bllPersonaje.ObtenerPorUsuario(usuarioSesion.IDUsuario), bllPersonaje);
        }

        private void CargarDatosPersonaje(BE.BE_Personaje personaje, BLL.BLL_Personaje bllPersonaje)
        {
            LblNavNombre.Text = personaje.Nombre;
            LblNavNivel.Text = personaje.Nivel.ToString();
            LblStatNivel.Text = personaje.Nivel.ToString();
            LblXPActual.Text = personaje.ExperienciaActual.ToString();
            LblXPSiguiente.Text = personaje.ExperienciaSiguienteNivel.ToString();

            RptEstadisticas.DataSource = bllPersonaje.ObtenerEstadisticas(personaje.IDPersonaje);
            RptEstadisticas.DataBind();
        }

        //SESION UNICA
        protected void TimerSesion_Tick(object sender, EventArgs e)
        {
            // Vacío a propósito: el postback generado por el Timer
            // es interceptado por SesionUnicaModule. Si la sesión
            // ya no es válida, el módulo redirige solo antes de llegar acá.
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


    }
}