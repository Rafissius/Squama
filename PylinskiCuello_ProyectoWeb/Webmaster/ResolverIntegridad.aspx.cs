using BE;
using SERVICIOS;
using System;
using System.Collections.Generic;
using System.Web.UI;

namespace PylinskiCuello_ProyectoWeb.Webmaster
{
    public partial class ResolverIntegridad : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            BE_Usuario usuario = Session["Usuario"] as BE_Usuario;

            if (usuario == null || !SERVICIOS_DigitoVerificador.EsWebmaster(usuario))
            {
                Response.Redirect("~/LoginIniciarSesion.aspx");
                return;
            }

            if (!IsPostBack)
            {
                CargarResumen();
                CargarInconsistencias();
                CargarBackups();
            }
        }

        private void CargarResumen()
        {
            lblCantidadInconsistencias.Text = EstadoSistema.CantidadInconsistencias.ToString();
            lblFechaBloqueo.Text = EstadoSistema.FechaBloqueo.HasValue
                ? EstadoSistema.FechaBloqueo.Value.ToString("dd/MM/yyyy HH:mm:ss")
                : "N/D";
            lblMotivoBloqueo.Text = EstadoSistema.MotivoBloqueo ?? "N/D";
        }

        private void CargarInconsistencias()
        {
            List<BE_InconsistenciaIntegridad> inconsistencias =
                SERVICIOS_DigitoVerificador.ObtenerUltimasInconsistencias(20);

            bool hayDatos = inconsistencias != null && inconsistencias.Count > 0;
            rptInconsistencias.Visible = hayDatos;
            pnlSinInconsistencias.Visible = !hayDatos;

            if (hayDatos)
            {
                rptInconsistencias.DataSource = inconsistencias;
                rptInconsistencias.DataBind();
            }
        }

        private void CargarBackups()
        {
            List<BE_Backup> backups = SERVICIOS_Restore.ObtenerBackupsDisponibles();

            bool hayBackups = backups != null && backups.Count > 0;
            ddlBackups.Visible = hayBackups;
            btnRestaurar.Enabled = hayBackups;
            pnlSinBackups.Visible = !hayBackups;

            if (hayBackups)
            {
                ddlBackups.DataSource = backups;
                ddlBackups.DataTextField = "NombreArchivo";
                ddlBackups.DataValueField = "IDBackup";
                ddlBackups.DataBind();
            }
        }

        protected void BtnRecalcular_Click(object sender, EventArgs e)
        {
            BE_Usuario usuario = (BE_Usuario)Session["Usuario"];

            SERVICIOS_DigitoVerificador.RecalcularTodosLosDV(usuario.IDUsuario, Request.UserHostAddress);

            pMensaje.InnerText = "Los dígitos verificadores se recalcularon correctamente. El sistema fue desbloqueado.";
            CargarResumen();
            CargarInconsistencias();
        }

        protected void BtnRestaurar_Click(object sender, EventArgs e)
        {
            BE_Usuario usuario = (BE_Usuario)Session["Usuario"];
            int idBackup = int.Parse(ddlBackups.SelectedValue);

            try
            {
                SERVICIOS_Restore.RestaurarDesdeBackup(idBackup, usuario.IDUsuario, Request.UserHostAddress);
                SERVICIOS_DigitoVerificador.MarcarSistemaDesbloqueadoPorRestore(usuario.IDUsuario, Request.UserHostAddress);

                pMensaje.InnerText = "Restore completado. El sistema fue desbloqueado.";
                CargarResumen();
                CargarInconsistencias();
            }
            catch (NotImplementedException)
            {
                // Gap conocido y documentado: el restore real todavía no está implementado.
                pMensaje.InnerText = "La funcionalidad de restore todavía no está implementada.";
            }
        }
    }
}
