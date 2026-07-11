using BE;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace DAL
{
    public class DAL_DigitoVerificador
    {
        private readonly DAL_General _dal = new DAL_General();

        public string ObtenerDVH(string nombreTabla, int idRegistro)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = $@"
                SELECT ValorDigito FROM {nombreTabla}DV
                WHERE TipoDigito = 'DVH' AND IDRegistro = @IDRegistro";
            cmd.Parameters.Add("@IDRegistro", SqlDbType.Int).Value = idRegistro;

            object resultado = _dal.EjecutarScalar(cmd);
            return resultado == null || resultado == DBNull.Value ? null : resultado.ToString();
        }

        public string ObtenerDVV(string nombreTabla, string nombreAtributo)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = $@"
                SELECT ValorDigito FROM {nombreTabla}DV
                WHERE TipoDigito = 'DVV' AND NombreAtributo = @NombreAtributo";
            cmd.Parameters.Add("@NombreAtributo", SqlDbType.VarChar, 100).Value = nombreAtributo;

            object resultado = _dal.EjecutarScalar(cmd);
            return resultado == null || resultado == DBNull.Value ? null : resultado.ToString();
        }

        public void ReemplazarDVH(string nombreTabla, int idRegistro, string valorDigito)
        {
            string tablaDV = nombreTabla + "DV";

            SqlCommand cmdDelete = new SqlCommand();
            cmdDelete.CommandText = $@"
                DELETE FROM {tablaDV}
                WHERE TipoDigito = 'DVH' AND IDRegistro = @IDRegistro";
            cmdDelete.Parameters.Add("@IDRegistro", SqlDbType.Int).Value = idRegistro;

            SqlCommand cmdInsert = new SqlCommand();
            cmdInsert.CommandText = $@"
                INSERT INTO {tablaDV} (TipoDigito, IDRegistro, NombreAtributo, ValorDigito, FechaCalculo)
                VALUES ('DVH', @IDRegistro, NULL, @ValorDigito, @FechaCalculo)";
            cmdInsert.Parameters.Add("@IDRegistro", SqlDbType.Int).Value = idRegistro;
            cmdInsert.Parameters.Add("@ValorDigito", SqlDbType.VarChar, 255).Value = valorDigito;
            cmdInsert.Parameters.Add("@FechaCalculo", SqlDbType.DateTime).Value = DateTime.Now;

            _dal.EjecutarEnTransaccion(new List<SqlCommand> { cmdDelete, cmdInsert });
        }

        public void ReemplazarDVV(string nombreTabla, string nombreAtributo, string valorDigito)
        {
            string tablaDV = nombreTabla + "DV";

            SqlCommand cmdDelete = new SqlCommand();
            cmdDelete.CommandText = $@"
                DELETE FROM {tablaDV}
                WHERE TipoDigito = 'DVV' AND NombreAtributo = @NombreAtributo";
            cmdDelete.Parameters.Add("@NombreAtributo", SqlDbType.VarChar, 100).Value = nombreAtributo;

            SqlCommand cmdInsert = new SqlCommand();
            cmdInsert.CommandText = $@"
                INSERT INTO {tablaDV} (TipoDigito, IDRegistro, NombreAtributo, ValorDigito, FechaCalculo)
                VALUES ('DVV', NULL, @NombreAtributo, @ValorDigito, @FechaCalculo)";
            cmdInsert.Parameters.Add("@NombreAtributo", SqlDbType.VarChar, 100).Value = nombreAtributo;
            cmdInsert.Parameters.Add("@ValorDigito", SqlDbType.VarChar, 255).Value = valorDigito;
            cmdInsert.Parameters.Add("@FechaCalculo", SqlDbType.DateTime).Value = DateTime.Now;

            _dal.EjecutarEnTransaccion(new List<SqlCommand> { cmdDelete, cmdInsert });
        }

        public DataTable ObtenerTodosLosRegistros(string nombreTabla)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = $"SELECT * FROM {nombreTabla}";
            return _dal.EjecutarDataTable(cmd);
        }

        // USO: CalcularYGuardarDVH releé la fila por este método en vez de hashear el objeto
        // en memoria — ver Contexto.md, "Causa raíz encontrada y reproducida (2026-07-10)".
        public DataRow ObtenerFilaPorId(string nombreTabla, int idRegistro)
        {
            string nombrePK = "ID" + nombreTabla;

            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = $"SELECT * FROM {nombreTabla} WHERE {nombrePK} = @IDRegistro";
            cmd.Parameters.Add("@IDRegistro", SqlDbType.Int).Value = idRegistro;

            DataTable dt = _dal.EjecutarDataTable(cmd);
            return dt.Rows.Count > 0 ? dt.Rows[0] : null;
        }

        // nombreColumna proviene de reflection (PropertyInfo.Name) sobre los BE registrados, nunca de input externo.
        public DataTable ObtenerValoresDeColumna(string nombreTabla, string nombreColumna)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = $"SELECT {nombreColumna} FROM {nombreTabla} ORDER BY ID{nombreTabla}";
            return _dal.EjecutarDataTable(cmd);
        }

        public void RegistrarInconsistencia(string nombreTabla, int? idRegistro, string nombreAtributo,
                                            string tipoDigito, string valorEsperado, string valorCalculado,
                                            int? idUsuarioWebmaster)
        {
            // Upsert por (Tabla, Registro, Atributo, Tipo) sobre la fila pendiente (Estado=1) más
            // reciente, si existe:
            //   - Si el valor calculado no cambió desde la última detección: no se toca (evita
            //     que cada verificación periódica agregue una fila nueva del mismo problema).
            //   - Si cambió (la fila mutó de nuevo, o el problema pendiente es en realidad otro
            //     valor distinto al que se logueó originalmente): se actualiza esa misma fila con
            //     el valor y la fecha nuevos, en vez de insertar una fila aparte. Necesario porque
            //     el DVV es tabla-completa: dos causas distintas (ej. el email de dos usuarios
            //     distintos) comparten la misma clave (Tabla, Atributo, Tipo) y no deben quedar
            //     enmascaradas una a la otra.
            int? idPendiente = ObtenerIdInconsistenciaPendiente(nombreTabla, idRegistro, nombreAtributo, tipoDigito, out string valorCalculadoPrevio);

            if (idPendiente.HasValue)
            {
                if (string.Equals(valorCalculadoPrevio, valorCalculado, StringComparison.OrdinalIgnoreCase))
                    return;

                SqlCommand cmdUpdate = new SqlCommand();
                cmdUpdate.CommandText = @"
                    UPDATE InconsistenciaIntegridad
                    SET ValorCalculado = @ValorCalculado, FechaDeteccion = @FechaDeteccion
                    WHERE IDInconsistenciaIntegridad = @IDInconsistenciaIntegridad";
                cmdUpdate.Parameters.Add("@ValorCalculado", SqlDbType.VarChar, 255).Value = valorCalculado;
                cmdUpdate.Parameters.Add("@FechaDeteccion", SqlDbType.DateTime).Value = DateTime.Now;
                cmdUpdate.Parameters.Add("@IDInconsistenciaIntegridad", SqlDbType.Int).Value = idPendiente.Value;

                _dal.EjecutarNonQuery(cmdUpdate);
                return;
            }

            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = @"
                INSERT INTO InconsistenciaIntegridad
                (NombreTabla, IDRegistro, NombreAtributo, TipoDigito, ValorEsperado, ValorCalculado,
                 FechaDeteccion, IDUsuarioWebmaster, AccionTomada, Estado)
                VALUES
                (@NombreTabla, @IDRegistro, @NombreAtributo, @TipoDigito, @ValorEsperado, @ValorCalculado,
                 @FechaDeteccion, @IDUsuarioWebmaster, @AccionTomada, @Estado)";

            cmd.Parameters.Add("@NombreTabla", SqlDbType.VarChar, 100).Value = nombreTabla;
            cmd.Parameters.Add("@IDRegistro", SqlDbType.Int).Value =
                idRegistro.HasValue ? (object)idRegistro.Value : DBNull.Value;
            cmd.Parameters.Add("@NombreAtributo", SqlDbType.VarChar, 100).Value =
                (object)nombreAtributo ?? DBNull.Value;
            cmd.Parameters.Add("@TipoDigito", SqlDbType.VarChar, 3).Value = tipoDigito;
            cmd.Parameters.Add("@ValorEsperado", SqlDbType.VarChar, 255).Value = valorEsperado;
            cmd.Parameters.Add("@ValorCalculado", SqlDbType.VarChar, 255).Value = valorCalculado;
            cmd.Parameters.Add("@FechaDeteccion", SqlDbType.DateTime).Value = DateTime.Now;
            cmd.Parameters.Add("@IDUsuarioWebmaster", SqlDbType.Int).Value =
                idUsuarioWebmaster.HasValue ? (object)idUsuarioWebmaster.Value : DBNull.Value;
            cmd.Parameters.Add("@AccionTomada", SqlDbType.VarChar, 100).Value = DBNull.Value;
            cmd.Parameters.Add("@Estado", SqlDbType.TinyInt).Value = 1;

            _dal.EjecutarNonQuery(cmd);
        }

        private int? ObtenerIdInconsistenciaPendiente(string nombreTabla, int? idRegistro, string nombreAtributo,
                                                       string tipoDigito, out string valorCalculadoPrevio)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = @"
                SELECT TOP (1) IDInconsistenciaIntegridad, ValorCalculado FROM InconsistenciaIntegridad
                WHERE NombreTabla = @NombreTabla
                  AND TipoDigito = @TipoDigito
                  AND Estado = 1
                  AND ISNULL(IDRegistro, -1) = ISNULL(@IDRegistro, -1)
                  AND ISNULL(NombreAtributo, '') = ISNULL(@NombreAtributo, '')
                ORDER BY FechaDeteccion DESC";

            cmd.Parameters.Add("@NombreTabla", SqlDbType.VarChar, 100).Value = nombreTabla;
            cmd.Parameters.Add("@TipoDigito", SqlDbType.VarChar, 3).Value = tipoDigito;
            cmd.Parameters.Add("@IDRegistro", SqlDbType.Int).Value =
                idRegistro.HasValue ? (object)idRegistro.Value : DBNull.Value;
            cmd.Parameters.Add("@NombreAtributo", SqlDbType.VarChar, 100).Value =
                (object)nombreAtributo ?? DBNull.Value;

            DataTable dt = _dal.EjecutarDataTable(cmd);

            if (dt.Rows.Count == 0)
            {
                valorCalculadoPrevio = null;
                return null;
            }

            valorCalculadoPrevio = dt.Rows[0]["ValorCalculado"].ToString();
            return Convert.ToInt32(dt.Rows[0]["IDInconsistenciaIntegridad"]);
        }

        // Se llama después de recalcular el DV de una tabla: todo lo que estaba marcado como
        // pendiente para esa tabla queda resuelto (el recálculo asume que los datos están bien).
        public void MarcarInconsistenciasResueltas(string nombreTabla, string accionTomada)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = @"
                UPDATE InconsistenciaIntegridad
                SET Estado = 2, AccionTomada = @AccionTomada
                WHERE NombreTabla = @NombreTabla AND Estado = 1";

            cmd.Parameters.Add("@NombreTabla", SqlDbType.VarChar, 100).Value = nombreTabla;
            cmd.Parameters.Add("@AccionTomada", SqlDbType.VarChar, 100).Value = accionTomada;

            _dal.EjecutarNonQuery(cmd);
        }

        public bool ObtenerEsWebmaster(int idUsuario)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = @"
                SELECT 1 FROM UsuarioRol ur
                JOIN Rol r ON ur.IDRol = r.IDRol
                WHERE ur.IDUsuario = @IDUsuario AND r.Nombre = 'Webmaster' AND ur.Estado = 1 AND r.Estado = 1";
            cmd.Parameters.Add("@IDUsuario", SqlDbType.Int).Value = idUsuario;

            object resultado = _dal.EjecutarScalar(cmd);
            return resultado != null && resultado != DBNull.Value;
        }

        public List<BE_InconsistenciaIntegridad> ObtenerUltimasInconsistencias(int cantidad)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = @"
                SELECT TOP (@Cantidad) IDInconsistenciaIntegridad, NombreTabla, IDRegistro, NombreAtributo,
                       TipoDigito, ValorEsperado, ValorCalculado, FechaDeteccion, IDUsuarioWebmaster,
                       AccionTomada, Estado
                FROM InconsistenciaIntegridad
                ORDER BY FechaDeteccion DESC";
            cmd.Parameters.Add("@Cantidad", SqlDbType.Int).Value = cantidad;

            DataTable dt = _dal.EjecutarDataTable(cmd);
            List<BE_InconsistenciaIntegridad> lista = new List<BE_InconsistenciaIntegridad>();

            foreach (DataRow row in dt.Rows)
            {
                lista.Add(new BE_InconsistenciaIntegridad
                {
                    IDInconsistenciaIntegridad = Convert.ToInt32(row["IDInconsistenciaIntegridad"]),
                    NombreTabla = row["NombreTabla"].ToString(),
                    IDRegistro = row["IDRegistro"] == DBNull.Value ? (int?)null : Convert.ToInt32(row["IDRegistro"]),
                    NombreAtributo = row["NombreAtributo"] == DBNull.Value ? null : row["NombreAtributo"].ToString(),
                    TipoDigito = row["TipoDigito"].ToString(),
                    ValorEsperado = row["ValorEsperado"].ToString(),
                    ValorCalculado = row["ValorCalculado"].ToString(),
                    FechaDeteccion = Convert.ToDateTime(row["FechaDeteccion"]),
                    IDUsuarioWebmaster = row["IDUsuarioWebmaster"] == DBNull.Value ? (int?)null : Convert.ToInt32(row["IDUsuarioWebmaster"]),
                    AccionTomada = row["AccionTomada"] == DBNull.Value ? null : row["AccionTomada"].ToString(),
                    Estado = Convert.ToByte(row["Estado"])
                });
            }

            return lista;
        }

        public List<string> ObtenerColumnasReales(string nombreTabla)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @NombreTabla";
            cmd.Parameters.Add("@NombreTabla", SqlDbType.VarChar, 128).Value = nombreTabla;

            DataTable dt = _dal.EjecutarDataTable(cmd);
            List<string> columnas = new List<string>();
            foreach (DataRow row in dt.Rows)
                columnas.Add(row["COLUMN_NAME"].ToString());
            return columnas;
        }

        // USO: tarjeta "Estado de tablas verificadas" en ResolverIntegridad.aspx.
        public int ObtenerCantidadRegistros(string nombreTabla)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = $"SELECT COUNT(*) FROM {nombreTabla}";
            return Convert.ToInt32(_dal.EjecutarScalar(cmd));
        }

        // USO: tarjeta "Estado de tablas verificadas" — si una tabla tiene alguna
        // inconsistencia pendiente (Estado=1), no solo las últimas 20 mostradas en la grilla.
        public int ObtenerCantidadInconsistenciasPendientes(string nombreTabla)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = @"
                SELECT COUNT(*) FROM InconsistenciaIntegridad
                WHERE NombreTabla = @NombreTabla AND Estado = 1";
            cmd.Parameters.Add("@NombreTabla", SqlDbType.VarChar, 100).Value = nombreTabla;
            return Convert.ToInt32(_dal.EjecutarScalar(cmd));
        }

        // USO: tarjetas "DVH con error" / "DVV con error" del resumen en ResolverIntegridad.aspx.
        public int ObtenerCantidadInconsistenciasPendientesPorTipo(string tipoDigito)
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = @"
                SELECT COUNT(*) FROM InconsistenciaIntegridad
                WHERE TipoDigito = @TipoDigito AND Estado = 1";
            cmd.Parameters.Add("@TipoDigito", SqlDbType.VarChar, 3).Value = tipoDigito;
            return Convert.ToInt32(_dal.EjecutarScalar(cmd));
        }

        // USO: RecalcularDVDeEntidad (recálculo manual del webmaster) — purga las entradas de
        // DVH cuyo registro ya no existe. Sin esto, "Recalcular todos los DV" nunca podía
        // resolver de verdad una "Eliminación": el bucle de recálculo solo reescribe el DVH de
        // filas que SÍ existen hoy, nunca borra el DVH de una fila que ya no está, así que la
        // próxima verificación la volvía a encontrar huérfana y la marcaba de nuevo, sin fin.
        public void EliminarDVHHuerfanos(string nombreTabla)
        {
            string tablaDV = nombreTabla + "DV";
            string nombrePK = "ID" + nombreTabla;

            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = $@"
                DELETE dv FROM {tablaDV} dv
                WHERE dv.TipoDigito = 'DVH'
                  AND NOT EXISTS (SELECT 1 FROM {nombreTabla} t WHERE t.{nombrePK} = dv.IDRegistro)";
            _dal.EjecutarNonQuery(cmd);
        }

        // USO: detección de "Eliminación" en la grilla de inconsistencias — chequeo inverso
        // (¿hay un DVH guardado cuyo registro ya no existe en la tabla real?). Antes de esto,
        // VerificarIntegridadTablaInterno solo recorría los registros reales y los comparaba
        // contra su DV, nunca al revés, así que un DELETE directo en la base pasaba
        // desapercibido salvo que además rompiera el DVV de alguna columna.
        public List<int> ObtenerIdsRegistroHuerfanos(string nombreTabla)
        {
            string tablaDV = nombreTabla + "DV";
            string nombrePK = "ID" + nombreTabla;

            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = $@"
                SELECT dv.IDRegistro
                FROM {tablaDV} dv
                WHERE dv.TipoDigito = 'DVH'
                  AND NOT EXISTS (SELECT 1 FROM {nombreTabla} t WHERE t.{nombrePK} = dv.IDRegistro)";

            DataTable dt = _dal.EjecutarDataTable(cmd);
            List<int> ids = new List<int>();
            foreach (DataRow row in dt.Rows)
                ids.Add(Convert.ToInt32(row["IDRegistro"]));
            return ids;
        }

        // USO: botón "Detalle" en la grilla de inconsistencias — valores actuales del
        // registro (para Inserción/Modificación; en Eliminación el registro ya no existe,
        // así que devuelve null y la UI solo avisa que fue eliminado, sin listar campos).
        public Dictionary<string, string> ObtenerValoresActuales(string nombreTabla, int idRegistro)
        {
            string nombrePK = "ID" + nombreTabla;

            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = $"SELECT * FROM {nombreTabla} WHERE {nombrePK} = @IDRegistro";
            cmd.Parameters.Add("@IDRegistro", SqlDbType.Int).Value = idRegistro;

            DataTable dt = _dal.EjecutarDataTable(cmd);
            if (dt.Rows.Count == 0) return null;

            Dictionary<string, string> valores = new Dictionary<string, string>();
            DataRow fila = dt.Rows[0];
            foreach (DataColumn col in dt.Columns)
                valores[col.ColumnName] = fila[col] == DBNull.Value ? null : fila[col].ToString();
            return valores;
        }
    }
}
