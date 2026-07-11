using BE;
using SERVICIOS;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PylinskiCuello_ProyectoWeb
{
    public partial class BitacoraEventos : System.Web.UI.Page
    {

        private const int ROWS_PER_PAGE = 10;



        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                CargarEventos();
                CargarFiltros();
            }
        }

        //SESION UNICA
        protected void TimerSesion_Tick(object sender, EventArgs e)
        {
            // Vacío a propósito: el postback generado por el Timer
            // es interceptado por SesionUnicaModule. Si la sesión
            // ya no es válida, el módulo redirige solo antes de llegar acá.
        }

        private void CargarFiltros()
        {
            ddlUsuario.Items.Clear();
            ddlUsuario.Items.Add(new ListItem("Usuario", ""));
            foreach (var u in SERVICIOS.SERVICIOS_Bitacora.ObtenerUsuarios())
                ddlUsuario.Items.Add(new ListItem(u, u));

            ddlCriticidad.Items.Clear();
            ddlCriticidad.Items.Add(new ListItem("Criticidad", ""));
            foreach (var c in SERVICIOS.SERVICIOS_Bitacora.ObtenerCriticidades())
                ddlCriticidad.Items.Add(new ListItem(c, c));

            ddlModulo.Items.Clear();
            ddlModulo.Items.Add(new ListItem("Modulo", ""));
            foreach (var m in SERVICIOS.SERVICIOS_Bitacora.ObtenerModulos())
                ddlModulo.Items.Add(new ListItem(m, m));
        }

        private void CargarEventos()
        {

            List<BE_EventoBitacoraVista> eventos = ObtenerEventosFiltrados();
            bool hayDatos = eventos != null && eventos.Count > 0;

            rptEventos.Visible = hayDatos;
            pnlEmpty.Visible = !hayDatos;

            if (hayDatos)
            {
                rptEventos.DataSource = eventos;
                rptEventos.DataBind();
            }
            CargarRecientes(eventos);

    

            // Stats — TODO: obtener desde DAL DESPUES LO ARREGLAMOS
            // lblEventosHoy.Text    = dal.GetEventosHoy().ToString();
            // lblAlertas.Text       = dal.GetAlertas().ToString();
            // lblFallidos.Text      = dal.GetFallidos().ToString();
            // lblSeguridad.Text     = dal.GetCambiosSeguridad().ToString();
            // lblUltimoEvento.Text  = dal.GetTiempoUltimoEvento();
            // lblPaginacionInfo.Text = $"{eventos.Count} eventos — Mostrando {Math.Min(ROWS_PER_PAGE, eventos.Count)} — Pág 1/{Math.Ceiling((double)eventos.Count/ROWS_PER_PAGE)}";

        }

        private void CargarRecientes(List<BE_EventoBitacoraVista> eventos)
        {
            // TODO: obtener los últimos N eventos relevantes desde DAL
            // Debe incluir un campo calculado "TiempoRelativo" (ej. "hace 3 min")
            // rptRecientes.DataSource = dal.GetEventosRecientes(5);
            // rptRecientes.DataBind();
        }

        // Devuelve la clase de color CSS según criticidad/tipo
        protected string GetColorClass(string criticidad, string tipo)
        {
            if (criticidad == "CRITICO" || tipo == "SEGURIDAD" || tipo == "INTEGRIDAD")
                return "red";
            if (tipo == "SISTEMA")
                return "purple";
            if (criticidad == "ADVERTENCIA" || tipo == "CAMBIO")
                return "orange";
            return "blue";
        }

      

        protected void BtnBuscar_Click(object sender, EventArgs e)
        {


            SERVICIOS.SERVICIOS_Bitacora.RegistrarEvento(null,2, Request.UserHostAddress);


            CargarEventos();

        }

        protected void BtnLimpiar_Click(object sender, EventArgs e)
        {

            txtBuscar.Value = "";
            txtFechaDesde.Value = "";
            txtFechaHasta.Value = "";
            ddlUsuario.SelectedIndex = 0;
            ddlCriticidad.SelectedIndex = 0;
            ddlModulo.SelectedIndex = 0;
            //Limpiamos filtros y cargamos dsp
            CargarEventos();
        }

        protected void BtnExportar_Click(object sender, EventArgs e)
        {
            //Exportamos dsp
        }


        private List<BE_EventoBitacoraVista> ObtenerEventosFiltrados()
        {
            BE_FiltroBitacora filtro = new BE_FiltroBitacora
            {
                Buscar = txtBuscar.Value,
                Usuario = ddlUsuario.SelectedValue,
                Criticidad = ddlCriticidad.SelectedValue,
                Modulo = ddlModulo.SelectedValue
            };

            DateTime fd, fh;
            if (DateTime.TryParse(txtFechaDesde.Value, out fd)) filtro.FechaDesde = fd;
            if (DateTime.TryParse(txtFechaHasta.Value, out fh)) filtro.FechaHasta = fh;

            return SERVICIOS.SERVICIOS_Bitacora.ObtenerEventos(filtro);
        }

    }







}