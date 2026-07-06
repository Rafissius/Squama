using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using BE;
using BLL;
using System.Data;

namespace PylinskiCuello_ProyectoWeb
{
    public partial class BackUpYRestore : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Verificar sesión activa
            if (Session["Usuario"] == null)
            {
                Response.Redirect("LoginIniciarSesion.aspx");
                return;
            }

            if (!IsPostBack)
            {
                CargarTablaBackups();
                // Pre-completar nombre sugerido con fecha actual
                txtNombreArchivo.Value = "backup_squama_" + DateTime.Now.ToString("yyyyMMdd_HHmm");
            }

        }


        //SESION UNICA
        protected void TimerSesion_Tick(object sender, EventArgs e)
        {
            // Vacío a propósito: el postback generado por el Timer
            // es interceptado por SesionUnicaModule. Si la sesión
            // ya no es válida, el módulo redirige solo antes de llegar acá.
        }

        // ── Cargar tabla de backups realizados ──────────────────────
        private void CargarTablaBackups()
        {
            try
            {
                BLL_Backup bll = new BLL_Backup();
                DataTable dt = bll.ObtenerBackups();
                // Si usás un GridView server-side, enlazalo acá.
                // Con la tabla HTML estática del .aspx no hace falta,
                // pero si querés hacerla dinámica agregá un Repeater o GridView.
            }
            catch { /* log si tenés */ }
        }

        // ── Botón Generar Backup ────────────────────────────────────
        protected void btnGenerarBackup_Click(object sender, EventArgs e)
        {
            // ── Obtener usuario de sesión ───────────────────────────
            BE_Usuario usuario = Session["Usuario"] as BE_Usuario;
            if (usuario == null)
            {
                MostrarMensaje("Tu sesión expiró. Volvé a ingresar.", esError: true);
                return;
            }

            // ── Leer valores del formulario ─────────────────────────
            string nombre = txtNombreArchivo.Value.Trim();
            string ruta = txtRutaDestino.Value.Trim();
            string obs = txtObservacion.Value.Trim();

            // ── Validación en capa de presentación ──────────────────
            if (string.IsNullOrEmpty(nombre))
            {
                MostrarMensaje("El nombre del archivo es obligatorio.", esError: true);
                return;
            }
            if (string.IsNullOrEmpty(ruta))
            {
                MostrarMensaje("La ruta de destino es obligatoria.", esError: true);
                return;
            }

            try
            {
                // ── Llamada a BLL ───────────────────────────────────
                BLL_Backup bll = new BLL_Backup();
                bll.GenerarBackup(nombre, ruta, obs, usuario);

                // ── Éxito ───────────────────────────────────────────
                MostrarMensaje(
                    $"✔ Backup generado correctamente: {nombre}.bak en {ruta}",
                    esError: false);

                // Limpiar campos
                txtNombreArchivo.Value = "backup_squama_" + DateTime.Now.ToString("yyyyMMdd_HHmm");
                txtRutaDestino.Value = "";
                txtObservacion.Value = "";

                // Recargar tabla
                CargarTablaBackups();
            }
            catch (Exception ex)
            {
                MostrarMensaje("Error al generar el backup: " + ex.Message, esError: true);
            }
        }

        // ── Helper para mostrar mensajes ────────────────────────────
        private void MostrarMensaje(string texto, bool esError)
        {
            divMensajeBackup.InnerText = texto;
            divMensajeBackup.Attributes["class"] = esError
                ? "msg-backup error"
                : "msg-backup exito";
            divMensajeBackup.Style["display"] = "block";
        }



        // ── Botón Confirmar Restore (desde el modal) ────────────────
        protected void btnConfirmarRestore_Click(object sender, EventArgs e)
        {
            // ── Obtener usuario de sesión ───────────────────────────
            BE_Usuario usuario = Session["Usuario"] as BE_Usuario;
            if (usuario == null)
            {
                // Mostrar error en el panel rojo
                divMensajeRestore.InnerText = "Tu sesión expiró. Volvé a ingresar.";
                divMensajeRestore.Attributes["class"] = "msg-restore error";
                divMensajeRestore.Style["display"] = "block";
                return;
            }

            // ── Leer valores ────────────────────────────────────────
            // hdnRutaBAK contiene el nombre del archivo seleccionado.
            // IMPORTANTE: en una app web el navegador solo envía el nombre,
            // no la ruta completa por seguridad. La ruta debe combinarse
            // con la carpeta de backups configurada en el servidor.
            string nombreBAK = hdnRutaBAK.Value.Trim();
            string motivo = txtMotivoRestore.Value.Trim();

            // Combinar con la ruta base de backups del servidor
            // (ajustá esta ruta a donde realmente están los .bak en tu servidor)
            string carpetaBackups = System.Configuration.ConfigurationManager
                                          .AppSettings["RutaCarpetaBackups"]
                                    ?? @"C:\Backups\Squama";

            string rutaCompleta = System.IO.Path.Combine(carpetaBackups, nombreBAK);

            if (string.IsNullOrEmpty(nombreBAK))
            {
                divMensajeRestore.InnerText = "No se recibió el archivo seleccionado.";
                divMensajeRestore.Attributes["class"] = "msg-restore error";
                divMensajeRestore.Style["display"] = "block";
                return;
            }

            try
            {
                // ── Llamada a BLL ───────────────────────────────────
                BLL_RESTORE bll = new BLL_RESTORE();
                bll.EjecutarRestore(rutaCompleta, motivo, usuario);

                // ── Éxito ───────────────────────────────────────────
                divMensajeRestore.InnerText =
                    "Restore completado correctamente. BD restaurada desde: " + nombreBAK;
                divMensajeRestore.Attributes["class"] = "msg-restore exito";
                divMensajeRestore.Style["display"] = "block";

                // Limpiar campos
                hdnRutaBAK.Value = "";
                txtMotivoRestore.Value = "";
            }
            catch (Exception ex)
            {
                divMensajeRestore.InnerText = "Error al ejecutar el restore: " + ex.Message;
                divMensajeRestore.Attributes["class"] = "msg-restore error";
                divMensajeRestore.Style["display"] = "block";
            }
        }


    }


    
}