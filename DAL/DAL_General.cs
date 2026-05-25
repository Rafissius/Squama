using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Configuration;

namespace DAL
{
    public class DAL_General
    {
        private readonly string connectionString;

        public DAL_General()
        {
            connectionString = ConfigurationManager.ConnectionStrings["ConexionPrincipal"].ConnectionString;
           // connectionString = "Server=localhost\\SQLEXPRESS;Database=Squama;Trusted_Connection=True;";
        }

        private SqlConnection CrearConexion()
        {
            return new SqlConnection(connectionString);
        }

        public void EjecutarNonQuery(SqlCommand cmd)
        {
            using (SqlConnection conexion = CrearConexion())
            {
                cmd.Connection = conexion;

                conexion.Open();
                cmd.ExecuteNonQuery();
            }
        }

        public object EjecutarScalar(SqlCommand cmd)
        {
            using (SqlConnection conexion = CrearConexion())
            {
                cmd.Connection = conexion;

                conexion.Open();
                return cmd.ExecuteScalar();
            }
        }

        public DataTable EjecutarDataTable(SqlCommand cmd)
        {
            using (SqlConnection conexion = CrearConexion())
            {
                cmd.Connection = conexion;

                using (SqlDataAdapter adaptador = new SqlDataAdapter(cmd))
                {
                    DataTable tabla = new DataTable();
                    adaptador.Fill(tabla);
                    return tabla;
                }
            }
        }



    }
}
