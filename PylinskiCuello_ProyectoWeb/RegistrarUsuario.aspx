<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RegistrarUsuario.aspx.cs" Inherits="PylinskiCuello_ProyectoWeb.RegistrarUsuario" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Squama - Crear Cuenta</title>
      <link rel="stylesheet" href="Styles/RegistrarUsuario.css" />

</head>
<body class="registro-body">
    <form id="form1" runat="server">

          

        <div class="registro-marco">

            <header class="registro-header">
                <h1 class="registro-titulo">SQUAMA</h1>
                <p class="registro-subtitulo">Unete a la aventura</p>
            </header>

            <div class="registro-layout">

                <section class="registro-card">
                    <h2 class="card-titulo">Crea tu cuenta de guerrero</h2>
                    <p class="card-descripcion">Completa tus datos y comienza tu leyenda en Squama</p>

                    <asp:Label ID="lblMensaje" runat="server" CssClass="mensaje" EnableViewState="false"></asp:Label>

                    <div class="form-group">
                        <asp:Label runat="server" AssociatedControlID="txtNombreUsuario" CssClass="form-label">Nombre de usuario</asp:Label>
                        <asp:TextBox ID="txtNombreUsuario" runat="server" CssClass="form-control" placeholder="Ej: Aldric_Guerrero" MaxLength="50"></asp:TextBox>
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtNombreUsuario"
                            CssClass="form-error" ErrorMessage="Ingresa un nombre de usuario." Display="Dynamic" ValidationGroup="Registro" />
                    </div>

                    <div class="form-group">
                        <asp:Label runat="server" AssociatedControlID="txtEmail" CssClass="form-label">Correo electronico</asp:Label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" placeholder="tu@correo.com" MaxLength="100"></asp:TextBox>
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEmail"
                            CssClass="form-error" ErrorMessage="Ingresa tu correo electronico." Display="Dynamic" ValidationGroup="Registro" />
                        <asp:RegularExpressionValidator runat="server" ControlToValidate="txtEmail"
                            CssClass="form-error" ErrorMessage="El correo no tiene un formato valido."
                            ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" Display="Dynamic" ValidationGroup="Registro" />
                    </div>

                    <div class="form-row">
                        <div class="form-group form-group-mitad">
                            <asp:Label runat="server" AssociatedControlID="txtClave" CssClass="form-label">Clave</asp:Label>
                            <asp:TextBox ID="txtClave" runat="server" CssClass="form-control" TextMode="Password" placeholder="********"></asp:TextBox>
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtClave"
                                CssClass="form-error" ErrorMessage="Ingresa una clave." Display="Dynamic" ValidationGroup="Registro" />
                        </div>
                        <div class="form-group form-group-mitad">
                            <asp:Label runat="server" AssociatedControlID="txtConfirmarClave" CssClass="form-label">Confirmar contrasena</asp:Label>
                            <asp:TextBox ID="txtConfirmarClave" runat="server" CssClass="form-control" TextMode="Password" placeholder="********"></asp:TextBox>
                            <asp:CompareValidator runat="server" ControlToValidate="txtConfirmarClave" ControlToCompare="txtClave"
                                CssClass="form-error" ErrorMessage="Las claves no coinciden." Display="Dynamic" ValidationGroup="Registro" />
                        </div>
                    </div>

                    <div class="form-group form-checkbox">
                        <asp:CheckBox ID="chkTerminos" runat="server" />
                        <asp:Label runat="server" AssociatedControlID="chkTerminos" CssClass="checkbox-label">Acepto los terminos y condiciones de Squama</asp:Label>
                    </div>

                    <asp:Button ID="btnRegistrar" runat="server" CssClass="btn-primario"
                        Text="Crear mi cuenta y comenzar" OnClick="btnRegistrar_Click" ValidationGroup="Registro" />

                    <div class="separador-o"><span>o</span></div>

                    <p class="texto-secundario">Ya tenes cuenta?</p>
                    <asp:HyperLink ID="lnkIniciarSesion" runat="server" CssClass="btn-secundario" NavigateUrl="LoginIniciarSesion.aspx">Iniciar sesion</asp:HyperLink>

                    <asp:HyperLink ID="lnkVolver" runat="server" CssClass="link-volver" NavigateUrl="LoginIniciarSesion.aspx">&larr; Volver al inicio</asp:HyperLink>
                </section>

                <aside class="registro-beneficios">
                    <h3>Al registrarte obtienes:</h3>
                    <ul>
                        <li class="beneficio beneficio-dorado"><span class="beneficio-punto"></span>500 Monedas de bienvenida para tu primer gacha</li>
                        <li class="beneficio beneficio-azul"><span class="beneficio-punto"></span>Personaje inicial con estadisticas aleatorias</li>
                        <li class="beneficio beneficio-verde"><span class="beneficio-punto"></span>Acceso a la arena tras el nivel 3</li>
                        <li class="beneficio beneficio-violeta"><span class="beneficio-punto"></span>Posibilidad de unirte o crear un clan</li>
                        <li class="beneficio beneficio-naranja"><span class="beneficio-punto"></span>Un objeto comun garantizado en tu primera tirada</li>
                    </ul>
                </aside>

            </div>

            <p class="pie-frase">Tu leyenda comienza hoy</p>
        </div>
    </form>
</body>
</html>