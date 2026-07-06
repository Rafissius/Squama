using BE;
using DAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL
{
    public class BLL_RESTORE
    {
        private readonly DAL_RESTORE _dal = new DAL_RESTORE();

        /// <summary>
        /// Ejecuta el restore completo:
        ///   1. Valida los parámetros
        ///   2. Calcula el IDBackup (último registrado + 1)
        ///   3. Ejecuta RESTORE DATABASE via DAL
        ///   4. Registra el restore en la tabla Restore de la BD restaurada
        /// </summary>
        /// <param name="rutaArchivoBAK">Ruta completa del .bak seleccionado</param>
        /// <param name="motivo">Texto del campo "Motivo del restore"</param>
        /// <param name="usuario">BE_Usuario de la sesión activa</param>
        public void EjecutarRestore(string rutaArchivoBAK, string motivo, BE_Usuario usuario)
        {
            // ── Validaciones ────────────────────────────────────────
            if (string.IsNullOrWhiteSpace(rutaArchivoBAK))
                throw new ArgumentException("Debe seleccionar un archivo de backup.");

            if (!File.Exists(rutaArchivoBAK))
                throw new FileNotFoundException(
                    "El archivo de backup no fue encontrado: " + rutaArchivoBAK);

            if (!rutaArchivoBAK.EndsWith(".bak", StringComparison.OrdinalIgnoreCase))
                throw new ArgumentException("El archivo debe tener extensión .bak");

            if (string.IsNullOrWhiteSpace(motivo))
                throw new ArgumentException("El motivo del restore es obligatorio.");

            // ── Calcular IDBackup ───────────────────────────────────
            // Primero intenta encontrar el backup por nombre de archivo.
            // Si no lo encuentra en la tabla, usa último ID + 1.
            string nombreSoloArchivo = Path.GetFileName(rutaArchivoBAK);
            int idBackup = _dal.ObtenerIDBackupPorNombre(nombreSoloArchivo);

            if (idBackup == 0)
            {
                // No está en la tabla (archivo externo): último + 1
                int ultimoId = _dal.ObtenerUltimoIDBackup();
                idBackup = ultimoId;
            }

            DateTime ahora = DateTime.Now;

            // ── Ejecutar RESTORE DATABASE ───────────────────────────
            _dal.EjecutarRestoreSqlServer(rutaArchivoBAK);

            // ── Registrar en tabla Restore ──────────────────────────
            // NOTA: después del restore la BD se reinició, pero la conexión
            // de DAL_General apunta a la misma cadena, así que funciona.
            BE_RESTORE registro = new BE_RESTORE
            {
                IDUsuarioWebmaster = usuario.IDUsuario,
                IDBackup = idBackup,
                NombreArchivo = nombreSoloArchivo,
                RutaArchivo = rutaArchivoBAK,
                FechaRestore = ahora,
                Observacion = motivo.Trim(),
                Estado = 1
            };

            _dal.RegistrarRestore(registro);
        }

        // ── Obtener lista de restores para la tabla ─────────────────
        public DataTable ObtenerRestores()
        {
            return _dal.ObtenerTodos();
        }
    }
}
