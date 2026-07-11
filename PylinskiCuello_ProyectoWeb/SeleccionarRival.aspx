<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SeleccionarRival.aspx.cs" Inherits="PylinskiCuello_ProyectoWeb.SeleccionarRival" %>

<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>La Arena — Selección de Rivales · SQUAMA</title>
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@400;600;700;900&family=Inter:wght@400;600;700&display=swap" rel="stylesheet" />
<style>
:root{
  --bg:#2e1a0a;--bg-dark:#0f0803;--bg-card:#261507;
  --gold:#d9ad26;--gold-br:#ffe066;--cream:#f5e8bf;
  --green:#47d96b;--red:#f24d33;--blue:#5999f2;--ora:#f29e38;--purp:#b86bf2;
  --dark:#1f1005;--black:#000;
  --stripe:rgba(82,46,20,.14);
  --font:'Inter',system-ui,sans-serif;--font-title:'Cinzel',serif;
  /* Rank colors */
  --rank-oro:#f2c733;--rank-plata:#b8b8b8;--rank-bronce:#b87333;--rank-diamante:#6bc7f2;
}
*{box-sizing:border-box;margin:0;padding:0}
html{scroll-behavior:smooth}
body{
  font-family:var(--font);background-color:var(--bg);
  background-image:repeating-linear-gradient(to bottom,var(--stripe) 0,var(--stripe) 26px,transparent 26px,transparent 54px);
  color:var(--cream);min-height:100vh;
}
body::before{content:'';position:fixed;inset:0;
  background:radial-gradient(ellipse at center,rgba(0,0,0,0) 0%,rgba(140,38,13,.18) 55%,rgba(0,0,0,.65) 100%);
  pointer-events:none;z-index:0}

/* ─── NAVBAR (Player) ─── */
.navbar{position:sticky;top:0;z-index:100;display:flex;align-items:center;
  height:68px;padding:0 28px;background:rgba(15,8,3,.97);
  border-top:3px solid var(--gold);border-bottom:2px solid rgba(217,173,38,.35);backdrop-filter:blur(6px)}
.nav-logo{font-family:var(--font-title);font-size:24px;font-weight:700;color:var(--gold);letter-spacing:1px;margin-right:auto}
.nav-links{display:flex;gap:6px;list-style:none;margin:0 auto}
.nav-links a{display:block;padding:8px 16px;font-size:14px;color:rgba(245,232,191,.55);
  text-decoration:none;border-radius:6px;transition:color .15s;text-transform:capitalize;font-weight:500}
.nav-links a:hover{color:var(--cream)}
.nav-links a.active{color:var(--gold-br);font-weight:700}
.nav-user{display:flex;align-items:center;gap:10px;margin-left:auto}
.nav-avatar{width:44px;height:44px;border-radius:50%;background:rgba(140,82,31,.7);border:2px solid rgba(217,173,38,.5)}
.nav-user-info{display:flex;flex-direction:column;line-height:1.2;text-align:right}
.nav-user-name{font-size:13px;font-weight:600;color:var(--cream)}
.nav-user-detail{font-size:11px;color:rgba(178,148,102,.8)}

/* ─── PAGE ─── */
.page{position:relative;z-index:1;max-width:1440px;margin:0 auto;padding:0 16px}

/* ─── ARENA HEADER ─── */
.arena-header{text-align:center;padding:20px 0 6px;
  background:linear-gradient(to right,rgba(191,64,13,.45),transparent 50%,rgba(191,64,13,.25))}
.arena-title{font-family:var(--font-title);font-size:42px;font-weight:700;color:var(--gold-br);letter-spacing:1px}
.arena-subtitle{font-size:14px;color:rgba(245,232,191,.7);margin-top:6px}
.arena-rule{width:360px;height:2px;margin:10px auto 0;background:rgba(217,173,38,.5);border-radius:1px}

/* ─── PLAYER BAR ─── */
.player-bar{display:flex;align-items:center;justify-content:center;gap:10px;
  margin:12px auto;padding:10px 20px;max-width:820px;
  background:rgba(31,18,5,.85);border:1.5px solid rgba(217,173,38,.4);border-radius:22px}
.player-bar__label{font-size:10px;font-weight:700;color:var(--cream)}
.player-bar__name{font-size:14px;font-weight:700;color:var(--gold-br)}
.stat-pill{font-size:10px;font-weight:700;padding:4px 10px;border-radius:13px;white-space:nowrap}
.stat-pill--vid{color:var(--red);background:rgba(242,77,51,.18)}
.stat-pill--fue{color:var(--ora);background:rgba(242,158,56,.18)}
.stat-pill--agl{color:var(--green);background:rgba(71,217,107,.18)}
.stat-pill--vel{color:var(--blue);background:rgba(89,153,242,.18)}
.stat-pill--int{color:var(--purp);background:rgba(184,107,242,.18)}
.attempts-pill{font-size:10px;font-weight:700;color:var(--gold-br);padding:4px 12px;
  border-radius:13px;background:rgba(217,173,38,.2);border:1px solid rgba(217,173,38,.5)}

/* ─── SECTION TITLE ─── */
.section-title{text-align:center;font-size:22px;font-weight:700;color:var(--gold-br);margin:14px 0 16px}

/* ─── RIVALS GRID ─── */
.rivals-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:20px}

/* ─── RIVAL CARD ─── */
.rival-card{position:relative;background:linear-gradient(to bottom,rgba(66,41,15,.97),rgba(46,26,10,.97));
  border:1.5px solid;border-radius:14px;overflow:hidden;
  box-shadow:0 8px 0 rgba(0,0,0,.5);transition:transform .15s,box-shadow .15s}
.rival-card:hover{transform:translateY(-3px);box-shadow:0 12px 20px rgba(0,0,0,.5)}
.rival-card::before{content:'';position:absolute;top:0;left:0;right:0;height:6px;border-radius:3px 3px 0 0}
/* Rank variants */
.rival-card[data-rank="oro"]{border-color:rgba(242,199,51,.5)}.rival-card[data-rank="oro"]::before{background:var(--rank-oro)}
.rival-card[data-rank="plata"]{border-color:rgba(184,184,184,.45)}.rival-card[data-rank="plata"]::before{background:var(--rank-plata)}
.rival-card[data-rank="bronce"]{border-color:rgba(184,115,51,.45)}.rival-card[data-rank="bronce"]::before{background:var(--rank-bronce)}
.rival-card[data-rank="diamante"]{border-color:rgba(107,199,242,.45)}.rival-card[data-rank="diamante"]::before{background:var(--rank-diamante)}

.rival-card__top{display:flex;gap:12px;padding:14px 14px 0;align-items:flex-start}
.rival-avatar{position:relative;flex-shrink:0}
.rival-avatar__circle{width:74px;height:74px;border-radius:50%;
  background:rgba(140,82,31,.5);border:3px solid rgba(217,173,38,.4)}
.rival-avatar__level{position:absolute;bottom:-2px;left:50%;transform:translateX(-50%);
  font-size:10px;font-weight:700;color:var(--gold-br);background:rgba(0,0,0,.6);
  padding:1px 8px;border-radius:8px;white-space:nowrap}
.rival-avatar__rank{position:absolute;bottom:-16px;left:50%;transform:translateX(-50%);
  font-size:10px;font-weight:700;padding:2px 12px;border-radius:9px;white-space:nowrap}
.rank-oro{background:var(--rank-oro);color:var(--dark)}
.rank-plata{background:var(--rank-plata);color:var(--dark)}
.rank-bronce{background:var(--rank-bronce);color:var(--dark)}
.rank-diamante{background:var(--rank-diamante);color:var(--dark)}

.rival-info{flex:1;min-width:0}
.rival-info__name{font-size:16px;font-weight:700;color:var(--cream)}
.rival-info__clan{font-size:11px;color:var(--gold-br);margin-top:2px}
.rival-mini-stats{display:flex;gap:6px;margin-top:10px}
.mini-stat{background:rgba(0,0,0,.3);border-radius:6px;padding:5px 10px;min-width:72px}
.mini-stat__label{font-size:9px;color:rgba(245,232,191,.6)}
.mini-stat__value{font-size:12px;font-weight:700;margin-top:2px}
.mini-stat__value.v-red{color:var(--red)}.mini-stat__value.v-ora{color:var(--ora)}
.mini-stat__value.v-green{color:var(--green)}.mini-stat__value.v-blue{color:var(--blue)}

/* Stats bars */
.rival-stats{padding:12px 14px 0}
.rival-stats__divider{height:1px;background:rgba(217,173,38,.2);margin-bottom:10px}
.stats-grid{display:grid;grid-template-columns:1fr 1fr;gap:8px 20px}
.stat-row{display:flex;flex-direction:column;gap:2px}
.stat-row__head{display:flex;justify-content:space-between;align-items:baseline}
.stat-row__label{font-size:10px;color:rgba(245,232,191,.7)}
.stat-row__val{font-size:10px;font-weight:700}
.stat-row__val.s-vid{color:var(--red)}.stat-row__val.s-fue{color:var(--ora)}
.stat-row__val.s-agl{color:var(--green)}.stat-row__val.s-vel{color:var(--blue)}.stat-row__val.s-int{color:var(--purp)}
.stat-bar{height:8px;background:rgba(0,0,0,.38);border-radius:4px;overflow:hidden}
.stat-bar__fill{height:100%;border-radius:4px}
.bar-vid{background:linear-gradient(to right,#f24d33,#79261a)}
.bar-fue{background:linear-gradient(to right,#f29e38,#794f1c)}
.bar-agl{background:linear-gradient(to right,#47d96b,#246c36)}
.bar-vel{background:linear-gradient(to right,#5999f2,#2d4d79)}
.bar-int{background:linear-gradient(to right,#b86bf2,#5c3679)}

.rival-card__divider2{height:1px;background:rgba(217,173,38,.2);margin:10px 14px 0}

/* Fight button */
.rival-card__foot{padding:10px 14px 14px}
.btn-fight{display:block;width:100%;padding:11px;font-family:var(--font);font-size:14px;font-weight:700;
  color:var(--dark);background:linear-gradient(to right,#f2c733,#b28014);border:none;border-radius:10px;
  cursor:pointer;text-transform:uppercase;letter-spacing:1px;
  transition:filter .15s,transform .1s;box-shadow:0 2px 8px rgba(178,128,20,.3)}
.btn-fight:hover{filter:brightness(1.1);transform:translateY(-1px)}
.btn-fight:active{transform:translateY(1px)}
.btn-fight:focus-visible{outline:2px solid var(--gold-br);outline-offset:3px}

/* ─── BOTTOM BAR ─── */
.bottom-bar{position:relative;z-index:1;margin-top:20px;padding:14px 20px;
  display:flex;align-items:center;justify-content:center;gap:14px;
  background:rgba(26,15,5,.92);border-top:2px solid var(--gold)}
.bottom-bar__text{font-size:12px;color:rgba(245,232,191,.7)}
.btn-refresh{font-size:10px;font-weight:700;color:var(--gold-br);
  padding:5px 16px;border-radius:14px;
  background:rgba(217,173,38,.22);border:1px solid rgba(217,173,38,.55);
  cursor:pointer;transition:background .15s;white-space:nowrap}
.btn-refresh:hover{background:rgba(217,173,38,.35)}

/* Toast */
.toast{position:fixed;bottom:24px;left:50%;transform:translateX(-50%);padding:12px 24px;
  background:rgba(15,8,3,.98);border:1.5px solid var(--gold);border-radius:10px;
  color:var(--cream);font-size:13px;font-weight:600;box-shadow:0 6px 30px rgba(0,0,0,.5);z-index:2000;
  animation:toastIn .25s ease}
.toast[hidden]{display:none}
@keyframes toastIn{from{transform:translate(-50%,20px);opacity:0}to{transform:translate(-50%,0);opacity:1}}

/* Responsive */
@media(max-width:1100px){.rivals-grid{grid-template-columns:repeat(2,1fr)}}
@media(max-width:900px){.nav-links{display:none}.player-bar{flex-wrap:wrap;justify-content:center}}
@media(max-width:640px){.rivals-grid{grid-template-columns:1fr}.arena-title{font-size:30px}
  .player-bar{gap:6px}.stat-pill{font-size:9px;padding:3px 7px}}
@media(prefers-reduced-motion:reduce){*,*::before,*::after{animation:none!important;transition:none!important}}
</style>
</head>
<body>
<form id="form1" runat="server">

<!-- ═══════════ NAVBAR ═══════════ -->
<nav class="navbar">
  <span class="nav-logo">SQUAMA</span>
  <ul class="nav-links">
    <li><a href="HomeJugador.aspx">Inicio</a></li>
    <li><a href="SeleccionarRival.aspx" class="active">Arena</a></li>
    <li><a href="EnConstruccionJugador.aspx">Gacha</a></li>
    <li><a href="EnConstruccionJugador.aspx">Clan</a></li>
    <li><a href="EnConstruccionJugador.aspx">Perfil</a></li>
    <li><a href="EnConstruccionJugador.aspx">Inventario</a></li>
  </ul>
  <div class="nav-user">
    <div class="nav-user-info">
      <asp:Label ID="LblNavNombre" runat="server" CssClass="nav-user-name" />
      <span class="nav-user-detail">Nivel <asp:Label ID="LblNavNivel" runat="server" /> · Sin clan</span>
    </div>
    <div class="nav-avatar"></div>
  </div>
</nav>

<main class="page">
  <!-- ═══════════ HEADER ═══════════ -->
  <header class="arena-header">
    <h1 class="arena-title">La Arena</h1>
    <p class="arena-subtitle">El campo donde los guerreros forjan su leyenda. Elige a tu rival con sabiduría.</p>
    <div class="arena-rule"></div>
  </header>

  <!-- ═══════════ PLAYER BAR ═══════════ -->
  <div class="player-bar">
    <span class="player-bar__label">TU PERSONAJE:</span>
    <asp:Label ID="LblJugadorNombreNivel" runat="server" CssClass="player-bar__name" />
    <asp:Label ID="LblStatVida" runat="server" CssClass="stat-pill stat-pill--vid" />
    <asp:Label ID="LblStatFuerza" runat="server" CssClass="stat-pill stat-pill--fue" />
    <asp:Label ID="LblStatAgilidad" runat="server" CssClass="stat-pill stat-pill--agl" />
    <asp:Label ID="LblStatVelocidad" runat="server" CssClass="stat-pill stat-pill--vel" />
    <asp:Label ID="LblStatInteligencia" runat="server" CssClass="stat-pill stat-pill--int" />
    <span class="attempts-pill">Intentos hoy: 3 / 5</span>
  </div>

  <!-- ═══════════ RIVAL SELECTION ═══════════ -->
  <h2 class="section-title">Elige tu Rival</h2>

  <section class="rivals-grid" id="rivalsGrid"></section>
</main>

<!-- ═══════════ BOTTOM BAR ═══════════ -->
<div class="bottom-bar">
  <span class="bottom-bar__text">Los rivales se renuevan automáticamente cada 24 hs</span>
  <button class="btn-refresh" id="btnRefresh">Refrescar (1 intento)</button>
</div>

<div id="toast" class="toast" hidden></div>

</form>

<script>
    'use strict';

    /* ─── RIVALES REALES (vía ArenaApi.ashx) ─── */
    let RIVALES = [];

    // Valor máximo de estadística para escalar las barras. Fijo por ahora (las stats
    // reales arrancan en single-digits y crecen de a +5 por nivel); se hará dinámico
    // más adelante (por ejemplo, a partir del máximo real entre los rivales mostrados).
    const VALOR_MAXIMO_ESTADISTICA = 50;

    function obtenerRivalesReales() {
        return fetch('ArenaApi.ashx?accion=ListarRivales', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({}),
            credentials: 'same-origin',
        })
            .then((resp) => resp.json().then((data) => ({ ok: resp.ok, data })))
            .then(({ ok, data }) => {
                if (!ok) throw new Error((data && data.error) || 'Error inesperado.');
                RIVALES = data;
                renderizarRivales();
            })
            .catch((err) => mostrarNotificacion(err.message || 'No se pudieron cargar los rivales.'));
    }

    function obtenerAnchoBarraEstadistica(valor) { return Math.min(100, (valor / VALOR_MAXIMO_ESTADISTICA) * 100) + '%'; }

    function obtenerEtiquetaRango(rango) {
        const etiquetasPorRango = { oro: 'Oro', plata: 'Plata', bronce: 'Bronce', diamante: 'Diamante' };
        return etiquetasPorRango[rango] || rango;
    }

    function mostrarNotificacion(mensaje) {
        const notificacion = document.getElementById('toast');
        notificacion.textContent = mensaje; notificacion.hidden = false;
        clearTimeout(notificacion._timer);
        notificacion._timer = setTimeout(() => { notificacion.hidden = true; }, 3200);
    }

    function renderizarRivales() {
        const grillaRivales = document.getElementById('rivalsGrid');

        if (RIVALES.length === 0) {
            grillaRivales.innerHTML = '<p style="grid-column:1/-1;text-align:center;color:rgba(245,232,191,.7)">No hay rivales disponibles todavía.</p>';
            return;
        }

        grillaRivales.innerHTML = RIVALES.map((rival, indice) => `
    <article class="rival-card" data-rank="${rival.Rango}" data-rival="${indice}">
      <div class="rival-card__top">
        <div class="rival-avatar">
          <div class="rival-avatar__circle"></div>
          <span class="rival-avatar__level">Nv.${rival.Nivel}</span>
          <span class="rival-avatar__rank rank-${rival.Rango}">${obtenerEtiquetaRango(rival.Rango)}</span>
        </div>
        <div class="rival-info">
          <p class="rival-info__name">${rival.Nombre}</p>
          <p class="rival-info__clan">Clan: ${rival.Clan}</p>
          <div class="rival-mini-stats">
            <div class="mini-stat">
              <div class="mini-stat__label">Winrate</div>
              <div class="mini-stat__value ${rival.ColorPorcentajeVictorias}">${rival.PorcentajeVictorias}</div>
            </div>
            <div class="mini-stat">
              <div class="mini-stat__label">Combates</div>
              <div class="mini-stat__value v-blue">${rival.Combates}</div>
            </div>
            <div class="mini-stat">
              <div class="mini-stat__label">Racha</div>
              <div class="mini-stat__value ${rival.ColorRacha}">${rival.Racha}</div>
            </div>
          </div>
        </div>
      </div>

      <div class="rival-stats">
        <div class="rival-stats__divider"></div>
        <div class="stats-grid">
          <div class="stat-row">
            <div class="stat-row__head"><span class="stat-row__label">Vida</span><span class="stat-row__val s-vid">${rival.Estadisticas.vid}</span></div>
            <div class="stat-bar"><div class="stat-bar__fill bar-vid" style="width:${obtenerAnchoBarraEstadistica(rival.Estadisticas.vid)}"></div></div>
          </div>
          <div class="stat-row">
            <div class="stat-row__head"><span class="stat-row__label">Velocidad</span><span class="stat-row__val s-vel">${rival.Estadisticas.vel}</span></div>
            <div class="stat-bar"><div class="stat-bar__fill bar-vel" style="width:${obtenerAnchoBarraEstadistica(rival.Estadisticas.vel)}"></div></div>
          </div>
          <div class="stat-row">
            <div class="stat-row__head"><span class="stat-row__label">Fuerza</span><span class="stat-row__val s-fue">${rival.Estadisticas.fue}</span></div>
            <div class="stat-bar"><div class="stat-bar__fill bar-fue" style="width:${obtenerAnchoBarraEstadistica(rival.Estadisticas.fue)}"></div></div>
          </div>
          <div class="stat-row">
            <div class="stat-row__head"><span class="stat-row__label">Intelig.</span><span class="stat-row__val s-int">${rival.Estadisticas.int}</span></div>
            <div class="stat-bar"><div class="stat-bar__fill bar-int" style="width:${obtenerAnchoBarraEstadistica(rival.Estadisticas.int)}"></div></div>
          </div>
          <div class="stat-row">
            <div class="stat-row__head"><span class="stat-row__label">Agilidad</span><span class="stat-row__val s-agl">${rival.Estadisticas.agl}</span></div>
            <div class="stat-bar"><div class="stat-bar__fill bar-agl" style="width:${obtenerAnchoBarraEstadistica(rival.Estadisticas.agl)}"></div></div>
          </div>
        </div>
      </div>

      <div class="rival-card__divider2"></div>
      <div class="rival-card__foot">
        <button class="btn-fight" data-fight="${indice}">⚔ Pelear ahora</button>
      </div>
    </article>
  `).join('');
    }

    // Combate real (fórmula estadísticas+random en el server, ver Contexto.md), pero la
    // pantalla espera ~5s simulados antes de mostrar el resultado (sin lógica real detrás,
    // solo para que no se sienta instantáneo — CombateEnCurso.aspx no se usa todavía).
    function pelearContraRival(rival, boton) {
        boton.disabled = true;
        mostrarNotificacion(`Combate en curso contra ${rival.Nombre}...`);

        const esperaSimulada = new Promise((resolve) => setTimeout(resolve, 5000));
        const pelea = fetch('ArenaApi.ashx?accion=Pelear', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ idPersonajeDefensor: rival.IDPersonaje }),
            credentials: 'same-origin',
        }).then((resp) => resp.json().then((data) => ({ ok: resp.ok, data })));

        Promise.all([pelea, esperaSimulada])
            .then(([{ ok, data }]) => {
                if (!ok) throw new Error((data && data.error) || 'Error inesperado.');

                if (data.Gano) {
                    window.location.href = 'ArenaVictoria.aspx?idCombate=' + data.IDCombate;
                } else {
                    boton.disabled = false;
                    mostrarNotificacion(`Perdiste contra ${data.NombreDefensor} (tu poder: ${data.PoderAtacante} vs ${data.PoderDefensor}). ¡Suerte la próxima!`);
                }
            })
            .catch((err) => {
                boton.disabled = false;
                mostrarNotificacion(err.message || 'No se pudo resolver el combate.');
            });
    }

    function inicializar() {
        obtenerRivalesReales();

        document.addEventListener('click', (evento) => {
            const botonPelear = evento.target.closest('[data-fight]');
            if (botonPelear) {
                if (botonPelear.disabled) return;
                const indiceRival = parseInt(botonPelear.dataset.fight, 10);
                const rival = RIVALES[indiceRival];
                pelearContraRival(rival, botonPelear);
                return;
            }
        });

        document.getElementById('btnRefresh').addEventListener('click', () => {
            mostrarNotificacion('Rivales refrescados. Se consumió 1 intento.');
        });
    }

    document.addEventListener('DOMContentLoaded', inicializar);
</script>
</body>
</html>