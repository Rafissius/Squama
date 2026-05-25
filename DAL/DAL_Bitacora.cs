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
    }
}
