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


    //    SERVICIOS.SERVICIOS_Bitacora.RegistrarEvento(int/null/usuario.idquetengo,int (ID del evento), Request.UserHostAddress (ip));



        public static void RegistrarEvento(int? idUsuario, int idTipoEvento, string ipOrigen = null)
        {
            DAL_Bitacora dalBitacora = new DAL_Bitacora();

            BE_Bitacora bitacora = new BE_Bitacora
            {
                IDUsuario = idUsuario,
                IDTipoEventoBitacora = idTipoEvento,
                FechaEvento = DateTime.Now,
                Descripcion = dalBitacora.ObtenerDescripcionTipoEvento(idTipoEvento),
                IPOrigen = ipOrigen
            };

            dalBitacora.Guardar(bitacora);

            // Toda alta en una entidad registrada en SERVICIOS_DigitoVerificador._entidades
            // debe actualizar su propio DVH (fila nueva) y recalcular el DVV (el agregado por
            // columna cambia al sumar una fila) — ver Reglas.md, "Regla general".
            SERVICIOS_DigitoVerificador.CalcularYGuardarDVH(bitacora);
            SERVICIOS_DigitoVerificador.RecalcularDVV<BE_Bitacora>();
        }

        public static List<BE_EventoBitacoraVista> ObtenerEventos()
        {
            return new DAL_Bitacora().ObtenerEventos();
        }



    }
}
