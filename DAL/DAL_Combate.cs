using BE;
using System;
using System.Data;
using System.Data.SqlClient;

namespace DAL
{
    public class DAL_Combate
    {
        private readonly DAL_General _dal = new DAL_General();

        public int ObtenerIDResultado(string nombre)
        {
            SqlCommand cmd = new SqlCommand(
                "SELECT IDResultadoCombate FROM ResultadoCombate WHERE Nombre = @Nombre");
            cmd.Parameters.AddWithValue("@Nombre", nombre);

            object resultado = _dal.EjecutarScalar(cmd);
            if (resultado == null || resultado == DBNull.Value)
                throw new Exception("No existe un ResultadoCombate con nombre: " + nombre);

            return Convert.ToInt32(resultado);
        }

        public int RegistrarCombate(BE_Combate combate)
        {
            SqlCommand cmd = new SqlCommand(@"
                INSERT INTO Combate
                    (IDPersonajeAtacante, IDPersonajeDefensor, IDResultadoCombate, FechaCombate,
                     CopasAtacanteAntes, CopasAtacanteDespues, VariacionCopas, ExperienciaGanada, Estado)
                VALUES
                    (@IDPersonajeAtacante, @IDPersonajeDefensor, @IDResultadoCombate, @FechaCombate,
                     @CopasAntes, @CopasDespues, @VariacionCopas, @ExperienciaGanada, 1);
                SELECT SCOPE_IDENTITY();");

            cmd.Parameters.AddWithValue("@IDPersonajeAtacante", combate.IDPersonajeAtacante);
            cmd.Parameters.AddWithValue("@IDPersonajeDefensor", combate.IDPersonajeDefensor);
            cmd.Parameters.AddWithValue("@IDResultadoCombate", combate.IDResultadoCombate);
            cmd.Parameters.AddWithValue("@FechaCombate", combate.FechaCombate);
            cmd.Parameters.AddWithValue("@CopasAntes", combate.CopasAtacanteAntes);
            cmd.Parameters.AddWithValue("@CopasDespues", combate.CopasAtacanteDespues);
            cmd.Parameters.AddWithValue("@VariacionCopas", combate.VariacionCopas);
            cmd.Parameters.AddWithValue("@ExperienciaGanada", combate.ExperienciaGanada);

            object idGenerado = _dal.EjecutarScalar(cmd);
            return Convert.ToInt32(idGenerado);
        }

        public BE_Combate ObtenerPorId(int idCombate)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT IDCombate, IDPersonajeAtacante, IDPersonajeDefensor, IDResultadoCombate,
                       FechaCombate, CopasAtacanteAntes, CopasAtacanteDespues, VariacionCopas,
                       ExperienciaGanada, Estado
                FROM Combate
                WHERE IDCombate = @IDCombate");
            cmd.Parameters.AddWithValue("@IDCombate", idCombate);

            DataTable dt = _dal.EjecutarDataTable(cmd);
            if (dt.Rows.Count == 0)
                return null;

            DataRow row = dt.Rows[0];
            return new BE_Combate
            {
                IDCombate = Convert.ToInt32(row["IDCombate"]),
                IDPersonajeAtacante = Convert.ToInt32(row["IDPersonajeAtacante"]),
                IDPersonajeDefensor = Convert.ToInt32(row["IDPersonajeDefensor"]),
                IDResultadoCombate = Convert.ToInt32(row["IDResultadoCombate"]),
                FechaCombate = Convert.ToDateTime(row["FechaCombate"]),
                CopasAtacanteAntes = Convert.ToInt32(row["CopasAtacanteAntes"]),
                CopasAtacanteDespues = Convert.ToInt32(row["CopasAtacanteDespues"]),
                VariacionCopas = Convert.ToInt32(row["VariacionCopas"]),
                ExperienciaGanada = Convert.ToInt32(row["ExperienciaGanada"]),
                Estado = Convert.ToInt32(row["Estado"])
            };
        }
    }
}
