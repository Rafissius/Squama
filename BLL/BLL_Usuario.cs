using BE;
using DAL;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace BLL
{
    public class BLL_Usuario
    {
        private readonly DAL_Usuario dal = new DAL_Usuario();

        // Devuelve: el BE con IDRol cargado si login OK
        //           null si usuario no existe o clave incorrecta
        //           BE con IntentosFallidos >= 3 si está bloqueado
        public BE_Usuario Login(string credencial, string claveIngresada)
        {
            BE_Usuario usuario = dal.ObtenerUsuarioPorCredencial(credencial);

            // Usuario no encontrado
            if (usuario == null)
                return null;

            // Usuario bloqueado
            if (usuario.IntentosFallidos >= 3)
                return usuario; // La GUI detecta que IntentosFallidos >= 3

            // Hashear la clave ingresada y comparar
            string hashIngresado = HashSHA256(claveIngresada);

            if (!hashIngresado.Equals(usuario.PasswordHash, StringComparison.OrdinalIgnoreCase))
            {
                // Clave incorrecta: sumar intento fallido
                dal.SumarIntentoFallido(usuario.IDUsuario);
                usuario.IntentosFallidos += 1; // reflejar en el objeto devuelto
                usuario.PasswordHash = null;   // no exponer el hash //////////////////////////////////acacaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
                return usuario;                // La GUI detecta clave incorrecta
            }

            // Login exitoso: obtener rol-
            usuario.IDRol = dal.ObtenerRolPorUsuario(usuario.IDUsuario);
            // La verificación de integridad NO vive acá: la dispara Application_Start
            // (al arrancar) y el timer periódico (SERVICIOS_DigitoVerificador vía Global.asax).
            // El login solo autentica; BloqueoIntegridadModule es quien reparte por rol
            // en cada request si EstadoSistema.Bloqueado ya está en true.
            usuario.PasswordHash = null; // no exponer el hash
            return usuario;
        }

        public string ObtenerNombreRol(int idUsuario)
        {
            return dal.ObtenerNombreRolPorUsuario(idUsuario);
        }

        private string HashSHA256(string texto)
        {
            using (SHA256 sha = SHA256.Create())
            {
                byte[] bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(texto));
                StringBuilder sb = new StringBuilder();
                foreach (byte b in bytes)
                    sb.Append(b.ToString("x2"));
                return sb.ToString();
            }
        }



        /////////MODULO REGISTRAR USUARIO


        /// <summary>
        /// Registra un nuevo usuario: hashea la clave, completa los campos
        /// automaticos, inserta en Usuario y asigna el rol por defecto (IDRol = 3)
        /// en UsuarioRol. Devuelve el IDUsuario generado.
        /// </summary>
        public int RegistrarUsuario(BE_Usuario usuario)
        {
            if (string.IsNullOrWhiteSpace(usuario.NombreUsuario))
                throw new Exception("El nombre de usuario es obligatorio.");

            if (string.IsNullOrWhiteSpace(usuario.Email))
                throw new Exception("El correo electronico es obligatorio.");

            if (string.IsNullOrWhiteSpace(usuario.PasswordHash))
                throw new Exception("La clave es obligatoria.");

            if (dal.ExisteNombreUsuario(usuario.NombreUsuario))
                throw new Exception("Ese nombre de usuario ya esta en uso.");

            if (dal.ExisteEmail(usuario.Email))
                throw new Exception("Ese correo electronico ya esta registrado.");

            // Hasheo de la clave (llega en texto plano desde la GUI en este campo)
            usuario.PasswordHash = HashSHA256(usuario.PasswordHash);

            // Campos automaticos / de negocio
            usuario.FechaRegistro = DateTime.Now;
            usuario.Estado = 1;
            usuario.Bloqueado = false;
            usuario.IntentosFallidos = 0;

            int idGenerado = dal.Insertar(usuario);
            usuario.IDUsuario = idGenerado;

            // Rol por defecto para todo usuario nuevo
            const int ID_ROL_POR_DEFECTO = 3;
            dal.AsignarRolPredeterminado(idGenerado, ID_ROL_POR_DEFECTO);

            return idGenerado;
        }

       
        /////////MODULO REGISTRAR USUARIO

    }
}
