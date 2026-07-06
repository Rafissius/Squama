<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EnConstruccionJugador.aspx.cs" Inherits="PylinskiCuello_ProyectoWeb.EnConstruccionJugador" %>
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
      --c-role:        #d9ad26;
      --c-role-border: rgba(217,173,38,.70);
      --c-role-bg:     rgba(217,173,38,.20);
      --glow-bg:       rgba(160,80,20,.45);
    }
    .bg-glow {
      background: radial-gradient(ellipse at center, rgba(160,80,20,.40) 0%, rgba(90,40,10,.20) 55%, transparent 100%);
    }
    .nav-avatar {
      background: linear-gradient(135deg, #a67a14, #80520a);
      color: #1a0a00;
    }
    .nav-brand .name { letter-spacing: 1px; }
    .nav-user .uname { color: var(--gold); }
    .nav-links a.active::after { left: 12px; right: 12px; }
    .wip-title { color: var(--gold); text-shadow: 0 0 40px rgba(217,173,38,.30), 0 4px 8px rgba(0,0,0,.8); }
    .wip-badge { border-color: rgba(217,173,38,.50); background: rgba(217,173,38,.12); color: var(--gold); }
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

    <!-- NAVBAR JUGADOR -->
    <nav class="navbar" role="navigation">
      <div class="nav-brand">
        <span class="name">SQUAMA</span>
        <span class="sub">Forja tu Leyenda</span>
      </div>
      <div class="nav-role">JUGADOR</div>
      <div class="nav-links">
        <a href="HomeJugador.aspx">Inicio</a>
        <a href="EnConstruccionJugador.aspx">Perfil</a>
        <a href="EnConstruccionJugador.aspx">Arena</a>
        <a href="EnConstruccionJugador.aspx">Gacha</a>
        <a href="EnConstruccionJugador.aspx">Clan</a>
        <a href="EnConstruccionJugador.aspx">Tienda</a>
      </div>
<button type="button" class="nav-hamburger" onclick="toggleNav()" aria-label="Abrir menú">&#9776;</button>
      <div class="nav-right">
        <div class="nav-avatar">G</div>
        <div class="nav-user">
          <span class="uname">Goku</span>
          <span class="ulevel">Nivel 24 &bull; Los Dragon</span>
        </div>
        <asp:Button ID="BtnLogout" runat="server" CssClass="nav-logout"
          Text="Salir" OnClick="BtnLogout_Click" ToolTip="Cerrar sesi&oacute;n" />
      </div>
      <div class="nav-dropdown" id="navDropdown">
        <a href="HomeJugador.aspx">Inicio</a>
        <a href="EnConstruccionJugador.aspx">Perfil</a>
        <a href="EnConstruccionJugador.aspx">Arena</a>
        <a href="EnConstruccionJugador.aspx">Gacha</a>
        <a href="EnConstruccionJugador.aspx">Clan</a>
        <a href="EnConstruccionJugador.aspx">Tienda</a>
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
      <button type="button" class="wip-btn" onclick="location.href='HomeJugador.aspx'">
        &#8592; Volver al inicio
      </button>
    </div>

  </div>
</div>

<script src="Scripts/nav.js"></script>
</form>
</body>
</html>