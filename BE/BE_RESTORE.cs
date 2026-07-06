using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BE
{
    public class BE_RESTORE
    {
        public int IDRestore { get; set; }
        public int IDUsuarioWebmaster { get; set; }
        public int IDBackup { get; set; }
        public string NombreArchivo { get; set; }
        public string RutaArchivo { get; set; }
        public DateTime FechaRestore { get; set; }
        public string Observacion { get; set; }  // = Motivo del restore
        public byte Estado { get; set; }
    }
}
