<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ArenaVictoria.aspx.cs" Inherits="PylinskiCuello_ProyectoWeb.ArenaVictoria" %>

<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Arena — ¡Victoria! · SQUAMA</title>
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@400;600;700;900&family=Inter:wght@400;600;700&display=swap" rel="stylesheet" />
<style>
:root{--bg:#1a0f03;--gold:#d9ad26;--gold-br:#ffe066;--cream:#f5e8bf;--green:#47d96b;--red:#f2522e;--blue:#5999f2;--ora:#f29e38;--purp:#b86bf2;--dark:#1f1005;--font:'Inter',system-ui,sans-serif;--font-title:'Cinzel',serif}
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:var(--font);background-color:var(--bg);background-image:repeating-linear-gradient(to bottom,rgba(82,46,20,.1) 0,rgba(82,46,20,.1) 26px,transparent 26px,transparent 54px);color:var(--cream);min-height:100vh;overflow-x:hidden}
body::before{content:'';position:fixed;inset:0;background:radial-gradient(ellipse at center,transparent 0%,rgba(0,0,0,.25) 55%,rgba(0,0,0,.82) 100%);pointer-events:none;z-index:0}

/* Navbar */
.navbar{position:sticky;top:0;z-index:100;display:flex;align-items:center;justify-content:space-between;height:56px;padding:0 24px;background:rgba(15,8,3,.95);border-top:2px solid var(--gold)}
.nav-logo{font-size:18px;font-weight:700;color:var(--gold)}
.nav-center{position:absolute;left:50%;transform:translateX(-50%);text-align:center}
.nav-center__title{font-size:13px;font-weight:700;color:var(--gold-br)}
.nav-center__sub{font-size:10px;color:var(--cream)}

.page{position:relative;z-index:1;max-width:1440px;margin:0 auto;padding:0 16px}

/* Victory header */
.victory-header{text-align:center;padding:10px 0 0;position:relative}
.victory-header__glow{position:absolute;top:-20px;left:50%;transform:translateX(-50%);width:720px;height:100px;
  background:radial-gradient(ellipse at center,rgba(242,191,26,.3),rgba(121,96,13,.1) 50%,transparent);pointer-events:none}
.victory-stars{font-size:14px;color:var(--gold-br);letter-spacing:8px}
.victory-title{font-family:var(--font-title);font-size:76px;font-weight:900;color:var(--gold-br);text-transform:uppercase;
  text-shadow:0 2px 30px rgba(217,173,38,.3);letter-spacing:6px;line-height:1}
.victory-defeated{font-size:18px;color:var(--cream);margin-top:8px}
.victory-flavor{font-size:13px;color:var(--gold);margin-top:6px}
.victory-rule{width:600px;max-width:90%;height:2px;margin:10px auto;background:rgba(217,173,38,.6);border-radius:1px;position:relative}
.victory-rule::after{content:'';position:absolute;top:6px;left:50%;transform:translateX(-50%);width:400px;max-width:100%;height:1px;background:rgba(217,173,38,.3)}

/* Chronicle summary */
.chronicle-summary{margin:16px auto;max-width:720px;background:rgba(41,23,8,.95);border:2px solid rgba(217,173,38,.55);border-radius:16px;padding:14px 20px;position:relative}
.chronicle-summary::before,.chronicle-summary::after{content:'◆';position:absolute;top:-8px;font-size:12px;color:var(--gold)}
.chronicle-summary::before{left:6px}.chronicle-summary::after{right:6px}
.cs-title{text-align:center;font-size:14px;font-weight:700;color:var(--gold-br);margin-bottom:8px}
.cs-divider{height:1px;background:rgba(217,173,38,.4);margin-bottom:10px}
.cs-entry{display:flex;align-items:flex-start;gap:8px;padding:3px 0}
.cs-entry:nth-child(odd) .cs-bg{background:rgba(0,0,0,.2);border-radius:4px}
.cs-dot{width:10px;height:10px;border-radius:50%;flex-shrink:0;margin-top:3px}
.cs-dot--normal{background:rgba(217,173,38,.4);border:1px solid rgba(217,173,38,.6)}
.cs-dot--final{background:var(--gold-br);border:1px solid var(--gold)}
.cs-text{font-size:11px;color:var(--cream);line-height:1.4}
.cs-text--final{font-weight:700;color:var(--gold-br)}

/* Fighter stats row */
.fighters-row{display:grid;grid-template-columns:1fr auto 1fr;gap:20px;margin:20px auto;max-width:1100px;align-items:start}
.f-panel{border-radius:12px;padding:12px 16px;border:1.5px solid}
.f-panel--player{background:rgba(51,20,8,.9);border-color:rgba(242,82,46,.55)}
.f-panel--player::before{content:'';display:block;height:5px;border-radius:3px;margin:-12px -16px 10px;width:calc(100% + 32px);background:var(--red)}
.f-panel--rival{background:rgba(10,26,66,.9);border-color:rgba(89,153,242,.55)}
.f-panel--rival::before{content:'';display:block;height:5px;border-radius:3px;margin:-12px -16px 10px;width:calc(100% + 32px);background:var(--blue)}
.f-panel__title{font-size:13px;font-weight:700;color:var(--gold-br);text-align:center}
.f-panel__sub{font-size:10px;text-align:center;margin-top:2px}
.f-panel__sub--win{color:var(--green)}.f-panel__sub--lose{color:var(--red)}
.f-panel__divider{height:1px;margin:8px 0;background:rgba(255,255,255,.1)}
.f-row{display:flex;justify-content:space-between;padding:4px 0;font-size:11px}
.f-row__label{color:var(--cream)}
.f-row__val{font-weight:700}.f-row__val.fv-green{color:var(--green)}.f-row__val.fv-ora{color:var(--ora)}.f-row__val.fv-red{color:var(--red)}.f-row__val.fv-gold{color:var(--gold-br)}.f-row__val.fv-cream{color:var(--cream)}

/* Center victory badge */
.v-badge{text-align:center;padding:16px 0;align-self:center}
.v-badge__ring{width:160px;height:160px;border-radius:50%;margin:0 auto;
  background:radial-gradient(circle,rgba(217,173,38,.25),rgba(0,0,0,.4));
  border:3px solid rgba(217,173,38,.5);display:flex;flex-direction:column;align-items:center;justify-content:center;
  box-shadow:0 0 40px rgba(217,173,38,.15)}
.v-badge__title{font-size:18px;font-weight:700;color:var(--gold-br)}
.v-badge__round{font-size:13px;color:var(--cream);margin-top:4px}
.v-badge__detail{font-size:11px;margin-top:4px}
.v-badge__detail.vd-gold{color:var(--gold)}.v-badge__detail.vd-green{color:var(--green)}
.v-badge__winrate{font-size:10px;color:var(--cream);margin-top:4px}

/* Rewards */
.rewards-section{margin:20px auto;max-width:840px;background:rgba(46,26,8,.95);border:2px solid rgba(217,173,38,.55);border-radius:16px;padding:16px 20px}
.rewards-title{text-align:center;font-size:15px;font-weight:700;color:var(--gold-br);margin-bottom:8px}
.rewards-divider{height:3px;background:rgba(217,173,38,.35);border-radius:2px;margin-bottom:14px}
.rewards-grid{display:grid;grid-template-columns:repeat(2,1fr);gap:14px}
.reward-card{background:rgba(255,255,255,.05);border-radius:10px;padding:12px 16px;display:flex;gap:12px;align-items:center}
.reward-card__icon{width:40px;height:40px;border-radius:50%;flex-shrink:0}
.reward-card__icon--xp{background:rgba(255,224,102,.15);border:1px solid rgba(255,224,102,.3)}
.reward-card__icon--arena{background:rgba(242,158,56,.15);border:1px solid rgba(242,158,56,.3)}
.reward-card__icon--gold{background:rgba(217,173,38,.15);border:1px solid rgba(217,173,38,.3)}
.reward-card__info{flex:1}
.reward-card__label{font-size:11px;color:var(--cream)}
.reward-card__val{font-size:20px;font-weight:700;margin-top:2px}
.reward-card__val--xp{color:var(--gold-br)}.reward-card__val--arena{color:var(--ora)}.reward-card__val--gold{color:var(--gold)}
.reward-card__detail{font-size:9px;color:var(--cream);opacity:.7;margin-top:2px}

/* Ranking */
.ranking-bar{margin:14px auto;max-width:640px;padding:10px 20px;
  background:rgba(31,18,5,.9);border:1.5px solid rgba(71,217,107,.55);border-radius:22px;
  display:flex;align-items:center;gap:10px;justify-content:center}
.ranking-bar__label{font-size:12px;font-weight:700;color:var(--cream)}
.ranking-bar__old{font-size:16px;font-weight:700;color:var(--red)}
.ranking-bar__arrow{font-size:16px;font-weight:700;color:var(--gold-br)}
.ranking-bar__new{font-size:18px;font-weight:700;color:var(--green)}
.ranking-bar__msg{font-size:12px;font-weight:700;color:var(--green)}

/* Action buttons */
.actions-bar{display:flex;gap:14px;justify-content:center;padding:16px 0 24px;flex-wrap:wrap}
.action-btn{padding:14px 24px;font-family:var(--font);font-size:13px;font-weight:700;border-radius:12px;cursor:pointer;
  text-align:center;min-width:180px;transition:filter .15s,transform .1s;border:1.5px solid;text-decoration:none;display:block}
.action-btn:hover{filter:brightness(1.1);transform:translateY(-1px)}.action-btn:active{transform:translateY(1px)}
.action-btn:focus-visible{outline:2px solid var(--gold-br);outline-offset:3px}
.action-btn--fight{background:linear-gradient(to right,#f2522e,#91311c);border-color:transparent;color:var(--dark)}
.action-btn--chronicle{background:rgba(0,0,0,.3);border-color:rgba(255,224,102,.6);color:var(--gold-br)}
.action-btn--inventory{background:rgba(0,0,0,.3);border-color:rgba(89,153,242,.6);color:var(--blue)}
.action-btn--home{background:rgba(0,0,0,.3);border-color:rgba(245,232,191,.6);color:var(--cream)}
.action-btn__sub{font-size:10px;font-weight:400;margin-top:4px;opacity:.7}

/* Footer bar */
.footer-bar{border-top:2px solid rgba(217,173,38,.45);background:rgba(15,8,3,.85);height:52px}

@media(max-width:900px){.fighters-row{grid-template-columns:1fr;gap:12px}.v-badge{order:-1}.rewards-grid{grid-template-columns:1fr}}
@media(max-width:640px){.victory-title{font-size:48px;letter-spacing:3px}.actions-bar{flex-direction:column;align-items:center}.action-btn{width:80%}}
@media(prefers-reduced-motion:reduce){*,*::before,*::after{animation:none!important;transition:none!important}}
</style>
</head>
<body>
<form id="form1" runat="server">

<nav class="navbar">
  <span class="nav-logo">SQUAMA</span>
  <div class="nav-center"><p class="nav-center__title">RESULTADO DEL COMBATE</p><p class="nav-center__sub">Arena — Combate contra <asp:Label ID="LblNombreDefensorNav" runat="server" /></p></div>
</nav>

<main class="page">
  <header class="victory-header">
    <div class="victory-header__glow"></div>
    <p class="victory-stars">✦ &ensp; ✦ &ensp; ✦</p>
    <h1 class="victory-title">Victoria</h1>
    <p class="victory-defeated">Has derrotado a <asp:Label ID="LblNombreDefensor" runat="server" /></p>
    <div class="victory-rule"></div>
  </header>

  <section class="fighters-row">
    <div class="f-panel f-panel--player">
      <p class="f-panel__title"><asp:Label ID="LblNombreAtacante" runat="server" /> — TÚ</p>
      <p class="f-panel__sub f-panel__sub--win">(Ganador)</p>
      <div class="f-panel__divider"></div>
      <div class="f-row"><span class="f-row__label">Nivel</span><span class="f-row__val fv-cream"><asp:Label ID="LblNivelAtacante" runat="server" /></span></div>
    </div>

    <div class="v-badge">
      <div class="v-badge__ring">
        <span class="v-badge__title">VICTORIA</span>
      </div>
    </div>

    <div class="f-panel f-panel--rival">
      <p class="f-panel__title"><asp:Label ID="LblNombreDefensorPanel" runat="server" /> — RIVAL</p>
      <div class="f-panel__divider"></div>
      <div class="f-row"><span class="f-row__label">Nivel</span><span class="f-row__val fv-cream"><asp:Label ID="LblNivelDefensor" runat="server" /></span></div>
    </div>
  </section>

  <section class="rewards-section">
    <p class="rewards-title">Recompensas obtenidas</p>
    <div class="rewards-divider"></div>
    <div class="rewards-grid">
      <div class="reward-card">
        <div class="reward-card__icon reward-card__icon--xp"></div>
        <div class="reward-card__info">
          <p class="reward-card__label">Experiencia</p>
          <p class="reward-card__val reward-card__val--xp"><asp:Label ID="LblXPGanada" runat="server" /></p>
        </div>
      </div>
      <div class="reward-card">
        <div class="reward-card__icon reward-card__icon--arena"></div>
        <div class="reward-card__info">
          <p class="reward-card__label">Copas de Arena</p>
          <p class="reward-card__val reward-card__val--arena"><asp:Label ID="LblCopas" runat="server" /></p>
        </div>
      </div>
    </div>
  </section>

  <div class="actions-bar">
    <a href="SeleccionarRival.aspx" class="action-btn action-btn--fight">Pelear de nuevo<div class="action-btn__sub">(nuevo rival)</div></a>
    <a href="HomeJugador.aspx" class="action-btn action-btn--home">Volver al inicio<div class="action-btn__sub">(lobby)</div></a>
  </div>
</main>

<div class="footer-bar"></div>
</form>
</body>
</html>