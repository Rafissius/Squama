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
        public DateTime FechaRegistro { get; set; }

        [ExcluirDeDV]
        public int Estado { get; set; }

        [ExcluirDeDV]
        public bool Bloqueado { get; set; }

        [ExcluirDeDV]
        public int IntentosFallidos { get; set; }

        // No es columna real de Usuario (se carga desde UsuarioRol/Rol en BLL_Usuario).
        // Se excluye automáticamente del DV por el filtro de columnas reales, no requiere [ExcluirDeDV].
        public int IDRol { get; set; }
    }
}
