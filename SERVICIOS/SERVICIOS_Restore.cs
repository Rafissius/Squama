using BE;
using DAL;
using System;
using System.Collections.Generic;

namespace SERVICIOS
{
    public static class SERVICIOS_Restore
    {
        private static readonly DAL_Backup _dal = new DAL_Backup();

        // USO:
        //    List<BE_Backup> backups = SERVICIOS.SERVICIOS_Restore.ObtenerBackupsDisponibles();
        public static List<BE_Backup> ObtenerBackupsDisponibles() => _dal.ObtenerBackupsDisponibles();

        // USO:
        //    SERVICIOS.SERVICIOS_Restore.RestaurarDesdeBackup(idBackup, idWebmaster, ip);
        //    (acción del webmaster desde Webmaster/ResolverIntegridad.aspx para restaurar
        //     la BD desde un backup existente.)
        //
        // Todavía no existe la funcionalidad real de restore en el panel. Cuando se
        // implemente acá, al terminar con éxito debe llamar a
        // SERVICIOS_DigitoVerificador.MarcarSistemaDesbloqueadoPorRestore(idWebmaster, ip).
        public static void RestaurarDesdeBackup(int idBackup, int idWebmaster, string ip)
        {
            throw new NotImplementedException(
                "El restore real de la base de datos desde un backup todavía no está implementado.");
        }
    }
}
