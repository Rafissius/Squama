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
            // Explícito como DateTime2 (no AddWithValue, que infiere DateTime): la columna es
            // datetime2 y AddWithValue con un DateTime CLR trunca al precision de DateTime
            // (~3.33ms) del lado del cliente antes de llegar a la base, anulando el propósito
            // de la migración — ver Contexto.md, "Causa raíz encontrada y reproducida (2026-07-10)".
            cmd.Parameters.Add("@FechaRegistro", SqlDbType.DateTime2).Value = usuario.FechaRegistro;
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

        public bool ExisteNombreUsuario(string nombreUsuario, int idUsuarioExcluir)
        {
            string query = "SELECT COUNT(1) FROM Usuario WHERE NombreUsuario = @NombreUsuario AND IDUsuario <> @IDUsuarioExcluir";
            SqlCommand cmd = new SqlCommand(query);
            cmd.Parameters.AddWithValue("@NombreUsuario", nombreUsuario);
            cmd.Parameters.AddWithValue("@IDUsuarioExcluir", idUsuarioExcluir);

            object resultado = EjecutarScalar(cmd);
            return Convert.ToInt32(resultado) > 0;
        }

        public bool ExisteEmail(string email, int idUsuarioExcluir)
        {
            string query = "SELECT COUNT(1) FROM Usuario WHERE Email = @Email AND IDUsuario <> @IDUsuarioExcluir";
            SqlCommand cmd = new SqlCommand(query);
            cmd.Parameters.AddWithValue("@Email", email);
            cmd.Parameters.AddWithValue("@IDUsuarioExcluir", idUsuarioExcluir);

            object resultado = EjecutarScalar(cmd);
            return Convert.ToInt32(resultado) > 0;
        }

        /////////MODULO REGISTRAR USUARIO


        /////////MODULO GESTION DE USUARIOS (webmaster)

        public BE_Usuario ObtenerPorId(int idUsuario)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT IDUsuario, NombreUsuario, Email, PasswordHash, FechaRegistro,
                       Estado, Bloqueado, IntentosFallidos
                FROM Usuario
                WHERE IDUsuario = @IDUsuario");

            cmd.Parameters.AddWithValue("@IDUsuario", idUsuario);

            DataTable dt = EjecutarDataTable(cmd);
            if (dt.Rows.Count == 0)
                return null;

            DataRow row = dt.Rows[0];
            return new BE_Usuario
            {
                IDUsuario = Convert.ToInt32(row["IDUsuario"]),
                NombreUsuario = row["NombreUsuario"].ToString(),
                Email = row["Email"].ToString(),
                PasswordHash = row["PasswordHash"] == DBNull.Value ? null : row["PasswordHash"].ToString(),
                FechaRegistro = Convert.ToDateTime(row["FechaRegistro"]),
                Estado = Convert.ToInt32(row["Estado"]),
                Bloqueado = Convert.ToBoolean(row["Bloqueado"]),
                IntentosFallidos = Convert.ToInt32(row["IntentosFallidos"])
            };
        }

        // Un solo rol activo por usuario (UsuarioRol.Estado=1): LEFT JOIN por si
        // algún registro legado quedara sin rol asignado (no debería pasar, pero
        // así no rompe el listado).
        public List<BE_UsuarioListItem> ObtenerTodosConRol()
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT u.IDUsuario, u.NombreUsuario, u.Email, u.FechaRegistro,
                       u.Estado, u.Bloqueado, u.IntentosFallidos,
                       r.IDRol, r.Nombre AS NombreRol
                FROM Usuario u
                LEFT JOIN UsuarioRol ur ON ur.IDUsuario = u.IDUsuario AND ur.Estado = 1
                LEFT JOIN Rol r ON r.IDRol = ur.IDRol
                ORDER BY u.IDUsuario");

            DataTable dt = EjecutarDataTable(cmd);
            List<BE_UsuarioListItem> lista = new List<BE_UsuarioListItem>();

            foreach (DataRow row in dt.Rows)
            {
                lista.Add(new BE_UsuarioListItem
                {
                    IDUsuario = Convert.ToInt32(row["IDUsuario"]),
                    NombreUsuario = row["NombreUsuario"].ToString(),
                    Email = row["Email"].ToString(),
                    FechaRegistro = Convert.ToDateTime(row["FechaRegistro"]),
                    Estado = Convert.ToInt32(row["Estado"]),
                    Bloqueado = Convert.ToBoolean(row["Bloqueado"]),
                    IntentosFallidos = Convert.ToInt32(row["IntentosFallidos"]),
                    IDRol = row["IDRol"] == DBNull.Value ? 0 : Convert.ToInt32(row["IDRol"]),
                    NombreRol = row["NombreRol"] == DBNull.Value ? null : row["NombreRol"].ToString()
                });
            }

            return lista;
        }

        public List<BE_Rol> ObtenerRoles()
        {
            SqlCommand cmd = new SqlCommand(
                "SELECT IDRol, Nombre FROM Rol WHERE Estado = 1 ORDER BY IDRol");

            DataTable dt = EjecutarDataTable(cmd);
            List<BE_Rol> lista = new List<BE_Rol>();

            foreach (DataRow row in dt.Rows)
            {
                lista.Add(new BE_Rol
                {
                    IDRol = Convert.ToInt32(row["IDRol"]),
                    Nombre = row["Nombre"].ToString()
                });
            }

            return lista;
        }

        public void ActualizarDatos(int idUsuario, string nombreUsuario, string email)
        {
            SqlCommand cmd = new SqlCommand(
                "UPDATE Usuario SET NombreUsuario = @NombreUsuario, Email = @Email WHERE IDUsuario = @IDUsuario");

            cmd.Parameters.AddWithValue("@NombreUsuario", nombreUsuario);
            cmd.Parameters.AddWithValue("@Email", email);
            cmd.Parameters.AddWithValue("@IDUsuario", idUsuario);

            EjecutarNonQuery(cmd);
        }

        public void ActualizarEstado(int idUsuario, int estado)
        {
            SqlCommand cmd = new SqlCommand(
                "UPDATE Usuario SET Estado = @Estado WHERE IDUsuario = @IDUsuario");

            cmd.Parameters.AddWithValue("@Estado", estado);
            cmd.Parameters.AddWithValue("@IDUsuario", idUsuario);

            EjecutarNonQuery(cmd);
        }

        public void ActualizarBloqueado(int idUsuario, bool bloqueado)
        {
            SqlCommand cmd = new SqlCommand(
                "UPDATE Usuario SET Bloqueado = @Bloqueado WHERE IDUsuario = @IDUsuario");

            cmd.Parameters.AddWithValue("@Bloqueado", bloqueado);
            cmd.Parameters.AddWithValue("@IDUsuario", idUsuario);

            EjecutarNonQuery(cmd);
        }

        public void ResetearIntentosFallidos(int idUsuario)
        {
            SqlCommand cmd = new SqlCommand(
                "UPDATE Usuario SET IntentosFallidos = 0 WHERE IDUsuario = @IDUsuario");

            cmd.Parameters.AddWithValue("@IDUsuario", idUsuario);
            EjecutarNonQuery(cmd);
        }

        // Un solo rol activo por usuario: se actualiza la fila activa existente
        // en vez de desactivar+insertar (no hace falta historial de reasignaciones).
        public void ActualizarRol(int idUsuario, int idRol)
        {
            SqlCommand cmd = new SqlCommand(
                "UPDATE UsuarioRol SET IDRol = @IDRol WHERE IDUsuario = @IDUsuario AND Estado = 1");

            cmd.Parameters.AddWithValue("@IDRol", idRol);
            cmd.Parameters.AddWithValue("@IDUsuario", idUsuario);

            EjecutarNonQuery(cmd);
        }

        /////////MODULO GESTION DE USUARIOS (webmaster)

    }
}
