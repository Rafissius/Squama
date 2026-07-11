<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ResolverIntegridad.aspx.cs" Inherits="PylinskiCuello_ProyectoWeb.Webmaster.ResolverIntegridad" %>
<%@ Import Namespace="SERVICIOS" %>
<!DOCTYPE html>
<html lang="es">
<head runat="server">
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>SQUAMA &mdash; Resolver Integridad</title>
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet" />
  <style>
/* ═══════════════════════════════════════════════════════
   SQUAMA — Dígito Verificador · Webmaster
   Dark medieval/fantasy admin panel
   ═══════════════════════════════════════════════════════ */

:root {
  --bg:        #2e1a0a;
  --bg-dark:   #0f0803;
  --bg-card:   #261507;
  --gold:      #d9ad26;
  --gold-br:   #ffe066;
  --purp:      #b86bf2;
  --cream:     #f5e8bf;
  --green:     #47d96b;
  --red:       #f2522e;
  --blue:      #5999f2;
  --ora:       #f29e38;
  --dark:      #1f1005;
  --black:     #000000;

  --stripe:    rgba(82, 46, 20, 0.14);
  --radius:    10px;
  --radius-lg: 14px;

  --font: 'Inter', system-ui, -apple-system, sans-serif;
}

* { box-sizing: border-box; margin: 0; padding: 0; }

html { scroll-behavior: smooth; }

body {
  font-family: var(--font);
  background-color: var(--bg);
  background-image: repeating-linear-gradient(
    to bottom,
    var(--stripe) 0px,
    var(--stripe) 26px,
    transparent 26px,
    transparent 54px
  );
  color: var(--cream);
  min-height: 100vh;
  padding-bottom: 60px;
}

body::before {
  content: '';
  position: absolute;
  top: 68px; left: 0; right: 0;
  height: 280px;
  background: linear-gradient(to bottom, rgba(184,107,242,0.12), transparent);
  pointer-events: none;
  z-index: 0;
}

/* ═══════════════ NAVBAR ═══════════════ */
.navbar {
  position: sticky;
  top: 0;
  z-index: 100;
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 68px;
  padding: 0 28px;
  background: rgba(15, 8, 3, 0.97);
  border-top: 3px solid var(--gold);
  border-bottom: 3px solid rgba(217, 173, 38, 0.3);
  backdrop-filter: blur(6px);
  flex-wrap: wrap;
  gap: 8px;
}
.nav-brand { display: flex; align-items: center; gap: 16px; }
.nav-logo-group { display: flex; flex-direction: column; line-height: 1.1; }
.nav-logo { font-size: 22px; font-weight: 700; color: var(--gold); letter-spacing: 0.5px; }
.nav-tagline { font-size: 10px; color: rgba(245,232,191,0.65); }
.badge-webmaster {
  font-size: 9px; font-weight: 700; color: var(--purp);
  background: rgba(184,107,242,0.22);
  border: 1px solid rgba(184,107,242,0.7);
  border-radius: 11px;
  padding: 5px 12px;
  letter-spacing: 1px;
}
.nav-links { display: flex; gap: 8px; list-style: none; }
.nav-links a, .nav-links span.nav-blocked {
  display: block;
  padding: 8px 14px;
  font-size: 14px;
  text-decoration: none;
  border-radius: 6px;
  transition: color .15s, background .15s;
  position: relative;
}
.nav-links a { color: rgba(245,232,191,0.75); }
.nav-links a:hover { color: var(--cream); background: rgba(184,107,242,0.08); }
.nav-links a.active { color: var(--gold-br); font-weight: 700; }
.nav-links span.nav-blocked {
  color: rgba(245,232,191,0.3);
  cursor: not-allowed;
}
.nav-user { display: flex; align-items: center; gap: 10px; }
.nav-avatar {
  width: 44px; height: 44px; border-radius: 50%;
  background: rgba(184,107,242,0.35);
  border: 1.5px solid rgba(184,107,242,0.6);
}
.nav-user-info { display: flex; flex-direction: column; line-height: 1.2; }
.nav-user-name { font-size: 13px; font-weight: 700; color: var(--gold-br); }
.nav-user-role { font-size: 10px; font-weight: 700; color: var(--purp); }
.nav-logout {
  font-family: var(--font);
  font-size: 11px; font-weight: 700;
  color: rgba(245,232,191,0.75);
  background: transparent;
  border: 1px solid rgba(245,232,191,0.3);
  border-radius: 6px;
  padding: 7px 14px;
  cursor: pointer;
}
.nav-logout:hover { background: rgba(242,82,46,0.15); border-color: rgba(242,82,46,0.5); color: var(--red); }

/* ═══════════════ PAGE LAYOUT ═══════════════ */
.page { position: relative; z-index: 1; max-width: 1440px; margin: 0 auto; padding: 0 16px; }

/* ═══════════════ HEADER ═══════════════ */
.page-header { text-align: center; padding: 24px 0 8px; }
.page-eyebrow {
  display: inline-block;
  font-size: 11px; font-weight: 700; letter-spacing: 1px;
  color: var(--purp);
  background: rgba(184,107,242,0.18);
  border: 1px solid rgba(184,107,242,0.7);
  border-radius: 13px;
  padding: 6px 18px;
}
.page-title { font-size: 40px; font-weight: 700; color: var(--gold-br); margin-top: 12px; letter-spacing: -0.5px; }
.page-subtitle { font-size: 13px; color: rgba(245,232,191,0.72); margin-top: 8px; }
.header-rule {
  width: 600px; max-width: 80%; height: 2px;
  margin: 14px auto 0;
  background: rgba(217,173,38,0.4);
  position: relative;
}
.header-rule::after {
  content: ''; position: absolute; top: 6px; left: 50%;
  transform: translateX(-50%);
  width: 400px; max-width: 100%; height: 1px;
  background: rgba(217,173,38,0.2);
}

#pMensaje { margin-top: 18px; }
#pMensaje:empty { display: none; }
#pMensaje:not(:empty) {
  position: relative;
  margin: 18px 0;
  padding: 12px 16px 12px 20px;
  background: rgba(71,217,107,0.08);
  border: 1px solid rgba(71,217,107,0.35);
  border-radius: var(--radius);
  font-size: 12px;
  color: var(--cream);
  font-weight: 600;
}

/* ═══════════════ SUMMARY CARDS ═══════════════ */
.summary-grid { display: grid; grid-template-columns: repeat(6, 1fr); gap: 10px; margin-top: 24px; }
.sum-card {
  position: relative;
  background: rgba(38,21,7,0.97);
  border: 1.5px solid;
  border-radius: var(--radius);
  padding: 14px 10px;
  text-align: center;
  box-shadow: 0 4px 0 rgba(0,0,0,0.45);
  overflow: hidden;
}
.sum-card::before { content: ''; position: absolute; top: 0; left: 0; right: 0; height: 4px; background: currentColor; border-radius: 3px 3px 0 0; }
.sum-card__value { font-size: 20px; font-weight: 700; line-height: 1.2; }
.sum-card__label { font-size: 10px; font-weight: 700; color: var(--gold-br); margin-top: 6px; }

.c-green { color: var(--green); border-color: rgba(71,217,107,0.5); }
.c-red   { color: var(--red);   border-color: rgba(242,82,46,0.5); }
.c-blue  { color: var(--blue);  border-color: rgba(89,153,242,0.5); }
.c-gold  { color: var(--gold);  border-color: rgba(217,173,38,0.5); }
.c-purp  { color: var(--purp);  border-color: rgba(184,107,242,0.5); }
.c-ora   { color: var(--ora);   border-color: rgba(242,158,56,0.5); }

/* ═══════════════ STATUS BANNER ═══════════════ */
.status-banner { position: relative; margin-top: 20px; padding: 14px 16px 14px 30px; border: 1.5px solid; border-radius: var(--radius); }
.status-banner::before { content: ''; position: absolute; top: 0; left: 0; right: 0; height: 4px; border-radius: 3px 3px 0 0; background: currentColor; }
.status-banner__title { font-size: 14px; font-weight: 700; }
.status-banner__text { font-size: 11px; color: rgba(245,232,191,0.7); margin-top: 6px; }
.status-banner--ok  { color: var(--green); border-color: rgba(71,217,107,0.5); background: rgba(71,217,107,0.08); }
.status-banner--err { color: var(--red);   border-color: rgba(242,82,46,0.5);  background: rgba(242,82,46,0.08); }

/* ═══════════════ GLOBAL ACTIONS ═══════════════ */
.global-actions { display: flex; justify-content: flex-end; gap: 12px; margin-top: 16px; flex-wrap: wrap; }

/* ═══════════════ BUTTONS ═══════════════ */
.btn {
  font-family: var(--font);
  font-size: 12px; font-weight: 700;
  border: none;
  border-radius: 8px;
  padding: 9px 18px;
  cursor: pointer;
  transition: transform .1s, filter .15s, opacity .15s;
}
.btn:hover { filter: brightness(1.1); }
.btn:active { transform: translateY(1px); }
.btn:focus-visible { outline: 2px solid var(--gold-br); outline-offset: 2px; }
.btn:disabled { opacity: 0.4; cursor: not-allowed; filter: none; }

.btn-recalc { background: var(--ora); color: var(--dark); }
.btn-restore { background: var(--red); color: #fff; }
.btn-recalc-confirm { background: var(--ora); color: #fff; }
.btn-ghost { background: transparent; color: rgba(245,232,191,0.65); border: 1px solid rgba(245,232,191,0.3); }
.btn-ghost:hover { background: rgba(245,232,191,0.06); filter: none; }
.btn-block { width: 100%; }
.btn-sm { padding: 6px 12px; font-size: 11px; }

/* ═══════════════ DV EXPLANATION ═══════════════ */
.dv-explain {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
  margin-top: 20px;
  padding: 12px 20px;
  background: rgba(15,8,3,0.85);
  border: 1px solid rgba(217,173,38,0.2);
  border-top: 3px solid var(--gold);
  border-radius: var(--radius);
}
.dv-explain-item { display: flex; gap: 12px; align-items: flex-start; }
.dv-chip { flex-shrink: 0; width: 46px; height: 46px; display: grid; place-items: center; font-size: 13px; font-weight: 700; border-radius: 8px; }
.dv-chip--dvh  { color: var(--purp);  background: rgba(184,107,242,0.12); border: 1px solid rgba(184,107,242,0.4); }
.dv-chip--dvv  { color: var(--blue);  background: rgba(89,153,242,0.12);  border: 1px solid rgba(89,153,242,0.4); }
.dv-chip--both { color: var(--gold);  background: rgba(217,173,38,0.12);  border: 1px solid rgba(217,173,38,0.4); }
.dv-explain-title { font-size: 10px; font-weight: 700; margin-bottom: 3px; }
.dv-explain-item:nth-child(1) .dv-explain-title { color: var(--purp); }
.dv-explain-item:nth-child(2) .dv-explain-title { color: var(--blue); }
.dv-explain-item:nth-child(3) .dv-explain-title { color: var(--gold); }
.dv-explain-text { font-size: 9px; color: rgba(245,232,191,0.65); line-height: 1.4; }

/* ═══════════════ TABLES ═══════════════ */
.table-section { margin-top: 28px; }
.section-heading { font-size: 12px; font-weight: 700; color: var(--gold-br); padding-bottom: 8px; margin-bottom: 12px; border-top: 1px solid rgba(217,173,38,0.2); padding-top: 8px; }
.section-heading--danger { color: var(--red); border-top-color: rgba(242,82,46,0.25); }

.data-table { background: rgba(15,8,3,0.9); border: 1px solid rgba(217,173,38,0.18); border-radius: var(--radius); overflow: hidden; }
.data-table--danger { border-color: rgba(242,82,46,0.3); border-width: 1.5px; }

.data-table__head { display: grid; gap: 8px; padding: 12px 20px; background: rgba(184,107,242,0.1); border-top: 3px solid var(--purp); font-size: 10px; font-weight: 700; color: var(--purp); }
.data-table__head--danger { background: rgba(242,82,46,0.1); border-top-color: var(--red); color: var(--red); }

.data-table__body .row { display: grid; gap: 8px; padding: 10px 20px; align-items: center; border-top: 1px solid rgba(217,173,38,0.1); font-size: 10px; }
.tablas-grid { grid-template-columns: 160px 100px 100px 150px 1fr; }
.inc-grid { grid-template-columns: 44px 90px 70px 220px 170px 130px 90px 1fr; }

.data-table__body .row:nth-child(odd) { background: rgba(184,107,242,0.04); }
.data-table--danger .data-table__body .row { background: rgba(242,82,46,0.04); border-top-color: rgba(242,82,46,0.12); }

.cell-name { font-weight: 700; color: var(--gold-br); }
.cell-muted { color: rgba(245,232,191,0.6); }
.cell-num { text-align: center; font-weight: 700; }
.cell-center { text-align: center; }

.tag { display: inline-block; font-size: 8px; font-weight: 700; padding: 3px 0; width: 76px; text-align: center; border-radius: 9px; border: 1px solid; }
.tag--ok    { color: var(--green); background: rgba(71,217,107,0.12); border-color: rgba(71,217,107,0.55); }
.tag--error { color: var(--red);   background: rgba(242,82,46,0.12);  border-color: rgba(242,82,46,0.55); }
.tag--dv    { color: var(--purp);  background: rgba(184,107,242,0.1);  border-color: rgba(184,107,242,0.45); width: auto; padding: 3px 8px; }
.tag--pend  { color: var(--ora);   background: rgba(242,158,56,0.12);  border-color: rgba(242,158,56,0.55); width: 68px; }

.val-expected { color: var(--green); font-weight: 700; text-align: center; }
.val-calculated { color: var(--red); font-weight: 700; text-align: center; }

.btn-row {
  font-size: 9px; font-weight: 700;
  padding: 4px 10px;
  border-radius: 5px;
  border: 1px solid;
  background: transparent;
  cursor: pointer;
  transition: filter .15s;
}
.btn-row:hover { filter: brightness(1.3); }
.btn-row--view { color: var(--blue); background: rgba(89,153,242,0.1); border-color: rgba(89,153,242,0.5); }

.data-table__foot { padding: 12px 20px; font-size: 11px; color: rgba(245,232,191,0.5); border-top: 1px solid rgba(242,82,46,0.2); background: rgba(242,82,46,0.07); }

.clean-note { position: relative; padding: 12px 16px 12px 26px; background: rgba(71,217,107,0.06); border: 1px solid rgba(71,217,107,0.3); border-radius: var(--radius); }
.clean-note::before { content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 3px; background: rgba(71,217,107,0.7); border-radius: 2px; }
.clean-note__title { font-size: 12px; font-weight: 700; color: var(--green); }
.clean-note__text { font-size: 10px; color: rgba(245,232,191,0.6); margin-top: 4px; }

/* ═══════════════ RESTORE (embebido) ═══════════════ */
.campo-restore { margin-bottom: 14px; }
.campo-restore label { display: block; font-size: .85rem; margin-bottom: 6px; opacity: .85; }
.campo-restore textarea, .campo-restore input[type=file] {
  width: 100%;
  box-sizing: border-box;
  background: rgba(0,0,0,.25);
  border: 1px solid rgba(255,255,255,.2);
  border-radius: 6px;
  color: inherit;
  padding: 8px 10px;
  font-family: inherit;
}

/* ═══════════════ MODALS ═══════════════ */
.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.62); display: grid; place-items: center; z-index: 1000; padding: 20px; animation: fade .15s ease; }
@keyframes fade { from { opacity: 0; } to { opacity: 1; } }
.modal[hidden], .modal-overlay[hidden] { display: none; }

.modal { position: relative; width: 100%; max-height: 92vh; overflow-y: auto; background: rgba(15,8,3,0.99); border: 1.5px solid; border-radius: 12px; box-shadow: 0 6px 40px rgba(0,0,0,0.6); animation: pop .18s ease; }
@keyframes pop { from { transform: scale(0.97); opacity: 0; } to { transform: scale(1); opacity: 1; } }
.modal--danger  { max-width: 740px; border-color: rgba(242,82,46,0.65); }
.modal--confirm { max-width: 600px; border-color: rgba(242,158,56,0.8); border-width: 2px; }

.modal__head { position: relative; display: flex; align-items: center; gap: 12px; padding: 14px 16px; border-top: 4px solid; border-radius: 8px 8px 0 0; }
.modal__head--danger { border-top-color: var(--red); background: rgba(242,82,46,0.08); }
.modal__head--warn { border-top-color: var(--ora); background: rgba(242,158,56,0.1); }
.modal__head--center { flex-direction: column; gap: 4px; text-align: center; padding: 14px 16px 12px; }
.modal__title { font-size: 15px; font-weight: 700; color: var(--gold-br); }
.modal__title--center { font-size: 15px; }
.modal__subtitle { font-size: 11px; color: rgba(245,232,191,0.5); }
.modal__subnote { padding: 6px 16px; font-size: 10px; color: rgba(245,232,191,0.45); }
.modal__close { margin-left: auto; width: 24px; height: 24px; display: grid; place-items: center; background: rgba(245,232,191,0.1); border: 1px solid rgba(245,232,191,0.3); border-radius: 7px; color: rgba(245,232,191,0.5); font-size: 12px; cursor: pointer; }
.modal__close:hover { background: rgba(242,82,46,0.2); color: var(--red); }
.modal__divider { height: 1px; margin: 0 0 4px; }
.modal__divider--danger { background: rgba(242,82,46,0.3); }
.modal__divider--warn { background: rgba(242,158,56,0.4); }
.modal__foot { padding: 16px; border-top: 1px solid rgba(217,173,38,0.2); margin-top: 8px; }
.modal__foot--split { display: flex; gap: 16px; }
.modal__foot--split .btn { flex: 1; }

.pill { font-size: 9px; font-weight: 700; padding: 4px 12px; border-radius: 11px; border: 1px solid; }
.pill--warn { color: var(--ora); background: rgba(242,158,56,0.2); border-color: rgba(242,158,56,0.55); }
.pill--pend { color: var(--ora); background: rgba(242,158,56,0.2); border-color: rgba(242,158,56,0.55); }
.pill--ok { color: var(--green); background: rgba(71,217,107,0.2); border-color: rgba(71,217,107,0.55); }

.detail-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px 16px; padding: 12px 16px; }
.detail-field__label { font-size: 9px; color: rgba(245,232,191,0.45); }
.detail-field__value { font-size: 11px; font-weight: 700; color: var(--cream); margin-top: 2px; word-break: break-all; }
.detail-field__value.is-green { color: var(--green); }
.detail-field__value.is-red { color: var(--red); }
.detail-field__value.is-ora { color: var(--ora); }

.note { position: relative; margin: 8px 16px; padding: 10px 12px 10px 20px; border-radius: 8px; font-size: 10px; color: rgba(245,232,191,0.75); }
.note::before { content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 3px; border-radius: 2px; }
.note__sub { color: rgba(245,232,191,0.5); margin-top: 2px; }
.note--purple { background: rgba(184,107,242,0.08); border: 1px solid rgba(184,107,242,0.3); }
.note--purple::before { background: rgba(184,107,242,0.6); }
.note--warn { background: rgba(242,158,56,0.06); border: 1px solid rgba(242,158,56,0.25); }
.note--warn::before { background: rgba(242,158,56,0.6); }
.note--blue { background: rgba(89,153,242,0.07); border: 1px solid rgba(89,153,242,0.3); }
.note--blue::before { background: rgba(89,153,242,0.7); }

.warn-box { position: relative; margin: 8px 16px; padding: 12px 14px 12px 20px; background: rgba(242,158,56,0.08); border: 1px solid rgba(242,158,56,0.3); border-radius: var(--radius); font-size: 10px; line-height: 1.5; color: rgba(245,232,191,0.8); }
.warn-box::before { content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 4px; background: rgba(242,158,56,0.8); border-radius: 2px; }
.warn-box__count { font-weight: 700; color: var(--cream); margin-top: 6px; }
.warn-box__danger { color: var(--red); margin-top: 6px; }
.warn-box__muted { color: rgba(245,232,191,0.55); margin-top: 4px; }

.confirm-label { text-align: center; font-size: 11px; color: rgba(245,232,191,0.65); margin: 16px 16px 0; }
.confirm-keyword { margin: 8px auto 0; width: max-content; min-width: 200px; padding: 7px 40px; text-align: center; font-size: 13px; font-weight: 700; letter-spacing: 2px; color: rgba(242,158,56,0.65); background: rgba(242,158,56,0.08); border: 2px solid rgba(242,158,56,0.5); border-radius: 10px; }
.confirm-input-label { display: block; text-align: center; font-size: 11px; color: rgba(245,232,191,0.65); margin: 18px 16px 8px; }
.confirm-input, .confirm-textarea {
  display: block;
  width: calc(100% - 120px);
  margin: 0 auto;
  padding: 9px 14px;
  font-family: var(--font);
  font-size: 11px;
  color: var(--cream);
  background: rgba(15,8,3,0.95);
  border: 1.5px solid rgba(242,158,56,0.5);
  border-radius: 8px;
}
.confirm-textarea { border-color: rgba(217,173,38,0.3); resize: vertical; min-height: 50px; }
.confirm-input::placeholder, .confirm-textarea::placeholder { color: rgba(245,232,191,0.3); }
.confirm-input:focus, .confirm-textarea:focus { outline: none; border-color: var(--ora); box-shadow: 0 0 0 3px rgba(242,158,56,0.15); }
.confirm-input.is-valid { border-color: var(--green); box-shadow: 0 0 0 3px rgba(71,217,107,0.15); }

/* Modal de Restore usa la misma familia visual que el resto de los modals */

/* ═══════════════ RESPONSIVE ═══════════════ */
@media (max-width: 1200px) {
  .summary-grid { grid-template-columns: repeat(3, 1fr); }
  .dv-explain { grid-template-columns: 1fr; gap: 12px; }
}
@media (max-width: 900px) {
  .nav-links { order: 3; width: 100%; overflow-x: auto; }
  .data-table { overflow-x: auto; }
  .data-table__head, .data-table__body .row { min-width: 780px; }
  .detail-grid { grid-template-columns: 1fr; }
}
@media (max-width: 640px) {
  .summary-grid { grid-template-columns: repeat(2, 1fr); }
  .page-title { font-size: 30px; }
  .global-actions { flex-direction: column; }
  .confirm-input, .confirm-textarea { width: calc(100% - 32px); }
}

@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after { animation: none !important; transition: none !important; }
}
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

    <!-- ══════════════ NAVBAR ══════════════ -->
    <nav class="navbar">
      <div class="nav-brand">
        <div class="nav-logo-group">
          <span class="nav-logo">SQUAMA</span>
          <span class="nav-tagline">Forj&aacute; tu Leyenda</span>
        </div>
        <span class="badge-webmaster">WEBMASTER</span>
      </div>
      <ul class="nav-links">
        <li><%= NavLink("../HomeWebmaster.aspx", "Inicio") %></li>
        <li><%= NavLink("../GestionUsuarios.aspx", "Usuarios") %></li>
        <li><%= NavLink("../EnConstruccionWebmaster.aspx", "Perfiles") %></li>
        <li><%= NavLink("../BitacoraEventos.aspx", "Bitácora") %></li>
        <li><%= NavLink("../BackUpYRestore.aspx", "Backup/Restore") %></li>
        <li><%= NavLink("ResolverIntegridad.aspx", "Dígito Verificador", true) %></li>
      </ul>
      <div class="nav-user">
        <div class="nav-avatar"></div>
        <div class="nav-user-info">
          <span class="nav-user-name">Webmaster</span>
          <span class="nav-user-role">WEBMASTER</span>
        </div>
        <asp:Button ID="btnLogout" runat="server" CssClass="nav-logout" Text="Salir"
                    OnClick="BtnLogout_Click" ToolTip="Cerrar sesi&oacute;n" />
      </div>
    </nav>

    <main class="page">
      <!-- ══════════════ HEADER ══════════════ -->
      <header class="page-header">
        <span class="page-eyebrow">D&Iacute;GITO VERIFICADOR</span>
        <h1 class="page-title">Resolver Integridad</h1>
        <p class="page-subtitle">Verific&aacute; la integridad de los datos mediante DVH y DVV.</p>
        <div class="header-rule"></div>
      </header>

      <p id="pMensaje" runat="server"></p>

      <!-- ══════════════ SUMMARY CARDS ══════════════ -->
      <section class="summary-grid" aria-label="Resumen de integridad">
        <div class="sum-card <%= SistemaBloqueado ? "c-red" : "c-green" %>">
          <div class="sum-card__value"><asp:Label ID="lblEstadoGeneral" runat="server" Text="&Iacute;NTEGRO" /></div>
          <div class="sum-card__label">Estado general</div>
        </div>
        <div class="sum-card <%= HayInconsistencias ? "c-red" : "c-green" %>">
          <div class="sum-card__value"><asp:Label ID="lblCantidadInconsistencias" runat="server" Text="0" /></div>
          <div class="sum-card__label">Inconsistencias</div>
        </div>
        <div class="sum-card <%= HayErrorDVH ? "c-red" : "c-green" %>">
          <div class="sum-card__value"><asp:Label ID="lblDvhConError" runat="server" Text="0" /></div>
          <div class="sum-card__label">DVH con error</div>
        </div>
        <div class="sum-card <%= HayErrorDVV ? "c-red" : "c-green" %>">
          <div class="sum-card__value"><asp:Label ID="lblDvvConError" runat="server" Text="0" /></div>
          <div class="sum-card__label">DVV con error</div>
        </div>
        <div class="sum-card c-gold">
          <div class="sum-card__value" style="font-size:13px;"><asp:Label ID="lblFechaBloqueo" runat="server" Text="N/D" /></div>
          <div class="sum-card__label">Fecha del bloqueo</div>
        </div>
        <div class="sum-card c-purp">
          <div class="sum-card__value" style="font-size:12px;"><asp:Label ID="lblMotivoBloqueo" runat="server" Text="N/D" /></div>
          <div class="sum-card__label">Motivo</div>
        </div>
      </section>

      <!-- ══════════════ STATUS BANNER ══════════════ -->
      <section class="status-banner <%= SistemaBloqueado ? "status-banner--err" : "status-banner--ok" %>" aria-live="polite">
        <% if (SistemaBloqueado) { %>
          <p class="status-banner__title"><%= EstadoSistema.CantidadInconsistencias %> inconsistencia(s) detectada(s) &mdash; acci&oacute;n requerida.</p>
          <p class="status-banner__text">Decid&iacute; si recalcular todos los DV (si los datos son confiables) o restaurar desde un backup &iacute;ntegro (si sospech&aacute;s que los datos en s&iacute; fueron alterados).</p>
        <% } else { %>
          <p class="status-banner__title">Sistema &iacute;ntegro &mdash; sin inconsistencias pendientes.</p>
          <p class="status-banner__text">DVH y DVV verificados correctamente en las tablas activas. No se requiere acci&oacute;n.</p>
        <% } %>
      </section>

      <!-- ══════════════ GLOBAL ACTIONS ══════════════ -->
      <div class="global-actions">
        <button type="button" class="btn btn-restore" id="btnAbrirRestore">Restaurar desde Backup</button>
        <button type="button" class="btn btn-recalc" id="btnRecalcGeneral">Recalcular DV (general)</button>
      </div>

      <!-- Botón real, oculto: ejecuta el postback verdadero cuando se confirma el modal -->
      <asp:Button ID="btnRecalcular" runat="server" Text="Recalcular todos los DV"
                  OnClick="BtnRecalcular_Click" style="display:none;" />

      <!-- ══════════════ DV EXPLANATION ══════════════ -->
      <section class="dv-explain">
        <div class="dv-explain-item">
          <span class="dv-chip dv-chip--dvh">H</span>
          <div>
            <p class="dv-explain-title">DVH (Fila)</p>
            <p class="dv-explain-text">Verifica que ning&uacute;n dato en una fila fue modificado, comparando el hash de todas sus columnas contra el guardado.</p>
          </div>
        </div>
        <div class="dv-explain-item">
          <span class="dv-chip dv-chip--dvv">V</span>
          <div>
            <p class="dv-explain-title">DVV (Columna)</p>
            <p class="dv-explain-text">Detecta un cambio en alguna fila de esa columna a lo largo de toda la tabla, sin identificar por s&iacute; solo cu&aacute;l fila puntual.</p>
          </div>
        </div>
        <div class="dv-explain-item">
          <span class="dv-chip dv-chip--both">HV</span>
          <div>
            <p class="dv-explain-title">DVH + DVV juntos</p>
            <p class="dv-explain-text">Si ambos se&ntilde;alan la misma tabla en la misma pasada, se puede inferir el campo probablemente afectado (ver bot&oacute;n Detalle).</p>
          </div>
        </div>
      </section>

      <!-- ══════════════ TABLAS VERIFICADAS ══════════════ -->
      <section class="table-section">
        <h2 class="section-heading">Estado de tablas verificadas</h2>
        <div class="data-table" role="table" aria-label="Estado de tablas verificadas">
          <div class="data-table__head tablas-grid" role="row">
            <span role="columnheader">Tabla</span>
            <span role="columnheader">Registros</span>
            <span role="columnheader">Estado</span>
            <span role="columnheader">Inconsistencias pendientes</span>
            <span role="columnheader">Nota</span>
          </div>
          <div class="data-table__body">
            <asp:Repeater ID="rptTablas" runat="server">
              <ItemTemplate>
                <div class="row tablas-grid">
                  <span class="cell-name"><%# Eval("NombreTabla") %></span>
                  <span class="cell-center cell-muted"><%# Eval("CantidadRegistros") %></span>
                  <span><%# TagEstadoTabla(Container.DataItem) %></span>
                  <span class="cell-num" style="color:<%# (int)DataBinder.Eval(Container.DataItem, "CantidadPendientes") > 0 ? "var(--red)" : "var(--green)" %>"><%# Eval("CantidadPendientes") %></span>
                  <span class="cell-muted"><%# Eval("NotaExclusion") ?? "—" %></span>
                </div>
              </ItemTemplate>
            </asp:Repeater>
          </div>
        </div>
      </section>

      <!-- ══════════════ INCONSISTENCIAS ══════════════ -->
      <section class="table-section" id="inconsistenciesSection">
        <h2 class="section-heading <%= HayInconsistencias ? "section-heading--danger" : "" %>">&Uacute;ltimas inconsistencias detectadas</h2>

        <asp:Panel ID="pnlSinInconsistencias" runat="server" CssClass="clean-note" Visible="false">
          <p class="clean-note__title">Inconsistencias detectadas: Ninguna.</p>
          <p class="clean-note__text">El sistema se encuentra en estado &iacute;ntegro.</p>
        </asp:Panel>

        <div class="data-table data-table--danger" role="table" aria-label="Inconsistencias detectadas">
          <div class="data-table__head data-table__head--danger inc-grid" role="row">
            <span role="columnheader">ID</span>
            <span role="columnheader">Tabla</span>
            <span role="columnheader">Registro</span>
            <span role="columnheader">Columna(s) cambiada(s)</span>
            <span role="columnheader">Qu&eacute; pas&oacute;</span>
            <span role="columnheader">Fecha detecci&oacute;n</span>
            <span role="columnheader">Estado</span>
            <span role="columnheader">Acciones</span>
          </div>
          <div class="data-table__body">
            <asp:Repeater ID="rptInconsistencias" runat="server">
              <ItemTemplate>
                <div class="row inc-grid">
                  <span class="cell-muted"><%# Eval("ID") %></span>
                  <span class="cell-name"><%# Eval("Tabla") %></span>
                  <span class="cell-muted"><%# Eval("RegistroDisplay") %></span>
                  <span style="color:var(--red);font-weight:700"><%# Eval("ColumnasCambiadas") %></span>
                  <span><span class="tag <%# Eval("QuePasoClass") %>" style="width:auto;padding:3px 8px;"><%# Eval("QuePaso") %></span></span>
                  <span class="cell-muted"><%# Eval("FechaDeteccion") %></span>
                  <span><span class="tag <%# Eval("EstadoClass") %>"><%# Eval("Estado") %></span></span>
                  <span><button type="button" class="btn-row btn-row--view" data-detalle='<%# Eval("DetalleBase64") %>'>Ver detalle</button></span>
                </div>
              </ItemTemplate>
            </asp:Repeater>
          </div>
          <div class="data-table__foot">
            El recálculo de DV y el Restore son acciones globales — usá los botones generales de la parte superior.
          </div>
        </div>
      </section>

      <asp:Panel ID="pnlSinBackups" runat="server" Visible="false" CssClass="note note--warn" style="margin:12px 0 0;">
        No hay backups disponibles.
      </asp:Panel>
    </main>

    <!-- ══════════════ MODAL: DETALLE INCONSISTENCIA ══════════════ -->
    <div class="modal-overlay" id="modalDetalle" hidden>
      <div class="modal modal--danger" role="dialog" aria-modal="true" aria-labelledby="detalleTitle">
        <div class="modal__head modal__head--danger">
          <h3 class="modal__title" id="detalleTitle">Detalle de inconsistencia &mdash; <span id="detId">#</span></h3>
          <span class="pill pill--warn" id="detEstadoPill">PENDIENTE</span>
          <button type="button" class="modal__close" data-close aria-label="Cerrar">&#10005;</button>
        </div>
        <p class="modal__subnote">Solo lectura &mdash; esta inconsistencia se resuelve mediante recálculo global o restore.</p>
        <div class="modal__divider modal__divider--danger"></div>
        <div class="detail-grid" id="detailGrid"></div>
        <div class="note note--purple" id="detailRegistroActual" hidden>
          <p style="font-weight:700;">Valores actuales del registro:</p>
          <div id="detailRegistroActualGrid" class="detail-grid" style="padding:8px 0 0;"></div>
        </div>
        <div class="note note--purple" id="detailExplain" hidden>
          <p></p>
        </div>
        <div class="note note--warn">
          <p>El recálculo de Dígito Verificador aplica a todo el sistema, no a inconsistencias sueltas.</p>
          <p class="note__sub">Para recalcular todos los DV o restaurar la BD, usá los botones de la vista principal.</p>
        </div>
        <div class="modal__foot">
          <button type="button" class="btn btn-ghost btn-block" data-close>Cerrar</button>
        </div>
      </div>
    </div>

    <!-- ══════════════ MODAL: CONFIRMAR RECÁLCULO GENERAL ══════════════ -->
    <div class="modal-overlay" id="modalRecalc" hidden>
      <div class="modal modal--confirm" role="dialog" aria-modal="true" aria-labelledby="recalcTitle">
        <div class="modal__head modal__head--warn modal__head--center">
          <h3 class="modal__title modal__title--center" id="recalcTitle">RECALCULAR TODOS LOS D&Iacute;GITOS VERIFICADORES</h3>
          <p class="modal__subtitle">Acci&oacute;n de escritura global sobre la base de datos</p>
        </div>
        <div class="modal__divider modal__divider--warn"></div>

        <div class="warn-box">
          <p>Esta operaci&oacute;n recalcular&aacute; <strong>TODOS</strong> los DVH y DVV del sistema completo, aceptando el estado actual de los datos como correcto.</p>
          <p class="warn-box__count">Inconsistencias afectadas: <%= EstadoSistema.CantidadInconsistencias %> (<%= ResumenPendientes() %>)</p>
          <p class="warn-box__danger">Si los datos actuales NO son confiables, cancel&aacute; y usá Restore en su lugar.</p>
          <p class="warn-box__muted">Esta acci&oacute;n se registra en bit&aacute;cora y no puede deshacerse.</p>
        </div>

        <p class="confirm-label">Para confirmar, escrib&iacute; exactamente:</p>
        <div class="confirm-keyword">RECALCULAR</div>

        <label class="confirm-input-label" for="recalcConfirmInput">Confirm&aacute; escribiendo "RECALCULAR":</label>
        <input type="text" id="recalcConfirmInput" class="confirm-input" placeholder="Escrib&iacute; RECALCULAR para confirmar..." autocomplete="off" />

        <div class="modal__foot modal__foot--split">
          <button type="button" class="btn btn-ghost" data-close>Cancelar</button>
          <button type="button" class="btn btn-recalc-confirm" id="btnConfirmRecalc" disabled>Confirmar Recálculo Global</button>
        </div>
      </div>
    </div>

    <!-- ══════════════ MODAL: RESTAURAR DESDE BACKUP ══════════════ -->
    <div class="modal-overlay" id="modalRestoreOverlayRI" hidden>
      <div class="modal modal--confirm" role="dialog" aria-modal="true" aria-labelledby="restoreTitleRI">
        <div class="modal__head modal__head--warn modal__head--center">
          <h3 class="modal__title modal__title--center" id="restoreTitleRI">RESTAURAR DESDE BACKUP</h3>
          <p class="modal__subtitle">Reemplaza la base de datos completa. Usar cuando se sospecha que los DATOS (no solo los DV) fueron alterados.</p>
        </div>
        <div class="modal__divider modal__divider--warn"></div>

        <div class="campo-restore" style="margin:0 16px 14px;">
          <label>Archivo de backup (.bak) *</label>
          <asp:FileUpload ID="fileUploadBAK" runat="server" />
        </div>
        <div class="campo-restore" style="margin:0 16px 14px;">
          <label for="<%= txtMotivoRestore.ClientID %>">Motivo del restore *</label>
          <asp:TextBox ID="txtMotivoRestore" runat="server" TextMode="MultiLine" Rows="2" placeholder="Indicar motivo..." CssClass="confirm-textarea" style="width:100%;box-sizing:border-box;margin:0;" />
        </div>

        <div class="warn-box">
          Esta operaci&oacute;n reemplazar&aacute; la base de datos actual y sobrescribir&aacute; todos los datos. Es irreversible.
        </div>

        <p class="confirm-label">Para confirmar, escrib&iacute; exactamente:</p>
        <div class="confirm-keyword">RESTAURAR</div>

        <input type="text" class="confirm-input" id="inputConfirmacionRI"
               placeholder="Escrib&iacute; RESTAURAR para habilitar..."
               oninput="verificarConfirmacionRI(this)" />

        <div class="modal__foot modal__foot--split">
          <button type="button" class="btn btn-ghost" onclick="cerrarModalRestoreRI()">Cancelar</button>
          <asp:Button ID="btnRestaurar" runat="server" Text="Confirmar Restore"
                      CssClass="btn btn-recalc-confirm"
                      OnClick="BtnRestaurar_Click"
                      OnClientClick="return prepararRestoreRI();" />
        </div>
      </div>
    </div>

    <!-- Toast -->
    <div id="toast" class="toast" hidden></div>

    <script type="text/javascript">
        'use strict';

        var $ = function (sel, ctx) { return (ctx || document).querySelector(sel); };

        function showModal(sel) { $(sel).hidden = false; document.body.style.overflow = 'hidden'; }
        function hideModal(sel) { $(sel).hidden = true; document.body.style.overflow = ''; }
        function hideAllModals() {
            document.querySelectorAll('.modal-overlay').forEach(function (m) { m.hidden = true; });
            document.body.style.overflow = '';
        }

        /* ───────────── MODAL: DETALLE ───────────── */

        function abrirDetalle(base64) {
            var detalle;
            try {
                detalle = JSON.parse(decodeURIComponent(escape(window.atob(base64))));
            } catch (err) {
                console.error('No se pudo leer el detalle de la inconsistencia', err);
                return;
            }

            $('#detId').textContent = '#' + detalle.id;
            $('#detEstadoPill').textContent = detalle.estado;
            $('#detEstadoPill').className = 'pill ' + (detalle.estado === 'Pendiente' ? 'pill--pend' : 'pill--ok');

            var columnasCambiadas = detalle.columnasCambiadas || [];
            var textoColumnas = columnasCambiadas.length > 0 ? columnasCambiadas.join(', ') : '—';

            var campos = [
                ['ID inconsistencia', detalle.id, ''],
                ['Tabla afectada', detalle.tabla, ''],
                ['Registro afectado', detalle.registro, ''],
                ['Qué pasó', detalle.quePaso, 'is-ora'],
                ['Columna(s) cambiada(s)', detalle.quePaso === 'Modificación' ? textoColumnas : '—', 'is-red'],
                ['Fecha de detección', detalle.fecha, ''],
                ['Detectado por', detalle.webmaster, ''],
            ];
            if (detalle.valorEsperadoDVH) {
                campos.push(['Hash esperado (fila)', detalle.valorEsperadoDVH, 'is-green']);
                campos.push(['Hash calculado (fila)', detalle.valorCalculadoDVH, 'is-red']);
            }
            var grid = $('#detailGrid');
            grid.innerHTML = '';
            campos.forEach(function (c) {
                var label = c[0], value = c[1], cls = c[2];
                var f = document.createElement('div');
                var l = document.createElement('div'); l.className = 'detail-field__label'; l.textContent = label;
                var v = document.createElement('div'); v.className = 'detail-field__value ' + cls; v.textContent = value;
                f.appendChild(l); f.appendChild(v);
                grid.appendChild(f);
            });

            var registroActualBox = $('#detailRegistroActual');
            var registroActualGrid = $('#detailRegistroActualGrid');
            registroActualGrid.innerHTML = '';
            if (detalle.registroActual) {
                registroActualBox.hidden = false;
                Object.keys(detalle.registroActual).forEach(function (col) {
                    var esCambiada = columnasCambiadas.indexOf(col) !== -1;
                    var f = document.createElement('div');
                    var l = document.createElement('div'); l.className = 'detail-field__label'; l.textContent = col + (esCambiada ? ' (columna cambiada)' : '');
                    var v = document.createElement('div'); v.className = 'detail-field__value ' + (esCambiada ? 'is-red' : '');
                    v.textContent = detalle.registroActual[col] === null ? '(vacío)' : detalle.registroActual[col];
                    f.appendChild(l); f.appendChild(v);
                    registroActualGrid.appendChild(f);
                });
            } else {
                registroActualBox.hidden = true;
            }

            var explain = $('#detailExplain');
            if (detalle.mensajeDetalle) {
                explain.hidden = false;
                explain.querySelector('p').textContent = detalle.mensajeDetalle;
            } else if (columnasCambiadas.length > 0 && detalle.quePaso === 'Modificación') {
                explain.hidden = false;
                explain.querySelector('p').textContent = 'Campo(s) señalado(s) a partir de qué columna(s) de la tabla cambiaron en la misma pasada de verificación — si varias filas de la tabla cambiaron a la vez, esta correlación puede no ser exacta.';
            } else {
                explain.hidden = true;
            }

            showModal('#modalDetalle');
        }

        /* ───────────── MODAL: RECÁLCULO GENERAL ───────────── */

        function validateRecalcInput() {
            var input = $('#recalcConfirmInput');
            var confirmBtn = $('#btnConfirmRecalc');
            var ok = input.value.trim() === 'RECALCULAR';
            input.classList.toggle('is-valid', ok);
            confirmBtn.disabled = !ok;
        }

        /* ───────────── MODAL: RESTORE (portado de la versión anterior) ───────────── */

        function abrirModalRestoreRI() {
            var inputConf = document.getElementById('inputConfirmacionRI');
            inputConf.value = '';
            inputConf.classList.remove('is-valid');
            document.getElementById('<%= btnRestaurar.ClientID %>').disabled = true;

            showModal('#modalRestoreOverlayRI');
        }

        function cerrarModalRestoreRI() { hideModal('#modalRestoreOverlayRI'); }

        function verificarConfirmacionRI(input) {
            var btnConf = document.getElementById('<%= btnRestaurar.ClientID %>');
            var ok = input.value === 'RESTAURAR';
            input.classList.toggle('is-valid', ok);
            btnConf.disabled = !ok;
        }

        function prepararRestoreRI() {
            var fileInput = document.getElementById('<%= fileUploadBAK.ClientID %>');
            var motivo = document.getElementById('<%= txtMotivoRestore.ClientID %>').value.trim();

            if (!fileInput || !fileInput.files || fileInput.files.length === 0) {
                alert('Seleccioná un archivo .bak primero.');
                return false;
            }
            if (!motivo) {
                alert('El motivo del restore es obligatorio.');
                return false;
            }
            if (document.getElementById('inputConfirmacionRI').value !== 'RESTAURAR') {
                alert('Escribí RESTAURAR para confirmar.');
                return false;
            }
            return true;
        }

        /* ───────────── WIRING ───────────── */

        document.addEventListener('DOMContentLoaded', function () {
            var btnAbrirRecalc = $('#btnRecalcGeneral');
            if (btnAbrirRecalc) {
                btnAbrirRecalc.addEventListener('click', function () {
                    var input = $('#recalcConfirmInput');
                    input.value = '';
                    input.classList.remove('is-valid');
                    $('#btnConfirmRecalc').disabled = true;
                    showModal('#modalRecalc');
                    setTimeout(function () { input.focus(); }, 100);
                });
            }

            var btnAbrirRestore = $('#btnAbrirRestore');
            if (btnAbrirRestore) {
                btnAbrirRestore.addEventListener('click', abrirModalRestoreRI);
            }

            $('#recalcConfirmInput').addEventListener('input', validateRecalcInput);

            $('#btnConfirmRecalc').addEventListener('click', function () {
                if ($('#recalcConfirmInput').value.trim() !== 'RECALCULAR') return;
                // Dispara el postback real (asp:Button oculto con OnClick=BtnRecalcular_Click)
                document.getElementById('<%= btnRecalcular.ClientID %>').click();
            });

            document.addEventListener('click', function (e) {
                var detBtn = e.target.closest('[data-detalle]');
                if (detBtn) { abrirDetalle(detBtn.getAttribute('data-detalle')); return; }

                if (e.target.closest('[data-close]')) { hideAllModals(); return; }

                if (e.target.classList.contains('modal-overlay')) { hideAllModals(); }
            });

            document.addEventListener('keydown', function (e) {
                if (e.key === 'Escape') { hideAllModals(); cerrarModalRestoreRI(); }
            });
        });
    </script>

  </form>
</body>
</html>
