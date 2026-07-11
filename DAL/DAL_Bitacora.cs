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
    public class DAL_Bitacora
    {
        private readonly DAL_General dalGeneral = new DAL_General();

        public void Guardar(BE_Bitacora evento)
        {
            SqlCommand cmd = new SqlCommand();

            cmd.CommandText = @"
                INSERT INTO Bitacora
                (
                    IDUsuario,
                    IDTipoEventoBitacora,
                    FechaEvento,
                    Descripcion,
                    IPOrigen
                )
                VALUES
                (
                    @IDUsuario,
                    @IDTipoEventoBitacora,
                    @FechaEvento,
                    @Descripcion,
                    @IPOrigen
                );
                SELECT SCOPE_IDENTITY();";

            cmd.CommandType = CommandType.Text;

            cmd.Parameters.Add("@IDUsuario", SqlDbType.Int).Value =
                evento.IDUsuario.HasValue ? (object)evento.IDUsuario.Value : DBNull.Value;

            cmd.Parameters.Add("@IDTipoEventoBitacora", SqlDbType.Int).Value = evento.IDTipoEventoBitacora;
            // DateTime2 (no DateTime): la columna es datetime2 desde la migración del
            // 2026-07-10 — ver Contexto.md, "Causa raíz encontrada y reproducida".
            cmd.Parameters.Add("@FechaEvento", SqlDbType.DateTime2).Value = evento.FechaEvento;
            cmd.Parameters.Add("@Descripcion", SqlDbType.VarChar, 500).Value = evento.Descripcion;

            cmd.Parameters.Add("@IPOrigen", SqlDbType.VarChar, 45).Value =
                string.IsNullOrWhiteSpace(evento.IPOrigen)
                ? (object)DBNull.Value
                : evento.IPOrigen;

            object idGenerado = dalGeneral.EjecutarScalar(cmd);
            evento.IDBitacora = Convert.ToInt32(idGenerado);
        }

        public int ObtenerIdTipoEventoPorNombre(string nombreEvento)
        {
            SqlCommand cmd = new SqlCommand();

            cmd.CommandText = @"
                SELECT IDTipoEventoBitacora
                FROM TipoEventoBitacora
                WHERE Nombre = @Nombre
                AND Estado = 1";

            cmd.CommandType = CommandType.Text;

            cmd.Parameters.Add("@Nombre", SqlDbType.VarChar, 100).Value = nombreEvento;

            object resultado = dalGeneral.EjecutarScalar(cmd);

            if (resultado == null || resultado == DBNull.Value)
            {
                throw new Exception("No existe un tipo de evento activo con el nombre: " + nombreEvento);
            }

            return Convert.ToInt32(resultado);
        }


        public string ObtenerDescripcionTipoEvento(int idTipoEvento)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = @"
        SELECT Descripcion 
        FROM TipoEventoBitacora 
        WHERE IDTipoEventoBitacora = @ID AND Estado = 1";
            cmd.CommandType = CommandType.Text;
            cmd.Parameters.Add("@ID", SqlDbType.Int).Value = idTipoEvento;

            object resultado = dalGeneral.EjecutarScalar(cmd);
            return resultado == null || resultado == DBNull.Value
                ? "Sin descripción"
                : resultado.ToString();
        }



        public List<BE_EventoBitacoraVista> ObtenerEventos()
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = @"
        SELECT 
            b.IDBitacora        AS IDEvento,
            b.FechaEvento       AS FechaHora,
            ISNULL(u.NombreUsuario, 'Sistema') AS NombreUsuario,
            t.Nombre            AS TipoEvento,
            b.Descripcion,
            t.Criticidad,
            t.Modulo            AS ModuloRelacionado,
            b.IPOrigen
        FROM Bitacora b
        INNER JOIN TipoEventoBitacora t ON b.IDTipoEventoBitacora = t.IDTipoEventoBitacora
        LEFT  JOIN Usuario           u ON b.IDUsuario = u.IDUsuario
        ORDER BY b.FechaEvento DESC";
            cmd.CommandType = CommandType.Text;

            DataTable dt = dalGeneral.EjecutarDataTable(cmd);
            List<BE_EventoBitacoraVista> lista = new List<BE_EventoBitacoraVista>();

            foreach (DataRow row in dt.Rows)
            {
                lista.Add(new BE_EventoBitacoraVista
                {
                    IDEvento = Convert.ToInt32(row["IDEvento"]),
                    FechaHora = Convert.ToDateTime(row["FechaHora"]),
                    NombreUsuario = row["NombreUsuario"].ToString(),
                    TipoEvento = row["TipoEvento"].ToString(),
                    Descripcion = row["Descripcion"].ToString(),
                    Criticidad = row["Criticidad"].ToString(),
                    ModuloRelacionado = row["ModuloRelacionado"].ToString(),
                    IPOrigen = row["IPOrigen"] == DBNull.Value ? "—" : row["IPOrigen"].ToString()
                });
            }
            return lista;
        }



        public List<BE_EventoBitacoraVista> ObtenerEventos(BE_FiltroBitacora filtro = null)
        {
            SqlCommand cmd = new SqlCommand();

            StringBuilder sql = new StringBuilder(@"
        SELECT 
            b.IDBitacora        AS IDEvento,
            b.FechaEvento       AS FechaHora,
            ISNULL(u.NombreUsuario, 'Sistema') AS NombreUsuario,
            t.Nombre            AS TipoEvento,
            b.Descripcion,
            t.Criticidad,
            t.Modulo            AS ModuloRelacionado,
            b.IPOrigen
        FROM Bitacora b
        INNER JOIN TipoEventoBitacora t ON b.IDTipoEventoBitacora = t.IDTipoEventoBitacora
        LEFT  JOIN Usuario           u ON b.IDUsuario = u.IDUsuario
        WHERE 1 = 1");

            if (filtro != null)
            {
                if (!string.IsNullOrWhiteSpace(filtro.Buscar))
                {
                    sql.Append(@" AND (b.Descripcion LIKE @Buscar 
                           OR ISNULL(u.NombreUsuario,'Sistema') LIKE @Buscar
                           OR CAST(b.IDBitacora AS VARCHAR(20)) LIKE @Buscar)");
                }
                if (filtro.FechaDesde.HasValue)
                    sql.Append(" AND b.FechaEvento >= @FechaDesde");
                if (filtro.FechaHasta.HasValue)
                    sql.Append(" AND b.FechaEvento < @FechaHasta"); // exclusivo, ver nota abajo
                if (!string.IsNullOrWhiteSpace(filtro.Usuario))
                    sql.Append(" AND ISNULL(u.NombreUsuario,'Sistema') = @Usuario");
                if (!string.IsNullOrWhiteSpace(filtro.Criticidad))
                    sql.Append(" AND t.Criticidad = @Criticidad");
                if (!string.IsNullOrWhiteSpace(filtro.Modulo))
                    sql.Append(" AND t.Modulo = @Modulo");
            }

            sql.Append(" ORDER BY b.FechaEvento DESC");
            cmd.CommandText = sql.ToString();
            cmd.CommandType = CommandType.Text;

            if (filtro != null)
            {
                if (!string.IsNullOrWhiteSpace(filtro.Buscar))
                    cmd.Parameters.Add("@Buscar", SqlDbType.VarChar, 550).Value = "%" + filtro.Buscar.Trim() + "%";
                if (filtro.FechaDesde.HasValue)
                    cmd.Parameters.Add("@FechaDesde", SqlDbType.DateTime).Value = filtro.FechaDesde.Value.Date;
                if (filtro.FechaHasta.HasValue)
                    cmd.Parameters.Add("@FechaHasta", SqlDbType.DateTime).Value = filtro.FechaHasta.Value.Date.AddDays(1);
                if (!string.IsNullOrWhiteSpace(filtro.Usuario))
                    cmd.Parameters.Add("@Usuario", SqlDbType.VarChar, 100).Value = filtro.Usuario;
                if (!string.IsNullOrWhiteSpace(filtro.Criticidad))
                    cmd.Parameters.Add("@Criticidad", SqlDbType.VarChar, 50).Value = filtro.Criticidad;
                if (!string.IsNullOrWhiteSpace(filtro.Modulo))
                    cmd.Parameters.Add("@Modulo", SqlDbType.VarChar, 100).Value = filtro.Modulo;
            }

            DataTable dt = dalGeneral.EjecutarDataTable(cmd);
            List<BE_EventoBitacoraVista> lista = new List<BE_EventoBitacoraVista>();
            foreach (DataRow row in dt.Rows)
            {
                lista.Add(new BE_EventoBitacoraVista
                {
                    IDEvento = Convert.ToInt32(row["IDEvento"]),
                    FechaHora = Convert.ToDateTime(row["FechaHora"]),
                    NombreUsuario = row["NombreUsuario"].ToString(),
                    TipoEvento = row["TipoEvento"].ToString(),
                    Descripcion = row["Descripcion"].ToString(),
                    Criticidad = row["Criticidad"].ToString(),
                    ModuloRelacionado = row["ModuloRelacionado"].ToString(),
                    IPOrigen = row["IPOrigen"] == DBNull.Value ? "—" : row["IPOrigen"].ToString()
                });
            }
            return lista;
        }

        public List<string> ObtenerUsuariosDistintos()
        {
            SqlCommand cmd = new SqlCommand
            {
                CommandText = @"SELECT DISTINCT ISNULL(u.NombreUsuario,'Sistema') AS NombreUsuario
                         FROM Bitacora b LEFT JOIN Usuario u ON b.IDUsuario = u.IDUsuario
                         ORDER BY NombreUsuario",
                CommandType = CommandType.Text
            };
            return dalGeneral.EjecutarDataTable(cmd).Rows.Cast<DataRow>()
                .Select(r => r["NombreUsuario"].ToString()).ToList();
        }

        public List<string> ObtenerCriticidadesDistintas()
        {
            SqlCommand cmd = new SqlCommand
            {
                CommandText = "SELECT DISTINCT Criticidad FROM TipoEventoBitacora WHERE Estado = 1 ORDER BY Criticidad",
                CommandType = CommandType.Text
            };
            return dalGeneral.EjecutarDataTable(cmd).Rows.Cast<DataRow>()
                .Select(r => r["Criticidad"].ToString()).ToList();
        }

        public List<string> ObtenerModulosDistintos()
        {
            SqlCommand cmd = new SqlCommand
            {
                CommandText = "SELECT DISTINCT Modulo FROM TipoEventoBitacora WHERE Estado = 1 ORDER BY Modulo",
                CommandType = CommandType.Text
            };
            return dalGeneral.EjecutarDataTable(cmd).Rows.Cast<DataRow>()
                .Select(r => r["Modulo"].ToString()).ToList();
        }




    }
}
