using System;

namespace BE
{
    public class BE_MejoraNivelPersonaje
    {
        public int IDMejoraNivelPersonaje { get; set; }
        public int IDPersonaje { get; set; }
        public int NivelAlAplicar { get; set; }
        public int IDEstadistica { get; set; }
        public int ValorIncremento { get; set; }
        public DateTime FechaAplicacion { get; set; }
    }
}
