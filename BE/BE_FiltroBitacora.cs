using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BE
{
    public class BE_FiltroBitacora
    {
        public string Buscar { get; set; }
        public DateTime? FechaDesde { get; set; }
        public DateTime? FechaHasta { get; set; }
        public string Usuario { get; set; }
        public string Criticidad { get; set; }
        public string Modulo { get; set; }
    }
}
