using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BE
{
    // DTO de solo lectura para la grilla de Gestión de Usuarios: a diferencia de
    // BE_Usuario, nunca incluye PasswordHash, para que no viaje al cliente por WebMethod.
    public class BE_UsuarioListItem
    {
        public int IDUsuario { get; set; }
        public string NombreUsuario { get; set; }
        public string Email { get; set; }
        public DateTime FechaRegistro { get; set; }
        public int Estado { get; set; }
        public bool Bloqueado { get; set; }
        public int IntentosFallidos { get; set; }
        public int IDRol { get; set; }
        public string NombreRol { get; set; }
    }
}
