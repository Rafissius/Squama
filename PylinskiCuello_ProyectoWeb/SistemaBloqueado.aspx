<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SistemaBloqueado.aspx.cs" Inherits="PylinskiCuello_ProyectoWeb.SistemaBloqueado" %>
<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="UTF-8" />
    <title>SQUAMA &mdash; Sistema en mantenimiento</title>
</head>
<body>
    <form id="form1" runat="server">
        <div style="max-width:600px;margin:80px auto;text-align:center;font-family:sans-serif;">
            <h1>Sistema en mantenimiento</h1>
            <p>El sistema detect&oacute; una inconsistencia de integridad y est&aacute; en mantenimiento.</p>
            <p>Contacte al webmaster.</p>
            <p><a runat="server" href="~/LoginIniciarSesion.aspx">Ir al login</a></p>
        </div>
    </form>
</body>
</html>
