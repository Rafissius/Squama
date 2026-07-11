using BE;
using DAL;
using System;
using System.IO;
using System.Linq;

namespace BLL
{
    public class BLL_Backup
    {
        private readonly DAL_Backup _dal = new DAL_Backup();

        /// <summary>
        /// Genera el backup completo:
        ///   1. Crea carpeta de destino si no existe
        ///   2. Ejecuta BACKUP DATABASE → archivo .bak
        ///   3. Crea archivo .txt con observaciones + metadata
        ///   4. Registra el backup en la tabla Backups
        /// </summary>
        /// <param name="nombreArchivo">Nombre sin extensión, ingresado por el usuario</param>
        /// <param name="rutaDestino">Carpeta destino seleccionada</param>
        /// <param name="observacion">Texto libre del usuario</param>
        /// <param name="usuario">Objeto BE_Usuario de la sesión activa</param>
        public void GenerarBackup(string nombreArchivo, string rutaDestino,
                                  string observacion, BE_Usuario usuario)
        {
            // ── Validaciones básicas ────────────────────────────────
            if (string.IsNullOrWhiteSpace(nombreArchivo))
                throw new ArgumentException("El nombre del archivo es obligatorio.");

            if (string.IsNullOrWhiteSpace(rutaDestino))
                throw new ArgumentException("La ruta de destino es obligatoria.");

            // Caracteres inválidos en nombre de archivo
            foreach (char c in Path.GetInvalidFileNameChars())
                if (nombreArchivo.Contains(c))
                    throw new ArgumentException("El nombre del archivo contiene caracteres inválidos.");

            // ── Preparar rutas ──────────────────────────────────────
            // Asegurarse de que la carpeta exista
            if (!Directory.Exists(rutaDestino))
                Directory.CreateDirectory(rutaDestino);

            string nombreBak = nombreArchivo + ".bak";
            string nombreTxt = nombreArchivo + "_info.txt";
            string rutaBak = Path.Combine(rutaDestino, nombreBak);
            string rutaTxt = Path.Combine(rutaDestino, nombreTxt);

            DateTime ahora = DateTime.Now;

            // ── 1. Generar el .bak via SQL Server ───────────────────
            // SQL Server escribe el archivo directamente en el servidor.
            // La ruta debe ser accesible por la cuenta del servicio SQL.
            _dal.GenerarBakSqlServer(rutaBak);

            // ── 2. Crear el .txt con metadata ───────────────────────
            using (StreamWriter sw = new StreamWriter(rutaTxt, false,
                       System.Text.Encoding.UTF8))
            {
                sw.WriteLine("═══════════════════════════════════════════");
                sw.WriteLine("         SQUAMA — REGISTRO DE BACKUP");
                sw.WriteLine("═══════════════════════════════════════════");
                sw.WriteLine($"Archivo:        {nombreBak}");
                sw.WriteLine($"Ruta:           {rutaDestino}");
                sw.WriteLine($"Fecha y hora:   {ahora:dd/MM/yyyy HH:mm:ss}");
                sw.WriteLine($"Ejecutado por:  {usuario.NombreUsuario}");
                sw.WriteLine($"ID Usuario:     {usuario.IDUsuario}");
                sw.WriteLine("───────────────────────────────────────────");
                sw.WriteLine("Observaciones:");
                sw.WriteLine(string.IsNullOrWhiteSpace(observacion)
                    ? "(Sin observaciones)"
                    : observacion.Trim());
                sw.WriteLine("═══════════════════════════════════════════");
            }

            // ── 3. Registrar en BD ──────────────────────────────────
            BE_Backup2 registro = new BE_Backup2
            {
                NombreArchivo = nombreBak,
                RutaDestino = rutaDestino,
                Observacion = observacion,
                FechaHora = ahora,
                IDUsuario = usuario.IDUsuario,
                NombreUsuario = usuario.NombreUsuario,
                Estado = "COMPLETADO"
            };

            _dal.RegistrarBackup(registro);
        }

        // ── Obtener lista de backups para la tabla ──────────────────
        public System.Data.DataTable ObtenerBackups()
        {
            return _dal.ObtenerTodos();
        }
    }
}