namespace BE
{
    // DTO de respuesta del click "Pelear ahora" (ArenaApi.ashx) y de la pantalla
    // ArenaVictoria.aspx. Prototipo súper simple: sin HP/equipo/rondas reales.
    public class BE_ResultadoCombateVista
    {
        public int IDCombate { get; set; }
        public bool Gano { get; set; }
        public string NombreAtacante { get; set; }
        public string NombreDefensor { get; set; }
        public int NivelAtacante { get; set; }
        public int NivelDefensor { get; set; }
        public int PoderAtacante { get; set; }
        public int PoderDefensor { get; set; }
        public int ExperienciaGanada { get; set; }
        public int CopasAntes { get; set; }
        public int CopasDespues { get; set; }
    }
}
