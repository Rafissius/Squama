<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="HomeAdministrador.aspx.cs" Inherits="PylinskiCuello_ProyectoWeb.HomeAdministrador" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>SQUAMA &mdash; Panel de Administraci&oacute;n</title>
  <link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@400;600;700;900&family=IM+Fell+English:ital@0;1&display=swap" rel="stylesheet"/>
  <style>
    :root {
      --bg:         #2e1a0a;
      --gold:       #d9ad26;
      --gold-inner: rgba(242,209,128,0.35);
      --gold-light: #f2d180;
      --gold-mid:   #ebd9ad;
      --stripe:     rgba(82,46,20,0.14);
      --card-a:     rgba(61,36,13,0.97);
      --card-b:     rgba(41,23,8,0.97);
      --c-admin:    #f29e38;
      --c-stats:    #5999f2;
      --c-banners:  #47d96b;
      --c-perfil:   #d9ad26;
    }
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    html, body { width: 100%; min-height: 100dvh; background: var(--bg); font-family: 'Cinzel', serif; }
    .page { position: relative; width: 100%; min-height: 100dvh; display: flex; flex-direction: column; overflow: hidden; }

    .bg-stripes  { position: fixed; inset: 0; z-index: 0; pointer-events: none;
      background: repeating-linear-gradient(to bottom, var(--stripe) 0, var(--stripe) 26px, transparent 26px, transparent 50px); }
    .bg-vignette { position: fixed; inset: 0; z-index: 1; pointer-events: none;
      background: radial-gradient(ellipse at 50% 50%, transparent 25%, rgba(0,0,0,.30) 60%, rgba(0,0,0,.80) 100%); }
    .bg-glow     { position: fixed; z-index: 1; pointer-events: none; top: 50%; left: 50%;
      transform: translate(-50%,-50%); width: 80vw; height: 65vh; border-radius: 50%;
      background: radial-gradient(ellipse at center, rgba(242,158,56,.30) 0%, rgba(120,70,10,.20) 55%, transparent 100%); }
    .bg-sides    { position: fixed; inset: 0; z-index: 1; pointer-events: none;
      background: linear-gradient(to right, rgba(46,26,10,.60) 0%, transparent 18%),
                  linear-gradient(to left,  rgba(46,26,10,.60) 0%, transparent 18%); }
    .border-frame { position: fixed; inset: 0; z-index: 50; pointer-events: none; box-shadow: inset 0 0 0 4px var(--gold); }
    .border-frame::after { content: ''; position: absolute; inset: 12px; border: 2px solid var(--gold-inner); }
    .content { position: relative; z-index: 10; display: flex; flex-direction: column; flex: 1; }

    /* ── NAVBAR ── */
    .navbar { position: relative; width: 100%; height: 68px;
      background: rgba(15,8,3,.96); display: flex; align-items: center;
      border-bottom: 3px solid rgba(217,173,38,.30); }
    .navbar::before { content: ''; position: absolute; top: 0; left: 0; right: 0; height: 3px; background: var(--gold); }
    .nav-brand { display: flex; flex-direction: column; padding: 0 14px 0 28px; line-height: 1.1; flex-shrink: 0; }
    .nav-brand .name { font-size: 22px; font-weight: 700; color: var(--gold); }
    .nav-brand .sub  { font-size: 10px; color: #f5e8bf; font-weight: 400; }
    .nav-role { margin: 0 14px; padding: 3px 14px; border-radius: 11px; flex-shrink: 0;
      border: 1px solid rgba(242,158,56,.70); background: rgba(242,158,56,.20);
      font-size: 10px; font-weight: 700; color: var(--c-admin); white-space: nowrap; }
    .nav-links { display: flex; }
    .nav-links a { padding: 24px 14px 22px; text-decoration: none; font-size: 13px; font-weight: 400;
      color: #f5e8bf; position: relative; transition: color .2s; white-space: nowrap; }
    .nav-links a:hover { color: var(--gold-light); }
    .nav-links a.active { font-weight: 700; color: var(--gold); }
    .nav-links a.active::after { content: ''; position: absolute; bottom: 0; left: 10px; right: 10px;
      height: 3px; background: var(--gold); border-radius: 2px; }
    .nav-right { margin-left: auto; display: flex; align-items: center; gap: 10px; padding-right: 28px; flex-shrink: 0; }
    .nav-avatar { width: 44px; height: 44px; border-radius: 50%;
      background: linear-gradient(135deg, rgba(242,158,56,.8), rgba(160,80,10,.8));
      display: flex; align-items: center; justify-content: center;
      font-size: 18px; font-weight: 700; color: #1a0a00; border: 2px solid var(--c-admin); flex-shrink: 0; }
    .nav-user .uname { font-size: 13px; font-weight: 700; color: var(--gold-light); display: block; }
    .nav-user .urole { font-size: 11px; font-weight: 400; color: var(--c-admin); display: block; }

    /* ── HAMBURGER ── */
    .nav-hamburger { display: none; background: none;
      border: 1.5px solid rgba(242,158,56,.55); color: var(--c-admin);
      font-size: 18px; width: 38px; height: 38px; border-radius: 8px;
      cursor: pointer; align-items: center; justify-content: center;
      margin-left: 10px; transition: background .2s; flex-shrink: 0; }
    .nav-hamburger:hover { background: rgba(242,158,56,.15); }

    /* ── DROPDOWN MOBILE ── */
    .nav-dropdown { display: none; position: absolute; top: 68px; left: 0; right: 0;
      background: rgba(12,6,2,.98); border-bottom: 3px solid var(--gold);
      border-top: 1px solid rgba(242,158,56,.25); z-index: 200;
      flex-direction: column; box-shadow: 0 8px 24px rgba(0,0,0,.7); }
    .nav-dropdown.open { display: flex; }
    .nav-dropdown a { padding: 15px 28px; text-decoration: none; font-size: 14px; font-weight: 400;
      color: #f5e8bf; border-bottom: 1px solid rgba(217,173,38,.12);
      transition: background .2s, color .2s; position: relative; }
    .nav-dropdown a:hover  { background: rgba(242,158,56,.08); color: var(--gold-light); }
    .nav-dropdown a.active { font-weight: 700; color: var(--gold); background: rgba(217,173,38,.06); }
    .nav-dropdown a.active::before { content: ''; position: absolute; left: 0; top: 0; bottom: 0;
      width: 3px; background: var(--gold); border-radius: 0 2px 2px 0; }

    /* ── HERO ── */
    .hero { background: linear-gradient(to right, rgba(242,158,56,.25) 0%, transparent 50%);
      border-bottom: 2px solid rgba(217,173,38,.40);
      padding: clamp(18px,3vh,36px) 40px clamp(14px,2.5vh,28px);
      display: flex; flex-direction: column; align-items: center; text-align: center; gap: 6px; }
    .hero-badge { display: inline-block; padding: 3px 20px; border-radius: 14px;
      border: 1px solid rgba(242,158,56,.70); background: rgba(242,158,56,.20);
      font-size: 11px; font-weight: 700; color: var(--c-admin); letter-spacing: 1px; margin-bottom: 4px; }
    .hero-title { font-size: clamp(40px,6vw,80px); font-weight: 900; color: var(--gold); letter-spacing: 2px;
      text-shadow: 0 0 40px rgba(217,173,38,.35), 0 4px 8px rgba(0,0,0,.8); line-height: 1; }
    .hero-sub  { font-size: clamp(14px,1.6vw,20px); font-weight: 700; color: var(--gold-mid); letter-spacing: 1px; }
    .hero-desc { font-family: 'IM Fell English', serif; font-style: italic;
      font-size: clamp(12px,1.3vw,16px); color: #f5e8bf; max-width: 700px; }
    .hero-divider { width: min(600px,60%); height: 2px; background: rgba(217,173,38,.50); margin-top: 6px; border-radius: 1px; }

    /* ── STATS BAR ── */
    .stats-bar { display: flex; align-items: stretch; background: rgba(20,10,3,.88);
      border-top: 2px solid rgba(217,173,38,.35); border-bottom: 2px solid rgba(217,173,38,.20); }
    .stat-item { flex: 1; display: flex; flex-direction: column; align-items: center;
      justify-content: center; padding: 10px 8px; position: relative; }
    .stat-item + .stat-item::before { content: ''; position: absolute; left: 0; top: 15%; bottom: 15%;
      width: 1px; background: rgba(217,173,38,.30); }
    .stat-val { font-size: clamp(16px,2vw,26px); font-weight: 700; line-height: 1; }
    .stat-lbl { font-size: clamp(9px,.9vw,12px); font-weight: 400; color: #f5e8bf; margin-top: 3px; }

    /* ── CARDS GRID (4 cards) ── */
    .main-section { flex: 1; padding: clamp(14px,2vh,28px) clamp(16px,3vw,40px); }
    .main-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: clamp(10px,1.5vw,20px); }
    .card { position: relative; border-radius: 14px; overflow: hidden;
      background: linear-gradient(180deg, var(--card-a) 0%, var(--card-b) 50%, var(--card-a) 100%);
      border: 1.5px solid rgba(217,173,38,.30); display: flex; flex-direction: column;
      transition: transform .2s, box-shadow .2s; }
    .card:hover { transform: translateY(-3px); box-shadow: 0 8px 24px rgba(0,0,0,.5); }
    .card-top  { height: 5px; width: 100%; flex-shrink: 0; border-radius: 2px 2px 0 0; }
    .card-body { flex: 1; padding: clamp(14px,2vh,22px) clamp(12px,1.5vw,18px); display: flex; flex-direction: column; gap: 8px; }
    .card-title  { font-size: clamp(12px,1.1vw,16px); font-weight: 700; color: var(--gold-light); }
    .card-desc   { font-family: 'IM Fell English', serif; font-style: italic;
      font-size: clamp(11px,1vw,14px); color: #f5e8bf; line-height: 1.5; flex: 1; }
    .card-status { padding: 5px 10px; border-radius: 8px; font-size: clamp(9px,.85vw,11px); font-weight: 700; text-align: center; }
    .card-btn { width: 100%; padding: 8px; border-radius: 8px; border: none; cursor: pointer;
      font-family: 'Cinzel', serif; font-size: clamp(9px,.9vw,13px); font-weight: 700; letter-spacing: .5px;
      transition: filter .2s, transform .15s; }
    .card-btn:hover  { filter: brightness(1.15); transform: translateY(-1px); }
    .card-btn:active { filter: brightness(.90);  transform: translateY(1px);  }

    /* ── QUICK ACTIONS ── */
    .quick-section { padding: 0 clamp(16px,3vw,40px) clamp(14px,2vh,28px); }
    .quick-title { font-size: 11px; font-weight: 400; color: rgba(245,232,191,.6);
      letter-spacing: 1px; text-transform: uppercase; margin-bottom: 10px; }
    .quick-grid { display: flex; gap: clamp(8px,1vw,14px); flex-wrap: wrap; }
    .quick-btn { padding: clamp(10px,1.5vh,16px) clamp(16px,2vw,24px); border-radius: 10px;
      background: rgba(61,36,13,.97); border: 1.5px solid rgba(242,158,56,.40);
      cursor: pointer; font-family: 'Cinzel', serif; display: flex; flex-direction: column; gap: 3px;
      transition: border-color .2s, transform .15s, box-shadow .2s; flex: 1; min-width: 140px; }
    .quick-btn:hover { border-color: rgba(242,158,56,.80); transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,.4); }
    .quick-btn .qb-name { font-size: clamp(11px,1vw,14px); font-weight: 700; color: var(--gold-light); }
    .quick-btn .qb-sub  { font-size: clamp(10px,.85vw,12px); font-weight: 400; color: rgba(245,232,191,.6); }



                    .nav-logout {
  display: flex;
  align-items: center;
  gap: 6px;
  margin-left: 14px;
  padding: 6px 14px;
  background: transparent;
  border: 1.5px solid rgba(217,173,38,.40);
  border-radius: 8px;
  color: rgba(245,232,191,.70);
  font-family: 'Cinzel', serif;
  font-size: 12px;
  font-weight: 600;
  letter-spacing: .5px;
  cursor: pointer;
  transition: background .2s, border-color .2s, color .2s;
  white-space: nowrap;
  flex-shrink: 0;
}
.nav-logout:hover {
  background: rgba(242,82,46,.15);
  border-color: rgba(242,82,46,.70);
  color: #f2522e;
}
.nav-logout:active {
  background: rgba(242,82,46,.25);
}
/* Ocultar el texto en mobile, dejar solo el ícono */
@media (max-width: 600px) {
  .nav-logout span { display: none; }
  .nav-logout { padding: 6px 10px; }
}


    /* ── RESPONSIVE ── */
    @media (max-width: 1000px) { .main-grid { grid-template-columns: repeat(2, 1fr); } }
    @media (max-width: 600px) {
      .nav-links     { display: none; }
      .nav-hamburger { display: flex; }
      .main-grid     { grid-template-columns: 1fr; }
      .stats-bar     { flex-wrap: wrap; }
      .stat-item     { min-width: 50%; }
      .nav-user      { display: none; }
    }
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
    <!-- NAVBAR -->
    <nav class="navbar" role="navigation">
      <div class="nav-brand">
        <span class="name">SQUAMA</span>
        <span class="sub">Forja tu Leyenda</span>
      </div>
      <div class="nav-role">ADMINISTRADOR</div>

      <div class="nav-links">
        <a href="HomeAdministrador.aspx" class="active">Inicio</a>
        <a href="ABMHub.aspx">Objetos</a>
        <a href="Banners.aspx">Banners</a>
        <a href="EventosAdmin.aspx">Eventos</a>
        <a href="Estadisticas.aspx">Estad&iacute;sticas</a>
        <a href="PerfilAdmin.aspx">Perfil</a>
      </div>

      <button class="nav-hamburger" onclick="toggleNav()" aria-label="Abrir menú">&#9776;</button>

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
        <a href="ABMHub.aspx">Objetos</a>
        <a href="Banners.aspx">Banners</a>
        <a href="EventosAdmin.aspx">Eventos</a>
        <a href="Estadisticas.aspx">Estad&iacute;sticas</a>
        <a href="PerfilAdmin.aspx">Perfil</a>
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
            <button class="card-btn" style="background:rgba(242,158,56,.85);color:#1f1205" onclick="location.href='EventosAdmin.aspx'">Gestionar eventos</button>
          </div>
        </div>

        <div class="card">
          <div class="card-top" style="background:var(--c-stats)"></div>
          <div class="card-body">
            <p class="card-title">Estad&iacute;sticas del Juego</p>
            <p class="card-desc">Visualiza m&eacute;tricas: usuarios activos, combates, tiradas gacha y distribuciones de objetos.</p>
            <div class="card-status" style="background:rgba(89,153,242,.15);border:1px solid rgba(89,153,242,.45);color:var(--c-stats)">320 usuarios &mdash; 1.240 combates hoy</div>
            <button class="card-btn" style="background:rgba(89,153,242,.85);color:#fff" onclick="location.href='Estadisticas.aspx'">Ver estad&iacute;sticas</button>
          </div>
        </div>

        <div class="card">
          <div class="card-top" style="background:var(--c-banners)"></div>
          <div class="card-body">
            <p class="card-title">Gesti&oacute;n de Banners</p>
            <p class="card-desc">Configura los portales gacha activos, ajusta probabilidades por rareza y define la vigencia de cada banner.</p>
            <div class="card-status" style="background:rgba(71,217,107,.15);border:1px solid rgba(71,217,107,.45);color:var(--c-banners)">4 banners activos &mdash; 148 objetos en rotaci&oacute;n</div>
            <button class="card-btn" style="background:rgba(71,217,107,.85);color:#0a2010" onclick="location.href='Banners.aspx'">Gestionar banners</button>
          </div>
        </div>

        <div class="card">
          <div class="card-top" style="background:var(--c-perfil)"></div>
          <div class="card-body">
            <p class="card-title">Mi Perfil Admin</p>
            <p class="card-desc">Accede a tu perfil de administrador. Revisa tu actividad y acciones recientes en el sistema.</p>
            <div class="card-status" style="background:rgba(217,173,38,.15);border:1px solid rgba(217,173,38,.45);color:var(--c-perfil)">&Uacute;ltimo acceso: hoy &mdash; Sesi&oacute;n activa</div>
            <button class="card-btn" style="background:rgba(217,173,38,.85);color:#1f1205" onclick="location.href='PerfilAdmin.aspx'">Ver mi perfil</button>
          </div>
        </div>

      </div>
    </main>

    <!-- QUICK ACTIONS — solo ABMs -->
    <div class="quick-section">
      <p class="quick-title">Acciones r&aacute;pidas &mdash; ABM de objetos</p>
      <div class="quick-grid">
        <button class="quick-btn" onclick="location.href='ABMArmas.aspx'"><span class="qb-name">ABM Armas</span><span class="qb-sub">Crear / editar / eliminar</span></button>
        <button class="quick-btn" onclick="location.href='ABMArmaduras.aspx'"><span class="qb-name">ABM Armaduras</span><span class="qb-sub">Gestionar armaduras</span></button>
        <button class="quick-btn" onclick="location.href='ABMMascotas.aspx'"><span class="qb-name">ABM Mascotas</span><span class="qb-sub">Gestionar mascotas</span></button>
        <button class="quick-btn" onclick="location.href='ABMHabilidades.aspx'"><span class="qb-name">ABM Habilidades</span><span class="qb-sub">Gestionar habilidades</span></button>
      </div>
    </div>

  </div>
</div>

<script>
  function toggleNav() {
    document.getElementById('navDropdown').classList.toggle('open');
  }
  document.addEventListener('click', function(e) {
    if (!e.target.closest('.navbar')) {
      document.getElementById('navDropdown').classList.remove('open');
    }
  });
</script>
    </form>

</body>
</html>