using BE;
using BLL;
using SERVICIOS;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.AccessControl;
using System.Security.Principal;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PylinskiCuello_ProyectoWeb.Webmaster
{
    public partial class ResolverIntegridad : Page
    {
        // USO (markup): navbar deshabilitado salvo "Salir" mientras el sistema esté
        // bloqueado — se rehabilita solo con el próximo postback (recalcular/restaurar
        // ya desbloquean antes de volver a renderizar).
        protected bool SistemaBloqueado => EstadoSistema.Bloqueado;

        // USO (markup): mientras el sistema está bloqueado, toda la navegación (salvo
        // "Salir") queda deshabilitada de verdad (sin href, no solo con CSS) — se rehabilita
        // sola en el próximo postback una vez resuelto (recalcular/restaurar desbloquean
        // antes de volver a renderizar la página).
        protected string NavLink(string href, string texto, bool activo = false)
        {
            if (SistemaBloqueado)
                return "<span class=\"nav-blocked\" title=\"Resolvé la integridad para poder navegar\">"
                    + HttpUtility.HtmlEncode(texto) + "</span>";

            string claseActiva = activo ? " class=\"active\"" : "";
            return "<a href=\"" + href + "\"" + claseActiva + ">" + HttpUtility.HtmlEncode(texto) + "</a>";
        }

        // USO (markup): color de las tarjetas de resumen — se recalculan con una consulta
        // liviana propia en vez de parsear el texto de los <asp:Label>, para no depender del
        // orden de render entre Page_Load y la evaluación de estas propiedades en el markup.
        protected bool HayInconsistencias => EstadoSistema.CantidadInconsistencias > 0;
        protected bool HayErrorDVH => SERVICIOS_DigitoVerificador.ObtenerCantidadInconsistenciasPendientesPorTipo("DVH") > 0;
        protected bool HayErrorDVV => SERVICIOS_DigitoVerificador.ObtenerCantidadInconsistenciasPendientesPorTipo("DVV") > 0;

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
                CargarTablasVerificadas();
                CargarInconsistencias();
                //CargarBackups();
            }
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
            BE_Usuario usuario = Session["Usuario"] as BE_Usuario;

            if (usuario != null)
                SesionActivaSingleton.Instancia.CerrarSesion(usuario.IDUsuario);

            Session.Abandon();
            Response.Redirect("~/LoginIniciarSesion.aspx");
        }

        private void CargarResumen()
        {
            lblCantidadInconsistencias.Text = EstadoSistema.CantidadInconsistencias.ToString();
            lblFechaBloqueo.Text = EstadoSistema.FechaBloqueo.HasValue
                ? EstadoSistema.FechaBloqueo.Value.ToString("dd/MM/yyyy HH:mm:ss")
                : "N/D";
            lblMotivoBloqueo.Text = EstadoSistema.MotivoBloqueo ?? "N/D";

            lblEstadoGeneral.Text = SistemaBloqueado ? "ALERTA" : "ÍNTEGRO";
            lblDvhConError.Text = SERVICIOS_DigitoVerificador.ObtenerCantidadInconsistenciasPendientesPorTipo("DVH").ToString();
            lblDvvConError.Text = SERVICIOS_DigitoVerificador.ObtenerCantidadInconsistenciasPendientesPorTipo("DVV").ToString();
        }

        // Fila de la sección "Estado de tablas verificadas".
        private class EstadoTablaVM
        {
            public string NombreTabla { get; set; }
            public string CantidadRegistros { get; set; }
            public int CantidadPendientes { get; set; }
            public bool TieneError { get; set; }
            public bool Excluida { get; set; }
            public string NotaExclusion { get; set; }
        }

        private void CargarTablasVerificadas()
        {
            List<EstadoTablaVM> estados = new List<EstadoTablaVM>();

            foreach (string tabla in SERVICIOS_DigitoVerificador.ObtenerEntidadesRegistradas())
            {
                int cantidad = SERVICIOS_DigitoVerificador.ObtenerCantidadRegistros(tabla);
                int pendientes = SERVICIOS_DigitoVerificador.ObtenerCantidadInconsistenciasPendientes(tabla);

                estados.Add(new EstadoTablaVM
                {
                    NombreTabla = tabla,
                    CantidadRegistros = cantidad.ToString(),
                    CantidadPendientes = pendientes,
                    TieneError = pendientes > 0
                });
            }

            // Bitacora está temporalmente excluida de _entidades (bug de redondeo de datetime
            // en FechaEvento, ver Contexto.md) — se muestra igual, aclarando el motivo, para
            // que no parezca que el sistema "se olvidó" de auditarla.
            if (!estados.Any(x => x.NombreTabla == "Bitacora"))
            {
                estados.Add(new EstadoTablaVM
                {
                    NombreTabla = "Bitacora",
                    CantidadRegistros = "—",
                    CantidadPendientes = 0,
                    TieneError = false,
                    Excluida = true,
                    NotaExclusion = "Excluida temporalmente de la verificación automática (bug de redondeo en fechas, en investigación — ver Contexto.md)."
                });
            }

            rptTablas.DataSource = estados;
            rptTablas.DataBind();
        }

        // USO (markup): <%# TagEstadoTabla(Container.DataItem) %> en rptTablas.
        protected string TagEstadoTabla(object dataItem)
        {
            EstadoTablaVM item = (EstadoTablaVM)dataItem;
            if (item.Excluida) return "<span class=\"tag tag--pend\">EXCLUIDA</span>";
            if (item.TieneError) return "<span class=\"tag tag--error\">ERROR</span>";
            return "<span class=\"tag tag--ok\">OK</span>";
        }

        // Fila de la grilla de inconsistencias — friendly label + payload para el modal Detalle.
        // Una fila acá representa UN incidente real (un registro insertado/modificado/eliminado),
        // no una fila cruda de InconsistenciaIntegridad: un solo cambio de campo ya dispara,
        // aparte de su propio DVH, un DVV por cada columna verificable de la tabla — esos DVV
        // se consolidan acá adentro de la misma fila (ColumnasCambiadas) en vez de aparecer
        // como filas sueltas en la grilla.
        public class InconsistenciaVM
        {
            public int ID { get; set; }
            public string Tabla { get; set; }
            public string RegistroDisplay { get; set; }
            public string ColumnasCambiadas { get; set; }
            public string QuePaso { get; set; }
            public string QuePasoClass { get; set; }
            public string Estado { get; set; }
            public string EstadoClass { get; set; }
            public string FechaDeteccion { get; set; }
            public DateTime FechaDeteccionOrden { get; set; }
            public string DetalleBase64 { get; set; }
        }

        // Guardada para poder armar el resumen del modal de confirmación de recálculo
        // (ver ResumenPendientes) sin volver a golpear la base — se llena en CargarInconsistencias,
        // que corre en el mismo Page_Load (!IsPostBack) que renderiza ese modal.
        private List<BE_InconsistenciaIntegridad> _ultimasInconsistencias = new List<BE_InconsistenciaIntegridad>();

        private void CargarInconsistencias()
        {
            List<BE_InconsistenciaIntegridad> inconsistencias =
                SERVICIOS_DigitoVerificador.ObtenerUltimasInconsistencias(20);
            _ultimasInconsistencias = inconsistencias ?? new List<BE_InconsistenciaIntegridad>();

            bool hayDatos = inconsistencias != null && inconsistencias.Count > 0;
            rptInconsistencias.Visible = hayDatos;
            pnlSinInconsistencias.Visible = !hayDatos;

            if (!hayDatos) return;

            List<InconsistenciaVM> filas = ConsolidarFilas(inconsistencias);

            rptInconsistencias.DataSource = filas;
            rptInconsistencias.DataBind();
        }

        // Agrupa cada fila DVH (un registro puntual) con las DVV de la misma tabla/estado que
        // correlacionan con ella, para que la grilla muestre UN incidente por cambio real —
        // no una fila por cada DVV que ese cambio dispara. Las DVV que no correlacionan con
        // ninguna DVH de esta tanda (caso raro: cambio agregado detectado sin poder aislar la
        // fila) se muestran igual, como fallback, para no esconder una inconsistencia real.
        private List<InconsistenciaVM> ConsolidarFilas(List<BE_InconsistenciaIntegridad> todas)
        {
            List<BE_InconsistenciaIntegridad> filasDVH = todas.Where(x => x.TipoDigito == "DVH").ToList();
            List<BE_InconsistenciaIntegridad> filasDVV = todas.Where(x => x.TipoDigito == "DVV").ToList();
            HashSet<int> dvvConsumidas = new HashSet<int>();

            List<InconsistenciaVM> resultado = new List<InconsistenciaVM>();

            foreach (BE_InconsistenciaIntegridad inc in filasDVH)
            {
                List<BE_InconsistenciaIntegridad> dvvCorrelacionadas = filasDVV
                    .Where(x => x.NombreTabla == inc.NombreTabla && x.Estado == inc.Estado)
                    .ToList();

                foreach (BE_InconsistenciaIntegridad dvv in dvvCorrelacionadas)
                    dvvConsumidas.Add(dvv.IDInconsistenciaIntegridad);

                resultado.Add(ArmarFila(inc, dvvCorrelacionadas));
            }

            foreach (BE_InconsistenciaIntegridad dvv in filasDVV.Where(x => !dvvConsumidas.Contains(x.IDInconsistenciaIntegridad)))
                resultado.Add(ArmarFilaDVVSuelta(dvv));

            return resultado.OrderByDescending(f => f.FechaDeteccionOrden).ToList();
        }

        // USO (markup): texto informativo del modal "Confirmar recálculo global".
        protected string ResumenPendientes()
        {
            List<BE_InconsistenciaIntegridad> pendientes = _ultimasInconsistencias
                .Where(x => x.Estado == 1)
                .Take(6)
                .ToList();

            if (pendientes.Count == 0) return "sin detalle disponible";

            return string.Join(", ", pendientes.Select(x =>
                x.NombreTabla + (x.IDRegistro.HasValue ? " #" + x.IDRegistro : "")));
        }

        // inc: la fila DVH (un registro puntual). dvvCorrelacionadas: las DVV de la misma
        // tabla/estado ya identificadas como parte del mismo incidente (ver ConsolidarFilas).
        private InconsistenciaVM ArmarFila(BE_InconsistenciaIntegridad inc, List<BE_InconsistenciaIntegridad> dvvCorrelacionadas)
        {
            bool esperadoVacio = string.IsNullOrEmpty(inc.ValorEsperado);
            bool calculadoVacio = string.IsNullOrEmpty(inc.ValorCalculado);

            string quePaso, quePasoClass;

            if (esperadoVacio && !calculadoVacio)
            {
                quePaso = "Inserción";
                quePasoClass = "tag--ok";
            }
            else if (!esperadoVacio && calculadoVacio)
            {
                quePaso = "Eliminación";
                quePasoClass = "tag--error";
            }
            else
            {
                quePaso = "Modificación";
                quePasoClass = "tag--error";
            }

            bool pendiente = inc.Estado == 1;
            string registroDisplay = inc.IDRegistro.HasValue ? "#" + inc.IDRegistro.Value : "N/D";

            // Sin nombre de columna para Inserción/Eliminación (todas las columnas "aparecen"
            // o "desaparecen" juntas con la fila, no tiene sentido señalar una en particular).
            List<string> nombresColumnas = dvvCorrelacionadas.Select(x => x.NombreAtributo).Distinct().ToList();
            string columnasCambiadas = quePaso == "Modificación" && nombresColumnas.Count > 0
                ? string.Join(", ", nombresColumnas)
                : "—";

            var detalle = new Dictionary<string, object>
            {
                ["id"] = inc.IDInconsistenciaIntegridad,
                ["tabla"] = inc.NombreTabla,
                ["registro"] = registroDisplay,
                ["quePaso"] = quePaso,
                ["estado"] = pendiente ? "Pendiente" : "Resuelto",
                ["fecha"] = inc.FechaDeteccion.ToString("dd/MM/yyyy HH:mm:ss"),
                ["webmaster"] = ObtenerNombreWebmaster(inc.IDUsuarioWebmaster),
                ["columnasCambiadas"] = nombresColumnas,
                ["valorEsperadoDVH"] = string.IsNullOrEmpty(inc.ValorEsperado) ? "(sin línea base)" : inc.ValorEsperado,
                ["valorCalculadoDVH"] = string.IsNullOrEmpty(inc.ValorCalculado) ? "(registro inexistente)" : inc.ValorCalculado,
            };

            if (quePaso == "Eliminación")
            {
                detalle["mensajeDetalle"] = "El registro fue eliminado de la base. No hay un snapshot histórico de sus campos previos.";
            }
            else if (inc.IDRegistro.HasValue)
            {
                Dictionary<string, string> valoresActuales =
                    SERVICIOS_DigitoVerificador.ObtenerValoresActuales(inc.NombreTabla, inc.IDRegistro.Value);
                detalle["registroActual"] = valoresActuales;
            }

            string json = new JavaScriptSerializer().Serialize(detalle);
            string base64 = Convert.ToBase64String(Encoding.UTF8.GetBytes(json));

            return new InconsistenciaVM
            {
                ID = inc.IDInconsistenciaIntegridad,
                Tabla = inc.NombreTabla,
                RegistroDisplay = registroDisplay,
                ColumnasCambiadas = columnasCambiadas,
                QuePaso = quePaso,
                QuePasoClass = quePasoClass,
                Estado = pendiente ? "Pendiente" : "Resuelto",
                EstadoClass = pendiente ? "tag--pend" : "tag--ok",
                FechaDeteccion = inc.FechaDeteccion.ToString("dd/MM/yyyy HH:mm:ss"),
                FechaDeteccionOrden = inc.FechaDeteccion,
                DetalleBase64 = base64,
            };
        }

        // Fallback para una DVV que no correlacionó con ninguna fila DVH en esta tanda — caso
        // raro (un cambio agregado detectado sin poder aislar el registro puntual). Se muestra
        // igual, para no esconder una inconsistencia real.
        private InconsistenciaVM ArmarFilaDVVSuelta(BE_InconsistenciaIntegridad inc)
        {
            bool pendiente = inc.Estado == 1;
            const string quePaso = "Cambio en columna (fila no identificada)";

            var detalle = new Dictionary<string, object>
            {
                ["id"] = inc.IDInconsistenciaIntegridad,
                ["tabla"] = inc.NombreTabla,
                ["registro"] = "N/D",
                ["quePaso"] = quePaso,
                ["estado"] = pendiente ? "Pendiente" : "Resuelto",
                ["fecha"] = inc.FechaDeteccion.ToString("dd/MM/yyyy HH:mm:ss"),
                ["webmaster"] = ObtenerNombreWebmaster(inc.IDUsuarioWebmaster),
                ["columnasCambiadas"] = new List<string> { inc.NombreAtributo },
                ["mensajeDetalle"] = "Se detectó un cambio agregado en esta columna, pero no se pudo identificar de qué registro puntual se trata (no hay una inconsistencia de fila que correlacione en esta tanda).",
            };

            string json = new JavaScriptSerializer().Serialize(detalle);
            string base64 = Convert.ToBase64String(Encoding.UTF8.GetBytes(json));

            return new InconsistenciaVM
            {
                ID = inc.IDInconsistenciaIntegridad,
                Tabla = inc.NombreTabla,
                RegistroDisplay = "N/D",
                ColumnasCambiadas = inc.NombreAtributo,
                QuePaso = quePaso,
                QuePasoClass = "tag--dv",
                Estado = pendiente ? "Pendiente" : "Resuelto",
                EstadoClass = pendiente ? "tag--pend" : "tag--ok",
                FechaDeteccion = inc.FechaDeteccion.ToString("dd/MM/yyyy HH:mm:ss"),
                FechaDeteccionOrden = inc.FechaDeteccion,
                DetalleBase64 = base64,
            };
        }

        private string ObtenerNombreWebmaster(int? idUsuarioWebmaster)
        {
            if (!idUsuarioWebmaster.HasValue) return "Automático (arranque/timer/login)";

            BE_Usuario webmaster = new BLL_Usuario().ObtenerPorId(idUsuarioWebmaster.Value);
            return webmaster != null ? webmaster.NombreUsuario : "Webmaster #" + idUsuarioWebmaster.Value;
        }

        /*
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
        }*/

        protected void BtnRecalcular_Click(object sender, EventArgs e)
        {
            BE_Usuario usuario = (BE_Usuario)Session["Usuario"];

            SERVICIOS_DigitoVerificador.RecalcularTodosLosDV(usuario.IDUsuario, Request.UserHostAddress);

            pMensaje.InnerText = "Los dígitos verificadores se recalcularon correctamente. El sistema fue desbloqueado.";
            CargarResumen();
            CargarTablasVerificadas();
            CargarInconsistencias();
        }


        protected void BtnRestaurar_Click(object sender, EventArgs e)
        {

            BE_Usuario usuario = Session["Usuario"] as BE_Usuario;
            if (usuario == null)
            {
                ClientScript.RegisterStartupScript(this.GetType(), "sesionExpirada",
                    "alert('Tu sesión expiró. Volvé a ingresar.');", true);
                return;
            }

            if (fileUploadBAK.PostedFile == null || fileUploadBAK.PostedFile.ContentLength == 0)
            {
                ClientScript.RegisterStartupScript(this.GetType(), "sinArchivo",
                    "alert('Seleccioná un archivo .bak.');", true);
                return;
            }

            string motivo = txtMotivoRestore.Text.Trim();
            if (string.IsNullOrEmpty(motivo))
            {
                ClientScript.RegisterStartupScript(this.GetType(), "sinMotivo",
                    "alert('El motivo del restore es obligatorio.');", true);
                return;
            }

            string nombreArchivo = System.IO.Path.GetFileName(fileUploadBAK.PostedFile.FileName);

            string carpetaTemp = System.IO.Path.Combine(
                Server.MapPath("~"), "App_Data", "TempBackups");

            AsegurarCarpetaTempConPermisos(carpetaTemp);

            string rutaTemporal = System.IO.Path.Combine(carpetaTemp, nombreArchivo);

            try
            {
                fileUploadBAK.PostedFile.SaveAs(rutaTemporal);

                BLL_RESTORE bll = new BLL_RESTORE();
                bll.EjecutarRestore(rutaTemporal, motivo, usuario);

                SERVICIOS_DigitoVerificador.MarcarSistemaDesbloqueadoPorRestore(usuario.IDUsuario, Request.UserHostAddress);

                pMensaje.InnerText = "Restore completado correctamente. BD restaurada desde: " +
                    nombreArchivo + ". El sistema fue desbloqueado.";
                txtMotivoRestore.Text = "";

                CargarResumen();
                CargarTablasVerificadas();
                CargarInconsistencias();
            }
            catch (Exception ex)
            {
                ClientScript.RegisterStartupScript(this.GetType(), "restoreError",
                    "alert('Error al ejecutar el restore: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
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
