<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="HomeWebmaster.aspx.cs" Inherits="PylinskiCuello_ProyectoWeb.HomeWebmaster" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>SQUAMA &mdash; Panel Webmaster</title>
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
      --c-wm:       #b86bf2;
      --c-usuarios: #b86bf2;
      --c-roles:    #5999f2;
      --c-bitacora: #f29e38;
      --c-backup:   #47d96b;
      --c-dv:       #f2522e;
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
      background: radial-gradient(ellipse at center, rgba(184,107,242,.25) 0%, rgba(92,54,121,.15) 55%, transparent 100%); }
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
      border: 1px solid rgba(184,107,242,.70); background: rgba(184,107,242,.20);
      font-size: 10px; font-weight: 700; color: var(--c-wm); white-space: nowrap; }
    .nav-links { display: flex; }
    .nav-links a { padding: 24px 13px 22px; text-decoration: none; font-size: 13px; font-weight: 400;
      color: #f5e8bf; position: relative; transition: color .2s; white-space: nowrap; }
    .nav-links a:hover { color: var(--gold-light); }
    .nav-links a.active { font-weight: 700; color: var(--gold); }
    .nav-links a.active::after { content: ''; position: absolute; bottom: 0; left: 9px; right: 9px;
      height: 3px; background: var(--gold); border-radius: 2px; }
    .nav-right { margin-left: auto; display: flex; align-items: center; gap: 10px; padding-right: 28px; flex-shrink: 0; }
    .nav-avatar { width: 44px; height: 44px; border-radius: 50%;
      background: linear-gradient(135deg, rgba(184,107,242,.8), rgba(92,54,121,.8));
      display: flex; align-items: center; justify-content: center;
      font-size: 18px; font-weight: 700; color: #fff; border: 2px solid var(--c-wm); flex-shrink: 0; }
    .nav-user .uname { font-size: 13px; font-weight: 700; color: #ffe066; display: block; }
    .nav-user .urole { font-size: 11px; font-weight: 400; color: var(--c-wm); display: block; }

    /* ── HAMBURGER ── */
    .nav-hamburger { display: none; background: none;
      border: 1.5px solid rgba(184,107,242,.55); color: var(--c-wm);
      font-size: 18px; width: 38px; height: 38px; border-radius: 8px;
      cursor: pointer; align-items: center; justify-content: center;
      margin-left: 10px; transition: background .2s; flex-shrink: 0; }
    .nav-hamburger:hover { background: rgba(184,107,242,.15); }

    /* ── DROPDOWN MOBILE ── */
    .nav-dropdown { display: none; position: absolute; top: 68px; left: 0; right: 0;
      background: rgba(12,6,2,.98); border-bottom: 3px solid var(--gold);
      border-top: 1px solid rgba(184,107,242,.25); z-index: 200;
      flex-direction: column; box-shadow: 0 8px 24px rgba(0,0,0,.7); }
    .nav-dropdown.open { display: flex; }
    .nav-dropdown a { padding: 15px 28px; text-decoration: none; font-size: 14px; font-weight: 400;
      color: #f5e8bf; border-bottom: 1px solid rgba(217,173,38,.12);
      transition: background .2s, color .2s; position: relative; }
    .nav-dropdown a:hover  { background: rgba(184,107,242,.08); color: var(--gold-light); }
    .nav-dropdown a.active { font-weight: 700; color: var(--gold); background: rgba(217,173,38,.06); }
    .nav-dropdown a.active::before { content: ''; position: absolute; left: 0; top: 0; bottom: 0;
      width: 3px; background: var(--gold); border-radius: 0 2px 2px 0; }

    /* ── HERO ── */
    .hero { background: linear-gradient(to right, rgba(184,107,242,.30) 0%, transparent 50%);
      border-bottom: 2px solid rgba(217,173,38,.40);
      padding: clamp(18px,3vh,36px) 40px clamp(14px,2.5vh,28px);
      display: flex; flex-direction: column; align-items: center; text-align: center; gap: 6px; }
    .hero-badge { display: inline-block; padding: 3px 20px; border-radius: 14px;
      border: 1px solid rgba(184,107,242,.70); background: rgba(184,107,242,.20);
      font-size: 11px; font-weight: 700; color: var(--c-wm); letter-spacing: 1px; margin-bottom: 4px; }
    .hero-title { font-size: clamp(40px,6vw,80px); font-weight: 900; color: #ffe066; letter-spacing: 2px;
      text-shadow: 0 0 40px rgba(255,224,102,.25), 0 4px 8px rgba(0,0,0,.8); line-height: 1; }
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

    /* ── CARDS ── */
    .cards-section { flex: 1; padding: clamp(18px,3vh,36px) clamp(16px,3vw,40px); }
    .cards-grid { display: grid; grid-template-columns: repeat(5, 1fr); gap: clamp(10px,1.5vw,20px); }
    .card { position: relative; border-radius: 14px; overflow: hidden;
      background: linear-gradient(180deg, var(--card-a) 0%, var(--card-b) 50%, var(--card-a) 100%);
      border: 1.5px solid rgba(217,173,38,.30); display: flex; flex-direction: column;
      transition: transform .2s, box-shadow .2s; }
    .card:hover { transform: translateY(-3px); box-shadow: 0 8px 24px rgba(0,0,0,.5); }
    .card-top  { height: 5px; width: 100%; flex-shrink: 0; border-radius: 2px 2px 0 0; }
    .card-body { flex: 1; padding: clamp(14px,2vh,22px) clamp(10px,1.2vw,16px); display: flex; flex-direction: column; gap: 8px; }
    .card-title  { font-size: clamp(11px,1vw,15px); font-weight: 700; color: #ffe066; }
    .card-desc   { font-family: 'IM Fell English', serif; font-style: italic;
      font-size: clamp(10px,.9vw,13px); color: #f5e8bf; line-height: 1.5; flex: 1; }
    .card-status { padding: 4px 8px; border-radius: 8px; font-size: clamp(9px,.8vw,11px); font-weight: 700; text-align: center; }
    .card-btn { width: 100%; padding: 7px; border-radius: 8px; border: none; cursor: pointer;
      font-family: 'Cinzel', serif; font-size: clamp(9px,.85vw,12px); font-weight: 700; letter-spacing: .5px;
      transition: filter .2s, transform .15s; }
    .card-btn:hover  { filter: brightness(1.15); transform: translateY(-1px); }
    .card-btn:active { filter: brightness(.90);  transform: translateY(1px);  }

        
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
    @media (max-width: 1100px) { .cards-grid { grid-template-columns: repeat(3, 1fr); } }
    @media (max-width: 700px)  { .cards-grid { grid-template-columns: repeat(2, 1fr); } }
    @media (max-width: 1050px) {
      .nav-links     { display: none; }
      .nav-hamburger { display: flex; }
      .cards-grid    { grid-template-columns: 1fr; }
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
      <div class="nav-role">WEBMASTER</div>

      <div class="nav-links">
        <a href="HomeWebmaster.aspx" class="active">Inicio</a>
        <a href="EnConstruccionWebmaster.aspx">Usuarios</a>
        <a href="EnConstruccionWebmaster.aspx">Perfiles</a>
        <a href="BitacoraEventos.aspx">Bit&aacute;cora</a>
        <a href="EnConstruccionWebmaster.aspx">Backup/Restore</a>
        <a href="EnConstruccionWebmaster.aspx">Seguridad</a>
      </div>

<button type="button" class="nav-hamburger" onclick="toggleNav()" aria-label="Abrir menú">&#9776;</button>

      <div class="nav-right">
        <div class="nav-avatar">W</div>
        <div class="nav-user">
          <span class="uname">Webmaster</span>
          <span class="urole">WEBMASTER</span>
        </div>
          
          <asp:Button ID="BtnLogout" runat="server"
    CssClass="nav-logout"
    Text="Salir"
    OnClick="BtnLogout_Click"
    ToolTip="Cerrar sesión" />

         </div>

      <div class="nav-dropdown" id="navDropdown">
        <a href="HomeWebmaster.aspx" class="active">Inicio</a>
        <a href="EnConstruccionWebmaster.aspx">Usuarios</a>
        <a href="EnConstruccionWebmaster.aspx">Perfiles</a>
        <a href="BitacoraEventos.aspx">Bit&aacute;cora</a>
        <a href="EnConstruccionWebmaster.aspx">Backup / Restore</a>
        <a href="EnConstruccionWebmaster.aspx">Seguridad</a>
      </div>
    </nav>

    <!-- HERO -->
    <section class="hero">
      <span class="hero-badge">PANEL DEL WEBMASTER</span>
      <h1 class="hero-title">SQUAMA</h1>
      <p class="hero-sub">Control t&eacute;cnico, seguridad e integridad del sistema</p>
      <p class="hero-desc">Administra usuarios, revisa la bit&aacute;cora, ejecuta backups y verifica la integridad de datos.</p>
      <div class="hero-divider" aria-hidden="true"></div>
    </section>

    <!-- STATS BAR -->
    <div class="stats-bar" role="region" aria-label="Estado del sistema">
      <div class="stat-item"><span class="stat-val" style="color:var(--c-usuarios)">320</span><span class="stat-lbl">Usuarios totales</span></div>
      <div class="stat-item"><span class="stat-val" style="color:var(--c-roles)">3</span><span class="stat-lbl">Roles activos</span></div>
      <div class="stat-item"><span class="stat-val" style="color:var(--c-bitacora)">142</span><span class="stat-lbl">Eventos hoy</span></div>
      <div class="stat-item"><span class="stat-val" style="color:var(--c-backup)">OK</span><span class="stat-lbl">&Uacute;ltimo backup</span></div>
      <div class="stat-item"><span class="stat-val" style="color:var(--c-dv)">2</span><span class="stat-lbl">Alertas DV</span></div>
    </div>

    <!-- CARDS -->
    <main class="cards-section">
      <div class="cards-grid">

        <div class="card" style="border-color:rgba(184,107,242,.50)">
          <div class="card-top" style="background:var(--c-usuarios)"></div>
          <div class="card-body">
            <p class="card-title">Gesti&oacute;n de Usuarios</p>
            <p class="card-desc">ABM completo de usuarios. Crear, modificar, activar, desactivar, bloquear y asignar roles.</p>
            <div class="card-status" style="background:rgba(184,107,242,.15);border:1px solid rgba(184,107,242,.45);color:var(--c-usuarios)">320 usuarios &mdash; 3 bloqueados &mdash; 5 inactivos</div>
            <button type="button" class="card-btn" style="background:rgba(184,107,242,.85);color:#1f1205" onclick="location.href='EnConstruccionWebmaster.aspx'">Gestionar usuarios</button>
          </div>
        </div>

        <div class="card" style="border-color:rgba(89,153,242,.50)">
          <div class="card-top" style="background:var(--c-roles)"></div>
          <div class="card-body">
            <p class="card-title">Perfiles y Roles</p>
            <p class="card-desc">Gesti&oacute;n de perfiles, roles, familias y permisos. Asigna accesos granulares a cada usuario.</p>
            <div class="card-status" style="background:rgba(89,153,242,.15);border:1px solid rgba(89,153,242,.45);color:var(--c-roles)">3 roles &mdash; 8 perfiles &mdash; 24 permisos</div>
            <button type="button" class="card-btn" style="background:rgba(89,153,242,.85);color:#fff" onclick="location.href='EnConstruccionWebmaster.aspx'">Gestionar perfiles</button>
          </div>
        </div>

        <div class="card" style="border-color:rgba(242,158,56,.50)">
          <div class="card-top" style="background:var(--c-bitacora)"></div>
          <div class="card-body">
            <p class="card-title">Bit&aacute;cora de Eventos</p>
            <p class="card-desc">Registro de logins, errores, cambios cr&iacute;ticos, bloqueos y verificaciones de integridad.</p>
            <div class="card-status" style="background:rgba(242,158,56,.15);border:1px solid rgba(242,158,56,.45);color:var(--c-bitacora)">1.840 eventos &mdash; 3 alertas hoy</div>
            <button type="button" class="card-btn" style="background:rgba(242,158,56,.85);color:#1f1205" onclick="location.href='BitacoraEventos.aspx'">Ver bit&aacute;cora</button>
          </div>
        </div>

        <div class="card" style="border-color:rgba(71,217,107,.50)">
          <div class="card-top" style="background:var(--c-backup)"></div>
          <div class="card-body">
            <p class="card-title">Backup / Restore</p>
            <p class="card-desc">Genera copias de seguridad de la base de datos y restaura desde versiones anteriores.</p>
            <div class="card-status" style="background:rgba(71,217,107,.15);border:1px solid rgba(71,217,107,.45);color:var(--c-backup)">&Uacute;ltimo backup: hoy 03:00 &mdash; OK</div>
            <button type="button" class="card-btn" style="background:rgba(71,217,107,.85);color:#0a2010" onclick="location.href='EnConstruccionWebmaster.aspx'">Gestionar backups</button>
          </div>
        </div>

        <div class="card" style="border-color:rgba(242,82,46,.50)">
          <div class="card-top" style="background:var(--c-dv)"></div>
          <div class="card-body">
            <p class="card-title">D&iacute;gito Verificador</p>
            <p class="card-desc">Controla la integridad de registros mediante DVH y DVV. Detecta modificaciones no autorizadas.</p>
            <div class="card-status" style="background:rgba(242,82,46,.15);border:1px solid rgba(242,82,46,.45);color:var(--c-dv)">DVV: OK &mdash; DVH: 2 inconsistencias</div>
            <button type="button" class="card-btn" style="background:rgba(242,82,46,.85);color:#fff" onclick="location.href='EnConstruccionWebmaster.aspx'">Verificar integridad</button>
          </div>
        </div>

      </div>
    </main>
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