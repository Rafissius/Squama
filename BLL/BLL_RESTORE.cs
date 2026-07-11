using BE;
using DAL;
using System;
using System.Data;
using System.IO;

namespace BLL
{
    public class BLL_RESTORE
    {
        private readonly DAL_RESTORE _dal = new DAL_RESTORE();

        public void EjecutarRestore(string rutaArchivoBAK, string motivo, BE_Usuario usuario)
        {
            if (string.IsNullOrWhiteSpace(rutaArchivoBAK))
                throw new ArgumentException("Debe seleccionar un archivo de backup.");

            if (!rutaArchivoBAK.EndsWith(".bak", StringComparison.OrdinalIgnoreCase))
                throw new ArgumentException("El archivo debe tener extensión .bak");

            if (string.IsNullOrWhiteSpace(motivo))
                throw new ArgumentException("El motivo del restore es obligatorio.");

            string nombreSoloArchivo = Path.GetFileName(rutaArchivoBAK);
            DateTime ahora = DateTime.Now;

            // ── Ejecutar RESTORE DATABASE ───────────────────────────
            // A partir de acá la base ya quedó reemplazada por el backup — es el paso
            // crítico e irreversible. Todo lo que sigue es trazabilidad best-effort.
            _dal.EjecutarRestoreSqlServer(rutaArchivoBAK);

            // ── Registrar en tabla Restore ──────────────────────────
            BE_RESTORE registro = new BE_RESTORE
            {
                IDUsuarioWebmaster = usuario.IDUsuario,
                IDBackup = 0,
                NombreArchivo = nombreSoloArchivo,
                RutaArchivo = rutaArchivoBAK,
                FechaRestore = ahora,
                Observacion = motivo.Trim(),
                Estado = 1
            };

            try
            {
                _dal.RegistrarRestore(registro);
            }
            catch
            {
                // Best-effort: si el webmaster que ejecuta el restore fue dado de alta
                // DESPUÉS de la fecha del backup que se está restaurando, este INSERT
                // falla por FK (IDUsuarioWebmaster ya no existe en la BD recién restaurada).
                // No debe hacer parecer que el restore en sí falló — la BD ya se restauró
                // en el paso anterior — ni impedir que el código que llama (ResolverIntegridad
                // .aspx.cs) siga adelante y desbloquee el sistema.
            }
        }

        public DataTable ObtenerRestores()
        {
            return _dal.ObtenerTodos();
        }
    }
}