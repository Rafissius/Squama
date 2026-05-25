using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DAL;
using BE;

namespace SERVICIOS
{
    public static class SERVICIOS_Bitacora
    {
        public static void RegistrarEvento(int? idUsuario, string nombreEvento, string descripcion, string ipOrigen = null)
        {
            if (string.IsNullOrWhiteSpace(nombreEvento))
            {
                throw new Exception("El nombre del evento no puede estar vacío.");
            }

            if (string.IsNullOrWhiteSpace(descripcion))
            {
                descripcion = "Sin descripción";
            }


            DAL_Bitacora dalBitacora = new DAL_Bitacora();

            int idTipoEvento = dalBitacora.ObtenerIdTipoEventoPorNombre(nombreEvento);

            BE_Bitacora bitacora = new BE_Bitacora
            {
                IDUsuario = idUsuario,
                IDTipoEventoBitacora = idTipoEvento,
                FechaEvento = DateTime.Now,
                Descripcion = descripcion,
                IPOrigen = ipOrigen
            };

            dalBitacora.Guardar(bitacora);
        }
    }
}
