using BE;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace DAL
{
    public class DAL_Backup
    {
        private readonly DAL_General _dal = new DAL_General();

        public List<BE_Backup> ObtenerBackupsDisponibles()
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = @"
                SELECT IDBackup, IDUsuarioWebmaster, NombreArchivo, RutaArchivo, FechaBackup, Observacion, Estado
                FROM [Backup]
                WHERE Estado = 1
                ORDER BY FechaBackup DESC";

            DataTable dt = _dal.EjecutarDataTable(cmd);
            List<BE_Backup> lista = new List<BE_Backup>();

            foreach (DataRow row in dt.Rows)
            {
                lista.Add(new BE_Backup
                {
                    IDBackup = Convert.ToInt32(row["IDBackup"]),
                    IDUsuarioWebmaster = Convert.ToInt32(row["IDUsuarioWebmaster"]),
                    NombreArchivo = row["NombreArchivo"].ToString(),
                    RutaArchivo = row["RutaArchivo"].ToString(),
                    FechaBackup = Convert.ToDateTime(row["FechaBackup"]),
                    Observacion = row["Observacion"] == DBNull.Value ? null : row["Observacion"].ToString(),
                    Estado = Convert.ToByte(row["Estado"])
                });
            }

            return lista;
        }


        //natyyyyyyy
        // ── Registra el backup en la tabla Backups ──────────────────
        public void RegistrarBackup(BE_Backup2 backup)
        {
            SqlCommand cmd = new SqlCommand("INSERT INTO Backups " +
                "(NombreArchivo, RutaDestino, Observacion, FechaHora, IDUsuario, NombreUsuario, Estado) " +
                "VALUES (@nombre, @ruta, @obs, @fecha, @idUsuario, @nombreUsuario, @estado)");

            cmd.Parameters.AddWithValue("@nombre", backup.NombreArchivo);
            cmd.Parameters.AddWithValue("@ruta", backup.RutaDestino);
            cmd.Parameters.AddWithValue("@obs", (object)backup.Observacion ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@fecha", backup.FechaHora);
            cmd.Parameters.AddWithValue("@idUsuario", backup.IDUsuario);
            cmd.Parameters.AddWithValue("@nombreUsuario", backup.NombreUsuario);
            cmd.Parameters.AddWithValue("@estado", backup.Estado);

            _dal.EjecutarNonQuery(cmd);
        }

        // ── Trae todos los backups para mostrar en la tabla ─────────
        public DataTable ObtenerTodos()
        {
            SqlCommand cmd = new SqlCommand(
                "SELECT IDBackup, NombreArchivo, RutaDestino, FechaHora, " +
                "NombreUsuario, Estado FROM Backups ORDER BY FechaHora DESC");
            return _dal.EjecutarDataTable(cmd);
        }

        // ── Genera el .bak usando BACKUP DATABASE de SQL Server ─────
        // IMPORTANTE: la cuenta del servicio SQL Server necesita
        // permisos de escritura en la carpeta de destino.
        public void GenerarBakSqlServer(string rutaCompletaBak)
        {
            // Usamos la misma conexión pero con un comando especial.
            // STATS=10 muestra progreso cada 10%. WITH FORMAT sobreescribe.
            string sql = $"BACKUP DATABASE [Squama] TO DISK = @ruta WITH FORMAT, INIT, STATS = 10";

            SqlCommand cmd = new SqlCommand(sql);
            cmd.CommandTimeout = 300; // 5 minutos máximo
            cmd.Parameters.AddWithValue("@ruta", rutaCompletaBak);

            _dal.EjecutarNonQuery(cmd);
        }
    }
}
