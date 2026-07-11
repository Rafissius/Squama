using System;

namespace BE
{
    public class BE_InconsistenciaIntegridad
    {
        public int IDInconsistenciaIntegridad { get; set; }
        public string NombreTabla { get; set; }
        public int? IDRegistro { get; set; }
        public string NombreAtributo { get; set; }
        public string TipoDigito { get; set; }
        public string ValorEsperado { get; set; }
        public string ValorCalculado { get; set; }
        public DateTime FechaDeteccion { get; set; }
        public int? IDUsuarioWebmaster { get; set; }
        public string AccionTomada { get; set; }
        public byte Estado { get; set; }
    }
}
