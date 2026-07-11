<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SistemaBloqueado.aspx.cs" Inherits="PylinskiCuello_ProyectoWeb.SistemaBloqueado" %>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>En Mantenimiento — SQUAMA</title>
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@400;600;700;900&family=IM+Fell+English:ital@0;1&family=Inter:wght@400;600;700&display=swap" rel="stylesheet" />
<style>
:root {
  --bg: #2e1a0a;
  --gold: #d9ad26;
  --gold-br: #ffe066;
  --blue: #4a8fd9;
  --blue-light: #6bb3f2;
  --cream: #f5e8bf;
  --dark: #1f1005;
  --font-body: 'Inter', system-ui, sans-serif;
  --font-title: 'Cinzel', serif;
  --font-flavor: 'IM Fell English', serif;
}
* { box-sizing: border-box; margin: 0; padding: 0; }
html, body { height: 100%; }
body {
  font-family: var(--font-body);
  background-color: var(--bg);
  background-image: repeating-linear-gradient(
    to bottom,
    rgba(82,46,20,.14) 0, rgba(82,46,20,.14) 26px,
    transparent 26px, transparent 54px
  );
  color: var(--cream);
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  position: relative;
}

/* Large radial glow */
body::before {
  content: '';
  position: absolute;
  top: 50%; left: 50%;
  transform: translate(-50%,-50%);
  width: 900px; height: 900px;
  border-radius: 50%;
  background: radial-gradient(ellipse at center,
    rgba(74,143,217,.12) 0%,
    rgba(74,143,217,.06) 35%,
    rgba(46,26,10,0) 70%
  );
  pointer-events: none; z-index: 0;
}
/* Inner glow */
body::after {
  content: '';
  position: absolute;
  top: 50%; left: 50%;
  transform: translate(-50%,-50%);
  width: 520px; height: 520px;
  border-radius: 50%;
  background: radial-gradient(ellipse at center,
    rgba(74,143,217,.08) 0%, transparent 65%
  );
  pointer-events: none; z-index: 0;
}

.maintenance {
  position: relative;
  z-index: 1;
  text-align: center;
  max-width: 680px;
  padding: 40px 32px;
}

/* Icon circle */
.maintenance__icon {
  width: 88px; height: 88px;
  margin: 0 auto 32px;
  border-radius: 50%;
  background: rgba(74,143,217,.12);
  border: 2px solid rgba(74,143,217,.4);
  display: grid; place-items: center;
  box-shadow: 0 0 40px rgba(74,143,217,.12);
}
.maintenance__icon svg {
  width: 38px; height: 38px;
  color: var(--blue);
  opacity: .85;
}

/* Eyebrow badge */
.maintenance__eyebrow {
  display: inline-block;
  font-family: var(--font-title);
  font-size: 12px; font-weight: 600;
  letter-spacing: 3px;
  text-transform: uppercase;
  color: var(--blue-light);
  background: rgba(74,143,217,.15);
  border: 1px solid rgba(74,143,217,.5);
  border-radius: 20px;
  padding: 6px 24px;
  margin-bottom: 24px;
}

/* Title */
.maintenance__title {
  font-family: var(--font-title);
  font-size: 52px; font-weight: 900;
  text-transform: uppercase;
  letter-spacing: 4px;
  color: var(--gold-br);
  text-shadow: 0 2px 20px rgba(217,173,38,.25);
  line-height: 1.1;
  margin-bottom: 20px;
}

/* Subtitle */
.maintenance__subtitle {
  font-family: var(--font-title);
  font-size: 18px; font-weight: 700;
  color: var(--cream);
  letter-spacing: 1.5px;
  text-transform: uppercase;
  margin-bottom: 14px;
}

/* Flavor text */
.maintenance__flavor {
  font-family: var(--font-flavor);
  font-size: 16px;
  font-style: italic;
  color: rgba(245,232,191,.7);
  line-height: 1.5;
  margin-bottom: 10px;
}

/* Divider */
.maintenance__divider {
  width: 80px; height: 2px;
  margin: 20px auto 30px;
  background: linear-gradient(to right, transparent, rgba(217,173,38,.6), transparent);
}

/* CTA Button */
.maintenance__btn {
  display: inline-block;
  font-family: var(--font-title);
  font-size: 14px; font-weight: 700;
  letter-spacing: 2px;
  text-transform: uppercase;
  text-decoration: none;
  color: var(--dark);
  background: linear-gradient(to bottom, var(--gold-br), var(--gold));
  border: none; border-radius: 6px;
  padding: 14px 48px;
  cursor: pointer;
  transition: transform .15s, box-shadow .2s, filter .15s;
  box-shadow: 0 2px 12px rgba(217,173,38,.3), inset 0 1px 0 rgba(255,255,255,.2);
}
.maintenance__btn:hover {
  filter: brightness(1.08);
  box-shadow: 0 4px 20px rgba(217,173,38,.4), inset 0 1px 0 rgba(255,255,255,.25);
  transform: translateY(-1px);
}
.maintenance__btn:active { transform: translateY(1px); box-shadow: 0 1px 6px rgba(217,173,38,.3); }
.maintenance__btn:focus-visible { outline: 2px solid var(--gold-br); outline-offset: 4px; }

@media (max-width:640px) {
  .maintenance__title { font-size: 34px; letter-spacing: 2px; }
  .maintenance__subtitle { font-size: 14px; }
  .maintenance__flavor { font-size: 14px; }
  .maintenance__icon { width: 72px; height: 72px; }
  .maintenance__icon svg { width: 30px; height: 30px; }
  .maintenance__btn { padding: 12px 36px; font-size: 13px; }
}
@media (prefers-reduced-motion:reduce) { ,::before,*::after { animation:none!important; transition:none!important; } }
</style>
</head>
<body>
    <form id="form1" runat="server">
<div class="maintenance">
  <div class="maintenance__icon">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
      <path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z" />
    </svg>


  </div>

  <span class="maintenance__eyebrow">Sistema en mantenimiento</span>

  <h1 class="maintenance__title">En Mantenimiento</h1>

  <p class="maintenance__subtitle">Los herreros del reino trabajan en las forjas</p>

  <p class="maintenance__flavor">El sistema se encuentra temporalmente fuera de servicio.<br/>Regresa pronto; el reino estara listo con la proxima luna.</p>

  <div class="maintenance__divider"></div>

   <asp:LinkButton 
      ID="btnIrLogin" 
      runat="server" 
      CssClass="maintenance__btn" 
      OnClick="maintenance__btn" 
      Text=" Ir al inicio de sesion" />
</div>
        </form>
</body>
</html>