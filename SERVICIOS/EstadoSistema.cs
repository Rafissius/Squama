using System;

namespace SERVICIOS
{
    public static class EstadoSistema
    {
        private static readonly object _lock = new object();

        private static volatile bool _bloqueado = false;
        private static string _motivoBloqueo = null;
        private static DateTime? _fechaBloqueo = null;
        private static int _cantidadInconsistencias = 0;

        public static bool Bloqueado => _bloqueado;
        public static string MotivoBloqueo => _motivoBloqueo;
        public static DateTime? FechaBloqueo => _fechaBloqueo;
        public static int CantidadInconsistencias => _cantidadInconsistencias;

        internal static void Bloquear(string motivo, int cantidadInconsistencias)
        {
            lock (_lock)
            {
                _motivoBloqueo = motivo;
                _cantidadInconsistencias = cantidadInconsistencias;
                _fechaBloqueo = DateTime.Now;
                _bloqueado = true;
            }
        }

        internal static void Desbloquear()
        {
            lock (_lock)
            {
                _bloqueado = false;
                _motivoBloqueo = null;
                _fechaBloqueo = null;
                _cantidadInconsistencias = 0;
            }
        }
    }
}
