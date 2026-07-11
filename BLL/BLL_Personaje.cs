using BE;
using DAL;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;

namespace BLL
{
    public class BLL_Personaje
    {
        private readonly DAL_Personaje dal = new DAL_Personaje();

        private const int PUNTOS_INICIALES_TOTAL = 20;
        private const int PUNTOS_BONUS_POR_NIVEL = 5;
        //PROTOTIPOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO
        
        private static readonly ConcurrentDictionary<int, object> _locksPersonaje
            = new ConcurrentDictionary<int, object>();

        
        private static readonly object _rngLock = new object();
        private static readonly Random _rng = new Random();

      
        public int CrearPersonaje(int idUsuario, string nombre)
        {
            List<BE_Estadistica> estadisticas = dal.ObtenerTodasLasEstadisticas();
            List<string> nombresEstadisticas = estadisticas.Select(e => e.Nombre).ToList();
            Dictionary<string, int> reparto = RepartirPuntosIniciales(nombresEstadisticas);

            return dal.CrearPersonajeConEstadisticas(
                idUsuario, nombre, DateTime.Now, XPParaSiguienteNivel(1),
                reparto["Vida"], reparto["Fuerza"], reparto["Agilidad"], reparto["Velocidad"], reparto["Inteligencia"]);
        }

        // null si el usuario todavía no tiene Personaje asignado.
        public BE_Personaje ObtenerPorUsuario(int idUsuario)
        {
            return dal.ObtenerPorUsuario(idUsuario);
        }

        // Backfill perezoso "crear si falta" para cuentas preexistentes (creadas antes
        // de este feature): se llama desde HomeJugador.aspx.cs en cada Page_Load.
        // Da igual el rol actual de la cuenta (jugador/admin/webmaster) — el Personaje
        // ya existe desde el alta eager en cualquier caso, así que esto solo entra en
        // juego para cuentas viejas sin Personaje todavía.
        public BE_Personaje ObtenerOCrearPorUsuario(int idUsuario, string nombreParaCrear)
        {
            BE_Personaje personaje = dal.ObtenerPorUsuario(idUsuario);
            if (personaje != null)
                return personaje;

            try
            {
                int idPersonaje = CrearPersonaje(idUsuario, nombreParaCrear);
                return dal.ObtenerPorId(idPersonaje);
            }
            catch (SqlException ex) when (ex.Number == 2627 || ex.Number == 2601)
            {
                // Carrera: otro request ya creó el Personaje de este usuario entre el
                // SELECT de arriba y este INSERT (dos pestañas, doble click). Se
                // devuelve la fila que ganó la carrera en vez de reventar la página.
                return dal.ObtenerPorUsuario(idUsuario);
            }
        }

        public List<BE_PersonajeEstadisticaVista> ObtenerEstadisticas(int idPersonaje)
        {
            return dal.ObtenerEstadisticas(idPersonaje);
        }

        // Suma XP y aplica tantos saltos de nivel como correspondan (una ganancia grande
        // puede cruzar varios niveles de un solo golpe). Todo el lote (updates + historial
        // de mejoras) se arma en C# y se ejecuta una sola vez en una única transacción,
        // para que un salto de varios niveles sea atómico de punta a punta.
        public void GanarExperiencia(int idPersonaje, int cantidadXP)
        {
            if (cantidadXP <= 0)
                return;

            lock (_locksPersonaje.GetOrAdd(idPersonaje, _ => new object()))
            {
                BE_Personaje personaje = dal.ObtenerPorId(idPersonaje);
                if (personaje == null)
                    throw new Exception("El personaje no existe.");

                List<BE_Estadistica> estadisticas = dal.ObtenerTodasLasEstadisticas();
                List<string> nombresEstadisticas = estadisticas.Select(e => e.Nombre).ToList();

                int nivelActual = personaje.Nivel;
                int experienciaAcumulada = personaje.ExperienciaActual + cantidadXP;
                DateTime ahora = DateTime.Now;

                var comandos = new List<SqlCommand>();

                while (experienciaAcumulada >= XPParaSiguienteNivel(nivelActual))
                {
                    experienciaAcumulada -= XPParaSiguienteNivel(nivelActual);
                    nivelActual++;

                    Dictionary<string, int> bonus = RepartirPuntosBonus(nombresEstadisticas);

                    foreach (BE_Estadistica est in estadisticas)
                    {
                        int puntos = bonus[est.Nombre];
                        if (puntos <= 0)
                            continue; // sin piso: una estadística puede no recibir nada ese nivel

                        comandos.Add(dal.ComandoSumarValorBase(idPersonaje, est.IDEstadistica, puntos, ahora));
                        comandos.Add(dal.ComandoInsertarMejoraNivel(idPersonaje, nivelActual, est.IDEstadistica, puntos, ahora));
                    }
                }

                comandos.Add(dal.ComandoActualizarNivelYExperiencia(
                    idPersonaje, nivelActual, experienciaAcumulada, XPParaSiguienteNivel(nivelActual)));

                dal.EjecutarLoteEnTransaccion(comandos);
            }
        }

        private const int CANTIDAD_RIVALES = 6;

        // Rivales reales para la Arena: siempre otros jugadores (nunca Admin/Webmaster,
        // filtrado ya en el DAL), nunca uno mismo. Sin combate real implementado todavía
        // (Combate está vacía), así que Racha se muestra neutra en vez de inventar un dato.
        public List<BE_RivalArenaVista> ObtenerRivales(int idUsuarioActual, string nombreUsuarioActual)
        {
            BE_Personaje miPersonaje = ObtenerOCrearPorUsuario(idUsuarioActual, nombreUsuarioActual);
            List<BE_RivalCandidato> candidatos = dal.ObtenerRivales(miPersonaje.IDPersonaje, miPersonaje.Nivel, CANTIDAD_RIVALES);

            List<BE_RivalArenaVista> resultado = new List<BE_RivalArenaVista>();
            foreach (BE_RivalCandidato candidato in candidatos)
            {
                int combates = candidato.VictoriasArena + candidato.DerrotasArena;
                int porcentaje = combates > 0 ? (int)Math.Round(candidato.VictoriasArena * 100.0 / combates) : 0;

                resultado.Add(new BE_RivalArenaVista
                {
                    IDPersonaje = candidato.IDPersonaje,
                    Nombre = candidato.Nombre,
                    Nivel = candidato.Nivel,
                    Clan = candidato.Clan ?? "Sin clan",
                    Rango = CalcularRango(candidato.CopasArena),
                    PorcentajeVictorias = porcentaje + "%",
                    ColorPorcentajeVictorias = CalcularColorVictorias(combates, porcentaje),
                    Combates = combates,
                    Racha = "—",
                    ColorRacha = "v-blue",
                    Estadisticas = MapearEstadisticas(dal.ObtenerEstadisticas(candidato.IDPersonaje))
                });
            }

            return resultado;
        }

        // Umbrales simples por CopasArena, fáciles de ajustar más adelante — hoy
        // CopasArena=0 para todos (nadie peleó todavía), así que todos caen en "bronce".
        private static string CalcularRango(int copasArena)
        {
            if (copasArena >= 600) return "diamante";
            if (copasArena >= 300) return "oro";
            if (copasArena >= 100) return "plata";
            return "bronce";
        }

        private static string CalcularColorVictorias(int combates, int porcentaje)
        {
            if (combates == 0) return "v-blue";
            if (porcentaje >= 60) return "v-red";
            if (porcentaje >= 40) return "v-ora";
            return "v-green";
        }

        private static Dictionary<string, int> MapearEstadisticas(List<BE_PersonajeEstadisticaVista> estadisticas)
        {
            var mapa = new Dictionary<string, int>
            {
                { "vid", 0 }, { "fue", 0 }, { "agl", 0 }, { "vel", 0 }, { "int", 0 }
            };

            foreach (BE_PersonajeEstadisticaVista est in estadisticas)
            {
                switch (est.Nombre)
                {
                    case "Vida": mapa["vid"] = est.ValorBase; break;
                    case "Fuerza": mapa["fue"] = est.ValorBase; break;
                    case "Agilidad": mapa["agl"] = est.ValorBase; break;
                    case "Velocidad": mapa["vel"] = est.ValorBase; break;
                    case "Inteligencia": mapa["int"] = est.ValorBase; break;
                }
            }

            return mapa;
        }

        private int XPParaSiguienteNivel(int nivelActual) => nivelActual * 100;

        // Piso de 1 punto por estadística (evita Vida=0 en un juego de combate) y el
        // remanente repartido al azar, un punto a la vez, entre todas las estadísticas.
        private Dictionary<string, int> RepartirPuntosIniciales(List<string> nombres)
        {
            Dictionary<string, int> reparto = nombres.ToDictionary(n => n, n => 1);
            int restantes = PUNTOS_INICIALES_TOTAL - nombres.Count;

            for (int i = 0; i < restantes; i++)
            {
                string nombre = nombres[SiguienteAleatorio(0, nombres.Count)];
                reparto[nombre]++;
            }

            return reparto;
        }

        // Sin piso mínimo: una estadística puede terminar en 0 puntos ese nivel.
        private Dictionary<string, int> RepartirPuntosBonus(List<string> nombres)
        {
            Dictionary<string, int> reparto = nombres.ToDictionary(n => n, n => 0);

            for (int i = 0; i < PUNTOS_BONUS_POR_NIVEL; i++)
            {
                string nombre = nombres[SiguienteAleatorio(0, nombres.Count)];
                reparto[nombre]++;
            }

            return reparto;
        }

        private static int SiguienteAleatorio(int minInclusive, int maxExclusive)
        {
            lock (_rngLock) { return _rng.Next(minInclusive, maxExclusive); }
        }
    }
}
