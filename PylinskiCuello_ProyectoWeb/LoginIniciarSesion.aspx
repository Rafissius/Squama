<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LoginIniciarSesion.aspx.cs" Inherits="PylinskiCuello_ProyectoWeb.LoginIniciarSesion" %>

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>SQUAMA — Iniciar Sesión</title>
  <link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@400;600;700;900&family=IM+Fell+English:ital@0;1&display=swap" rel="stylesheet" />
  <style>

    :root {
      --bg:           #47050a;
      --gold:         #a67a14;
      --gold-bar:     #d9ad26;
      --gold-light:   #f2d180;
      --gold-mid:     #ebd9ad;
      --gold-soft:    #e0cc9e;
      --gold-from:    #bf8c1f;
      --gold-to:      #80520a;
      --gold-hi:      rgba(242,209,128,0.70);
      --gold-lo:      rgba(166,122,20,0.70);
      --gold-inner:   rgba(242,209,128,0.35);
      --stripe:       rgba(77,5,10,0.14);
      --panel:        rgba(56,10,10,0.70);
      --card-a:       rgba(82,10,13,0.97);
      --card-b:       rgba(61,8,10,0.97);
      --input-bg:     rgba(36,5,5,0.85);
      --input-bdr:    rgba(166,122,20,0.65);
      --ph:           #8c6647;
      --feat-bg:      rgba(113,47,47,0.40);
      --error:        #ff6b6b;
      --blocked:      #ff9f43;
    }

    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    html, body {
      width: 100%; min-height: 100dvh;
      background: var(--bg);
      font-family: 'Cinzel', serif;
    }

    .page {
      position: relative;
      width: 100%;
      min-height: 100dvh;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      overflow: hidden;
    }

    /* ── FONDO ── */
    .bg-stripes {
      position: fixed; inset: 0; z-index: 0; pointer-events: none;
      background-image: repeating-linear-gradient(
        to bottom,
        var(--stripe) 0px, var(--stripe) 26px,
        transparent 26px, transparent 50px
      );
    }
    .bg-vignette {
      position: fixed; inset: 0; z-index: 1; pointer-events: none;
      background: radial-gradient(ellipse at 50% 50%,
        transparent 25%, rgba(0,0,0,0.30) 60%, rgba(0,0,0,0.80) 100%);
    }
    .bg-glow {
      position: fixed; z-index: 1; pointer-events: none;
      top: 50%; left: 50%; transform: translate(-50%, -50%);
      width: 80vw; height: 65vh; border-radius: 50%;
      background: radial-gradient(ellipse at center,
        rgba(160,30,30,0.55) 0%, rgba(90,10,10,0.28) 55%, transparent 100%);
    }
    .bg-sides {
      position: fixed; inset: 0; z-index: 1; pointer-events: none;
      background:
        linear-gradient(to right, rgba(51,3,5,0.60) 0%, transparent 18%),
        linear-gradient(to left,  rgba(51,3,5,0.60) 0%, transparent 18%);
    }

    /* ── BORDE DORADO FIJO ── */
    .border-frame {
      position: fixed; inset: 0; z-index: 50; pointer-events: none;
      box-shadow: inset 0 0 0 4px var(--gold);
    }
    .border-frame::after {
      content: '';
      position: absolute; inset: 12px;
      border: 2px solid var(--gold-inner);
    }

    /* ── CONTENIDO ── */
    .content {
      position: relative;
      z-index: 10;
      width: 100%;
      min-height: 100dvh;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      padding: clamp(56px, 8vh, 100px) clamp(28px, 6vw, 80px);
      gap: clamp(18px, 3vh, 38px);
    }

    /* ══════════════════════════════════════════════════════════
       HEADER
    ══════════════════════════════════════════════════════════ */
    .header {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 10px;
      width: 100%;
      animation: fadeUp 0.8s cubic-bezier(0.22,1,0.36,1) 0.1s both;
    }

    .hline     { height: 2px; background: var(--gold-hi); width: min(580px, 65%); }
    .hline-sm  { height: 2px; background: var(--gold-lo); width: min(400px, 48%); margin-top: 4px; }

    .logo-wrap {
      display: flex;
      align-items: center;
      gap: clamp(8px, 1.4vw, 20px);
    }

    .logo-img {
      width: clamp(500px,50vw,500px);
      margin-left: -4.5em;
      margin-right: -0.45em;
      margin-bottom: 0.12em;
      object-fit: contain;
    }

    .logo-name {
      font-size: clamp(48px, 7.5vw, 96px);
      font-weight: 700;
      color: var(--gold-mid);
      letter-spacing: 6px;
      text-shadow: 0 0 50px rgba(166,122,20,0.5), 0 4px 10px rgba(0,0,0,0.9);
      margin-left: -2em;
    }

    .logo-sub {
      font-family: 'IM Fell English', serif;
      font-style: italic;
      font-size: clamp(18px, 2.6vw, 30px);
      color: var(--gold-light);
      letter-spacing: 4px;
    }

    /* ══════════════════════════════════════════════════════════
       BODY ROW
    ══════════════════════════════════════════════════════════ */
    .body-row {
      position: relative;
      width: 100%;
      max-width: 1200px;
      display: flex;
      justify-content: center;
      align-items: flex-start;
      animation: fadeUp 0.8s cubic-bezier(0.22,1,0.36,1) 0.25s both;
    }

    .features {
      position: absolute;
      left: 0;
      top: clamp(28px, 6vh, 80px);
      display: flex;
      flex-direction: column;
      gap: clamp(10px, 1.4vh, 18px);
      width: clamp(190px, 24vw, 340px);
    }

    .feat-item {
      display: flex;
      align-items: center;
      gap: 14px;
      padding: clamp(10px, 1.4vh, 16px) clamp(16px, 1.8vw, 24px);
      background: var(--feat-bg);
      border: 1px solid rgba(9,8,8,0.98);
      border-radius: 24px;
    }
    .feat-item .dot {
      width: clamp(11px, 1.2vw, 15px);
      height: clamp(11px, 1.2vw, 15px);
      border-radius: 50%;
      background: radial-gradient(circle at 35% 35%, #f2d180, #a67a14);
      flex-shrink: 0;
    }
    .feat-item span {
      font-family: 'IM Fell English', serif;
      font-size: clamp(13px, 1.5vw, 18px);
      color: #f5e8bf;
      letter-spacing: 0.4px;
      white-space: nowrap;
    }

    /* ══════════════════════════════════════════════════════════
       CARD
    ══════════════════════════════════════════════════════════ */
    .card-wrap {
      position: relative;
      width: clamp(340px, 46vw, 620px);
    }

    .card-shadow {
      position: absolute;
      inset: 0; top: 10px; left: 10px;
      border-radius: 18px;
      background: rgba(0,0,0,0.55);
    }

    .card {
      position: relative;
      width: 100%;
      background: linear-gradient(180deg, var(--card-a) 0%, var(--card-b) 50%, var(--card-a) 100%);
      border: 2px solid var(--gold-lo);
      border-radius: 18px;
      overflow: hidden;
      padding: clamp(24px, 3.5vh, 48px) clamp(28px, 4vw, 56px);
      display: flex;
      flex-direction: column;
      gap: clamp(14px, 2vh, 24px);
    }

    .card::before {
      content: '';
      position: absolute; top: 0; left: 0; right: 0;
      height: 5px;
      background: var(--gold-bar);
      border-radius: 3px 3px 0 0;
    }
    .card::after {
      content: '';
      position: absolute; top: 6px; left: 16px; right: 16px;
      height: 1px;
      background: rgba(242,209,128,0.25);
    }

    .card-title {
      text-align: center;
      font-weight: 700;
      font-size: clamp(20px, 2.8vw, 34px);
      color: var(--gold-light);
      letter-spacing: 1px;
      margin-top: 8px;
    }

    /* Párrafo de descripción / mensaje dinámico */
    .card-desc {
      text-align: center;
      font-family: 'IM Fell English', serif;
      font-style: italic;
      font-size: clamp(13px, 1.5vw, 18px);
      color: var(--gold-soft);
      transition: color 0.3s;
    }
    .card-desc.msg-error   { color: var(--error);   font-style: normal; }
    .card-desc.msg-blocked { color: var(--blocked);  font-style: normal; }

    .card-divider {
      height: 1px;
      background: linear-gradient(to right, transparent, rgba(242,209,128,0.5), transparent);
    }

    .field { display: flex; flex-direction: column; gap: 7px; }

    .field label {
      font-weight: 700;
      font-size: clamp(11px, 1.2vw, 15px);
      color: var(--gold-light);
      letter-spacing: 0.5px;
    }

    .field input {
      width: 100%;
      height: clamp(46px, 6.5vh, 62px);
      background: var(--input-bg);
      border: 1.5px solid var(--input-bdr);
      border-radius: 10px;
      font-family: 'IM Fell English', serif;
      font-size: clamp(14px, 1.6vw, 19px);
      color: var(--gold-soft);
      padding: 0 18px;
      outline: none;
      transition: border-color 0.2s;
    }
    .field input::placeholder { color: var(--ph); font-style: italic; }
    .field input:focus { border-color: rgba(242,209,128,0.75); }

    .forgot {
      align-self: flex-end;
      font-family: 'Cinzel', serif;
      font-size: clamp(11px, 1.1vw, 14px);
      color: var(--gold);
      text-decoration: none;
      margin-top: -4px;
    }
    .forgot:hover { text-decoration: underline; }

    /* ── Botones ── */
    .btn {
      position: relative;
      width: 100%;
      height: clamp(52px, 7.5vh, 72px);
      border-radius: 12px;
      font-family: 'Cinzel', serif;
      font-weight: 700;
      font-size: clamp(15px, 1.8vw, 22px);
      letter-spacing: 1.5px;
      cursor: pointer;
      border: 1.5px solid var(--gold-hi);
      overflow: hidden;
      transition: filter 0.2s, transform 0.15s;
    }
    .btn::before {
      content: '';
      position: absolute; top: 2px; left: 2px; right: 2px;
      height: 1px; background: rgba(242,209,128,0.35);
    }
    .btn:hover  { filter: brightness(1.15); transform: translateY(-2px); }
    .btn:active { filter: brightness(0.90); transform: translateY(1px); }

    .btn-primary {
      background: linear-gradient(135deg, var(--gold-from), var(--gold-to));
      color: #1a0505;
    }

    .btn-secondary {
      background: var(--panel);
      border-color: var(--gold-lo);
      color: var(--gold-light);
    }
    .btn-secondary::before { background: rgba(242,209,128,0.10); }

    .or-row {
      display: flex; align-items: center; gap: 14px;
    }
    .or-row .line {
      flex: 1; height: 1px;
      background: linear-gradient(to right, transparent, rgba(242,209,128,0.4), transparent);
    }
    .or-row span {
      font-size: clamp(13px, 1.4vw, 17px);
      color: var(--gold);
    }

    .new-text {
      text-align: center;
      font-family: 'IM Fell English', serif;
      font-style: italic;
      font-size: clamp(13px, 1.4vw, 17px);
      color: var(--gold-soft);
    }

    .back-link {
      display: block; text-align: center;
      font-size: clamp(12px, 1.2vw, 15px);
      color: var(--gold);
      text-decoration: none;
      letter-spacing: 0.3px;
    }
    .back-link:hover { text-decoration: underline; }

    .card-bottom-line {
      height: 2px;
      background: var(--gold-lo);
      margin-top: 4px;
    }

    /* ══════════════════════════════════════════════════════════
       QUOTE
    ══════════════════════════════════════════════════════════ */
    .quote-wrap {
      width: 100%;
      display: flex;
      justify-content: center;
      padding: clamp(6px, 1.5vh, 18px) 0;
      animation: fadeIn 1.0s ease 0.5s both;
    }
    .quote {
      font-family: 'IM Fell English', serif;
      font-style: italic;
      font-size: clamp(18px, 2.8vw, 32px);
      color: var(--gold-light);
      letter-spacing: 0.5px;
      text-align: center;
      text-shadow: 0 0 24px rgba(242,209,128,0.28);
    }

    /* ══════════════════════════════════════════════════════════
       RESPONSIVE
    ══════════════════════════════════════════════════════════ */
    @media (max-width: 800px) {
      .body-row {
        flex-direction: column;
        align-items: center;
        gap: 22px;
      }
      .features {
        position: static;
        width: 100%;
        max-width: 540px;
        flex-direction: row;
        flex-wrap: wrap;
        justify-content: center;
      }
      .card-wrap { width: min(100%, 560px); }
    }

    @media (max-width: 480px) {
      .features { display: none; }
      .card-wrap { width: 100%; }
    }

    /* ══════════════════════════════════════════════════════════
       ANIMACIONES
    ══════════════════════════════════════════════════════════ */
    @keyframes fadeUp {
      from { opacity:0; transform:translateY(18px); }
      to   { opacity:1; transform:translateY(0); }
    }
    @keyframes fadeIn {
      from { opacity:0; } to { opacity:1; }
    }

  </style>
</head>
<body>
<form id="form1" runat="server">
<div class="page">

  <!-- FONDO -->
  <div class="bg-stripes"  aria-hidden="true"></div>
  <div class="bg-vignette" aria-hidden="true"></div>
  <div class="bg-glow"     aria-hidden="true"></div>
  <div class="bg-sides"    aria-hidden="true"></div>

  <!-- BORDE DORADO -->
  <div class="border-frame" aria-hidden="true"></div>

  <!-- CONTENIDO -->
  <div class="content">

    <!-- HEADER -->
    <header class="header">
      <div class="hline" aria-hidden="true"></div>
      <div class="logo-wrap">
        <img class="logo-img"
             src="https://www.figma.com/api/mcp/asset/005d687f-598b-4741-965e-49c2cdd0491f"
             alt="SQUAMA logo" loading="eager" />
        <span class="logo-name">QUAMA</span>
      </div>
      <p class="logo-sub">Iniciar Sesión</p>
      <div class="hline-sm" aria-hidden="true"></div>
    </header>

    <!-- BODY ROW -->
    <div class="body-row">

      <!-- Features a la izquierda (absolutas) -->
      <aside class="features" aria-label="Características del juego">
        <div class="feat-item"><span class="dot"></span><span>Combates automáticos</span></div>
        <div class="feat-item"><span class="dot"></span><span>Sistema Gacha</span></div>
        <div class="feat-item"><span class="dot"></span><span>Clanes</span></div>
        <div class="feat-item"><span class="dot"></span><span>Progresión de nivel</span></div>
      </aside>

      <!-- Card centrada -->
      <div class="card-wrap">
        <div class="card-shadow" aria-hidden="true"></div>
        <div class="card" role="main">

          <p class="card-title">Bienvenido de vuelta</p>

          <%-- 
            PÁRRAFO DINÁMICO: 
            - runat="server" permite modificarlo desde el .cs
            - La clase CSS se cambia desde code-behind según el resultado
          --%>
          <p id="pMensaje" runat="server" class="card-desc">
            Ingresa tus credenciales para continuar tu aventura
          </p>

          <div class="card-divider" aria-hidden="true"></div>

          <%-- CAMPO USUARIO / EMAIL — runat="server" para leerlo en el .cs --%>
          <div class="field">
            <label for="username">Usuario o correo electrónico</label>
            <input id="username" runat="server" type="text"
                   placeholder="Tu nombre de usuario..."
                   autocomplete="username" />
          </div>

          <%-- CAMPO CONTRASEÑA — runat="server" para leerlo en el .cs --%>
          <div class="field">
            <label for="password">Contraseña</label>
            <input id="password" runat="server" type="password"
                   placeholder="••••••••"
                   autocomplete="current-password" />
          </div>

          <a class="forgot" href="#">¿Olvidaste tu contraseña?</a>

          <%-- 
            BOTÓN PRINCIPAL:
            - runat="server" convierte el botón en control de servidor
            - onserverclick dispara el método btnIngresar_Click en el .cs
            - Se elimina el onclick de JavaScript
          --%>
          <button class="btn btn-primary"
                  runat="server"
                  onserverclick="btnIngresar_Click">
            Ingresar al Reino
          </button>

          <div class="or-row" aria-hidden="true">
            <span class="line"></span><span>o</span><span class="line"></span>
          </div>

          <p class="new-text">¿Eres nuevo en Squama?</p>

          <button class="btn btn-secondary"
                  onclick="window.location.href='#register'; return false;">
            Crear una cuenta nueva
          </button>

          <a class="back-link" href="squama-landing.html">← Volver al inicio</a>

          <div class="card-bottom-line" aria-hidden="true"></div>
        </div>
      </div>

    </div><!-- .body-row -->

    <!-- QUOTE -->
    <div class="quote-wrap">
      <p class="quote">"Solo los valientes merecen entrar a la arena"</p>
    </div>

  </div><!-- .content -->

</div><!-- .page -->
</form>
</body>
</html>
