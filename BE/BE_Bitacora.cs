using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BE
{
    public class BE_Bitacora
    {
        public int IDBitacora { get; set; }
        public int? IDUsuario { get; set; }
        public int IDTipoEventoBitacora { get; set; }
        public DateTime FechaEvento { get; set; }
        public string Descripcion { get; set; }
        public string IPOrigen { get; set; }
    }
}
