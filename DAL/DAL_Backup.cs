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
    }
}
