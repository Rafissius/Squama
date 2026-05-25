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
            }
        }


        private void CargarEventos()
        {
            // TODO: conectar con DAL y obtener datos reales filtrados.
            // La lista que se pase a DataSource debe ser una List<EventoBitacora>
            // o un DataTable con las columnas:
            //   IDEvento, FechaHora (DateTime), NombreUsuario, TipoEvento,
            //   Descripcion, EntidadAfectada, Criticidad, IPOrigen,
            //   ModuloRelacionado, IDRegistroAfectado

            List<object> eventos = ObtenerEventosFiltrados();

            bool hayDatos = eventos != null && eventos.Count > 0;
            rptEventos.Visible = hayDatos;
            pnlEmpty.Visible = !hayDatos;

            if (hayDatos)
            {
                rptEventos.DataSource = eventos;
                rptEventos.DataBind();
            }

            // Stats — TODO: obtener desde DAL
            // lblEventosHoy.Text    = dal.GetEventosHoy().ToString();
            // lblAlertas.Text       = dal.GetAlertas().ToString();
            // lblFallidos.Text      = dal.GetFallidos().ToString();
            // lblSeguridad.Text     = dal.GetCambiosSeguridad().ToString();
            // lblUltimoEvento.Text  = dal.GetTiempoUltimoEvento();
            // lblPaginacionInfo.Text = $"{eventos.Count} eventos — Mostrando {Math.Min(ROWS_PER_PAGE, eventos.Count)} — Pág 1/{Math.Ceiling((double)eventos.Count/ROWS_PER_PAGE)}";

            CargarRecientes();
        }

        private void CargarRecientes()
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

        private List<object> ObtenerEventosFiltrados()
        {
            // TODO: reemplazar con llamada real a la DAL con los filtros de búsqueda
            return new List<object>();
        }

        protected void BtnBuscar_Click(object sender, EventArgs e)
        {
            CargarEventos();

        }

        protected void BtnLimpiar_Click(object sender, EventArgs e)
        {

            //Limpiamos filtros y cargamos dsp
            CargarEventos();
        }

        protected void BtnExportar_Click(object sender, EventArgs e)
        {
            //Exportamos dsp
        }



    }







}