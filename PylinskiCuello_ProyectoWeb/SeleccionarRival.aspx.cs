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
    public partial class SeleccionarRival : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Session["Usuario"] ya está garantizado no-nulo acá: SesionUnicaModule
            // redirige a login antes de que este Page_Load se ejecute.
            BE_Usuario usuarioSesion = Session["Usuario"] as BE_Usuario;
            var bllPersonaje = new BLL_Personaje();
            BE_Personaje personaje = bllPersonaje.ObtenerOCrearPorUsuario(usuarioSesion.IDUsuario, usuarioSesion.NombreUsuario);

            LblNavNombre.Text = personaje.Nombre;
            LblNavNivel.Text = personaje.Nivel.ToString();

            LblJugadorNombreNivel.Text = personaje.Nombre + " — Nv." + personaje.Nivel;

            List<BE_PersonajeEstadisticaVista> estadisticas = bllPersonaje.ObtenerEstadisticas(personaje.IDPersonaje);
            LblStatVida.Text = "VID: " + ObtenerValor(estadisticas, "Vida");
            LblStatFuerza.Text = "FUE: " + ObtenerValor(estadisticas, "Fuerza");
            LblStatAgilidad.Text = "AGL: " + ObtenerValor(estadisticas, "Agilidad");
            LblStatVelocidad.Text = "VEL: " + ObtenerValor(estadisticas, "Velocidad");
            LblStatInteligencia.Text = "INT: " + ObtenerValor(estadisticas, "Inteligencia");
        }

        private int ObtenerValor(List<BE_PersonajeEstadisticaVista> estadisticas, string nombre)
        {
            BE_PersonajeEstadisticaVista est = estadisticas.FirstOrDefault(e => e.Nombre == nombre);
            return est != null ? est.ValorBase : 0;
        }
    }
}