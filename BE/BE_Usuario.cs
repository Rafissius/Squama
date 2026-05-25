using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BE
{
    public class BE_Usuario
    {
        public int IDUsuario { get; set; }
        public string NombreUsuario { get; set; }
        public string Email { get; set; }
        public string PasswordHash { get; set; }
        public int Estado { get; set; }
        public bool Bloqueado { get; set; }
        public int IntentosFallidos { get; set; }
        public int IDRol { get; set; }
    }
}
