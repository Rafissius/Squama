<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EnConstruccionWebmaster.aspx.cs" Inherits="PylinskiCuello_ProyectoWeb.EnConstruccionWebmaster" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>SQUAMA &mdash; En Construcci&oacute;n</title>
  <link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@400;600;700;900&family=IM+Fell+English:ital@0;1&display=swap" rel="stylesheet"/>
  <style>
    :root {
      --bg:         #2e1a0a;
      --gold:       #d9ad26;
      --gold-inner: rgba(242,209,128,0.35);
      --gold-light: #f2d180;
      --gold-mid:   #ebd9ad;
      --stripe:     rgba(82,46,20,0.14);
      --c-role:     #b86bf2;
    }
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    html, body { width: 100%; min-height: 100dvh; background: var(--bg); font-family: 'Cinzel', serif; }
    .page { position: relative; width: 100%; min-height: 100dvh; display: flex; flex-direction: column; overflow: hidden; }

    .bg-stripes  { position: fixed; inset: 0; z-index: 0; pointer-events: none;
      background: repeating-linear-gradient(to bottom, var(--stripe) 0, var(--stripe) 26px, transparent 26px, transparent 50px); }
    .bg-vignette { position: fixed; inset: 0; z-index: 1; pointer-events: none;
      background: radial-gradient(ellipse at 50% 50%, transparent 25%, rgba(0,0,0,.35) 60%, rgba(0,0,0,.85) 100%); }
    .bg-glow     { position: fixed; z-index: 1; pointer-events: none; top: 50%; left: 50%;
      transform: translate(-50%,-50%); width: 80vw; height: 65vh; border-radius: 50%;
      background: radial-gradient(ellipse at center, rgba(184,107,242,.22) 0%, rgba(92,54,121,.12) 55%, transparent 100%); }
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
      font-size: 10px; font-weight: 700; color: var(--c-role); white-space: nowrap; }
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
      font-size: 18px; font-weight: 700; color: #fff; border: 2px solid var(--c-role); flex-shrink: 0; }
    .nav-user .uname { font-size: 13px; font-weight: 700; color: #ffe066; display: block; }
    .nav-user .urole { font-size: 11px; font-weight: 400; color: var(--c-role); display: block; }
    .nav-hamburger { display: none; background: none; border: 1.5px solid rgba(184,107,242,.55);
      color: var(--c-role); font-size: 18px; width: 38px; height: 38px; border-radius: 8px;
      cursor: pointer; align-items: center; justify-content: center;
      margin-left: 10px; transition: background .2s; flex-shrink: 0; }
    .nav-hamburger:hover { background: rgba(184,107,242,.15); }
    .nav-logout { display: flex; align-items: center; gap: 6px; margin-left: 14px; padding: 6px 14px;
      background: transparent; border: 1.5px solid rgba(217,173,38,.40); border-radius: 8px;
      color: rgba(245,232,191,.70); font-family: 'Cinzel', serif; font-size: 12px; font-weight: 600;
      letter-spacing: .5px; cursor: pointer; transition: background .2s, border-color .2s, color .2s;
      white-space: nowrap; flex-shrink: 0; }
    .nav-logout:hover { background: rgba(242,82,46,.15); border-color: rgba(242,82,46,.70); color: #f2522e; }

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

    /* ── CONTENIDO ── */
    .wip-section { flex: 1; display: flex; flex-direction: column;
      align-items: center; justify-content: center;
      padding: clamp(40px,8vh,100px) 24px; text-align: center; gap: 20px; }
    .wip-icon { width: 90px; height: 90px; border-radius: 50%;
      background: linear-gradient(135deg, rgba(61,36,13,.97), rgba(41,23,8,.97));
      border: 2px solid rgba(184,107,242,.40);
      display: flex; align-items: center; justify-content: center; font-size: 38px;
      box-shadow: 0 0 40px rgba(184,107,242,.15); }
    .wip-divider-top { width: min(400px,60%); height: 2px;
      background: linear-gradient(to right, transparent, rgba(217,173,38,.60), transparent); }
    .wip-badge { display: inline-block; padding: 3px 18px; border-radius: 14px;
      border: 1px solid rgba(184,107,242,.50); background: rgba(184,107,242,.12);
      font-size: 10px; font-weight: 700; color: var(--c-role); letter-spacing: 2px; }
    .wip-title { font-size: clamp(28px,5vw,56px); font-weight: 900; color: #ffe066;
      letter-spacing: 2px; line-height: 1;
      text-shadow: 0 0 40px rgba(255,224,102,.20), 0 4px 8px rgba(0,0,0,.8); }
    .wip-sub  { font-size: clamp(13px,1.4vw,18px); font-weight: 700; color: var(--gold-mid); letter-spacing: 1px; }
    .wip-desc { font-family: 'IM Fell English', serif; font-style: italic;
      font-size: clamp(13px,1.3vw,17px); color: #f5e8bf; max-width: 500px; line-height: 1.7; }
    .wip-divider-bot { width: min(300px,50%); height: 1px;
      background: linear-gradient(to right, transparent, rgba(217,173,38,.40), transparent); }
    .wip-btn { padding: 12px 36px; border-radius: 10px; border: 1.5px solid rgba(217,173,38,.70);
      background: linear-gradient(135deg, rgba(191,140,31,.85), rgba(128,82,10,.85));
      color: #1f1205; font-family: 'Cinzel', serif; font-size: 14px; font-weight: 700;
      letter-spacing: 1px; cursor: pointer; transition: filter .2s, transform .15s; }
    .wip-btn:hover  { filter: brightness(1.15); transform: translateY(-2px); }
    .wip-btn:active { filter: brightness(.90);  transform: translateY(1px);  }

    @media (max-width: 1050px) {
      .nav-links     { display: none; }
      .nav-hamburger { display: flex; }
      .nav-user      { display: none; }
      .nav-logout span { display: none; }
      .nav-logout { padding: 6px 10px; }
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

    <!-- NAVBAR WEBMASTER -->
    <nav class="navbar" role="navigation">
      <div class="nav-brand">
        <span class="name">SQUAMA</span>
        <span class="sub">Forja tu Leyenda</span>
      </div>
      <div class="nav-role">WEBMASTER</div>
      <div class="nav-links">
        <a href="HomeWebmaster.aspx">Inicio</a>
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
        <asp:Button ID="BtnLogout" runat="server" CssClass="nav-logout"
          Text="Salir" OnClick="BtnLogout_Click" ToolTip="Cerrar sesi&oacute;n" />
      </div>
      <div class="nav-dropdown" id="navDropdown">
        <a href="HomeWebmaster.aspx">Inicio</a>
        <a href="EnConstruccionWebmaster.aspx">Usuarios</a>
        <a href="EnConstruccionWebmaster.aspx">Perfiles</a>
        <a href="BitacoraEventos.aspx">Bit&aacute;cora</a>
        <a href="EnConstruccionWebmaster.aspx">Backup / Restore</a>
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