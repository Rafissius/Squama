using System;

namespace BE
{
    public class BE_Backup
    {
        public int IDBackup { get; set; }
        public int IDUsuarioWebmaster { get; set; }
        public string NombreArchivo { get; set; }
        public string RutaArchivo { get; set; }
        public DateTime FechaBackup { get; set; }
        public string Observacion { get; set; }
        public byte Estado { get; set; }
    }

    //backupyrestorenaty
    public class BE_Backup2
    {
        public int IDBackup { get; set; }
        public string NombreArchivo { get; set; }
        public string RutaDestino { get; set; }
        public string Observacion { get; set; }
        public DateTime FechaHora { get; set; }
        public int IDUsuario { get; set; }
        public string NombreUsuario { get; set; }
        public string Estado { get; set; }
    }
}
