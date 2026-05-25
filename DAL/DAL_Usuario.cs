using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;
using System.Data.SqlClient;
using BE;

namespace DAL
{
    public class DAL_Usuario : DAL_General
    {
        public BE_Usuario ObtenerUsuarioPorCredencial(string credencial)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT IDUsuario, NombreUsuario, Email, PasswordHash, 
                       Estado, Bloqueado, IntentosFallidos
                FROM Usuario
                WHERE NombreUsuario = @Credencial OR Email = @Credencial");

            cmd.Parameters.AddWithValue("@Credencial", credencial);

            DataTable dt = EjecutarDataTable(cmd);

            if (dt.Rows.Count == 0)
                return null;

            DataRow row = dt.Rows[0];
            return new BE_Usuario
            {
                IDUsuario = Convert.ToInt32(row["IDUsuario"]),
                NombreUsuario = row["NombreUsuario"].ToString(),
                Email = row["Email"].ToString(),
                PasswordHash = row["PasswordHash"].ToString(),
                Estado = Convert.ToInt32(row["Estado"]),
                Bloqueado = Convert.ToBoolean(row["Bloqueado"]),
                IntentosFallidos = Convert.ToInt32(row["IntentosFallidos"])
            };
        }

        public int ObtenerRolPorUsuario(int idUsuario)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT IDRol FROM UsuarioRol
                WHERE IDUsuario = @IDUsuario AND Estado = 1");

            cmd.Parameters.AddWithValue("@IDUsuario", idUsuario);

            object resultado = EjecutarScalar(cmd);
            return resultado != null ? Convert.ToInt32(resultado) : 0;
        }

        public void SumarIntentoFallido(int idUsuario)
        {
            SqlCommand cmd = new SqlCommand(@"
                UPDATE Usuario
                SET IntentosFallidos = IntentosFallidos + 1
                WHERE IDUsuario = @IDUsuario");

            cmd.Parameters.AddWithValue("@IDUsuario", idUsuario);
            EjecutarNonQuery(cmd);
        }
    }
}
