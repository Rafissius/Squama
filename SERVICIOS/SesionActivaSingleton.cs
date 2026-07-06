using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SERVICIOS
{
     // Patrón Singleton: una sola instancia en toda la aplicación
        public sealed class SesionActivaSingleton
        {
            private static readonly SesionActivaSingleton _instancia = new SesionActivaSingleton();
            private readonly Dictionary<int, string> sesionesActivas = new Dictionary<int, string>();
            private static readonly object candado = new object();

            // Constructor privado: nadie puede hacer "new" desde afuera
            private SesionActivaSingleton() { }

            public static SesionActivaSingleton Instancia
            {
                get { return _instancia; }
            }

            // Se llama cuando el usuario hace login correctamente
            public void RegistrarSesion(int idUsuario, string sessionID)
            {
                lock (candado)
                {
                    sesionesActivas[idUsuario] = sessionID; // pisa la sesión anterior si había
                }
            }

            // Se llama en cada request para chequear si esta pestaña sigue siendo válida
            public bool EsSesionValida(int idUsuario, string sessionID)
            {
                lock (candado)
                {
                    return sesionesActivas.ContainsKey(idUsuario)
                           && sesionesActivas[idUsuario] == sessionID;
                }
            }

            // Se llama cuando el usuario presiona "Salir"
            public void CerrarSesion(int idUsuario)
            {
                lock (candado)
                {
                    if (sesionesActivas.ContainsKey(idUsuario))
                        sesionesActivas.Remove(idUsuario);
                }
            }
        }
    
}
