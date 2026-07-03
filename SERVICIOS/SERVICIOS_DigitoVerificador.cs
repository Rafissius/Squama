using BE;
using DAL;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Security.Cryptography;
using System.Text;

namespace SERVICIOS
{
    public static class SERVICIOS_DigitoVerificador
    {
        private static readonly DAL_DigitoVerificador _dal = new DAL_DigitoVerificador();

        // Lista manual de entidades con tablas DV reales (agregar nuevas aquí).
        // Antes de agregar una entidad, aplicar la regla de contraste propiedad/columna (ver Contexto.md).
        // ADEMAS, ACA VAN LAS QUE QUEREMOSQUE VERIFIQUE ACACACACACACACACAAC
        private static readonly List<Type> _entidades = new List<Type>
        {
            typeof(BE_Usuario),
            typeof(BE_Bitacora),
        };

        // Lock por tabla para concurrencia (in-process, alcanza para single-server)
        private static readonly ConcurrentDictionary<string, object> _locks
            = new ConcurrentDictionary<string, object>();

        // Cache de columnas reales por tabla. Invalidación MANUAL explícita (sin TTL):
        // el esquema no cambia en runtime salvo tras un restore de backup, por eso solo
        // se limpia en RecalcularTodosLosDV y MarcarSistemaDesbloqueadoPorRestore.
        private static readonly ConcurrentDictionary<string, HashSet<string>> _columnasPorTabla
            = new ConcurrentDictionary<string, HashSet<string>>();

        public static void LimpiarCacheColumnas() => _columnasPorTabla.Clear();

        // Stripea prefijo BE_ para derivar nombre de entidad, tabla y tabla DV
        private static string NombreEntidad(Type t) =>
            t.Name.StartsWith("BE_") ? t.Name.Substring(3) : t.Name;

        private static object LockDe(string nombreTabla) =>
            _locks.GetOrAdd(nombreTabla, _ => new object());

        private static HashSet<string> ColumnasRealesDe(string nombreTabla) =>
            _columnasPorTabla.GetOrAdd(nombreTabla, tabla => new HashSet<string>(_dal.ObtenerColumnasReales(tabla)));

        // Lista de propiedades a hashear en DVH y DVV (mismo filtro para ambos):
        // sin PK, sin [ExcluirDeDV], e intersectadas contra las columnas reales de la tabla
        // (evita hashear props inyectadas como BE_Usuario.IDRol, que viene de UsuarioRol y no de Usuario)
        private static IEnumerable<PropertyInfo> ColumnasVerificables(Type t)
        {
            string nombreTabla = NombreEntidad(t);
            HashSet<string> columnasReales = ColumnasRealesDe(nombreTabla);

            return t.GetProperties()
                .Where(p => !Attribute.IsDefined(p, typeof(ExcluirDeDVAttribute)))
                .Where(p => p.Name != "ID" + nombreTabla)
                .Where(p => columnasReales.Contains(p.Name))
                .OrderBy(p => p.Name);
        }

        // Canonicalización antes de hashear
        private static string CanonicalizarValor(object val)
        {
            if (val == null || val == DBNull.Value) return "";
            if (val is DateTime dt) return dt.ToString("yyyy-MM-dd HH:mm:ss", CultureInfo.InvariantCulture);
            if (val is decimal || val is double) return ((IFormattable)val).ToString(null, CultureInfo.InvariantCulture);
            if (val is bool b) return b ? "1" : "0";
            return val.ToString();
        }

        private static string HashSHA256(string valor)
        {
            using (SHA256 sha = SHA256.Create())
            {
                byte[] bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(valor));
                StringBuilder sb = new StringBuilder();
                foreach (byte b in bytes)
                    sb.Append(b.ToString("x2"));
                return sb.ToString();
            }
        }

        private static string HashearFila(Type t, object entidad)
        {
            string valorConcatenado = string.Join("|", ColumnasVerificables(t)
                .Select(p => CanonicalizarValor(p.GetValue(entidad))));
            return HashSHA256(valorConcatenado);
        }

        private static string HashearFila(Type t, DataRow fila)
        {
            string valorConcatenado = string.Join("|", ColumnasVerificables(t)
                .Select(p => CanonicalizarValor(fila[p.Name])));
            return HashSHA256(valorConcatenado);
        }

        private static string HashearColumna(string nombreTabla, string nombreColumna)
        {
            DataTable dt = _dal.ObtenerValoresDeColumna(nombreTabla, nombreColumna);
            string valorConcatenado = string.Join("|", dt.Rows.Cast<DataRow>()
                .Select(r => CanonicalizarValor(r[nombreColumna])));
            return HashSHA256(valorConcatenado);
        }

        // USO:
        //    SERVICIOS.SERVICIOS_DigitoVerificador.BloquearPorFallaDeVerificacion(mensaje);
        //    (caso defensivo: la verificación de integridad en sí falló con una excepción
        //     -p.ej. en Application_Start-, no que haya detectado inconsistencias. Bloquea
        //     por seguridad. Único punto público para setear EstadoSistema.Bloqueado desde
        //     fuera del assembly SERVICIOS, ya que EstadoSistema.Bloquear es internal.)
        public static void BloquearPorFallaDeVerificacion(string motivo)
        {
            EstadoSistema.Bloquear(motivo, -1);
        }

        // USO:
        //    List<BE_InconsistenciaIntegridad> ultimas =
        //        SERVICIOS.SERVICIOS_DigitoVerificador.ObtenerUltimasInconsistencias(20);
        //    (usado en Webmaster/ResolverIntegridad.aspx para mostrar la grilla de inconsistencias)
        public static List<BE_InconsistenciaIntegridad> ObtenerUltimasInconsistencias(int cantidad) =>
            _dal.ObtenerUltimasInconsistencias(cantidad);

        public static bool EsWebmaster(BE_Usuario usuario)
        {
            if (usuario == null) return false;
            return _dal.ObtenerEsWebmaster(usuario.IDUsuario);
        }

        // USO:
        //    SERVICIOS.SERVICIOS_DigitoVerificador.CalcularYGuardarDVH(usuario);
        //    (llamar después de cualquier Insert/Update sobre la entidad)
        public static void CalcularYGuardarDVH<T>(T entidad)
        {
            Type t = typeof(T);
            string nombreTabla = NombreEntidad(t);
            PropertyInfo pkProp = t.GetProperty("ID" + nombreTabla);
            int idRegistro = Convert.ToInt32(pkProp.GetValue(entidad));

            string hash = HashearFila(t, entidad);

            lock (LockDe(nombreTabla))
            {
                _dal.ReemplazarDVH(nombreTabla, idRegistro, hash);
            }
        }

        // USO:
        //    bool ok = SERVICIOS.SERVICIOS_DigitoVerificador.VerificarDVH(usuario);
        public static bool VerificarDVH<T>(T entidad)
        {
            Type t = typeof(T);
            string nombreTabla = NombreEntidad(t);
            PropertyInfo pkProp = t.GetProperty("ID" + nombreTabla);
            int idRegistro = Convert.ToInt32(pkProp.GetValue(entidad));

            string hashCalculado = HashearFila(t, entidad);
            string hashGuardado = _dal.ObtenerDVH(nombreTabla, idRegistro);

            return hashGuardado != null && hashGuardado.Equals(hashCalculado, StringComparison.OrdinalIgnoreCase);
        }

        // USO:
        //    SERVICIOS.SERVICIOS_DigitoVerificador.RecalcularDVV<BE.Usuario>();
        public static void RecalcularDVV<T>()
        {
            Type t = typeof(T);
            string nombreTabla = NombreEntidad(t);

            lock (LockDe(nombreTabla))
            {
                foreach (PropertyInfo prop in ColumnasVerificables(t))
                {
                    string hash = HashearColumna(nombreTabla, prop.Name);
                    _dal.ReemplazarDVV(nombreTabla, prop.Name, hash);
                }
            }
        }

        // USO:
        //    bool ok = SERVICIOS.SERVICIOS_DigitoVerificador.VerificarDVV<BE.Usuario>("Email");
        public static bool VerificarDVV<T>(string nombreAtributo)
        {
            Type t = typeof(T);
            string nombreTabla = NombreEntidad(t);

            string hashCalculado = HashearColumna(nombreTabla, nombreAtributo);
            string hashGuardado = _dal.ObtenerDVV(nombreTabla, nombreAtributo);

            return hashGuardado != null && hashGuardado.Equals(hashCalculado, StringComparison.OrdinalIgnoreCase);
        }

        private static int VerificarIntegridadTablaInterno(Type t, int? idUsuarioWebmaster)
        {
            string nombreTabla = NombreEntidad(t);
            int inconsistencias = 0;

            // Mismo lock por tabla que usan CalcularYGuardarDVH/RecalcularDVV/RecalcularTodosLosDV:
            // evita leer un DV a mitad de un DELETE+INSERT concurrente sobre la misma tabla
            // (la verificación se serializa contra las escrituras de esa tabla, no contra otras).
            lock (LockDe(nombreTabla))
            {
                // DVV: una por columna verificable, agregando todos los valores de la tabla
                foreach (PropertyInfo prop in ColumnasVerificables(t))
                {
                    string hashCalculado = HashearColumna(nombreTabla, prop.Name);
                    string hashGuardado = _dal.ObtenerDVV(nombreTabla, prop.Name);

                    if (hashGuardado == null || !hashGuardado.Equals(hashCalculado, StringComparison.OrdinalIgnoreCase))
                    {
                        inconsistencias++;
                        _dal.RegistrarInconsistencia(nombreTabla, null, prop.Name, "DVV",
                            hashGuardado ?? "", hashCalculado, idUsuarioWebmaster);
                    }
                }

                // DVH: uno por fila
                DataTable filas = _dal.ObtenerTodosLosRegistros(nombreTabla);
                string nombrePK = "ID" + nombreTabla;

                foreach (DataRow fila in filas.Rows)
                {
                    int idRegistro = Convert.ToInt32(fila[nombrePK]);
                    string hashCalculado = HashearFila(t, fila);
                    string hashGuardado = _dal.ObtenerDVH(nombreTabla, idRegistro);

                    if (hashGuardado == null || !hashGuardado.Equals(hashCalculado, StringComparison.OrdinalIgnoreCase))
                    {
                        inconsistencias++;
                        _dal.RegistrarInconsistencia(nombreTabla, idRegistro, null, "DVH",
                            hashGuardado ?? "", hashCalculado, idUsuarioWebmaster);
                    }
                }
            }

            return inconsistencias;
        }

        // USO:
        //    int inconsistencias = SERVICIOS.SERVICIOS_DigitoVerificador.VerificarIntegridadTabla<BE.Usuario>(idUsuarioWebmaster);
        //    (idUsuarioWebmaster: null en verificaciones automáticas de arranque/login)
        public static int VerificarIntegridadTabla<T>(int? idUsuarioWebmaster = null) =>
            VerificarIntegridadTablaInterno(typeof(T), idUsuarioWebmaster);

        // USO:
        //    int totales = SERVICIOS.SERVICIOS_DigitoVerificador.VerificarIntegridadTotal(idUsuarioWebmaster);
        //    (verifica todas las entidades registradas. Si encuentra inconsistencias,
        //     llama automáticamente a EstadoSistema.Bloquear y registra en Bitacora.
        //     Devuelve el total de inconsistencias detectadas.)
        public static int VerificarIntegridadTotal(int? idUsuarioWebmaster = null)
        {
            int total = 0;

            foreach (Type t in _entidades)
                total += VerificarIntegridadTablaInterno(t, idUsuarioWebmaster);

            if (total > 0)
            {
                EstadoSistema.Bloquear(
                    "Se detectaron " + total + " inconsistencias de integridad en la verificación de arranque/login.",
                    total);
            }

            return total;
        }

        // USO:
        //    bool ok = SERVICIOS.SERVICIOS_DigitoVerificador.VerificarTablaCritica<BE.Usuario>();
        //    (verificación liviana usada en cada login: solo DVV de la tabla indicada.
        //     Si falla, llama a EstadoSistema.Bloquear. Devuelve true si la integridad está OK.)
        public static bool VerificarTablaCritica<T>()
        {
            int inconsistencias = VerificarIntegridadTabla<T>(null);

            if (inconsistencias > 0)
            {
                EstadoSistema.Bloquear(
                    "Se detectaron " + inconsistencias + " inconsistencias de integridad en " + NombreEntidad(typeof(T)) + ".",
                    inconsistencias);
                return false;
            }

            return true;
        }

        // USO:
        //    SERVICIOS.SERVICIOS_DigitoVerificador.RecalcularTodosLosDV(idUsuarioWebmaster, ip);
        //    (acción del webmaster: recalcula TODOS los DV de TODAS las entidades desde cero,
        //     asumiendo que los datos están bien y los DV estaban mal. Al terminar exitosamente
        //     llama a EstadoSistema.Desbloquear, registra evento SISTEMA_DESBLOQUEADO_RECALCULO
        //     y llama a LimpiarCacheColumnas().)
        public static void RecalcularTodosLosDV(int idUsuarioWebmaster, string ip)
        {
            foreach (Type t in _entidades)
                RecalcularDVDeEntidad(t, "Recalculo manual");

            LimpiarCacheColumnas();
            EstadoSistema.Desbloquear();
            SERVICIOS_Bitacora.RegistrarEvento(idUsuarioWebmaster, 8, ip);

            // RegistrarEvento acaba de insertar una fila nueva en Bitacora, posterior al
            // recálculo de arriba: sin este segundo paso, esa fila (y por lo tanto el DVH de
            // esa fila y el DVV tabla-wide de Bitacora) quedaría fuera de la línea base recién
            // creada, y el propio desbloqueo generaría una inconsistencia nueva de inmediato.
            RecalcularDVDeEntidad(typeof(BE_Bitacora), "Recalculo manual");
        }

        // USO:
        //    SERVICIOS.SERVICIOS_DigitoVerificador.MarcarSistemaDesbloqueadoPorRestore(idUsuarioWebmaster, ip);
        //    (acción del webmaster: llamar DESPUÉS de completar un restore exitoso desde el panel.
        //     Llama a EstadoSistema.Desbloquear y registra evento SISTEMA_DESBLOQUEADO_RESTORE.)
        public static void MarcarSistemaDesbloqueadoPorRestore(int idUsuarioWebmaster, string ip)
        {
            LimpiarCacheColumnas();
            EstadoSistema.Desbloquear();
            SERVICIOS_Bitacora.RegistrarEvento(idUsuarioWebmaster, 9, ip);

            // Mismo motivo que en RecalcularTodosLosDV: este RegistrarEvento inserta una fila
            // nueva en Bitacora que el backup restaurado no puede contemplar en su propio DV.
            RecalcularDVDeEntidad(typeof(BE_Bitacora), "Restore");

            // El resto de las entidades no se recalculan (el restore ya trae sus DV correctos
            // desde el backup), pero cualquier inconsistencia pendiente que hubiera quedado
            // registrada antes del restore ya no aplica: se marca resuelta igual.
            foreach (Type t in _entidades)
                if (t != typeof(BE_Bitacora))
                    _dal.MarcarInconsistenciasResueltas(NombreEntidad(t), "Restore");
        }

        // Recalcula DVH (por fila) y DVV (por columna verificable) de una entidad completa,
        // sobrescribiendo lo que hubiera, y marca como resueltas las inconsistencias pendientes
        // de esa tabla. Extraído de RecalcularTodosLosDV para poder reusarlo puntualmente sobre
        // BE_Bitacora después de registrar un evento de desbloqueo (ver arriba).
        private static void RecalcularDVDeEntidad(Type t, string accion)
        {
            string nombreTabla = NombreEntidad(t);
            DataTable filas = _dal.ObtenerTodosLosRegistros(nombreTabla);
            string nombrePK = "ID" + nombreTabla;

            lock (LockDe(nombreTabla))
            {
                foreach (DataRow fila in filas.Rows)
                {
                    int idRegistro = Convert.ToInt32(fila[nombrePK]);
                    string hash = HashearFila(t, fila);
                    _dal.ReemplazarDVH(nombreTabla, idRegistro, hash);
                }

                foreach (PropertyInfo prop in ColumnasVerificables(t))
                {
                    string hash = HashearColumna(nombreTabla, prop.Name);
                    _dal.ReemplazarDVV(nombreTabla, prop.Name, hash);
                }

                _dal.MarcarInconsistenciasResueltas(nombreTabla, accion);
            }
        }
    }
}
