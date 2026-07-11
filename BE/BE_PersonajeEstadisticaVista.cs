namespace BE
{
    // DTO de solo lectura (JOIN PersonajeEstadistica+Estadistica) para mostrar las
    // estadísticas de un personaje en pantalla, mismo espíritu que
    // BE_EventoBitacoraVista/BE_UsuarioListItem.
    public class BE_PersonajeEstadisticaVista
    {
        public int IDEstadistica { get; set; }
        public string Nombre { get; set; }
        public int ValorBase { get; set; }
    }
}
