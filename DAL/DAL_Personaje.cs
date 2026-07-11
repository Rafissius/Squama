using BE;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace DAL
{
    public class DAL_Personaje
    {
        private readonly DAL_General _dal = new DAL_General();

        // Atómico: 1 insert en Personaje + 5 inserts en PersonajeEstadistica en un solo
        // batch T-SQL con BEGIN TRAN/COMMIT/ROLLBACK explícito. DAL_General.EjecutarEnTransaccion
        // no permite encadenar el ID generado del primer insert en los siguientes comandos del
        // mismo lote, por eso este método arma el batch como texto en vez de usarlo.
        // Devuelve el IDPersonaje generado. Estadistica no tiene columna Codigo, así que
        // el reparto se identifica por Nombre exacto ('Vida','Fuerza','Agilidad','Velocidad','Inteligencia').
        public int CrearPersonajeConEstadisticas(int idUsuario, string nombre, DateTime fechaCreacion,
            int experienciaSiguienteNivel,
            int valorVida, int valorFuerza, int valorAgilidad, int valorVelocidad, int valorInteligencia)
        {
            string query = @"
                DECLARE @IDPersonajeNuevo INT;

                BEGIN TRY
                    BEGIN TRANSACTION;

                    INSERT INTO Personaje
                        (IDUsuario, Nombre, Nivel, ExperienciaActual, ExperienciaSiguienteNivel,
                         CopasArena, VictoriasArena, DerrotasArena, FechaCreacion, Estado)
                    VALUES
                        (@IDUsuario, @Nombre, 1, 0, @ExperienciaSiguienteNivel,
                         0, 0, 0, @FechaCreacion, 1);

                    SET @IDPersonajeNuevo = SCOPE_IDENTITY();

                    INSERT INTO PersonajeEstadistica (IDPersonaje, IDEstadistica, ValorBase, FechaUltimaModificacion)
                    SELECT @IDPersonajeNuevo, IDEstadistica,
                        CASE Nombre
                            WHEN 'Vida' THEN @ValorVida
                            WHEN 'Fuerza' THEN @ValorFuerza
                            WHEN 'Agilidad' THEN @ValorAgilidad
                            WHEN 'Velocidad' THEN @ValorVelocidad
                            WHEN 'Inteligencia' THEN @ValorInteligencia
                        END,
                        @FechaCreacion
                    FROM Estadistica
                    WHERE Nombre IN ('Vida','Fuerza','Agilidad','Velocidad','Inteligencia');

                    COMMIT TRANSACTION;
                    SELECT @IDPersonajeNuevo;
                END TRY
                BEGIN CATCH
                    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
                    THROW;
                END CATCH";

            SqlCommand cmd = new SqlCommand(query);
            cmd.Parameters.AddWithValue("@IDUsuario", idUsuario);
            cmd.Parameters.AddWithValue("@Nombre", nombre);
            cmd.Parameters.AddWithValue("@FechaCreacion", fechaCreacion);
            cmd.Parameters.AddWithValue("@ExperienciaSiguienteNivel", experienciaSiguienteNivel);
            cmd.Parameters.AddWithValue("@ValorVida", valorVida);
            cmd.Parameters.AddWithValue("@ValorFuerza", valorFuerza);
            cmd.Parameters.AddWithValue("@ValorAgilidad", valorAgilidad);
            cmd.Parameters.AddWithValue("@ValorVelocidad", valorVelocidad);
            cmd.Parameters.AddWithValue("@ValorInteligencia", valorInteligencia);

            object resultado = _dal.EjecutarScalar(cmd);
            return Convert.ToInt32(resultado);
        }

        // null si el usuario todavía no tiene Personaje asignado.
        public BE_Personaje ObtenerPorUsuario(int idUsuario)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT IDPersonaje, IDUsuario, Nombre, Nivel, ExperienciaActual, ExperienciaSiguienteNivel,
                       CopasArena, VictoriasArena, DerrotasArena, FechaCreacion, Estado
                FROM Personaje
                WHERE IDUsuario = @IDUsuario");
            cmd.Parameters.AddWithValue("@IDUsuario", idUsuario);

            DataTable dt = _dal.EjecutarDataTable(cmd);
            if (dt.Rows.Count == 0)
                return null;

            return MapearPersonaje(dt.Rows[0]);
        }

        // null si no existe ese IDPersonaje (no debería pasar en uso normal).
        public BE_Personaje ObtenerPorId(int idPersonaje)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT IDPersonaje, IDUsuario, Nombre, Nivel, ExperienciaActual, ExperienciaSiguienteNivel,
                       CopasArena, VictoriasArena, DerrotasArena, FechaCreacion, Estado
                FROM Personaje
                WHERE IDPersonaje = @IDPersonaje");
            cmd.Parameters.AddWithValue("@IDPersonaje", idPersonaje);

            DataTable dt = _dal.EjecutarDataTable(cmd);
            if (dt.Rows.Count == 0)
                return null;

            return MapearPersonaje(dt.Rows[0]);
        }

        private static BE_Personaje MapearPersonaje(DataRow row)
        {
            return new BE_Personaje
            {
                IDPersonaje = Convert.ToInt32(row["IDPersonaje"]),
                IDUsuario = Convert.ToInt32(row["IDUsuario"]),
                Nombre = row["Nombre"].ToString(),
                Nivel = Convert.ToInt32(row["Nivel"]),
                ExperienciaActual = Convert.ToInt32(row["ExperienciaActual"]),
                ExperienciaSiguienteNivel = Convert.ToInt32(row["ExperienciaSiguienteNivel"]),
                CopasArena = Convert.ToInt32(row["CopasArena"]),
                VictoriasArena = Convert.ToInt32(row["VictoriasArena"]),
                DerrotasArena = Convert.ToInt32(row["DerrotasArena"]),
                FechaCreacion = Convert.ToDateTime(row["FechaCreacion"]),
                Estado = Convert.ToInt32(row["Estado"])
            };
        }

        public List<BE_PersonajeEstadisticaVista> ObtenerEstadisticas(int idPersonaje)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT e.IDEstadistica, e.Nombre, pe.ValorBase
                FROM PersonajeEstadistica pe
                INNER JOIN Estadistica e ON e.IDEstadistica = pe.IDEstadistica
                WHERE pe.IDPersonaje = @IDPersonaje
                ORDER BY e.IDEstadistica");
            cmd.Parameters.AddWithValue("@IDPersonaje", idPersonaje);

            DataTable dt = _dal.EjecutarDataTable(cmd);
            List<BE_PersonajeEstadisticaVista> lista = new List<BE_PersonajeEstadisticaVista>();

            foreach (DataRow row in dt.Rows)
            {
                lista.Add(new BE_PersonajeEstadisticaVista
                {
                    IDEstadistica = Convert.ToInt32(row["IDEstadistica"]),
                    Nombre = row["Nombre"].ToString(),
                    ValorBase = Convert.ToInt32(row["ValorBase"])
                });
            }

            return lista;
        }

        // Usado por BLL_Combate.PelearContraRival para validar el defensor, además del
        // propio filtro de ObtenerRivales: sin esto, alguien podría forzar un ataque
        // directo contra un IDPersonaje de Admin/Webmaster armando el request a mano,
        // aunque esa cuenta nunca aparezca en la lista de rivales.
        public bool EsPersonajeDeJugador(int idPersonaje)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT COUNT(1)
                FROM Personaje p
                INNER JOIN UsuarioRol ur ON ur.IDUsuario = p.IDUsuario AND ur.Estado = 1
                INNER JOIN Rol r ON r.IDRol = ur.IDRol AND r.Nombre = 'Jugador'
                WHERE p.IDPersonaje = @IDPersonaje");
            cmd.Parameters.AddWithValue("@IDPersonaje", idPersonaje);

            object resultado = _dal.EjecutarScalar(cmd);
            return Convert.ToInt32(resultado) > 0;
        }

        // Candidatos a rival para la Arena: solo cuentas con rol Jugador (nunca
        // Admin/Webmaster, que tienen Personaje solo por el alta eager), excluyendo al
        // propio jugador. Ordena por cercanía de nivel (sin rango estricto: con pocas
        // cuentas reales en la base, un filtro estricto dejaría la grilla vacía).
        // LEFT JOIN a ClanMiembro/Clan porque el sistema de clanes ya tiene tablas
        // reales (vacías todavía, ningún jugador tiene clan aún).
        public List<BE_RivalCandidato> ObtenerRivales(int idPersonajeExcluir, int nivelReferencia, int cantidad)
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT TOP (@Cantidad)
                       p.IDPersonaje, p.Nombre, p.Nivel, p.CopasArena, p.VictoriasArena, p.DerrotasArena,
                       cl.Nombre AS Clan
                FROM Personaje p
                INNER JOIN Usuario u ON u.IDUsuario = p.IDUsuario
                INNER JOIN UsuarioRol ur ON ur.IDUsuario = u.IDUsuario AND ur.Estado = 1
                INNER JOIN Rol r ON r.IDRol = ur.IDRol AND r.Nombre = 'Jugador'
                LEFT JOIN ClanMiembro cm ON cm.IDPersonaje = p.IDPersonaje AND cm.Estado = 1
                LEFT JOIN Clan cl ON cl.IDClan = cm.IDClan AND cl.Estado = 1
                WHERE p.Estado = 1 AND p.IDPersonaje <> @IDPersonajeExcluir
                ORDER BY ABS(p.Nivel - @NivelReferencia), p.IDPersonaje");
            cmd.Parameters.AddWithValue("@Cantidad", cantidad);
            cmd.Parameters.AddWithValue("@IDPersonajeExcluir", idPersonajeExcluir);
            cmd.Parameters.AddWithValue("@NivelReferencia", nivelReferencia);

            DataTable dt = _dal.EjecutarDataTable(cmd);
            List<BE_RivalCandidato> lista = new List<BE_RivalCandidato>();

            foreach (DataRow row in dt.Rows)
            {
                lista.Add(new BE_RivalCandidato
                {
                    IDPersonaje = Convert.ToInt32(row["IDPersonaje"]),
                    Nombre = row["Nombre"].ToString(),
                    Nivel = Convert.ToInt32(row["Nivel"]),
                    CopasArena = Convert.ToInt32(row["CopasArena"]),
                    VictoriasArena = Convert.ToInt32(row["VictoriasArena"]),
                    DerrotasArena = Convert.ToInt32(row["DerrotasArena"]),
                    Clan = row["Clan"] == DBNull.Value ? null : row["Clan"].ToString()
                });
            }

            return lista;
        }

        // Solo estadísticas activas (Estado = 1) — mismo criterio de "activo/inactivo"
        // ya usado en Usuario.Estado.
        public List<BE_Estadistica> ObtenerTodasLasEstadisticas()
        {
            SqlCommand cmd = new SqlCommand(
                "SELECT IDEstadistica, Nombre, Descripcion, Estado FROM Estadistica WHERE Estado = 1 ORDER BY IDEstadistica");

            DataTable dt = _dal.EjecutarDataTable(cmd);
            List<BE_Estadistica> lista = new List<BE_Estadistica>();

            foreach (DataRow row in dt.Rows)
            {
                lista.Add(new BE_Estadistica
                {
                    IDEstadistica = Convert.ToInt32(row["IDEstadistica"]),
                    Nombre = row["Nombre"].ToString(),
                    Descripcion = row["Descripcion"] == DBNull.Value ? null : row["Descripcion"].ToString(),
                    Estado = Convert.ToInt32(row["Estado"])
                });
            }

            return lista;
        }

        // Comandos SIN ejecutar: BLL_Personaje.GanarExperiencia arma el lote completo
        // (potencialmente varios niveles cruzados de un solo salto de XP) y lo pasa una
        // sola vez a EjecutarLoteEnTransaccion, para que todo el salto sea atómico.
        public SqlCommand ComandoActualizarNivelYExperiencia(int idPersonaje, int nivel, int experienciaActual, int experienciaSiguienteNivel)
        {
            SqlCommand cmd = new SqlCommand(
                "UPDATE Personaje SET Nivel = @Nivel, ExperienciaActual = @ExperienciaActual, " +
                "ExperienciaSiguienteNivel = @ExperienciaSiguienteNivel WHERE IDPersonaje = @IDPersonaje");
            cmd.Parameters.AddWithValue("@Nivel", nivel);
            cmd.Parameters.AddWithValue("@ExperienciaActual", experienciaActual);
            cmd.Parameters.AddWithValue("@ExperienciaSiguienteNivel", experienciaSiguienteNivel);
            cmd.Parameters.AddWithValue("@IDPersonaje", idPersonaje);
            return cmd;
        }

        public SqlCommand ComandoSumarValorBase(int idPersonaje, int idEstadistica, int puntos, DateTime fecha)
        {
            SqlCommand cmd = new SqlCommand(
                "UPDATE PersonajeEstadistica SET ValorBase = ValorBase + @Puntos, FechaUltimaModificacion = @Fecha " +
                "WHERE IDPersonaje = @IDPersonaje AND IDEstadistica = @IDEstadistica");
            cmd.Parameters.AddWithValue("@Puntos", puntos);
            cmd.Parameters.AddWithValue("@Fecha", fecha);
            cmd.Parameters.AddWithValue("@IDPersonaje", idPersonaje);
            cmd.Parameters.AddWithValue("@IDEstadistica", idEstadistica);
            return cmd;
        }

        public SqlCommand ComandoInsertarMejoraNivel(int idPersonaje, int nivelAlAplicar, int idEstadistica, int valorIncremento, DateTime fecha)
        {
            SqlCommand cmd = new SqlCommand(@"
                INSERT INTO MejoraNivelPersonaje (IDPersonaje, NivelAlAplicar, IDEstadistica, ValorIncremento, FechaAplicacion)
                VALUES (@IDPersonaje, @NivelAlAplicar, @IDEstadistica, @ValorIncremento, @Fecha)");
            cmd.Parameters.AddWithValue("@IDPersonaje", idPersonaje);
            cmd.Parameters.AddWithValue("@NivelAlAplicar", nivelAlAplicar);
            cmd.Parameters.AddWithValue("@IDEstadistica", idEstadistica);
            cmd.Parameters.AddWithValue("@ValorIncremento", valorIncremento);
            cmd.Parameters.AddWithValue("@Fecha", fecha);
            return cmd;
        }

        public void EjecutarLoteEnTransaccion(List<SqlCommand> comandos) => _dal.EjecutarEnTransaccion(comandos);

        // Actualiza copas/victorias/derrotas de arena tras un combate. Solo se llama sobre
        // el atacante (el defensor no sufre cambios en este prototipo, ver Contexto.md).
        public void ActualizarStatsArena(int idPersonaje, int nuevasCopas, int incrementoVictorias, int incrementoDerrotas)
        {
            SqlCommand cmd = new SqlCommand(@"
                UPDATE Personaje
                SET CopasArena = @CopasArena,
                    VictoriasArena = VictoriasArena + @IncrementoVictorias,
                    DerrotasArena = DerrotasArena + @IncrementoDerrotas
                WHERE IDPersonaje = @IDPersonaje");
            cmd.Parameters.AddWithValue("@CopasArena", nuevasCopas);
            cmd.Parameters.AddWithValue("@IncrementoVictorias", incrementoVictorias);
            cmd.Parameters.AddWithValue("@IncrementoDerrotas", incrementoDerrotas);
            cmd.Parameters.AddWithValue("@IDPersonaje", idPersonaje);
            _dal.EjecutarNonQuery(cmd);
        }
    }
}
