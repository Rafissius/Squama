<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EnConstruccionAdministrador.aspx.cs" Inherits="PylinskiCuello_ProyectoWeb.EnConstruccionAdministrador" %>
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
      --c-role:        #f29e38;
      --c-role-border: rgba(242,158,56,.70);
      --c-role-bg:     rgba(242,158,56,.20);
      --glow-bg:       rgba(242,158,56,.30);
    }
    .bg-glow {
      background: radial-gradient(ellipse at center, rgba(242,158,56,.30) 0%, rgba(120,70,10,.15) 55%, transparent 100%);
    }
    .nav-avatar {
      background: linear-gradient(135deg, rgba(242,158,56,.8), rgba(160,80,10,.8));
      color: #1a0a00;
    }
    .nav-user .uname { color: var(--gold-light); }
    .wip-title { color: var(--gold); text-shadow: 0 0 40px rgba(217,173,38,.30), 0 4px 8px rgba(0,0,0,.8); }
  </style>
</head>
<body>
<form id="form1" runat="server">
<div class="page">
  <div class="bg-stripes"   aria-hidden="true"></div>
  <div class="bg-vignette"  aria-hidden="true"></div>
  <div class="bg-glow"      aria-hidden="true"></div>
  <div class="bg-sides"     aria-hidden="true"></div>
  <div class="border-frame" aria-hidden="true"></div>

  <div class="content">

    <!-- NAVBAR ADMINISTRADOR -->
    <nav class="navbar" role="navigation">
      <div class="nav-brand">
        <span class="name">SQUAMA</span>
        <span class="sub">Forja tu Leyenda</span>
      </div>
      <div class="nav-role">ADMINISTRADOR</div>
      <div class="nav-links">
        <a href="HomeAdministrador.aspx">Inicio</a>
        <a href="EnConstruccionAdministrador.aspx">Objetos</a>
        <a href="EnConstruccionAdministrador.aspx">Banners</a>
        <a href="EnConstruccionAdministrador.aspx">Eventos</a>
        <a href="EnConstruccionAdministrador.aspx">Estad&iacute;sticas</a>
        <a href="EnConstruccionAdministrador.aspx">Perfil</a>
      </div>
<button type="button" class="nav-hamburger" onclick="toggleNav()" aria-label="Abrir menú">&#9776;</button>
      <div class="nav-right">
        <div class="nav-avatar">A</div>
        <div class="nav-user">
          <span class="uname">Admin</span>
          <span class="urole">ADMINISTRADOR</span>
        </div>
        <asp:Button ID="BtnLogout" runat="server" CssClass="nav-logout"
          Text="Salir" OnClick="BtnLogout_Click" ToolTip="Cerrar sesi&oacute;n" />
      </div>
      <div class="nav-dropdown" id="navDropdown">
        <a href="HomeAdministrador.aspx">Inicio</a>
        <a href="EnConstruccionAdministrador.aspx">Objetos</a>
        <a href="EnConstruccionAdministrador.aspx">Banners</a>
        <a href="EnConstruccionAdministrador.aspx">Eventos</a>
        <a href="EnConstruccionAdministrador.aspx">Estad&iacute;sticas</a>
        <a href="EnConstruccionAdministrador.aspx">Perfil</a>
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
      <button type="button" class="wip-btn" onclick="location.href='HomeAdministrador.aspx'">
        &#8592; Volver al inicio
      </button>
    </div>

  </div>
</div>

<script src="Scripts/nav.js"></script>
</form>
</body>
</html>