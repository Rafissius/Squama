<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SistemaBloqueado.aspx.cs" Inherits="PylinskiCuello_ProyectoWeb.SistemaBloqueado" %>
<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="UTF-8" />
    <title>SQUAMA &mdash; Sistema en mantenimiento</title>
</head>
<body>
    <form id="form1" runat="server">

               <!-- SESION UNICA -->
        <asp:ScriptManager ID="ScriptManagerSesion" runat="server" />
<asp:UpdatePanel ID="UpdatePanelSesion" runat="server">
    <ContentTemplate>
        <asp:Timer ID="TimerSesion" runat="server" Interval="1000" OnTick="TimerSesion_Tick" />
    </ContentTemplate>
</asp:UpdatePanel>
           <!-- SESION UNICA -->

        <div style="max-width:600px;margin:80px auto;text-align:center;font-family:sans-serif;">
            <h1>Sistema en mantenimiento</h1>
            <p>El sistema detect&oacute; una inconsistencia de integridad y est&aacute; en mantenimiento.</p>
            <p>Contacte al webmaster.</p>
            <p><a runat="server" href="~/LoginIniciarSesion.aspx">Ir al login</a></p>
        </div>
        <asp:Button ID="Button1" runat="server" OnClick="Button1_Click" Text="Button" />
    </form>
</body>
</html>
