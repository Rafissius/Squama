using System.Collections.Generic;

namespace BE
{
    // DTO final que viaja como JSON a SeleccionarRival.aspx vía ArenaApi.ashx.
    public class BE_RivalArenaVista
    {
        public int IDPersonaje { get; set; }
        public string Nombre { get; set; }
        public int Nivel { get; set; }
        public string Clan { get; set; }
        public string Rango { get; set; }                    // "oro"|"plata"|"bronce"|"diamante"
        public string PorcentajeVictorias { get; set; }       // "0%" ya formateado
        public string ColorPorcentajeVictorias { get; set; }  // "v-red"|"v-ora"|"v-green"|"v-blue"
        public int Combates { get; set; }
        public string Racha { get; set; }                     // "—" hasta que exista historial real de Combate
        public string ColorRacha { get; set; }
        public Dictionary<string, int> Estadisticas { get; set; } // claves: vid, fue, agl, vel, int
    }
}
