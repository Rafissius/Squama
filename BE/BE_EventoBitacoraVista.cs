using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BE
{
    public class BE_EventoBitacoraVista
    {

        public int IDEvento { get; set; }
        public DateTime FechaHora { get; set; }
        public string NombreUsuario { get; set; }  
        public string TipoEvento { get; set; }  
        public string Descripcion { get; set; }
        public string Criticidad { get; set; }    
        public string ModuloRelacionado { get; set; } 
        public string IPOrigen { get; set; }

        public string TiempoRelativo
        {
            get
            {
                var diff = DateTime.Now - FechaHora;
                if (diff.TotalMinutes < 1) return "hace un momento";
                if (diff.TotalMinutes < 60) return $"hace {(int)diff.TotalMinutes} min";
                if (diff.TotalHours < 24) return $"hace {(int)diff.TotalHours} h";
                return $"hace {(int)diff.TotalDays} días";
            }
        }






    }
}
