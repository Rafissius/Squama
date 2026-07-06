
using BE;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAL
{
    public class DAL_RESTORE
    {
        private readonly DAL_General _dal = new DAL_General();

        // ── Obtiene el último IDBackup registrado en la tabla Backups ──
        // Necesario para completar el campo IDBackup en la tabla Restore.
        public int ObtenerUltimoIDBackup()
        {
            SqlCommand cmd = new SqlCommand(
                "SELECT ISNULL(MAX(IDBackup), 0) FROM Backups");
            object result = _dal.EjecutarScalar(cmd);
            return result == DBNull.Value ? 0 : Convert.ToInt32(result);
        }

        // ── Obtiene el IDBackup por nombre de archivo ──────────────────
        // Alternativa más precisa: busca el backup exacto que se va a restaurar.
        public int ObtenerIDBackupPorNombre(string nombreArchivo)
        {
            SqlCommand cmd = new SqlCommand(
                "SELECT TOP 1 IDBackup FROM Backups " +
                "WHERE NombreArchivo = @nombre " +
                "ORDER BY FechaHora DESC");
            cmd.Parameters.AddWithValue("@nombre", nombreArchivo);
            object result = _dal.EjecutarScalar(cmd);
            return (result == null || result == DBNull.Value) ? 0 : Convert.ToInt32(result);
        }

        // ── Registra el restore en la tabla Restore ────────────────────
        // IDRestore es IDENTITY → lo maneja la BD.
        // IDBackup lo calculamos en BLL (último ID + 1 o por nombre).
        public void RegistrarRestore(BE_RESTORE restore)
        {
            SqlCommand cmd = new SqlCommand(
       "INSERT INTO [Restore] " +
       "(IDUsuarioWebmaster, IDBackup, NombreArchivo, RutaArchivo, " +
       " FechaRestore, Observacion, Estado) " +
       "VALUES (@idUsuario, @idBackup, @nombre, @ruta, " +
       "        @fecha, @obs, @estado)");

            cmd.Parameters.AddWithValue("@idUsuario", restore.IDUsuarioWebmaster);
            cmd.Parameters.AddWithValue("@idBackup", restore.IDBackup);
            cmd.Parameters.AddWithValue("@nombre", restore.NombreArchivo);
            cmd.Parameters.AddWithValue("@ruta", restore.RutaArchivo);
            cmd.Parameters.AddWithValue("@fecha", restore.FechaRestore);
            cmd.Parameters.AddWithValue("@obs", (object)restore.Observacion ?? DBNull.Value);
            cmd.Parameters.Add("@estado", SqlDbType.TinyInt).Value = restore.Estado;

            _dal.EjecutarNonQuery(cmd);
        }

        // ── Obtiene todos los restores para la tabla ───────────────────
        public DataTable ObtenerTodos()
        {
            SqlCommand cmd = new SqlCommand(
       "SELECT r.IDRestore, r.IDBackup, r.NombreArchivo, r.RutaArchivo, " +
       "       r.FechaRestore, u.NombreUsuario, r.Observacion, r.Estado " +
       "FROM [Restore] r " +
       "INNER JOIN Usuarios u ON u.IDUsuario = r.IDUsuarioWebmaster " +
       "ORDER BY r.FechaRestore DESC");
            return _dal.EjecutarDataTable(cmd);
        }

        // ── Ejecuta el RESTORE DATABASE de SQL Server ──────────────────
        // IMPORTANTE: SQL Server necesita acceso exclusivo a la BD.
        // Usamos WITH REPLACE para sobrescribir, y ponemos la BD en
        // modo SINGLE_USER antes y volvemos a MULTI_USER después.
        public void EjecutarRestoreSqlServer(string rutaArchivoBAK)
        {
            // ══════════════════════════════════════════════════════════
            // CRÍTICO: hay que conectarse a [master], NO a [Squama].
            // Si nos conectamos a Squama, esa misma sesión bloquea el
            // restore. Master no tiene ese problema.
            // ══════════════════════════════════════════════════════════
            string connMaster = ConfigurationManager
                                    .ConnectionStrings["ConexionPrincipal"]
                                    .ConnectionString;

            // Reemplazamos el nombre de la BD por "master" en la cadena
            connMaster = System.Text.RegularExpressions.Regex.Replace(
                connMaster,
                @"(Database|Initial Catalog)\s*=\s*[^;]+",
                "Database=master",
                System.Text.RegularExpressions.RegexOptions.IgnoreCase
            );

            using (var conexion = new SqlConnection(connMaster))
            {
                conexion.Open();

                // Paso 1: forzar cierre de TODAS las conexiones a Squama
                using (var cmd = new SqlCommand(
                    "ALTER DATABASE [Squama] SET SINGLE_USER WITH ROLLBACK IMMEDIATE",
                    conexion))
                {
                    cmd.CommandTimeout = 60;
                    cmd.ExecuteNonQuery();
                }

                try
                {
                    // Paso 2: ejecutar el restore
                    using (var cmd = new SqlCommand(
                        "RESTORE DATABASE [Squama] FROM DISK = @ruta " +
                        "WITH REPLACE, RECOVERY, STATS = 10",
                        conexion))
                    {
                        cmd.CommandTimeout = 600;
                        cmd.Parameters.AddWithValue("@ruta", rutaArchivoBAK);
                        cmd.ExecuteNonQuery();
                    }
                }
                finally
                {
                    // Paso 3: siempre volver a MULTI_USER
                    try
                    {
                        using (var cmd = new SqlCommand(
                            "ALTER DATABASE [Squama] SET MULTI_USER",
                            conexion))
                        {
                            cmd.CommandTimeout = 60;
                            cmd.ExecuteNonQuery();
                        }
                    }
                    catch { /* si el restore falló y la BD quedó en mal estado */ }
                }
            }
        }
    }
}