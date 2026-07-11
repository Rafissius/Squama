using System;

namespace BE
{
    public class BE_Combate
    {
        public int IDCombate { get; set; }
        public int IDPersonajeAtacante { get; set; }
        public int IDPersonajeDefensor { get; set; }
        public int IDResultadoCombate { get; set; }
        public DateTime FechaCombate { get; set; }
        public int CopasAtacanteAntes { get; set; }
        public int CopasAtacanteDespues { get; set; }
        public int VariacionCopas { get; set; }
        public int ExperienciaGanada { get; set; }
        public int Estado { get; set; }
    }
}
