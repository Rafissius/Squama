using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.AccessControl;
using System.Security.Principal;
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
            BE_Usuario usuario = Session["Usuario"] as BE_Usuario;
            if (usuario == null)
            {
                divMensajeRestore.InnerText = "Tu sesión expiró. Volvé a ingresar.";
                divMensajeRestore.Attributes["class"] = "msg-restore error";
                divMensajeRestore.Style["display"] = "block";
                return;
            }

            string motivo = txtMotivoRestore.Value.Trim();

            if (fileUploadBAK.PostedFile == null || fileUploadBAK.PostedFile.ContentLength == 0)
            {
                divMensajeRestore.InnerText = "Seleccioná un archivo .bak antes de continuar.";
                divMensajeRestore.Attributes["class"] = "msg-restore error";
                divMensajeRestore.Style["display"] = "block";
                return;
            }

            if (string.IsNullOrEmpty(motivo))
            {
                divMensajeRestore.InnerText = "El motivo del restore es obligatorio.";
                divMensajeRestore.Attributes["class"] = "msg-restore error";
                divMensajeRestore.Style["display"] = "block";
                return;
            }

            // ── Guardar el .bak temporalmente en el servidor ────────
            string nombreArchivo = System.IO.Path.GetFileName(
                fileUploadBAK.PostedFile.FileName);

            string carpetaTemp = System.IO.Path.Combine(
                Server.MapPath("~"), "App_Data", "TempBackups");

            AsegurarCarpetaTempConPermisos(carpetaTemp);

            string rutaTemporal = System.IO.Path.Combine(carpetaTemp, nombreArchivo);

            try
            {
                fileUploadBAK.PostedFile.SaveAs(rutaTemporal);

                BLL_RESTORE bll = new BLL_RESTORE();
                bll.EjecutarRestore(rutaTemporal, motivo, usuario);

                divMensajeRestore.InnerText =
                    "✔ Restore completado correctamente. BD restaurada desde: " + nombreArchivo;
                divMensajeRestore.Attributes["class"] = "msg-restore exito";
                divMensajeRestore.Style["display"] = "block";

                txtMotivoRestore.Value = "";
            }
            catch (Exception ex)
            {
                divMensajeRestore.InnerText = "Error al ejecutar el restore: " + ex.Message;
                divMensajeRestore.Attributes["class"] = "msg-restore error";
                divMensajeRestore.Style["display"] = "block";
            }
            finally
            {
                // ── Borrar siempre el temporal ──────────────────────
                try
                {
                    if (System.IO.File.Exists(rutaTemporal))
                        System.IO.File.Delete(rutaTemporal);
                }
                catch { }
            }


        }

        // Crea la carpeta temporal de backups si no existe y le garantiza permiso de lectura
        // a "Authenticated Users". No apuntamos a la cuenta puntual del servicio de SQL Server
        // porque esa cuenta varía según la instalación (cuenta virtual NT SERVICE\..., cuenta de
        // dominio, NETWORK SERVICE, etc.) y no hay forma de cubrir todos los casos con un solo
        // nombre fijo. "Authenticated Users" cubre cualquier cuenta que use SQL Server sin
        // importar cómo esté configurado el servicio en esa PC. Riesgo bajo: la carpeta solo
        // contiene el .bak de forma transitoria, se borra apenas termina el intento de restore.
        //
        // Se usa el SID conocido (WellKnownSidType), NO el string "Authenticated Users": ese
        // nombre en inglés no se resuelve en Windows con configuración regional distinta al
        // inglés (ej. español), y NTAccount.Translate tira IdentityNotMappedException. El SID
        // es el mismo sin importar el idioma del sistema operativo.
        private void AsegurarCarpetaTempConPermisos(string carpetaTemp)
        {
            if (!System.IO.Directory.Exists(carpetaTemp))
                System.IO.Directory.CreateDirectory(carpetaTemp);

            try
            {
                SecurityIdentifier usuariosAutenticados =
                    new SecurityIdentifier(WellKnownSidType.AuthenticatedUserSid, null);

                DirectorySecurity seguridad = System.IO.Directory.GetAccessControl(carpetaTemp);
                seguridad.AddAccessRule(new FileSystemAccessRule(
                    usuariosAutenticados,
                    FileSystemRights.ReadAndExecute,
                    InheritanceFlags.ContainerInherit | InheritanceFlags.ObjectInherit,
                    PropagationFlags.None,
                    AccessControlType.Allow));
                System.IO.Directory.SetAccessControl(carpetaTemp, seguridad);
            }
            catch
            {
                // Si el pool de IIS no tiene permiso para modificar el ACL de la carpeta,
                // seguimos igual: el restore fallará más abajo con un mensaje claro.
            }
        }
    }


}