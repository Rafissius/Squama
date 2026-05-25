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
                )";

            cmd.CommandType = CommandType.Text;

            cmd.Parameters.Add("@IDUsuario", SqlDbType.Int).Value =
                evento.IDUsuario.HasValue ? (object)evento.IDUsuario.Value : DBNull.Value;

            cmd.Parameters.Add("@IDTipoEventoBitacora", SqlDbType.Int).Value = evento.IDTipoEventoBitacora;
            cmd.Parameters.Add("@FechaEvento", SqlDbType.DateTime).Value = evento.FechaEvento;
            cmd.Parameters.Add("@Descripcion", SqlDbType.VarChar, 500).Value = evento.Descripcion;

            cmd.Parameters.Add("@IPOrigen", SqlDbType.VarChar, 45).Value =
                string.IsNullOrWhiteSpace(evento.IPOrigen)
                ? (object)DBNull.Value
                : evento.IPOrigen;

            dalGeneral.EjecutarNonQuery(cmd);
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








    }
}
