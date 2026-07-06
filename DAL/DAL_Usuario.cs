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
        
        public string ObtenerNombreRolPorUsuario(int idUsuario)
        {
            SqlCommand cmd = new SqlCommand(@"
        SELECT R.Nombre
        FROM UsuarioRol UR
        INNER JOIN Rol R ON UR.IDRol = R.IDRol
        WHERE UR.IDUsuario = @IDUsuario AND UR.Estado = 1");

            cmd.Parameters.AddWithValue("@IDUsuario", idUsuario);

            object resultado = EjecutarScalar(cmd);
            return resultado != null ? resultado.ToString() : null;
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


        /////////MODULO REGISTRAR USUARIO


        public int Insertar(BE_Usuario usuario)
        {
            string query = @"INSERT INTO Usuario
                                (NombreUsuario, Email, PasswordHash, FechaRegistro, Estado, Bloqueado, IntentosFallidos)
                             OUTPUT INSERTED.IDUsuario
                             VALUES
                                (@NombreUsuario, @Email, @PasswordHash, @FechaRegistro, @Estado, @Bloqueado, @IntentosFallidos)";

            SqlCommand cmd = new SqlCommand(query);
            cmd.Parameters.AddWithValue("@NombreUsuario", usuario.NombreUsuario);
            cmd.Parameters.AddWithValue("@Email", usuario.Email);
            cmd.Parameters.AddWithValue("@PasswordHash", usuario.PasswordHash);
            cmd.Parameters.AddWithValue("@FechaRegistro", usuario.FechaRegistro);
            cmd.Parameters.AddWithValue("@Estado", usuario.Estado);
            cmd.Parameters.AddWithValue("@Bloqueado", usuario.Bloqueado);
            cmd.Parameters.AddWithValue("@IntentosFallidos", usuario.IntentosFallidos);

            object resultado = EjecutarScalar(cmd);
            return Convert.ToInt32(resultado);
        }

        public void AsignarRolPredeterminado(int idUsuario, int idRol)
        {
            string query = @"INSERT INTO UsuarioRol
                                (IDUsuario, IDRol, FechaAsignacion, Estado)
                             VALUES
                                (@IDUsuario, @IDRol, @FechaAsignacion, @Estado)";

            SqlCommand cmd = new SqlCommand(query);
            cmd.Parameters.AddWithValue("@IDUsuario", idUsuario);
            cmd.Parameters.AddWithValue("@IDRol", idRol);
            cmd.Parameters.AddWithValue("@FechaAsignacion", DateTime.Now);
            cmd.Parameters.AddWithValue("@Estado", 1);

            EjecutarNonQuery(cmd);
        }

        public bool ExisteNombreUsuario(string nombreUsuario)
        {
            string query = "SELECT COUNT(1) FROM Usuario WHERE NombreUsuario = @NombreUsuario";
            SqlCommand cmd = new SqlCommand(query);
            cmd.Parameters.AddWithValue("@NombreUsuario", nombreUsuario);

            object resultado = EjecutarScalar(cmd);
            return Convert.ToInt32(resultado) > 0;
        }

        public bool ExisteEmail(string email)
        {
            string query = "SELECT COUNT(1) FROM Usuario WHERE Email = @Email";
            SqlCommand cmd = new SqlCommand(query);
            cmd.Parameters.AddWithValue("@Email", email);

            object resultado = EjecutarScalar(cmd);
            return Convert.ToInt32(resultado) > 0;
        }

        /////////MODULO REGISTRAR USUARIO

    }
}
