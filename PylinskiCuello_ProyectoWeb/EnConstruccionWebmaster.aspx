<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EnConstruccionWebmaster.aspx.cs" Inherits="PylinskiCuello_ProyectoWeb.EnConstruccionWebmaster" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>SQUAMA &mdash; En Construcci&oacute;n</title>
  <link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@400;600;700;900&family=IM+Fell+English:ital@0;1&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="Styles/base.css" />
  <link rel="stylesheet" href="Styles/navbar.css" />
  <link rel="stylesheet" href="Styles/en-construccion.css" />
  <style>
    :root {
      --c-role:        #b86bf2;
      --c-role-border: rgba(184,107,242,.70);
      --c-role-bg:     rgba(184,107,242,.20);
      --glow-bg:       rgba(184,107,242,.25);
    }
    .bg-glow {
      background: radial-gradient(ellipse at center, rgba(184,107,242,.22) 0%, rgba(92,54,121,.12) 55%, transparent 100%);
    }
    .nav-avatar {
      background: linear-gradient(135deg, rgba(184,107,242,.8), rgba(92,54,121,.8));
      color: #fff;
    }
  </style>
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

<div class="page">
  <div class="bg-stripes"   aria-hidden="true"></div>
  <div class="bg-vignette"  aria-hidden="true"></div>
  <div class="bg-glow"      aria-hidden="true"></div>
  <div class="bg-sides"     aria-hidden="true"></div>
  <div class="border-frame" aria-hidden="true"></div>

  <div class="content">

    <!-- NAVBAR WEBMASTER -->
    <nav class="navbar" role="navigation">
      <div class="nav-brand">
        <span class="name">SQUAMA</span>
        <span class="sub">Forja tu Leyenda</span>
      </div>
      <div class="nav-role">WEBMASTER</div>
      <div class="nav-links">
        <a href="HomeWebmaster.aspx">Inicio</a>
        <a href="GestionUsuarios.aspx">Usuarios</a>
        <a href="EnConstruccionWebmaster.aspx">Perfiles</a>
        <a href="BitacoraEventos.aspx">Bit&aacute;cora</a>
        <a href="BackUpYRestore.aspx">Backup/Restore</a>
        <a href="EnConstruccionWebmaster.aspx">Seguridad</a>
      </div>
<button type="button" class="nav-hamburger" onclick="toggleNav()" aria-label="Abrir menú">&#9776;</button>
      <div class="nav-right">
        <div class="nav-avatar">W</div>
        <div class="nav-user">
          <span class="uname">Webmaster</span>
          <span class="urole">WEBMASTER</span>
        </div>
        <asp:Button ID="BtnLogout" runat="server" CssClass="nav-logout"
          Text="Salir" OnClick="BtnLogout_Click" ToolTip="Cerrar sesi&oacute;n" />
      </div>
      <div class="nav-dropdown" id="navDropdown">
        <a href="HomeWebmaster.aspx">Inicio</a>
        <a href="GestionUsuarios.aspx">Usuarios</a>
        <a href="EnConstruccionWebmaster.aspx">Perfiles</a>
        <a href="BitacoraEventos.aspx">Bit&aacute;cora</a>
        <a href="BackUpYRestore.aspx">Backup / Restore</a>
        <a href="EnConstruccionWebmaster.aspx">Seguridad</a>
      </div>
    </nav>

    <!-- CONTENIDO -->
    <div class="wip-section">
      <div class="wip-icon">⚒</div>
      <div class="wip-divider-top" aria-hidden="true"></div>
      <span class="wip-badge">SECCIÓN EN DESARROLLO</span>
      <h1 class="wip-title">EN CONSTRUCCI&Oacute;N</h1>
      <p class="wip-sub">Los herreros del reino trabajan en esto</p>
      <p class="wip-desc">Esta pantalla a&uacute;n no ha sido forjada. Regresa pronto; el reino crece con cada luna.</p>
      <div class="wip-divider-bot" aria-hidden="true"></div>
      <button type="button" class="wip-btn" onclick="location.href='HomeWebmaster.aspx'">
        &#8592; Volver al inicio
      </button>
    </div>

  </div>
</div>

<script src="Scripts/nav.js"></script>
</form>
</body>
</html>