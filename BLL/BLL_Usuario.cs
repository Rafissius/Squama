using BE;
using DAL;
using SERVICIOS;
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
        //           BE con Bloqueado=true si el webmaster lo bloqueó manualmente
        //           BE con Estado=0 si está desactivado
        //           BE con IntentosFallidos >= 3 si está bloqueado por intentos fallidos
        public BE_Usuario Login(string credencial, string claveIngresada)
        {
            BE_Usuario usuario = dal.ObtenerUsuarioPorCredencial(credencial);

            // Usuario no encontrado
            if (usuario == null)
                return null;

            // Bloqueado (Usuario.Bloqueado=1) o desactivado (Usuario.Estado=0): no se valida
            // la contraseña, la GUI detecta el motivo exacto a través de estas propiedades
            // (mismo criterio que IntentosFallidos >= 3 más abajo).
            if (usuario.Bloqueado || usuario.Estado == 0)
                return usuario;

            // Usuario bloqueado por intentos fallidos
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

            // Bug encontrado (2026-07-10): esto no existía — un login exitoso nunca reseteaba
            // el contador de intentos fallidos, así que una clave tipeada mal un par de veces
            // (aunque el intento SIGUIENTE fuera exitoso) dejaba al usuario cada vez más cerca
            // del bloqueo por intentos (>=3), acumulando entre sesiones sin relación entre sí.
            if (usuario.IntentosFallidos > 0)
            {
                dal.ResetearIntentosFallidos(usuario.IDUsuario);
                usuario.IntentosFallidos = 0;
            }

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
        public int RegistrarUsuario(BE_Usuario usuario, int idRol = 3, int estadoInicial = 1)
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
            usuario.Estado = estadoInicial;
            usuario.Bloqueado = false;
            usuario.IntentosFallidos = 0;

            int idGenerado = dal.Insertar(usuario);
            usuario.IDUsuario = idGenerado;

            // Rol: 3 (Jugador) por defecto para el alta pública (RegistrarUsuario.aspx);
            // el panel de Gestión de Usuarios del webmaster pasa el rol elegido.
            dal.AsignarRolPredeterminado(idGenerado, idRol);

            // Sin esto, la fila queda con DVH/DVV en null: la verificación de integridad
            // (Application_Start, timer, login) trata un DV nunca calculado igual que un
            // mismatch y bloquea el sistema en el primer login de este usuario nuevo.
            // RecalcularDVV además de CalcularYGuardarDVH porque el DVV es un hash agregado
            // de TODA la columna a lo largo de la tabla: la fila nueva invalida el DVV
            // guardado de cada columna, no solo el DVH de esta fila puntual.
            SERVICIOS_DigitoVerificador.CalcularYGuardarDVH(usuario);
            SERVICIOS_DigitoVerificador.RecalcularDVV<BE_Usuario>();

            // Alta eager de Personaje: sin importar el rol con el que se registre, todo
            // usuario nuevo queda con su Personaje desde este momento (1 a 1, nunca se
            // toca por cambios de rol posteriores). Best-effort: si esto falla, el
            // backfill perezoso de HomeJugador.aspx.cs lo crea en el primer login, así
            // que un problema acá nunca debe hacer fallar el alta de usuario.
            try
            {
                new BLL_Personaje().CrearPersonaje(idGenerado, usuario.NombreUsuario);
            }
            catch { }

            return idGenerado;
        }


        /////////MODULO REGISTRAR USUARIO


        /////////MODULO GESTION DE USUARIOS (webmaster)

        // Recalcula el DV del usuario después de cualquier UPDATE sobre Usuario.
        // Mismo motivo que en RegistrarUsuario: sin esto, la próxima verificación
        // de integridad (login, timer) encuentra un DV desactualizado y bloquea el sistema.
        private void RecalcularDVDeUsuario(int idUsuario)
        {
            BE_Usuario usuario = dal.ObtenerPorId(idUsuario);
            SERVICIOS_DigitoVerificador.CalcularYGuardarDVH(usuario);
            SERVICIOS_DigitoVerificador.RecalcularDVV<BE_Usuario>();
        }

        public List<BE_UsuarioListItem> ObtenerUsuarios()
        {
            return dal.ObtenerTodosConRol();
        }

        // USO: ResolverIntegridad.aspx.cs, para mostrar quién (qué webmaster) resolvió/verificó
        // una inconsistencia — la capa Web no referencia DAL directamente, pasa por BLL/SERVICIOS.
        public BE_Usuario ObtenerPorId(int idUsuario)
        {
            return dal.ObtenerPorId(idUsuario);
        }

        public List<BE_Rol> ObtenerRoles()
        {
            return dal.ObtenerRoles();
        }

        public void EditarUsuario(int idUsuario, string nombreUsuario, string email)
        {
            if (string.IsNullOrWhiteSpace(nombreUsuario))
                throw new Exception("El nombre de usuario es obligatorio.");

            if (string.IsNullOrWhiteSpace(email))
                throw new Exception("El correo electronico es obligatorio.");

            if (dal.ExisteNombreUsuario(nombreUsuario, idUsuario))
                throw new Exception("Ese nombre de usuario ya esta en uso.");

            if (dal.ExisteEmail(email, idUsuario))
                throw new Exception("Ese correo electronico ya esta registrado.");

            dal.ActualizarDatos(idUsuario, nombreUsuario, email);
            RecalcularDVDeUsuario(idUsuario);
        }

        public void CambiarEstado(int idUsuario, bool activo)
        {
            dal.ActualizarEstado(idUsuario, activo ? 1 : 0);
            RecalcularDVDeUsuario(idUsuario);
        }

        public void CambiarBloqueo(int idUsuario, bool bloqueado)
        {
            dal.ActualizarBloqueado(idUsuario, bloqueado);

            // Al desbloquear, se resetean los intentos fallidos (mismo criterio
            // que ya tenía el flujo de desbloqueo antes de conectarse al backend real).
            if (!bloqueado)
                dal.ResetearIntentosFallidos(idUsuario);

            RecalcularDVDeUsuario(idUsuario);
        }

        public void ResetearIntentos(int idUsuario)
        {
            dal.ResetearIntentosFallidos(idUsuario);
            RecalcularDVDeUsuario(idUsuario);
        }

        // Sin recálculo de DV: UsuarioRol no es una tabla trackeada por el módulo
        // de Dígito Verificador (no está en SERVICIOS_DigitoVerificador._entidades).
        public void CambiarRol(int idUsuario, int idRol)
        {
            dal.ActualizarRol(idUsuario, idRol);
        }

        /////////MODULO GESTION DE USUARIOS (webmaster)

    }
}
