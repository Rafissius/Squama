using BE;
using SERVICIOS;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Threading;
using System.Web;
using System.Web.Hosting;
using System.Web.Optimization;
using System.Web.Routing;
using System.Web.Security;
using System.Web.SessionState;

namespace PylinskiCuello_ProyectoWeb
{
    public class Global : HttpApplication
    {
        private const int IntervaloMinutosPorDefecto = 5;

        // System.Threading.Timer, no System.Timers.Timer: el callback corre directo en un
        // hilo de ThreadPool, sin el overhead de componente/SynchronizingObject que trae
        // System.Timers.Timer (pensado para marshalling a un hilo de UI de WinForms/WPF,
        // que acá no aplica). Es lo más liviano para un chequeo en background en ASP.NET.
        private static Timer _timerVerificacionPeriodica;

        // 0 = libre, 1 = verificación en curso. Evita que dos ticks del timer se solapen
        // si una verificación tarda más que el intervalo configurado.
        private static int _verificacionEnCurso = 0;

        void Application_Start(object sender, EventArgs e)
        {
            // Código que se ejecuta al iniciar la aplicación
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);

            // Modelo de detección: SOLO Application_Start (acá) y el timer periódico
            // (más abajo) detectan inconsistencias y setean EstadoSistema.Bloqueado.
            // BloqueoIntegridadModule y el login NO detectan nada, solo reaccionan al flag.
            try
            {
                int inconsistencias = SERVICIOS_DigitoVerificador.VerificarIntegridadTotal(null);
                if (inconsistencias > 0)
                {
                    // Ya fue marcado como bloqueado por VerificarIntegridadTotal.
                }
            }
            catch (Exception ex)
            {
                // Si la verificación misma falla, bloquear por seguridad.
                // EstadoSistema.Bloquear es internal a SERVICIOS: se pasa por el wrapper
                // público de SERVICIOS_DigitoVerificador en vez de acceder directo.
                SERVICIOS_DigitoVerificador.BloquearPorFallaDeVerificacion(
                    "Error en verificación de arranque: " + ex.Message);
            }

            IniciarTimerVerificacionPeriodica();
        }

        private void IniciarTimerVerificacionPeriodica()
        {
            TimeSpan periodo = TimeSpan.FromMinutes(ObtenerIntervaloMinutos());

            _timerVerificacionPeriodica = new Timer(
                VerificacionPeriodicaCallback,
                null,
                periodo,
                periodo);
        }

        private static int ObtenerIntervaloMinutos()
        {
            string valorConfig = ConfigurationManager.AppSettings["IntervaloVerificacionMinutos"];
            int minutos;
            if (!int.TryParse(valorConfig, out minutos) || minutos <= 0)
                return IntervaloMinutosPorDefecto;
            return minutos;
        }

        private static void VerificacionPeriodicaCallback(object state)
        {
            // No-solapamiento: si el tick anterior todavía está corriendo, este se saltea.
            if (Interlocked.CompareExchange(ref _verificacionEnCurso, 1, 0) != 0)
                return;

            try
            {
                // Verificación LIVIANA (solo la tabla crítica), no VerificarIntegridadTotal.
                // Ya llama a EstadoSistema.Bloquear internamente si encuentra inconsistencias;
                // no se duplica esa lógica acá.
                SERVICIOS_DigitoVerificador.VerificarTablaCritica<BE_Usuario>();
            }
            catch (Exception ex)
            {
                // No se deja escapar la excepción (un callback de System.Threading.Timer corre
                // en un hilo de ThreadPool; una excepción no observada ahí puede tumbar el
                // proceso completo). Pero tragarla en silencio significa que el detector
                // periódico se puede apagar sin que nadie se entere, así que se deja registro
                // persistente ANTES de descartarla.
                RegistrarFallaVerificacionPeriodica(ex);
            }
            finally
            {
                Interlocked.Exchange(ref _verificacionEnCurso, 0);
            }
        }

        // Archivo en App_Data en vez de Windows Event Log o Bitácora:
        // - EventLog.WriteEntry necesita una "fuente" registrada en el registro de Windows;
        //   crearla requiere permisos de administrador que la identidad del app pool
        //   normalmente no tiene, así que puede fallar en silencio según el hosting.
        // - Bitácora pasa por la misma conexión a la BD que la propia verificación acaba
        //   de usar. Si la falla es justamente de conectividad a la BD (el caso más
        //   probable), el intento de loguear el fallo en la BD fallaría por la misma razón
        //   que se quiere registrar — no sirve como red de contención para ese escenario.
        // Un archivo plano en App_Data no depende de la BD ni de permisos especiales de OS,
        // y HostingEnvironment.MapPath (a diferencia de Server.MapPath / HttpContext.Current)
        // funciona sin un HttpContext activo, que es la situación del timer.
        private static void RegistrarFallaVerificacionPeriodica(Exception ex)
        {
            try
            {
                string carpeta = HostingEnvironment.MapPath("~/App_Data");
                Directory.CreateDirectory(carpeta);

                string ruta = Path.Combine(carpeta, "dv-verificacion-periodica.log");
                string linea = string.Format(
                    "{0:yyyy-MM-dd HH:mm:ss} | Falló la verificación periódica de integridad: {1}{2}",
                    DateTime.Now, ex, Environment.NewLine);

                File.AppendAllText(ruta, linea);
            }
            catch
            {
                // Si ni siquiera se puede escribir el log (disco lleno, permisos, etc.),
                // no hay más remedio que perder este tick sin registro. No debe volver a
                // tirar: seguimos garantizando que el callback del timer nunca crashea.
            }
        }
    }
}