<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="HomeJugador.aspx.cs" Inherits="PylinskiCuello_ProyectoWeb.HomeJugador" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>SQUAMA &mdash; Inicio</title>
  <link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@400;600;700;900&family=IM+Fell+English:ital@0;1&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="Styles/base.css" />
  <link rel="stylesheet" href="Styles/navbar.css" />
  <link rel="stylesheet" href="Styles/home-jugador.css" />
  <style>
    :root {
      --c-role:        #d9ad26;
      --c-role-border: rgba(217,173,38,.70);
      --c-role-bg:     rgba(217,173,38,.20);
      --glow-bg:       rgba(160,80,20,.45);
      --c-perfil:      #d9ad26;
      --c-arena:       #f2522e;
      --c-gacha:       #b86bf2;
      --c-clan:        #47d96b;
      --c-tienda:      #5999f2;
    }
    .bg-glow {
      background: radial-gradient(ellipse at center, rgba(160,80,20,.45) 0%, rgba(90,40,10,.25) 55%, transparent 100%);
    }
    .nav-avatar {
      background: linear-gradient(135deg, #a67a14, #80520a);
      color: #1a0a00;
    }
    .nav-user .uname { color: var(--gold); }
    .nav-brand .name { letter-spacing: 1px; }
    .nav-links a.active::after { left: 12px; right: 12px; }
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
      <div class="nav-role">JUGADOR</div>

      <!-- Nav horizontal (desktop) -->
      <div class="nav-links">
        <a href="HomeJugador.aspx" class="active">Inicio</a>
        <a href="EnConstruccionJugador.aspx">Perfil</a>
        <a href="SeleccionarRival.aspx">Arena</a>
        <a href="EnConstruccionJugador.aspx">Gacha</a>
        <a href="EnConstruccionJugador.aspx">Clan</a>
        <a href="EnConstruccionJugador.aspx">Tienda</a>
      </div>

      <!-- Hamburger (mobile) -->
<button type="button" class="nav-hamburger" onclick="toggleNav()" aria-label="Abrir menú">&#9776;</button>

      <div class="nav-right">
        <div class="nav-avatar">G</div>
        <div class="nav-user">
          <asp:Label ID="LblNavNombre" runat="server" CssClass="uname" Text="Goku" />
          <span class="ulevel">Nivel <asp:Label ID="LblNavNivel" runat="server" Text="24" /> &bull; Los Dragon</span>
        </div>

                    <asp:Button ID="BtnLogout" runat="server"
    CssClass="nav-logout"
    Text="Salir"
    OnClick="BtnLogout_Click"
    ToolTip="Cerrar sesión" />


      </div>

      <!-- Dropdown mobile -->
      <div class="nav-dropdown" id="navDropdown">
        <a href="HomeJugador.aspx" class="active">Inicio</a>
        <a href="EnConstruccionJugador.aspx">Perfil</a>
        <a href="SeleccionarRival.aspx">Arena</a>
        <a href="EnConstruccionJugador.aspx">Gacha</a>
        <a href="EnConstruccionJugador.aspx">Clan</a>
        <a href="EnConstruccionJugador.aspx">Tienda</a>
      </div>
    </nav>

    <!-- HERO -->
    <section class="hero">
      <span class="hero-badge">BIENVENIDO, GUERRERO</span>
      <h1 class="hero-title">SQUAMA</h1>
      <p class="hero-sub">El campo de batalla te aguarda</p>
      <p class="hero-desc">Forja tu leyenda con cada combate, cada invocaci&oacute;n y cada alianza.</p>
      <div class="hero-divider" aria-hidden="true"></div>
    </section>

    <!-- STATS BAR -->
    <div class="stats-bar" role="region" aria-label="Resumen del jugador">
      <div class="stat-item"><asp:Label ID="LblStatNivel" runat="server" CssClass="stat-val" Style="color:var(--gold)" Text="24" /><span class="stat-lbl">Tu nivel</span></div>
      <div class="stat-item"><span class="stat-val" style="color:var(--c-arena)">3/5</span><span class="stat-lbl">Intentos arena</span></div>
      <div class="stat-item"><span class="stat-val" style="color:var(--c-gacha)">3.420</span><span class="stat-lbl">Monedas</span></div>
      <div class="stat-item"><span class="stat-val" style="color:var(--c-clan)">57%</span><span class="stat-lbl">Jefe clan HP</span></div>
      <div class="stat-item"><span class="stat-val" style="color:var(--c-tienda)">Fuerza</span><span class="stat-lbl">Evento activo</span></div>
    </div>

    <!-- PROTOTIPO: Personaje + Estadísticas + Nivel -->
    <asp:Panel ID="PanelPersonajePrototipo" runat="server" CssClass="card-status" Style="margin:20px 0;padding:16px;display:block">
      <p>Experiencia: <asp:Label ID="LblXPActual" runat="server" /> / <asp:Label ID="LblXPSiguiente" runat="server" /></p>
      <asp:Repeater ID="RptEstadisticas" runat="server">
        <ItemTemplate>
          <span class="stat-pill"><%# Eval("Nombre") %>: <%# Eval("ValorBase") %></span>
        </ItemTemplate>
      </asp:Repeater>
      <asp:Button ID="BtnGanarXPPrueba" runat="server" CssClass="card-btn" Text="Ganar XP de prueba" OnClick="BtnGanarXPPrueba_Click" />
    </asp:Panel>

    <!-- CARDS — mismo orden que el nav: Perfil, Arena, Gacha, Clan, Tienda -->
    <main class="cards-section">
      <div class="cards-grid">

        <div class="card">
          <div class="card-top" style="background:var(--c-perfil)"></div>
          <div class="card-body">
            <p class="card-title">Mi Perfil</p>
            <p class="card-desc">Consulta tus estad&iacute;sticas, historial de combates, logros y progreso de nivel.</p>
            <div class="card-status" style="background:rgba(217,173,38,.15);border:1px solid rgba(217,173,38,.45);color:var(--c-perfil)">Nivel 24 &mdash; Rango Oro &mdash; 287 combates</div>
            <button type="button" class="card-btn" style="background:rgba(217,173,38,.85);color:#1f1205" onclick="location.href='EnConstruccionJugador.aspx'">Ver mi perfil</button>
          </div>
        </div>

        <div class="card">
          <div class="card-top" style="background:var(--c-arena)"></div>
          <div class="card-body">
            <p class="card-title">Arena</p>
            <p class="card-desc">Elige entre 6 rivales de tu nivel y combate. El resultado se calcula por f&oacute;rmula con aleatoriedad controlada.</p>
            <div class="card-status" style="background:rgba(242,82,46,.15);border:1px solid rgba(242,82,46,.45);color:var(--c-arena)">3 intentos disponibles hoy</div>
            <button type="button" class="card-btn" style="background:rgba(242,82,46,.85);color:#fff" onclick="location.href='SeleccionarRival.aspx'">Entrar a la arena</button>
          </div>
        </div>

        <div class="card">
          <div class="card-top" style="background:var(--c-gacha)"></div>
          <div class="card-body">
            <p class="card-title">Gacha</p>
            <p class="card-desc">Abre portales y obtiene armas, armaduras, mascotas y habilidades para equipar a tu personaje.</p>
            <div class="card-status" style="background:rgba(184,107,242,.15);border:1px solid rgba(184,107,242,.45);color:var(--c-gacha)">3.420 monedas disponibles</div>
            <button type="button" class="card-btn" style="background:rgba(184,107,242,.85);color:#fff" onclick="location.href='EnConstruccionJugador.aspx'">Ir al Gacha</button>
          </div>
        </div>

        <div class="card">
          <div class="card-top" style="background:var(--c-clan)"></div>
          <div class="card-body">
            <p class="card-title">Clan</p>
            <p class="card-desc">Une fuerzas con tu clan. Ataca al jefe diario y obtiene bonificaciones para todos los miembros.</p>
            <div class="card-status" style="background:rgba(71,217,107,.15);border:1px solid rgba(71,217,107,.45);color:var(--c-clan)">Los Dragon &mdash; Nivel 3 &mdash; 42 miembros</div>
            <button type="button" class="card-btn" style="background:rgba(71,217,107,.85);color:#0a2010" onclick="location.href='EnConstruccionJugador.aspx'">Ver mi clan</button>
          </div>
        </div>

        <div class="card">
          <div class="card-top" style="background:var(--c-tienda)"></div>
          <div class="card-body">
            <p class="card-title">Tienda</p>
            <p class="card-desc">Compra paquetes de monedas, tiradas adicionales y packs especiales para potenciar tu progresi&oacute;n.</p>
            <div class="card-status" style="background:rgba(89,153,242,.15);border:1px solid rgba(89,153,242,.45);color:var(--c-tienda)">Packs disponibles &mdash; Eventos activos</div>
            <button type="button" class="card-btn" style="background:rgba(89,153,242,.85);color:#fff" onclick="location.href='EnConstruccionJugador.aspx'">Ir a la tienda</button>
          </div>
        </div>

      </div>
    </main>
  </div>
</div>

<script src="Scripts/nav.js"></script>
        </form>
</body>
</html>