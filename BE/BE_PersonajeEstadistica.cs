using System;

namespace BE
{
    public class BE_PersonajeEstadistica
    {
        public int IDPersonajeEstadistica { get; set; }
        public int IDPersonaje { get; set; }
        public int IDEstadistica { get; set; }
        public int ValorBase { get; set; }
        public DateTime FechaUltimaModificacion { get; set; }
    }
}
