using System;

namespace BE
{
    public class BE_Personaje
    {
        public int IDPersonaje { get; set; }
        public int IDUsuario { get; set; }
        public string Nombre { get; set; }
        public int Nivel { get; set; }
        public int ExperienciaActual { get; set; }
        public int ExperienciaSiguienteNivel { get; set; }
        public int CopasArena { get; set; }
        public int VictoriasArena { get; set; }
        public int DerrotasArena { get; set; }
        public DateTime FechaCreacion { get; set; }
        public int Estado { get; set; }
    }
}
