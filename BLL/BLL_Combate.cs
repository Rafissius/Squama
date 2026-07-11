using BE;
using DAL;
using System;
using System.Linq;

namespace BLL
{
    public class BLL_Combate
    {
        private readonly DAL_Combate dal = new DAL_Combate();
        private readonly DAL_Personaje dalPersonaje = new DAL_Personaje();

        //PROTOTIPOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO
        private const int VARIACION_ALEATORIA_PORCENTAJE = 20; // ±20%
        private const int COPAS_POR_VICTORIA = 10;
        private const int COPAS_PERDIDAS_POR_DERROTA = 5;
        private const int XP_BASE_POR_VICTORIA = 30;
        private const int XP_POR_NIVEL_RIVAL = 5;

        
        private static readonly object _rngLock = new object();
        private static readonly Random _rng = new Random();

        public BE_ResultadoCombateVista PelearContraRival(int idUsuarioAtacante, int idPersonajeDefensor)
        {
            var bllPersonaje = new BLL_Personaje();

            BE_Personaje atacante = bllPersonaje.ObtenerPorUsuario(idUsuarioAtacante);
            if (atacante == null)
                throw new Exception("No tenés un personaje todavía.");

            if (atacante.IDPersonaje == idPersonajeDefensor)
                throw new Exception("No podés pelear contra vos mismo.");

            BE_Personaje defensor = dalPersonaje.ObtenerPorId(idPersonajeDefensor);
            if (defensor == null)
                throw new Exception("El rival ya no existe.");

            // Mismo filtro que ObtenerRivales: nunca se puede atacar a un Admin/Webmaster,
            // aunque el request se arme a mano con un IDPersonaje que no está en la lista.
            if (!dalPersonaje.EsPersonajeDeJugador(idPersonajeDefensor))
                throw new Exception("Ese personaje no puede ser atacado.");

            int poderAtacante = CalcularPoder(bllPersonaje.ObtenerEstadisticas(atacante.IDPersonaje));
            int poderDefensor = CalcularPoder(bllPersonaje.ObtenerEstadisticas(defensor.IDPersonaje));

            bool gano = poderAtacante >= poderDefensor;

            int copasAntes = atacante.CopasArena;
            int variacionCopas = gano ? COPAS_POR_VICTORIA : -COPAS_PERDIDAS_POR_DERROTA;
            int copasDespues = Math.Max(0, copasAntes + variacionCopas);
            int experienciaGanada = gano ? XP_BASE_POR_VICTORIA + defensor.Nivel * XP_POR_NIVEL_RIVAL : 0;

            dalPersonaje.ActualizarStatsArena(atacante.IDPersonaje, copasDespues, gano ? 1 : 0, gano ? 0 : 1);

            if (gano)
                bllPersonaje.GanarExperiencia(atacante.IDPersonaje, experienciaGanada);

            int idResultado = dal.ObtenerIDResultado(gano ? "Victoria" : "Derrota");

            BE_Combate combate = new BE_Combate
            {
                IDPersonajeAtacante = atacante.IDPersonaje,
                IDPersonajeDefensor = defensor.IDPersonaje,
                IDResultadoCombate = idResultado,
                FechaCombate = DateTime.Now,
                CopasAtacanteAntes = copasAntes,
                CopasAtacanteDespues = copasDespues,
                VariacionCopas = variacionCopas,
                ExperienciaGanada = experienciaGanada
            };
            int idCombate = dal.RegistrarCombate(combate);

            return new BE_ResultadoCombateVista
            {
                IDCombate = idCombate,
                Gano = gano,
                NombreAtacante = atacante.Nombre,
                NombreDefensor = defensor.Nombre,
                NivelAtacante = atacante.Nivel,
                NivelDefensor = defensor.Nivel,
                PoderAtacante = poderAtacante,
                PoderDefensor = poderDefensor,
                ExperienciaGanada = experienciaGanada,
                CopasAntes = copasAntes,
                CopasDespues = copasDespues
            };
        }

        // Para ArenaVictoria.aspx: reconstruye el resultado desde un combate ya registrado.
        // Devuelve null si el combate no existe o no pertenece al usuario logueado (el
        // caller debe redirigir en ese caso, no mostrar el resultado de otro por URL).
        // PoderAtacante/PoderDefensor no quedan guardados en Combate, así que viajan en 0
        // acá (no se recalculan con stats actuales para no mostrar un valor engañoso).
        public BE_ResultadoCombateVista ObtenerCombateParaMostrar(int idCombate, int idUsuarioActual)
        {
            BE_Combate combate = dal.ObtenerPorId(idCombate);
            if (combate == null)
                return null;

            BE_Personaje atacante = dalPersonaje.ObtenerPorId(combate.IDPersonajeAtacante);
            if (atacante == null || atacante.IDUsuario != idUsuarioActual)
                return null;

            BE_Personaje defensor = dalPersonaje.ObtenerPorId(combate.IDPersonajeDefensor);
            int idResultadoVictoria = dal.ObtenerIDResultado("Victoria");

            return new BE_ResultadoCombateVista
            {
                IDCombate = combate.IDCombate,
                Gano = combate.IDResultadoCombate == idResultadoVictoria,
                NombreAtacante = atacante.Nombre,
                NombreDefensor = defensor != null ? defensor.Nombre : "Rival",
                NivelAtacante = atacante.Nivel,
                NivelDefensor = defensor != null ? defensor.Nivel : 0,
                PoderAtacante = 0,
                PoderDefensor = 0,
                ExperienciaGanada = combate.ExperienciaGanada,
                CopasAntes = combate.CopasAtacanteAntes,
                CopasDespues = combate.CopasAtacanteDespues
            };
        }

        private int CalcularPoder(System.Collections.Generic.List<BE_PersonajeEstadisticaVista> estadisticas)
        {
            int poderBase = estadisticas.Sum(e => e.ValorBase);
            double factorAleatorio = 1.0 + SiguienteAleatorio(-VARIACION_ALEATORIA_PORCENTAJE, VARIACION_ALEATORIA_PORCENTAJE) / 100.0;
            return (int)Math.Round(poderBase * factorAleatorio);
        }

        private static int SiguienteAleatorio(int minInclusive, int maxInclusive)
        {
            lock (_rngLock) { return _rng.Next(minInclusive, maxInclusive + 1); }
        }
    }
}
