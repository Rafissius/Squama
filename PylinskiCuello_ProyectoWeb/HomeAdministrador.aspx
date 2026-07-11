<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="HomeAdministrador.aspx.cs" Inherits="PylinskiCuello_ProyectoWeb.HomeAdministrador" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>SQUAMA &mdash; Panel de Administraci&oacute;n</title>
  <link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@400;600;700;900&family=IM+Fell+English:ital@0;1&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="Styles/base.css" />
  <link rel="stylesheet" href="Styles/navbar.css" />
  <link rel="stylesheet" href="Styles/home-admin.css" />
  <style>
    :root {
      --c-role:        #f29e38;
      --c-role-border: rgba(242,158,56,.70);
      --c-role-bg:     rgba(242,158,56,.20);
      --glow-bg:       rgba(242,158,56,.30);
      --c-admin:       #f29e38;
      --c-stats:       #5999f2;
      --c-banners:     #47d96b;
      --c-perfil:      #d9ad26;
    }
    .bg-glow {
      background: radial-gradient(ellipse at center, rgba(242,158,56,.30) 0%, rgba(120,70,10,.20) 55%, transparent 100%);
    }
    .nav-avatar {
      background: linear-gradient(135deg, rgba(242,158,56,.8), rgba(160,80,10,.8));
      color: #1a0a00;
    }
    .nav-user .uname { color: var(--gold-light); }
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
    <!-- NAVBAR -->
    <nav class="navbar" role="navigation">
      <div class="nav-brand">
        <span class="name">SQUAMA</span>
        <span class="sub">Forja tu Leyenda</span>
      </div>
      <div class="nav-role">ADMINISTRADOR</div>

      <div class="nav-links">
        <a href="HomeAdministrador.aspx" class="active">Inicio</a>
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

                    <asp:Button ID="BtnLogout" runat="server"
    CssClass="nav-logout"
    Text="Salir"
    OnClick="BtnLogout_Click"
    ToolTip="Cerrar sesión" />


      </div>

      <div class="nav-dropdown" id="navDropdown">
        <a href="HomeAdministrador.aspx" class="active">Inicio</a>
        <a href="EnConstruccionAdministrador.aspx">Objetos</a>
        <a href="EnConstruccionAdministrador.aspx">Banners</a>
        <a href="EnConstruccionAdministrador.aspx">Eventos</a>
        <a href="EnConstruccionAdministrador.aspx">Estad&iacute;sticas</a>
        <a href="EnConstruccionAdministrador.aspx">Perfil</a>
      </div>
    </nav>

    <!-- HERO -->
    <section class="hero">
      <span class="hero-badge">PANEL DE ADMINISTRACI&Oacute;N</span>
      <h1 class="hero-title">SQUAMA</h1>
      <p class="hero-sub">Gesti&oacute;n del contenido y balance del juego</p>
      <p class="hero-desc">Crea objetos, configura banners gacha, ajusta probabilidades y controla eventos.</p>
      <div class="hero-divider" aria-hidden="true"></div>
    </section>

    <!-- STATS BAR -->
    <div class="stats-bar" role="region" aria-label="Resumen del sistema">
      <div class="stat-item"><span class="stat-val" style="color:var(--c-admin)">247</span><span class="stat-lbl">Objetos totales</span></div>
      <div class="stat-item"><span class="stat-val" style="color:var(--c-stats)">4</span><span class="stat-lbl">Banners activos</span></div>
      <div class="stat-item"><span class="stat-val" style="color:var(--c-perfil)">1</span><span class="stat-lbl">Evento activo</span></div>
      <div class="stat-item"><span class="stat-val" style="color:#47d96b">320</span><span class="stat-lbl">Usuarios activos</span></div>
      <div class="stat-item"><span class="stat-val" style="color:var(--c-admin)">12</span><span class="stat-lbl">Acciones hoy</span></div>
    </div>

    <!-- 4 CARDS PRINCIPALES -->
    <main class="main-section">
      <div class="main-grid">

        <div class="card">
          <div class="card-top" style="background:var(--c-admin)"></div>
          <div class="card-body">
            <p class="card-title">Eventos Estad&iacute;sticos</p>
            <p class="card-desc">Crea y gestiona eventos que modifican el peso de estad&iacute;sticas en la f&oacute;rmula de combate.</p>
            <div class="card-status" style="background:rgba(242,158,56,.15);border:1px solid rgba(242,158,56,.45);color:var(--c-admin)">Evento activo: Semana de la Fuerza</div>
            <button type="button" class="card-btn" style="background:rgba(242,158,56,.85);color:#1f1205" onclick="location.href='EnConstruccionAdministrador.aspx'">Gestionar eventos</button>
          </div>
        </div>

        <div class="card">
          <div class="card-top" style="background:var(--c-stats)"></div>
          <div class="card-body">
            <p class="card-title">Estad&iacute;sticas del Juego</p>
            <p class="card-desc">Visualiza m&eacute;tricas: usuarios activos, combates, tiradas gacha y distribuciones de objetos.</p>
            <div class="card-status" style="background:rgba(89,153,242,.15);border:1px solid rgba(89,153,242,.45);color:var(--c-stats)">320 usuarios &mdash; 1.240 combates hoy</div>
            <button type="button" class="card-btn" style="background:rgba(89,153,242,.85);color:#fff" onclick="location.href='EnConstruccionAdministrador.aspx'">Ver estad&iacute;sticas</button>
          </div>
        </div>

        <div class="card">
          <div class="card-top" style="background:var(--c-banners)"></div>
          <div class="card-body">
            <p class="card-title">Gesti&oacute;n de Banners</p>
            <p class="card-desc">Configura los portales gacha activos, ajusta probabilidades por rareza y define la vigencia de cada banner.</p>
            <div class="card-status" style="background:rgba(71,217,107,.15);border:1px solid rgba(71,217,107,.45);color:var(--c-banners)">4 banners activos &mdash; 148 objetos en rotaci&oacute;n</div>
            <button type="button" class="card-btn" style="background:rgba(71,217,107,.85);color:#0a2010" onclick="location.href='EnConstruccionAdministrador.aspx'">Gestionar banners</button>
          </div>
        </div>

        <div class="card">
          <div class="card-top" style="background:var(--c-perfil)"></div>
          <div class="card-body">
            <p class="card-title">Mi Perfil Admin</p>
            <p class="card-desc">Accede a tu perfil de administrador. Revisa tu actividad y acciones recientes en el sistema.</p>
            <div class="card-status" style="background:rgba(217,173,38,.15);border:1px solid rgba(217,173,38,.45);color:var(--c-perfil)">&Uacute;ltimo acceso: hoy &mdash; Sesi&oacute;n activa</div>
            <button type="button" class="card-btn" style="background:rgba(217,173,38,.85);color:#1f1205" onclick="location.href='EnConstruccionAdministrador.aspx'">Ver mi perfil</button>
          </div>
        </div>

      </div>
    </main>

    <!-- QUICK ACTIONS — solo ABMs -->
    <div class="quick-section">
      <p class="quick-title">Acciones r&aacute;pidas &mdash; ABM de objetos</p>
      <div class="quick-grid">
        <button type="button" class="quick-btn" onclick="location.href='EnConstruccionAdministrador.aspx'"><span class="qb-name">ABM Armas</span><span class="qb-sub">Crear / editar / eliminar</span></button>
        <button type="button" class="quick-btn" onclick="location.href='EnConstruccionAdministrador.aspx'"><span class="qb-name">ABM Armaduras</span><span class="qb-sub">Gestionar armaduras</span></button>
        <button type="button" class="quick-btn" onclick="location.href='EnConstruccionAdministrador.aspx'"><span class="qb-name">ABM Mascotas</span><span class="qb-sub">Gestionar mascotas</span></button>
        <button type="button" class="quick-btn" onclick="location.href='EnConstruccionAdministrador.aspx'"><span class="qb-name">ABM Habilidades</span><span class="qb-sub">Gestionar habilidades</span></button>
      </div>
    </div>

  </div>
</div>

<script src="Scripts/nav.js"></script>
    </form>

</body>
</html>