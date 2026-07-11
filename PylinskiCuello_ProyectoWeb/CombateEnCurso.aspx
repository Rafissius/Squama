<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CombateEnCurso.aspx.cs" Inherits="PylinskiCuello_ProyectoWeb.CombateEnCurso" %>

<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Arena — Combate en Curso · SQUAMA</title>
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@400;600;700;900&family=Inter:wght@400;600;700&display=swap" rel="stylesheet" />
<style>
:root{--bg:#1a0f05;--bg-dark:#0f0803;--bg-card:#261507;--gold:#d9ad26;--gold-br:#ffe066;--cream:#f5e8bf;--green:#47d96b;--red:#f2522e;--blue:#5999f2;--ora:#f29e38;--purp:#b86bf2;--dark:#1f1005;--font:'Inter',system-ui,sans-serif;--font-title:'Cinzel',serif}
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:var(--font);background-color:var(--bg);background-image:repeating-linear-gradient(to bottom,rgba(82,46,20,.1) 0,rgba(82,46,20,.1) 26px,transparent 26px,transparent 54px);color:var(--cream);min-height:100vh;overflow-x:hidden}
body::before{content:'';position:fixed;inset:0;background:radial-gradient(ellipse at center,transparent 0%,rgba(0,0,0,.3) 60%,rgba(0,0,0,.8) 100%);pointer-events:none;z-index:0}
body::after{content:'';position:fixed;inset:0;background:linear-gradient(to right,rgba(178,26,13,.15),transparent 40%,transparent 60%,rgba(26,51,128,.12));pointer-events:none;z-index:0}
.navbar{position:sticky;top:0;z-index:100;display:flex;align-items:center;justify-content:space-between;height:60px;padding:0 24px;background:rgba(20,10,3,.92);border-top:2px solid var(--gold);border-bottom:2px solid rgba(217,173,38,.4)}
.nav-left{display:flex;flex-direction:column}.nav-logo{font-size:18px;font-weight:700;color:var(--gold)}.nav-status{font-size:10px;font-weight:700;color:var(--red);letter-spacing:1px}
.nav-center{font-size:32px;color:var(--cream);text-align:center;position:absolute;left:50%;transform:translateX(-50%)}.nav-center b{color:var(--gold-br)}
.combat-layout{position:relative;z-index:1;display:grid;grid-template-columns:420px 1fr 420px;gap:0;max-width:1440px;margin:0 auto;min-height:calc(100vh - 60px - 100px)}
.fighter{padding:12px 16px;border-radius:14px;margin:8px}
.fighter--player{background:linear-gradient(to right,rgba(77,20,10,.95),rgba(36,15,5,.95));border:2px solid rgba(242,82,46,.7)}
.fighter--rival{background:linear-gradient(to right,rgba(10,26,66,.95),rgba(15,10,36,.95));border:2px solid rgba(89,153,242,.7)}
.fighter::before{content:'';display:block;height:5px;border-radius:3px;margin:-12px -16px 10px;width:calc(100% + 32px)}
.fighter--player::before{background:var(--red)}.fighter--rival::before{background:var(--blue)}
.fighter__avatar{width:100px;height:100px;border-radius:50%;margin:0 auto 8px;background:rgba(140,82,31,.4);border:3px solid rgba(217,173,38,.4)}
.fighter__name{font-size:18px;font-weight:700;color:var(--gold-br);text-align:center}
.fighter__sub{font-size:11px;color:var(--cream);text-align:center;margin-top:2px}
.fighter__rank{display:block;width:max-content;margin:6px auto;font-size:10px;font-weight:700;padding:3px 14px;border-radius:10px;color:var(--dark);background:#f2c733}
.hp-row{display:flex;align-items:baseline;gap:8px;margin-top:10px}.hp-label{font-size:11px;font-weight:700;color:var(--cream)}.hp-value{font-size:11px;font-weight:700}
.hp-value--ok{color:var(--green)}.hp-value--mid{color:var(--ora)}
.hp-bar{height:14px;background:rgba(0,0,0,.45);border-radius:7px;margin-top:4px;overflow:hidden}
.hp-bar__fill{height:100%;border-radius:7px;transition:width .6s ease}
.hp-fill--ok{background:linear-gradient(to right,#33d959,#1a8c33)}.hp-fill--mid{background:linear-gradient(to right,#f29e1a,#b24d0d)}
.stat-boxes{display:flex;gap:6px;margin-top:10px}
.stat-box{flex:1;background:rgba(0,0,0,.3);border-radius:6px;padding:6px 4px;text-align:center}
.stat-box__val{font-size:16px;font-weight:700}.stat-box__val.s-fue{color:var(--ora)}.stat-box__val.s-agl{color:var(--green)}.stat-box__val.s-vel{color:var(--blue)}.stat-box__val.s-int{color:var(--purp)}
.stat-box__label{font-size:9px;color:rgba(245,232,191,.6);margin-top:2px}
.equip-section{margin-top:12px}.equip-label{font-size:10px;font-weight:700;color:var(--gold);margin-bottom:6px}
.equip-grid{display:flex;gap:6px}.equip-slot{width:68px;height:56px;border-radius:8px;text-align:center;padding-top:22px;font-size:8px;color:var(--cream)}
.equip-slot--player{background:rgba(64,26,13,.7);border:1px solid rgba(242,82,46,.55)}.equip-slot--rival{background:rgba(26,20,64,.7);border:1px solid rgba(184,107,242,.45)}
.equip-slot__type{display:block;font-size:8px;color:rgba(245,232,191,.7);margin-top:2px}.equip-slot__name{display:block;font-size:7px;color:var(--ora);margin-top:1px}
.chronicle{margin:8px 12px;background:linear-gradient(to bottom,rgba(51,31,10,.97),rgba(41,23,8,.97) 50%,rgba(51,31,10,.97));border:2px solid rgba(217,173,38,.55);border-radius:16px;display:flex;flex-direction:column;overflow:hidden}
.chronicle__head{padding:10px 16px;background:linear-gradient(to right,rgba(140,97,10,.8),transparent);text-align:center}
.chronicle__title{font-size:16px;font-weight:700;color:var(--gold-br)}.chronicle__sub{font-size:10px;color:var(--cream);opacity:.7}
.chronicle__divider{height:1px;background:rgba(217,173,38,.3)}
.vs-badge{position:absolute;top:60px;left:50%;transform:translateX(-50%);z-index:10}
.vs-badge__ring{width:96px;height:96px;border-radius:50%;border:3px solid rgba(217,173,38,.5);background:radial-gradient(circle,rgba(217,173,38,.25),rgba(0,0,0,.6));display:grid;place-items:center;box-shadow:0 0 30px rgba(217,173,38,.2)}
.vs-badge__text{font-size:28px;font-weight:700;color:var(--dark)}
.vs-lines{position:absolute;top:108px;left:50%;transform:translateX(-50%);display:flex;align-items:center}
.vs-line{height:2px;width:200px;border-radius:1px}.vs-line--left{background:linear-gradient(to right,transparent,rgba(242,82,46,.5))}.vs-line--right{background:linear-gradient(to left,transparent,rgba(89,153,242,.5))}
.chronicle__log{flex:1;overflow-y:auto;padding:8px 12px}
.log-entry{display:flex;gap:8px;padding:8px 10px;border-radius:6px;margin-bottom:6px;align-items:flex-start}
.log-entry--system{background:rgba(51,38,10,.4)}.log-entry--player{background:rgba(89,38,5,.55)}.log-entry--rival{background:rgba(10,26,71,.55)}.log-entry--damage{background:rgba(64,10,10,.55)}.log-entry--buff{background:rgba(10,56,20,.55)}.log-entry--crit{background:rgba(77,56,5,.65)}
.log-bar{width:3px;min-height:100%;border-radius:2px;flex-shrink:0;align-self:stretch}
.log-entry--system .log-bar{background:#bfa666}.log-entry--player .log-bar{background:#f29933}.log-entry--rival .log-bar{background:#73a6f2}.log-entry--damage .log-bar{background:#f25933}.log-entry--buff .log-bar{background:#47d96b}.log-entry--crit .log-bar{background:#f2a61a}
.log-round{font-size:8px;font-weight:700;padding:2px 6px;border-radius:4px;white-space:nowrap;flex-shrink:0;align-self:flex-start}
.log-entry--system .log-round{background:rgba(191,166,102,.25);color:#bfa666}.log-entry--player .log-round{background:rgba(242,153,51,.25);color:#f29933}.log-entry--rival .log-round{background:rgba(115,166,242,.25);color:#73a6f2}.log-entry--damage .log-round{background:rgba(242,89,51,.25);color:#f25933}.log-entry--buff .log-round{background:rgba(71,217,107,.25);color:#47d96b}.log-entry--crit .log-round{background:rgba(242,166,26,.25);color:#f2a61a}
.log-content{flex:1;min-width:0}.log-speaker{font-size:10px;font-weight:700}
.log-entry--system .log-speaker{color:#bfa666}.log-entry--player .log-speaker{color:#f29933}.log-entry--rival .log-speaker{color:#73a6f2}.log-entry--damage .log-speaker{color:#f25933}.log-entry--buff .log-speaker{color:#47d96b}.log-entry--crit .log-speaker{color:#f2a61a}
.log-text{font-size:11px;color:var(--cream);line-height:1.4;margin-top:2px}
.chronicle__status{margin:6px 12px;padding:6px 12px;text-align:center;background:rgba(217,173,38,.15);border:1px solid rgba(217,173,38,.4);border-radius:6px;font-size:11px;color:var(--gold-br)}
.chronicle__actions-head{text-align:center;font-size:12px;font-weight:700;color:var(--gold-br);padding:6px 0 4px;border-top:1px solid rgba(217,173,38,.25);margin:0 12px}
.actions-grid{display:grid;grid-template-columns:1fr 1fr;gap:4px;padding:0 12px 12px}
.action-item{display:flex;justify-content:space-between;background:rgba(0,0,0,.28);border-radius:6px;padding:5px 10px;font-size:10px}
.action-item__label{color:var(--cream)}.action-item__val{font-weight:700}
.action-item__val.a-ora{color:var(--ora)}.action-item__val.a-purp{color:var(--purp)}.action-item__val.a-gold{color:var(--gold)}.action-item__val.a-blue{color:var(--blue)}
.bottom-bar{position:relative;z-index:1;background:rgba(20,10,3,.96);border-top:2px solid rgba(217,173,38,.5);padding:12px 40px;display:flex;align-items:center;gap:20px}
.bottom-bar__label{font-size:12px;font-weight:700;color:var(--cream);white-space:nowrap}
.reward-box{background:rgba(0,0,0,.3);border-radius:8px;padding:6px 20px;text-align:center;min-width:140px}
.reward-box__val{font-size:18px;font-weight:700}.reward-box__val.r-gold{color:var(--gold-br)}.reward-box__val.r-ora{color:var(--ora)}.reward-box__val.r-yellow{color:var(--gold)}
.reward-box__label{font-size:10px;color:var(--cream);margin-top:2px}
.bottom-spacer{flex:1}
.btn-results{padding:12px 30px;font-family:var(--font);font-size:13px;font-weight:700;color:var(--red);background:rgba(77,20,20,.7);border:1px solid rgba(242,82,46,.6);border-radius:10px;cursor:pointer;transition:background .15s}
.btn-results:hover{background:rgba(77,20,20,.9)}.btn-results:focus-visible{outline:2px solid var(--gold-br);outline-offset:3px}
@media(max-width:1100px){.combat-layout{grid-template-columns:1fr}.fighter{max-width:500px;margin:8px auto;width:100%}.chronicle{max-width:600px;margin:8px auto;width:100%}.vs-badge,.vs-lines{display:none}}
@media(max-width:640px){.bottom-bar{flex-wrap:wrap;justify-content:center;gap:10px}.reward-box{min-width:100px}.nav-center{font-size:22px}}
@media(prefers-reduced-motion:reduce){*,*::before,*::after{animation:none!important;transition:none!important}}
</style>
</head>
<body>
<nav class="navbar"><div class="nav-left"><span class="nav-logo">SQUAMA</span><span class="nav-status">ARENA — EN COMBATE</span></div><span class="nav-center"><b>Goku</b>&ensp;vs&ensp;<b>Chimuelo</b></span></nav>
<div class="vs-badge"><div class="vs-badge__ring"><span class="vs-badge__text">VS</span></div></div>
<div class="vs-lines"><div class="vs-line vs-line--left"></div><div class="vs-line vs-line--right"></div></div>
<div class="combat-layout">
  <div class="fighter fighter--player">
    <div class="fighter__avatar"></div><p class="fighter__name">Goku</p><p class="fighter__sub">El Implacable — Nv.24</p><span class="fighter__rank">ORO</span>
    <div class="hp-row"><span class="hp-label">HP</span><span class="hp-value hp-value--ok">2,840 / 3,200</span></div>
    <div class="hp-bar"><div class="hp-bar__fill hp-fill--ok" style="width:88%"></div></div>
    <div class="stat-boxes"><div class="stat-box"><div class="stat-box__val s-fue">412</div><div class="stat-box__label">FUE</div></div><div class="stat-box"><div class="stat-box__val s-agl">287</div><div class="stat-box__label">AGL</div></div><div class="stat-box"><div class="stat-box__val s-vel">334</div><div class="stat-box__label">VEL</div></div><div class="stat-box"><div class="stat-box__val s-int">198</div><div class="stat-box__label">INT</div></div></div>
    <div class="equip-section"><p class="equip-label">Equipamiento:</p><div class="equip-grid"><div class="equip-slot equip-slot--player"><span class="equip-slot__type">Arma</span><span class="equip-slot__name">Esp.Dragon</span></div><div class="equip-slot equip-slot--player"><span class="equip-slot__type">Armadura</span><span class="equip-slot__name">Egida</span></div><div class="equip-slot equip-slot--player"><span class="equip-slot__type">Mascota</span><span class="equip-slot__name">Dr.Cristal</span></div><div class="equip-slot equip-slot--player"><span class="equip-slot__type">Hab.1</span><span class="equip-slot__name">Tormenta</span></div><div class="equip-slot equip-slot--player"><span class="equip-slot__type">Hab.2</span><span class="equip-slot__name">G.Trueno</span></div></div></div>
  </div>
  <div class="chronicle">
    <div class="chronicle__head"><p class="chronicle__title">Crónica del Combate</p><p class="chronicle__sub">— El escriba registra cada golpe —</p></div><div class="chronicle__divider"></div>
    <div class="chronicle__log">
      <div class="log-entry log-entry--system"><div class="log-bar"></div><span class="log-round">R.1</span><div class="log-content"><p class="log-speaker">Sistema:</p><p class="log-text">El combate comienza. Los guerreros se enfrentan bajo la mirada del Salón de la Arena.</p></div></div>
      <div class="log-entry log-entry--player"><div class="log-bar"></div><span class="log-round">R.1</span><div class="log-content"><p class="log-speaker">Goku:</p><p class="log-text">Goku ataca primero gracias a su velocidad superior. El golpe conecta directo en el hombro de Chimuelo.</p></div></div>
      <div class="log-entry log-entry--damage"><div class="log-bar"></div><span class="log-round">R.1</span><div class="log-content"><p class="log-speaker">Sistema:</p><p class="log-text">La Espada del Dragon Eterno vibra con energía. Daño causado: 340 pts.</p></div></div>
      <div class="log-entry log-entry--rival"><div class="log-bar"></div><span class="log-round">R.1</span><div class="log-content"><p class="log-speaker">Chimuelo:</p><p class="log-text">Chimuelo contraataca con furia bruta. Su arma desconocida golpea con fuerza devastadora.</p></div></div>
      <div class="log-entry log-entry--damage"><div class="log-bar"></div><span class="log-round">R.1</span><div class="log-content"><p class="log-speaker">Sistema:</p><p class="log-text">Goku resiste gracias a la Egida del Caballero Eterno. Daño recibido: 210 pts.</p></div></div>
      <div class="log-entry log-entry--buff"><div class="log-bar"></div><span class="log-round">R.2</span><div class="log-content"><p class="log-speaker">Mascota:</p><p class="log-text">El Dragon de Cristal lanza un aullido. Los reflejos de Goku aumentan un 12% durante 2 rondas.</p></div></div>
      <div class="log-entry log-entry--player"><div class="log-bar"></div><span class="log-round">R.2</span><div class="log-content"><p class="log-speaker">Goku:</p><p class="log-text">Goku encadena la Tormenta de las Mil Almas. Una ráfaga mágica envuelve a Chimuelo.</p></div></div>
      <div class="log-entry log-entry--crit"><div class="log-bar"></div><span class="log-round">R.2</span><div class="log-content"><p class="log-speaker">Sistema:</p><p class="log-text">¡Crítico! Daño mágico: 520 pts. La mascota del rival queda aturdida.</p></div></div>
      <div class="log-entry log-entry--rival"><div class="log-bar"></div><span class="log-round">R.3</span><div class="log-content"><p class="log-speaker">Chimuelo:</p><p class="log-text">Chimuelo intenta recuperarse pero Goku no da tregua. La diferencia de nivel se hace sentir.</p></div></div>
    </div>
    <div class="chronicle__status">Ronda 3 / 5 estimadas — calculando resultado...</div>
    <div class="chronicle__divider"></div>
    <p class="chronicle__actions-head">Acciones del combate</p>
    <div class="actions-grid"><div class="action-item"><span class="action-item__label">Ataque básico</span><span class="action-item__val a-ora">x6</span></div><div class="action-item"><span class="action-item__label">Habilidad usada</span><span class="action-item__val a-purp">x3</span></div><div class="action-item"><span class="action-item__label">Críticos</span><span class="action-item__val a-gold">x1</span></div><div class="action-item"><span class="action-item__label">Bloqueos</span><span class="action-item__val a-blue">x2</span></div></div>
  </div>
  <div class="fighter fighter--rival">
    <div class="fighter__avatar"></div><p class="fighter__name">Kragnar el Bestia</p><p class="fighter__sub">El Implacable — Nv.23</p><span class="fighter__rank">ORO</span>
    <div class="hp-row"><span class="hp-label">HP</span><span class="hp-value hp-value--mid">1,705 / 3,100</span></div>
    <div class="hp-bar"><div class="hp-bar__fill hp-fill--mid" style="width:55%"></div></div>
    <div class="stat-boxes"><div class="stat-box"><div class="stat-box__val s-fue">445</div><div class="stat-box__label">FUE</div></div><div class="stat-box"><div class="stat-box__val s-agl">210</div><div class="stat-box__label">AGL</div></div><div class="stat-box"><div class="stat-box__val s-vel">290</div><div class="stat-box__label">VEL</div></div><div class="stat-box"><div class="stat-box__val s-int">155</div><div class="stat-box__label">INT</div></div></div>
    <div class="equip-section"><p class="equip-label">Equipamiento:</p><div class="equip-grid"><div class="equip-slot equip-slot--rival"><span class="equip-slot__type">Arma</span></div><div class="equip-slot equip-slot--rival"><span class="equip-slot__type">Armadura</span></div><div class="equip-slot equip-slot--rival"><span class="equip-slot__type">Mascota</span></div><div class="equip-slot equip-slot--rival"><span class="equip-slot__type">Hab.1</span></div><div class="equip-slot equip-slot--rival"><span class="equip-slot__type">Hab.2</span></div></div></div>
  </div>
</div>
<div class="bottom-bar"><span class="bottom-bar__label">Al finalizar el combate:</span><div class="reward-box"><div class="reward-box__val r-gold">+420</div><div class="reward-box__label">XP</div></div><div class="reward-box"><div class="reward-box__val r-ora">+2 pts</div><div class="reward-box__label">Arena</div></div><div class="reward-box"><div class="reward-box__val r-yellow">+1</div><div class="reward-box__label">Monedas</div></div><div class="bottom-spacer"></div><button class="btn-results" onclick="alert('Redirigiendo a resultados...')">Resultados</button></div>
</body>
</html>