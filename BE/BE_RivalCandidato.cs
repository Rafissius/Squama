namespace BE
{
    // Intermedio DAL→BLL: fila cruda de un posible rival, antes de aplicarle
    // presentación (rango, winrate, colores). No viaja tal cual a la GUI.
    public class BE_RivalCandidato
    {
        public int IDPersonaje { get; set; }
        public string Nombre { get; set; }
        public int Nivel { get; set; }
        public int CopasArena { get; set; }
        public int VictoriasArena { get; set; }
        public int DerrotasArena { get; set; }
        public string Clan { get; set; } // null si no tiene clan
    }
}
