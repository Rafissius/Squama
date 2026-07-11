<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="GestionUsuarios.aspx.cs" Inherits="PylinskiCuello_ProyectoWeb.GestionUsuarios" %>

<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Gestión de Usuarios — SQUAMA Webmaster</title>
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet" />
<style>
/* ═══════════════════════════════════════════════════════
   SQUAMA — Gestión de Usuarios · Webmaster
   ═══════════════════════════════════════════════════════ */
:root{
  --bg:#2e1a0a; --bg-dark:#0f0803; --bg-card:#261507;
  --gold:#d9ad26; --gold-br:#ffe066; --purp:#b86bf2; --cream:#f5e8bf;
  --green:#47d96b; --red:#f2522e; --blue:#5999f2; --ora:#f29e38;
  --dark:#1f1005; --black:#000;
  --stripe:rgba(82,46,20,.14);
  --radius:10px; --radius-lg:14px;
  --font:'Inter',system-ui,-apple-system,sans-serif;
}
*{box-sizing:border-box;margin:0;padding:0}
html{scroll-behavior:smooth}
body{
  font-family:var(--font);
  background-color:var(--bg);
  background-image:repeating-linear-gradient(to bottom,var(--stripe) 0,var(--stripe) 26px,transparent 26px,transparent 54px);
  color:var(--cream);min-height:100vh;padding-bottom:60px;
}
body::before{content:'';position:absolute;top:68px;left:0;right:0;height:280px;
  background:linear-gradient(to bottom,rgba(184,107,242,.12),transparent);pointer-events:none;z-index:0}

/* ─── NAVBAR ─── */
.navbar{position:sticky;top:0;z-index:100;display:flex;align-items:center;justify-content:space-between;
  height:68px;padding:0 28px;background:rgba(15,8,3,.97);
  border-top:3px solid var(--gold);border-bottom:3px solid rgba(217,173,38,.3);backdrop-filter:blur(6px)}
.nav-brand{display:flex;align-items:center;gap:16px}
.nav-logo-group{display:flex;flex-direction:column;line-height:1.1}
.nav-logo{font-size:22px;font-weight:700;color:var(--gold);letter-spacing:.5px}
.nav-tagline{font-size:10px;color:rgba(245,232,191,.65)}
.badge-webmaster{font-size:9px;font-weight:700;color:var(--purp);background:rgba(184,107,242,.22);
  border:1px solid rgba(184,107,242,.7);border-radius:11px;padding:5px 12px;letter-spacing:1px}
.nav-links{display:flex;gap:8px;list-style:none}
.nav-links a{display:block;padding:8px 14px;font-size:14px;color:rgba(245,232,191,.75);text-decoration:none;
  border-radius:6px;transition:color .15s,background .15s;position:relative}
.nav-links a:hover{color:var(--cream);background:rgba(184,107,242,.08)}
.nav-links a.active{color:var(--gold-br);font-weight:700}
.nav-links a.active::after{content:'';position:absolute;left:14px;right:14px;bottom:-20px;height:3px;background:var(--gold-br)}
.nav-user{display:flex;align-items:center;gap:10px}
.nav-avatar{width:44px;height:44px;border-radius:50%;background:rgba(184,107,242,.35);border:1.5px solid rgba(184,107,242,.6)}
.nav-user-info{display:flex;flex-direction:column;line-height:1.2}
.nav-user-name{font-size:13px;font-weight:700;color:var(--gold-br)}
.nav-user-role{font-size:10px;font-weight:700;color:var(--purp)}

.nav-hamburger{display:none;background:none;border:1.5px solid rgba(217,173,38,.55);color:var(--gold);
  font-size:18px;width:38px;height:38px;border-radius:8px;cursor:pointer;align-items:center;justify-content:center}
.nav-hamburger:hover{background:rgba(217,173,38,.15)}

/* ─── PAGE ─── */
.page{position:relative;z-index:1;max-width:1440px;margin:0 auto;padding:0 16px}
.page-header{text-align:center;padding:24px 0 8px}
.page-eyebrow{display:inline-block;font-size:11px;font-weight:700;letter-spacing:1px;color:var(--purp);
  background:rgba(184,107,242,.18);border:1px solid rgba(184,107,242,.7);border-radius:13px;padding:6px 18px}
.page-title{font-size:40px;font-weight:700;color:var(--gold-br);margin-top:12px;letter-spacing:-.5px}
.page-subtitle{font-size:13px;color:rgba(245,232,191,.72);margin-top:8px}
.header-rule{width:600px;max-width:80%;height:2px;margin:14px auto 0;background:rgba(217,173,38,.4);position:relative}
.header-rule::after{content:'';position:absolute;top:6px;left:50%;transform:translateX(-50%);
  width:400px;max-width:100%;height:1px;background:rgba(217,173,38,.2)}

/* ─── SUMMARY CARDS ─── */
.summary-grid{display:grid;grid-template-columns:repeat(5,1fr);gap:12px;margin-top:24px}
.sum-card{position:relative;background:rgba(38,21,7,.97);border:1.5px solid;border-radius:var(--radius);
  padding:14px 10px;text-align:center;box-shadow:0 4px 0 rgba(0,0,0,.45);overflow:hidden}
.sum-card::before{content:'';position:absolute;top:0;left:0;right:0;height:4px;background:currentColor;border-radius:3px 3px 0 0}
.sum-card__value{font-size:32px;font-weight:700;line-height:1.2}
.sum-card__label{font-size:11px;font-weight:700;color:var(--gold-br);margin-top:6px}
.sum-card__sub{display:inline-block;margin-top:8px;font-size:9px;padding:3px 10px;border-radius:8px;border:1px solid;background:transparent}
.c-purp{color:var(--purp);border-color:rgba(184,107,242,.5)}
.c-green{color:var(--green);border-color:rgba(71,217,107,.5)}
.c-red{color:var(--red);border-color:rgba(242,82,46,.5)}
.c-blue{color:var(--blue);border-color:rgba(89,153,242,.5)}
.c-gold{color:var(--gold);border-color:rgba(217,173,38,.5)}
.c-ora{color:var(--ora);border-color:rgba(242,158,56,.5)}

/* ─── FILTERS BAR ─── */
.filters{display:flex;gap:10px;margin-top:24px;padding:12px;background:rgba(15,8,3,.85);
  border:1px solid rgba(217,173,38,.2);border-radius:var(--radius)}
.filters__search{flex:1;min-width:180px;padding:8px 12px;font-family:var(--font);font-size:11px;
  color:var(--cream);background:rgba(15,8,3,.9);border:1px solid rgba(184,107,242,.3);border-radius:6px}
.filters__search::placeholder{color:rgba(245,232,191,.4)}
.filters__search:focus{outline:none;border-color:var(--purp);box-shadow:0 0 0 2px rgba(184,107,242,.2)}
.filter-select{padding:8px 12px;font-family:var(--font);font-size:11px;color:var(--cream);
  background:rgba(15,8,3,.9);border:1px solid rgba(217,173,38,.3);border-radius:6px;cursor:pointer;min-width:120px}
.filter-select:focus{outline:none;border-color:var(--gold)}
.btn{font-family:var(--font);font-size:12px;font-weight:700;border:none;border-radius:8px;
  padding:8px 16px;cursor:pointer;transition:filter .15s,transform .1s;white-space:nowrap}
.btn:hover{filter:brightness(1.1)}
.btn:active{transform:translateY(1px)}
.btn:disabled{opacity:.4;cursor:not-allowed;filter:none}
.btn:focus-visible{outline:2px solid var(--gold-br);outline-offset:2px}
.btn-purp{background:var(--purp);color:#fff}
.btn-ghost{background:transparent;color:rgba(245,232,191,.65);border:1px solid rgba(245,232,191,.3)}
.btn-ghost:hover{background:rgba(245,232,191,.06);filter:none}
.btn-green{background:var(--green);color:var(--dark)}
.btn-gold{background:var(--gold);color:var(--dark)}
.btn-red{background:var(--red);color:#fff}
.btn-block{width:100%}

/* ─── TABLE ─── */
.table-wrap{margin-top:16px;background:rgba(15,8,3,.9);border:1px solid rgba(217,173,38,.18);border-radius:var(--radius);overflow:hidden}
.tbl{width:100%;border-collapse:collapse;font-size:11px}
.tbl thead{background:rgba(184,107,242,.1);border-top:3px solid var(--purp)}
.tbl thead th{text-align:left;padding:12px 10px;font-weight:700;font-size:10px;color:var(--purp)}
.tbl tbody td{padding:10px;border-top:1px solid rgba(217,173,38,.1);vertical-align:middle}
.tbl tbody tr:nth-child(odd){background:rgba(184,107,242,.03)}
.tbl tbody tr:hover{background:rgba(184,107,242,.07)}
.cell-id{color:rgba(245,232,191,.6)}
.cell-name{font-weight:700}
.cell-name.role-webmaster{color:var(--purp)}
.cell-name.role-admin{color:var(--gold-br)}
.cell-name.role-user{color:var(--blue)}
.cell-name.role-mod{color:var(--ora)}
.cell-muted{color:rgba(245,232,191,.6)}
.cell-attempts{font-weight:700;text-align:center}
.cell-attempts.high{color:var(--red)}

.role-badge{display:inline-block;font-size:9px;font-weight:700;padding:3px 10px;border-radius:9px;border:1px solid;margin-right:4px}
.role-badge--webmaster{color:var(--purp);background:rgba(184,107,242,.12);border-color:rgba(184,107,242,.55)}
.role-badge--admin{color:var(--gold);background:rgba(217,173,38,.12);border-color:rgba(217,173,38,.55)}
.role-badge--user{color:var(--blue);background:rgba(89,153,242,.12);border-color:rgba(89,153,242,.55)}
.role-badge--mod{color:var(--ora);background:rgba(242,158,56,.12);border-color:rgba(242,158,56,.55)}

.status{display:inline-block;font-size:8px;font-weight:700;padding:3px 10px;border-radius:9px;border:1px solid;white-space:nowrap}
.status--active{color:var(--green);background:rgba(71,217,107,.12);border-color:rgba(71,217,107,.55)}
.status--inactive{color:rgba(245,232,191,.6);background:rgba(245,232,191,.06);border-color:rgba(245,232,191,.3)}
.status--blocked{color:var(--red);background:rgba(242,82,46,.12);border-color:rgba(242,82,46,.55)}
.status--unblocked{color:rgba(245,232,191,.5);background:rgba(245,232,191,.05);border-color:rgba(245,232,191,.25)}

.row-actions{display:flex;gap:5px;flex-wrap:wrap}
.btn-row{font-size:9px;font-weight:700;padding:4px 8px;border-radius:5px;border:1px solid;background:transparent;cursor:pointer;transition:filter .15s;white-space:nowrap}
.btn-row:hover{filter:brightness(1.3)}
.btn-row:focus-visible{outline:2px solid var(--gold-br);outline-offset:1px}
.btn-row--view{color:var(--blue);background:rgba(89,153,242,.1);border-color:rgba(89,153,242,.5)}
.btn-row--edit{color:var(--gold);background:rgba(217,173,38,.1);border-color:rgba(217,173,38,.5)}
.btn-row--roles{color:var(--purp);background:rgba(184,107,242,.1);border-color:rgba(184,107,242,.5)}
.btn-row--toggle{color:var(--ora);background:rgba(242,158,56,.1);border-color:rgba(242,158,56,.5)}
.btn-row--activate{color:var(--green);background:rgba(71,217,107,.1);border-color:rgba(71,217,107,.5)}
.btn-row--unblock{color:var(--red);background:rgba(242,82,46,.1);border-color:rgba(242,82,46,.5)}
.btn-row--block{color:var(--red);background:rgba(242,82,46,.1);border-color:rgba(242,82,46,.5)}

.table-foot{display:flex;align-items:center;justify-content:space-between;padding:12px 16px;
  font-size:11px;color:rgba(245,232,191,.5);border-top:1px solid rgba(217,173,38,.15);background:rgba(184,107,242,.05)}
.pagination{display:flex;gap:4px}
.page-btn{width:26px;height:26px;display:grid;place-items:center;background:transparent;
  border:1px solid rgba(217,173,38,.25);border-radius:5px;color:rgba(245,232,191,.6);font-size:10px;cursor:pointer}
.page-btn.active{background:var(--purp);border-color:var(--purp);color:#fff;font-weight:700}
.page-btn:hover{border-color:var(--purp);color:var(--cream)}
.page-btn:disabled{opacity:.3;cursor:not-allowed}

.no-results{padding:40px 20px;text-align:center;color:rgba(245,232,191,.5);font-size:12px}

/* ─── MODALS ─── */
.modal-overlay{position:fixed;inset:0;background:rgba(0,0,0,.62);display:grid;place-items:center;z-index:1000;padding:20px;animation:fade .15s ease}
@keyframes fade{from{opacity:0}to{opacity:1}}
.modal-overlay[hidden]{display:none}
.modal{position:relative;width:100%;max-height:92vh;overflow-y:auto;background:rgba(15,8,3,.99);
  border:1.5px solid;border-radius:14px;box-shadow:0 6px 40px rgba(0,0,0,.6);animation:pop .18s ease}
@keyframes pop{from{transform:scale(.97);opacity:0}to{transform:scale(1);opacity:1}}
.modal--new{max-width:560px;border-color:rgba(184,107,242,.65)}
.modal--edit{max-width:640px;border-color:rgba(217,173,38,.65)}
.modal--detail{max-width:640px;border-color:rgba(89,153,242,.65)}
.modal--roles{max-width:560px;border-color:rgba(184,107,242,.65)}
.modal--confirm{max-width:500px;border-color:rgba(242,82,46,.8);border-width:2px}

.modal__head{position:relative;padding:14px 16px;border-top:4px solid;border-radius:8px 8px 0 0;display:flex;align-items:center;gap:12px}
.modal--new .modal__head,.modal--roles .modal__head{border-top-color:var(--purp);background:rgba(184,107,242,.1)}
.modal--edit .modal__head{border-top-color:var(--gold);background:rgba(217,173,38,.08)}
.modal--detail .modal__head{border-top-color:var(--blue);background:rgba(89,153,242,.08)}
.modal--confirm .modal__head{border-top-color:var(--red);background:rgba(242,82,46,.1);flex-direction:column;text-align:center}
.modal__title{font-size:15px;font-weight:700;color:var(--gold-br)}
.modal--confirm .modal__title{color:var(--red);font-size:16px}
.modal__subtitle{font-size:11px;color:rgba(245,232,191,.55);margin-top:4px}
.modal__badge{font-size:9px;font-weight:700;padding:4px 12px;border-radius:11px;border:1px solid;margin-left:auto;margin-right:36px}
.modal__badge--edit{color:var(--ora);background:rgba(242,158,56,.2);border-color:rgba(242,158,56,.55)}
.modal__close{position:absolute;top:12px;right:14px;width:24px;height:24px;display:grid;place-items:center;
  background:rgba(245,232,191,.1);border:1px solid rgba(245,232,191,.3);border-radius:7px;color:rgba(245,232,191,.5);font-size:12px;cursor:pointer}
.modal__close:hover{background:rgba(242,82,46,.2);color:var(--red)}
.modal__divider{height:1px;margin:0}
.modal--new .modal__divider,.modal--roles .modal__divider{background:rgba(184,107,242,.3)}
.modal--edit .modal__divider{background:rgba(217,173,38,.3)}
.modal--detail .modal__divider{background:rgba(89,153,242,.3)}
.modal--confirm .modal__divider{background:rgba(242,82,46,.4)}
.modal__body{padding:16px}
.modal__foot{display:flex;gap:12px;padding:16px;border-top:1px solid rgba(217,173,38,.2)}
.modal__foot .btn{flex:1}

/* ─── FORM FIELDS (in modals) ─── */
.field{margin-bottom:14px}
.field:last-child{margin-bottom:0}
.field__label{display:block;font-size:10px;font-weight:700;color:rgba(245,232,191,.75);margin-bottom:6px}
.field__label--req::after{content:' *';color:var(--red)}
.field__input,.field__select{width:100%;padding:9px 12px;font-family:var(--font);font-size:11px;
  color:var(--cream);background:rgba(15,8,3,.9);border:1px solid rgba(217,173,38,.3);border-radius:6px}
.field__input::placeholder{color:rgba(245,232,191,.3)}
.field__input:focus,.field__select:focus{outline:none;border-color:var(--gold);box-shadow:0 0 0 2px rgba(217,173,38,.15)}
.field__input.is-error{border-color:var(--red);box-shadow:0 0 0 2px rgba(242,82,46,.15)}
.field__error{font-size:10px;color:var(--red);margin-top:4px;display:none}
.field__error.show{display:block}
.field__help{font-size:9px;color:rgba(245,232,191,.5);margin-top:4px}
.field__select{appearance:none;cursor:pointer;background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='10' height='6' viewBox='0 0 10 6'%3E%3Cpath d='M1 1l4 4 4-4' stroke='%23d9ad26' stroke-width='1.5' fill='none'/%3E%3C/svg%3E");
  background-repeat:no-repeat;background-position:right 12px center}

.field-row{display:grid;grid-template-columns:1fr 1fr;gap:12px}

/* Toggle group (Estado / Bloqueo) */
.toggle-group{display:flex;gap:8px}
.toggle-opt{flex:1;padding:8px;text-align:center;font-size:11px;font-weight:400;color:rgba(245,232,191,.6);
  background:rgba(15,8,3,.7);border:1px solid rgba(217,173,38,.2);border-radius:7px;cursor:pointer;transition:all .15s}
.toggle-opt:hover{border-color:rgba(217,173,38,.5)}
.toggle-opt.active{font-weight:700}
.toggle-opt.active[data-value="active"]{color:var(--green);background:rgba(71,217,107,.15);border-color:rgba(71,217,107,.6)}
.toggle-opt.active[data-value="inactive"]{color:rgba(245,232,191,.85);background:rgba(245,232,191,.08);border-color:rgba(245,232,191,.4)}
.toggle-opt.active[data-value="blocked"]{color:var(--red);background:rgba(242,82,46,.15);border-color:rgba(242,82,46,.6)}
.toggle-opt.active[data-value="unblocked"]{color:var(--green);background:rgba(71,217,107,.15);border-color:rgba(71,217,107,.6)}

/* Roles checkboxes */
.roles-check-list{display:flex;flex-direction:column;gap:8px}
.role-check{display:flex;align-items:center;gap:10px;padding:9px 12px;background:rgba(15,8,3,.7);
  border:1px solid rgba(217,173,38,.2);border-radius:8px;cursor:pointer;transition:border-color .15s}
.role-check:hover{border-color:rgba(184,107,242,.4)}
.role-check input{width:16px;height:16px;accent-color:var(--purp);cursor:pointer}
.role-check__name{font-size:11px;font-weight:700}
.role-check__name.role-webmaster{color:var(--purp)}
.role-check__name.role-admin{color:var(--gold-br)}
.role-check__name.role-user{color:var(--blue)}
.role-check__name.role-mod{color:var(--ora)}
.role-check__desc{font-size:9px;color:rgba(245,232,191,.55);margin-left:auto}
.role-check input:checked ~ .role-check__name{filter:brightness(1.2)}

/* Attempts counter */
.attempts-row{display:flex;align-items:center;gap:10px;padding:10px 12px;background:rgba(15,8,3,.7);
  border:1px solid rgba(242,158,56,.3);border-radius:8px}
.attempts-count{font-size:20px;font-weight:700;color:var(--ora)}
.attempts-label{font-size:10px;color:rgba(245,232,191,.65);flex:1}
.btn-reset-attempts{font-size:10px;padding:5px 12px;background:rgba(71,217,107,.15);
  color:var(--green);border:1px solid rgba(71,217,107,.5);border-radius:6px;cursor:pointer;font-weight:700}
.btn-reset-attempts:hover{background:rgba(71,217,107,.25)}

/* Detail grid */
.detail-grid{display:grid;grid-template-columns:1fr 1fr;gap:12px 16px}
.detail-item{background:rgba(15,8,3,.7);border:1px solid rgba(89,153,242,.2);border-radius:8px;padding:8px 12px}
.detail-item__label{font-size:9px;color:rgba(245,232,191,.45)}
.detail-item__value{font-size:11px;font-weight:700;color:rgba(245,232,191,.9);margin-top:2px}
.detail-item__value.is-green{color:var(--green)}
.detail-item__value.is-red{color:var(--red)}
.detail-item__value.is-purp{color:var(--purp)}
.detail-item__value.is-gold{color:var(--gold-br)}
.detail-item__value.is-blue{color:var(--blue)}
.detail-item__value.is-ora{color:var(--ora)}

.detail-section{margin-top:12px;padding-top:12px;border-top:1px solid rgba(89,153,242,.2)}
.detail-heading{font-size:11px;font-weight:700;color:var(--gold-br);margin-bottom:8px}
.roles-chips{display:flex;flex-wrap:wrap;gap:6px}

/* Info notes */
.note-box{position:relative;padding:10px 12px 10px 18px;border-radius:10px;font-size:10px;line-height:1.5;color:rgba(245,232,191,.75);margin-top:14px}
.note-box::before{content:'';position:absolute;left:0;top:0;bottom:0;width:4px;border-radius:2px}
.note-box--warn{background:rgba(242,158,56,.06);border:1px solid rgba(242,158,56,.28)}
.note-box--warn::before{background:rgba(242,158,56,.7)}
.note-box--danger{background:rgba(242,82,46,.08);border:1px solid rgba(242,82,46,.35)}
.note-box--danger::before{background:rgba(242,82,46,.8)}
.note-box__sub{color:rgba(245,232,191,.55);margin-top:4px}

/* Confirm modal */
.confirm-msg{padding:16px;text-align:center;font-size:12px;color:rgba(245,232,191,.85);line-height:1.6}
.confirm-msg strong{color:var(--gold-br)}

/* Toast */
.toast{position:fixed;bottom:24px;left:50%;transform:translateX(-50%);padding:12px 24px;background:rgba(15,8,3,.98);
  border:1.5px solid var(--green);border-radius:10px;color:var(--cream);font-size:13px;font-weight:600;
  box-shadow:0 6px 30px rgba(0,0,0,.5);z-index:2000;animation:toastIn .25s ease}
.toast--err{border-color:var(--red)}
.toast[hidden]{display:none}
@keyframes toastIn{from{transform:translate(-50%,20px);opacity:0}to{transform:translate(-50%,0);opacity:1}}

/* Responsive */
@media (max-width:1200px){.summary-grid{grid-template-columns:repeat(3,1fr)}}
@media (max-width:900px){
  .nav-hamburger{display:flex}
  .nav-user{display:none}
  .nav-links{display:none;position:absolute;top:100%;left:0;right:0;flex-direction:column;gap:0;
    background:rgba(15,8,3,.98);border-bottom:3px solid var(--gold);z-index:200}
  .nav-links.open{display:flex}
  .nav-links li{width:100%}
  .nav-links a{display:block;padding:14px 24px}
  .nav-links a.active::after{display:none}
  .table-wrap{overflow-x:auto}.tbl{min-width:820px}
  .filters{flex-wrap:wrap}
  .filter-select,.filters__search{flex:1 1 45%}
  .field-row{grid-template-columns:1fr}
  .detail-grid{grid-template-columns:1fr}
}
@media (max-width:640px){
  .summary-grid{grid-template-columns:repeat(2,1fr)}
  .page-title{font-size:30px}
  .filters .btn{flex:1}
}
@media (prefers-reduced-motion:reduce){*,*::before,*::after{animation:none!important;transition:none!important}}
</style>
</head>
<body>

<!-- ═══════════ NAVBAR ═══════════ -->
<nav class="navbar">
  <div class="nav-brand">
    <div class="nav-logo-group">
      <span class="nav-logo">SQUAMA</span>
      <span class="nav-tagline">Forjá tu Leyenda</span>
    </div>
    <span class="badge-webmaster">WEBMASTER</span>
  </div>
  <button type="button" class="nav-hamburger" onclick="toggleMenu()" aria-label="Abrir menú">&#9776;</button>
  <ul class="nav-links" id="navLinks">
    <li><a href="HomeWebmaster.aspx">Inicio</a></li>
    <li><a href="GestionUsuarios.aspx" class="active">Usuarios</a></li>
    <li><a href="BitacoraEventos.aspx">Bitácora</a></li>
    <li><a href="EnConstruccionWebmaster.aspx">Sistema</a></li>
    <li><a href="EnConstruccionWebmaster.aspx">Seguridad</a></li>
  </ul>
  <div class="nav-user">
    <div class="nav-avatar"></div>
    <div class="nav-user-info">
      <span class="nav-user-name">Webmaster</span>
      <span class="nav-user-role">WEBMASTER</span>
    </div>
  </div>
</nav>

<main class="page">
  <!-- ═══════════ HEADER ═══════════ -->
  <header class="page-header">
    <span class="page-eyebrow">GESTIÓN DE USUARIOS</span>
    <h1 class="page-title">Gestión de Usuarios</h1>
    <p class="page-subtitle">Administrá cuentas, roles y accesos del sistema.</p>
    <div class="header-rule"></div>
  </header>

  <!-- ═══════════ SUMMARY CARDS ═══════════ -->
  <section class="summary-grid" id="summaryGrid" aria-label="Resumen de usuarios"></section>

  <!-- ═══════════ FILTERS ═══════════ -->
  <section class="filters" aria-label="Filtros">
    <input type="search" id="filterSearch" class="filters__search" placeholder="Buscar por usuario, email o ID..." />
    <select class="filter-select" id="filterRole">
      <option value="">Todos los roles</option>
    </select>
    <select class="filter-select" id="filterEstado">
      <option value="">Todos los estados</option>
      <option value="active">Activo</option>
      <option value="inactive">Inactivo</option>
    </select>
    <select class="filter-select" id="filterBloqueo">
      <option value="">Bloqueo (todos)</option>
      <option value="blocked">Bloqueado</option>
      <option value="unblocked">Desbloqueado</option>
    </select>
    <button class="btn btn-ghost" id="btnClearFilters">Limpiar</button>
    <button class="btn btn-purp" id="btnNewUser">+ Nuevo Usuario</button>
  </section>

  <!-- ═══════════ TABLE ═══════════ -->
  <div class="table-wrap">
    <table class="tbl">
      <thead>
        <tr>
          <th>ID</th>
          <th>Usuario</th>
          <th>Email</th>
          <th>Roles</th>
          <th>Estado</th>
          <th>Bloqueo</th>
          <th>Intentos</th>
          <th>Últ. acceso</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody id="usersBody"></tbody>
    </table>
    <div class="table-foot">
      <span id="tableFootText">— usuarios</span>
      <div class="pagination" id="pagination"></div>
    </div>
  </div>
</main>

<!-- ═══════════ MODAL: NUEVO USUARIO ═══════════ -->
<div class="modal-overlay" id="modalNew" hidden>
  <div class="modal modal--new" role="dialog" aria-modal="true" aria-labelledby="newTitle">
    <div class="modal__head">
      <h3 class="modal__title" id="newTitle">Nuevo Usuario</h3>
      <button class="modal__close" data-close aria-label="Cerrar">✕</button>
    </div>
    <div class="modal__divider"></div>
    <div class="modal__body">
      <div class="field-row">
        <div class="field">
          <label class="field__label field__label--req" for="newUsername">Nombre de usuario</label>
          <input class="field__input" id="newUsername" type="text" placeholder="ej: goku_ssj" autocomplete="off" />
          <p class="field__error" id="errNewUsername">El nombre de usuario es obligatorio y debe ser único.</p>
        </div>
        <div class="field">
          <label class="field__label field__label--req" for="newEmail">Email</label>
          <input class="field__input" id="newEmail" type="email" placeholder="ej: usuario@squama.com" autocomplete="off" />
          <p class="field__error" id="errNewEmail">Email inválido o ya registrado.</p>
        </div>
      </div>
      <div class="field-row">
        <div class="field">
          <label class="field__label field__label--req" for="newPassword">Contraseña</label>
          <input class="field__input" id="newPassword" type="password" placeholder="Mínimo 8 caracteres" autocomplete="new-password" />
          <p class="field__error" id="errNewPassword">La contraseña debe tener al menos 8 caracteres.</p>
        </div>
        <div class="field">
          <label class="field__label field__label--req" for="newPasswordConfirm">Confirmar contraseña</label>
          <input class="field__input" id="newPasswordConfirm" type="password" placeholder="Repetir contraseña" autocomplete="new-password" />
          <p class="field__error" id="errNewPasswordConfirm">Las contraseñas no coinciden.</p>
        </div>
      </div>
      <div class="field">
        <label class="field__label">Estado inicial</label>
        <div class="toggle-group" data-toggle-group="newState">
          <div class="toggle-opt active" data-value="active">Activo</div>
          <div class="toggle-opt" data-value="inactive">Inactivo</div>
        </div>
      </div>
      <div class="field">
        <label class="field__label">Rol</label>
        <div class="roles-check-list" id="newRolesList"></div>
        <p class="field__help">Cada usuario tiene un único rol activo.</p>
      </div>
    </div>
    <div class="modal__foot">
      <button class="btn btn-ghost" data-close>Cancelar</button>
      <button class="btn btn-purp" id="btnSaveNew">Crear Usuario</button>
    </div>
  </div>
</div>

<!-- ═══════════ MODAL: EDITAR USUARIO ═══════════ -->
<div class="modal-overlay" id="modalEdit" hidden>
  <div class="modal modal--edit" role="dialog" aria-modal="true" aria-labelledby="editTitle">
    <div class="modal__head">
      <h3 class="modal__title" id="editTitle">Editar Usuario — <span id="editUsername"></span></h3>
      <span class="modal__badge modal__badge--edit">Editando</span>
      <button class="modal__close" data-close aria-label="Cerrar">✕</button>
    </div>
    <div class="modal__divider"></div>
    <div class="modal__body">
      <div class="field-row">
        <div class="field">
          <label class="field__label field__label--req" for="editUsernameInput">Nombre de usuario</label>
          <input class="field__input" id="editUsernameInput" type="text" />
        </div>
        <div class="field">
          <label class="field__label field__label--req" for="editEmailInput">Email</label>
          <input class="field__input" id="editEmailInput" type="email" />
        </div>
      </div>
      <div class="field-row">
        <div class="field">
          <label class="field__label">Estado</label>
          <div class="toggle-group" data-toggle-group="editEstado">
            <div class="toggle-opt" data-value="active">Activo</div>
            <div class="toggle-opt" data-value="inactive">Inactivo</div>
          </div>
        </div>
        <div class="field">
          <label class="field__label">Bloqueo</label>
          <div class="toggle-group" data-toggle-group="editBloqueo">
            <div class="toggle-opt" data-value="unblocked">Desbloqueado</div>
            <div class="toggle-opt" data-value="blocked">Bloqueado</div>
          </div>
        </div>
      </div>
      <div class="field">
        <label class="field__label">Rol</label>
        <div class="roles-check-list" id="editRolesList"></div>
      </div>
      <div class="field">
        <label class="field__label">Intentos fallidos</label>
        <div class="attempts-row">
          <span class="attempts-count" id="editAttempts">0</span>
          <span class="attempts-label">intentos consecutivos de login fallido</span>
          <button class="btn-reset-attempts" id="btnResetAttempts">Resetear</button>
        </div>
        <p class="field__help">Se bloquea automáticamente al alcanzar 5 intentos fallidos.</p>
      </div>
      <div class="note-box note-box--warn">
        <p>Los cambios afectarán al usuario inmediatamente en su próximo login.</p>
        <p class="note-box__sub">Todos los cambios quedan registrados en bitácora.</p>
      </div>
    </div>
    <div class="modal__foot">
      <button class="btn btn-ghost" data-close>Cancelar</button>
      <button class="btn btn-gold" id="btnSaveEdit">Guardar cambios</button>
    </div>
  </div>
</div>

<!-- ═══════════ MODAL: DETALLE USUARIO ═══════════ -->
<div class="modal-overlay" id="modalDetail" hidden>
  <div class="modal modal--detail" role="dialog" aria-modal="true" aria-labelledby="detailTitle">
    <div class="modal__head">
      <h3 class="modal__title" id="detailTitle">Detalle de usuario</h3>
      <button class="modal__close" data-close aria-label="Cerrar">✕</button>
    </div>
    <div class="modal__divider"></div>
    <div class="modal__body">
      <div class="detail-grid" id="detailGrid"></div>
      <div class="detail-section">
        <p class="detail-heading">Roles asignados</p>
        <div class="roles-chips" id="detailRoles"></div>
      </div>
    </div>
    <div class="modal__foot">
      <button class="btn btn-ghost" data-close>Cerrar</button>
      <button class="btn btn-gold" id="btnEditFromDetail">Editar usuario</button>
    </div>
  </div>
</div>

<!-- ═══════════ MODAL: ASIGNAR ROLES ═══════════ -->
<div class="modal-overlay" id="modalRoles" hidden>
  <div class="modal modal--roles" role="dialog" aria-modal="true" aria-labelledby="rolesTitle">
    <div class="modal__head">
      <h3 class="modal__title" id="rolesTitle">Asignar Roles — <span id="rolesUsername"></span></h3>
      <button class="modal__close" data-close aria-label="Cerrar">✕</button>
    </div>
    <div class="modal__divider"></div>
    <div class="modal__body">
      <div class="field">
        <label class="field__label">Rol</label>
        <div class="roles-check-list" id="rolesCheckList"></div>
        <p class="field__help">Los cambios de rol afectan los permisos del usuario en toda la aplicación.</p>
      </div>
    </div>
    <div class="modal__foot">
      <button class="btn btn-ghost" data-close>Cancelar</button>
      <button class="btn btn-purp" id="btnSaveRoles">Guardar roles</button>
    </div>
  </div>
</div>

<!-- ═══════════ MODAL: CONFIRMACIÓN CRÍTICA ═══════════ -->
<div class="modal-overlay" id="modalConfirm" hidden>
  <div class="modal modal--confirm" role="dialog" aria-modal="true" aria-labelledby="confirmTitle">
    <div class="modal__head">
      <h3 class="modal__title" id="confirmTitle">Confirmar acción crítica</h3>
      <p class="modal__subtitle" id="confirmSubtitle">Esta acción afectará al usuario inmediatamente</p>
    </div>
    <div class="modal__divider"></div>
    <div class="confirm-msg" id="confirmMsg"></div>
    <div class="modal__foot">
      <button class="btn btn-ghost" data-close>Cancelar</button>
      <button class="btn btn-red" id="btnConfirmAction">Confirmar</button>
    </div>
  </div>
</div>

<div id="toast" class="toast" hidden></div>

<script>
    'use strict';

    /* ─── NAVBAR MOBILE ─── */
    function toggleMenu() {
        document.getElementById('navLinks').classList.toggle('open');
    }
    document.querySelectorAll('#navLinks a').forEach((a) => {
        a.addEventListener('click', () => document.getElementById('navLinks').classList.remove('open'));
    });

    /* ─── ROLES DEL SISTEMA (cargados del server, ver init()) ─── */
    let ROLES = [];

    /* ─── USUARIOS (cargados del server, ver reloadUsers()) ─── */
    let USERS = [];

    const PAGE_SIZE = 8;

    let state = {
        filters: { search: '', role: '', estado: '', bloqueo: '' },
        page: 1,
        editingUserId: null,
        pendingAction: null, // {type, userId, callback}
    };

    const $ = (s, c = document) => c.querySelector(s);
    const $$ = (s, c = document) => [...c.querySelectorAll(s)];
    function estadoMeta(estado) {
        return estado === 'active'
            ? { label: 'ACTIVO', cls: 'status--active' }
            : { label: 'INACTIVO', cls: 'status--inactive' };
    }
    function bloqueadoMeta(bloqueado) {
        return bloqueado
            ? { label: 'BLOQUEADO', cls: 'status--blocked' }
            : { label: 'DESBLOQUEADO', cls: 'status--unblocked' };
    }
    // Los únicos 3 roles reales (Rol.Nombre): Webmaster / Administrador / Jugador.
    function roleKeyForName(nombre) {
        if (nombre === 'Webmaster') return 'webmaster';
        if (nombre === 'Administrador') return 'admin';
        return 'user'; // Jugador
    }
    function roleColorClass(nombre) {
        if (nombre === 'Webmaster') return 'is-purp';
        if (nombre === 'Administrador') return 'is-gold';
        return 'is-blue'; // Jugador
    }
    function toast(msg, isErr = false) {
        const t = $('#toast'); t.textContent = msg; t.className = 'toast' + (isErr ? ' toast--err' : ''); t.hidden = false;
        clearTimeout(t._timer); t._timer = setTimeout(() => { t.hidden = true; }, 3200);
    }
    function errMsg(err) { return (err && typeof err.get_message === 'function') ? err.get_message() : 'Ocurrió un error inesperado.'; }
    // Llama a GestionUsuariosApi.ashx?accion=X (reemplaza a PageMethods: un WebMethod vía
    // ScriptManager usa la URL /Pagina.aspx/NombreMetodo, que Friendly Urls intercepta y
    // rompe — un .ashx es una URL plana que no choca con esas rutas). onSuccess/onError
    // mantienen la misma firma que ya usaba PageMethods para no tocar el resto del código.
    function callApi(accion, args, onSuccess, onError) {
        fetch('GestionUsuariosApi.ashx?accion=' + encodeURIComponent(accion), {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(args || {}),
            credentials: 'same-origin',
        })
            .then((resp) => resp.json().then((data) => ({ ok: resp.ok, data })))
            .then(({ ok, data }) => {
                if (!ok) throw new Error((data && data.error) || 'Error inesperado.');
                onSuccess(data);
            })
            .catch((err) => onError({ get_message: () => err.message }));
    }
    function primaryRoleClass(user) { return 'role-' + roleKeyForName(user.nombreRol); }
    function isValidEmail(v) { return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v); }
    function findUser(id) { return USERS.find(u => u.id === Number(id)); }
    function parseAspDate(v) {
        if (!v) return null;
        const m = /\/Date\((\d+)\)\//.exec(v);
        const ms = m ? parseInt(m[1], 10) : Date.parse(v);
        return isNaN(ms) ? null : new Date(ms);
    }
    function mapUsuarioDto(dto) {
        const createdAtRaw = parseAspDate(dto.FechaRegistro);
        return {
            id: dto.IDUsuario,
            username: dto.NombreUsuario,
            email: dto.Email,
            idRol: dto.IDRol,
            nombreRol: dto.NombreRol,
            estado: dto.Estado === 1 ? 'active' : 'inactive',
            bloqueado: dto.Bloqueado,
            attempts: dto.IntentosFallidos,
            lastLogin: '', // sin tracking real de último acceso todavía
            createdAtRaw,
            createdAt: createdAtRaw ? createdAtRaw.toLocaleDateString('es-AR') : '—',
        };
    }
    function reloadUsers(onDone) {
        callApi('ListarUsuarios', {}, function (result) {
            USERS = result.map(mapUsuarioDto);
            renderAll();
            if (onDone) onDone();
        }, function (err) { toast(errMsg(err), true); });
    }
    // Ejecuta una serie de llamadas a la API en secuencia (cada una recibe
    // next/onError); se usa para guardar varios cambios de un mismo usuario
    // (datos + estado + bloqueo + rol) sin superponer varias operaciones a la vez.
    function runSequential(tasks, onDone, onError) {
        let i = 0;
        function next() {
            if (i >= tasks.length) { onDone(); return; }
            tasks[i++](next, onError);
        }
        next();
    }

    function renderSummary() {
        const total = USERS.length;
        const active = USERS.filter(u => u.estado === 'active').length;
        const blocked = USERS.filter(u => u.bloqueado).length;
        const inactive = USERS.filter(u => u.estado === 'inactive').length;
        const now = new Date();
        const thisMonth = USERS.filter(u => u.createdAtRaw
            && u.createdAtRaw.getMonth() === now.getMonth()
            && u.createdAtRaw.getFullYear() === now.getFullYear()).length;

        const cards = [
            { value: total, label: 'Total', sub: 'usuarios', cls: 'c-purp' },
            { value: active, label: 'Activos', sub: 'con acceso', cls: 'c-green' },
            { value: blocked, label: 'Bloqueados', sub: 'sin acceso', cls: 'c-red' },
            { value: inactive, label: 'Inactivos', sub: 'deshabilitados', cls: 'c-ora' },
            { value: thisMonth, label: 'Altas del mes', sub: 'nuevas cuentas', cls: 'c-blue' },
        ];
        $('#summaryGrid').innerHTML = cards.map(c => `
    <div class="sum-card ${c.cls}">
      <div class="sum-card__value">${c.value}</div>
      <div class="sum-card__label">${c.label}</div>
      <span class="sum-card__sub">${c.sub}</span>
    </div>
  `).join('');
    }

    function filteredUsers() {
        const { search, role, estado, bloqueo } = state.filters;
        const q = search.trim().toLowerCase();
        return USERS.filter(u => {
            if (role && u.idRol !== Number(role)) return false;
            if (estado && u.estado !== estado) return false;
            if (bloqueo === 'blocked' && !u.bloqueado) return false;
            if (bloqueo === 'unblocked' && u.bloqueado) return false;
            if (q) {
                const hay = (u.username + ' ' + u.email + ' ' + u.id).toLowerCase();
                if (!hay.includes(q)) return false;
            }
            return true;
        });
    }
    function paginate(list) {
        const totalPages = Math.max(1, Math.ceil(list.length / PAGE_SIZE));
        if (state.page > totalPages) state.page = totalPages;
        const start = (state.page - 1) * PAGE_SIZE;
        return { rows: list.slice(start, start + PAGE_SIZE), totalPages, total: list.length };
    }

    function renderTable() {
        const list = filteredUsers();
        const { rows, totalPages, total } = paginate(list);
        const body = $('#usersBody');

        if (rows.length === 0) {
            body.innerHTML = `<tr><td colspan="9" class="no-results">No se encontraron usuarios con los filtros aplicados.</td></tr>`;
        } else {
            body.innerHTML = rows.map(u => {
                const est = estadoMeta(u.estado);
                const blq = bloqueadoMeta(u.bloqueado);
                const roleKey = roleKeyForName(u.nombreRol);
                const rolesHtml = `<span class="role-badge role-badge--${roleKey}">${u.nombreRol || '—'}</span>`;
                const attemptsCls = u.attempts >= 3 ? 'high' : '';
                // Dos acciones independientes: Estado (activo/inactivo) y Bloqueo
                // (bloqueado/desbloqueado) ya no son mutuamente excluyentes.
                const estadoBtn = u.estado === 'active'
                    ? `<button class="btn-row btn-row--toggle" data-action="deactivate" data-user="${u.id}">Desactivar</button>`
                    : `<button class="btn-row btn-row--activate" data-action="activate" data-user="${u.id}">Activar</button>`;
                const bloqueoBtn = u.bloqueado
                    ? `<button class="btn-row btn-row--unblock" data-action="unblock" data-user="${u.id}">Desbloquear</button>`
                    : `<button class="btn-row btn-row--block" data-action="block" data-user="${u.id}">Bloquear</button>`;
                return `
      <tr>
        <td class="cell-id">${u.id}</td>
        <td><span class="cell-name ${primaryRoleClass(u)}">${u.username}</span></td>
        <td class="cell-muted">${u.email}</td>
        <td>${rolesHtml}</td>
        <td><span class="status ${est.cls}">${est.label}</span></td>
        <td><span class="status ${blq.cls}">${blq.label}</span></td>
        <td class="cell-attempts ${attemptsCls}">${u.attempts}${u.attempts >= 5 ? '/5' : ''}</td>
        <td class="cell-muted">${u.lastLogin}</td>
        <td>
          <div class="row-actions">
            <button class="btn-row btn-row--view"  data-action="view"  data-user="${u.id}">Ver</button>
            <button class="btn-row btn-row--edit"  data-action="edit"  data-user="${u.id}">Editar</button>
            <button class="btn-row btn-row--roles" data-action="roles" data-user="${u.id}">Roles</button>
            ${estadoBtn}
            ${bloqueoBtn}
          </div>
        </td>
      </tr>`;
            }).join('');
        }

        $('#tableFootText').textContent = `${total} usuario${total === 1 ? '' : 's'} — Mostrando ${rows.length}`;
        const pag = $('#pagination');
        if (totalPages <= 1) { pag.innerHTML = ''; }
        else {
            let html = `<button class="page-btn" data-page="prev" ${state.page === 1 ? 'disabled' : ''}>‹</button>`;
            for (let i = 1; i <= totalPages; i++) {
                html += `<button class="page-btn ${i === state.page ? 'active' : ''}" data-page="${i}">${i}</button>`;
            }
            html += `<button class="page-btn" data-page="next" ${state.page === totalPages ? 'disabled' : ''}>›</button>`;
            pag.innerHTML = html;
        }
    }

    function showModal(sel) { $(sel).hidden = false; document.body.style.overflow = 'hidden'; }
    function hideAllModals() { $$('.modal-overlay').forEach(m => m.hidden = true); document.body.style.overflow = ''; }

    function initToggleGroups() {
        $$('.toggle-group').forEach(g => {
            g.addEventListener('click', (e) => {
                const opt = e.target.closest('.toggle-opt');
                if (!opt) return;
                g.querySelectorAll('.toggle-opt').forEach(o => o.classList.remove('active'));
                opt.classList.add('active');
            });
        });
    }
    function getToggleValue(groupName) {
        const g = document.querySelector(`[data-toggle-group="${groupName}"]`);
        const act = g && g.querySelector('.toggle-opt.active');
        return act ? act.dataset.value : null;
    }
    function setToggleValue(groupName, value) {
        const g = document.querySelector(`[data-toggle-group="${groupName}"]`);
        if (!g) return;
        g.querySelectorAll('.toggle-opt').forEach(o => {
            o.classList.toggle('active', o.dataset.value === value);
        });
    }

    function buildRolesSelect(containerSel, selectedIdRol, selectId) {
        const c = $(containerSel);
        c.innerHTML = `<select class="field__select" id="${selectId}">` +
            ROLES.map(r => `<option value="${r.key}" ${r.key === selectedIdRol ? 'selected' : ''}>${r.label}</option>`).join('') +
            `</select>`;
    }
    function getSelectedRol(selectId) {
        const el = document.getElementById(selectId);
        return el ? parseInt(el.value, 10) : null;
    }

    function openNewUser() {
        $('#newUsername').value = '';
        $('#newEmail').value = '';
        $('#newPassword').value = '';
        $('#newPasswordConfirm').value = '';
        $$('.field__error').forEach(e => e.classList.remove('show'));
        $$('.field__input').forEach(i => i.classList.remove('is-error'));
        setToggleValue('newState', 'active');
        buildRolesSelect('#newRolesList', ROLES.length ? ROLES[ROLES.length - 1].key : null, 'newRolSelect');
        showModal('#modalNew');
        setTimeout(() => $('#newUsername').focus(), 100);
    }
    function saveNewUser() {
        const username = $('#newUsername').value.trim();
        const email = $('#newEmail').value.trim();
        const pwd = $('#newPassword').value;
        const pwd2 = $('#newPasswordConfirm').value;

        let ok = true;
        const flag = (id, err, cond) => {
            $(id).classList.toggle('is-error', !cond);
            $(err).classList.toggle('show', !cond);
            if (!cond) ok = false;
        };
        flag('#newUsername', '#errNewUsername', username.length >= 3);
        flag('#newEmail', '#errNewEmail', isValidEmail(email));
        flag('#newPassword', '#errNewPassword', pwd.length >= 8);
        flag('#newPasswordConfirm', '#errNewPasswordConfirm', pwd === pwd2 && pwd.length >= 8);
        if (!ok) return;

        const estado = getToggleValue('newState');
        const idRol = getSelectedRol('newRolSelect');

        callApi('CrearUsuario',
            { nombreUsuario: username, email: email, password: pwd, idRol: idRol, activo: estado === 'active' },
            () => {
                hideAllModals();
                reloadUsers(() => toast(`Usuario ${username} creado correctamente.`));
            },
            (err) => toast(errMsg(err), true));
    }

    function openEditUser(userId) {
        const u = findUser(userId);
        if (!u) return;
        state.editingUserId = Number(userId);
        $('#editUsername').textContent = u.username;
        $('#editUsernameInput').value = u.username;
        $('#editEmailInput').value = u.email;
        setToggleValue('editEstado', u.estado);
        setToggleValue('editBloqueo', u.bloqueado ? 'blocked' : 'unblocked');
        buildRolesSelect('#editRolesList', u.idRol, 'editRolSelect');
        $('#editAttempts').textContent = u.attempts;
        showModal('#modalEdit');
    }
    function resetAttempts() {
        const u = findUser(state.editingUserId);
        if (!u) return;
        callApi('ResetearIntentos', { idUsuario: u.id },
            () => reloadUsers(() => {
                $('#editAttempts').textContent = '0';
                toast(`Intentos fallidos reseteados para ${u.username}.`);
            }),
            (err) => toast(errMsg(err), true));
    }
    function saveEditUser() {
        const u = findUser(state.editingUserId);
        if (!u) return;
        const newUsername = $('#editUsernameInput').value.trim();
        const newEmail = $('#editEmailInput').value.trim();
        const newEstado = getToggleValue('editEstado');
        const newBloqueado = getToggleValue('editBloqueo') === 'blocked';
        const newIdRol = getSelectedRol('editRolSelect');

        if (newUsername.length < 3) { toast('Nombre de usuario inválido.', true); return; }
        if (!isValidEmail(newEmail)) { toast('Email inválido.', true); return; }

        if (newBloqueado && !u.bloqueado) {
            askConfirm({
                type: 'block', userId: u.id,
                msg: `Vas a bloquear a <strong>${u.username}</strong>.<br/>El usuario perderá acceso al sistema inmediatamente.`,
                onConfirm: () => applyEdit(u, newUsername, newEmail, newEstado, newBloqueado, newIdRol),
            });
            return;
        }
        applyEdit(u, newUsername, newEmail, newEstado, newBloqueado, newIdRol);
    }
    function applyEdit(u, username, email, estado, bloqueado, idRol) {
        const tasks = [
            (next, onErr) => callApi('EditarUsuario', { idUsuario: u.id, nombreUsuario: username, email: email }, next, onErr),
        ];
        if (estado !== u.estado) {
            tasks.push((next, onErr) => callApi('CambiarEstado', { idUsuario: u.id, activo: estado === 'active' }, next, onErr));
        }
        if (bloqueado !== u.bloqueado) {
            tasks.push((next, onErr) => callApi('CambiarBloqueo', { idUsuario: u.id, bloqueado: bloqueado }, next, onErr));
        }
        if (idRol !== u.idRol) {
            tasks.push((next, onErr) => callApi('CambiarRol', { idUsuario: u.id, idRol: idRol }, next, onErr));
        }
        runSequential(tasks, () => {
            hideAllModals();
            reloadUsers(() => toast(`Cambios guardados para ${username}.`));
        }, (err) => toast(errMsg(err), true));
    }

    function openDetail(userId) {
        const u = findUser(userId);
        if (!u) return;
        state.editingUserId = Number(userId);
        const est = estadoMeta(u.estado);
        const blq = bloqueadoMeta(u.bloqueado);
        const estadoValueCls = u.estado === 'active' ? 'is-green' : 'is-ora';
        const bloqueoValueCls = u.bloqueado ? 'is-red' : 'is-green';
        const items = [
            ['ID de usuario', u.id, ''],
            ['Nombre', u.username, roleColorClass(u.nombreRol)],
            ['Email', u.email, ''],
            ['Estado', est.label, estadoValueCls],
            ['Bloqueo', blq.label, bloqueoValueCls],
            ['Último acceso', u.lastLogin, ''],
            ['Intentos fallidos', String(u.attempts) + (u.attempts >= 5 ? ' (bloqueo)' : ''), u.attempts >= 3 ? 'is-red' : ''],
            ['Cuenta creada', u.createdAt, ''],
        ];
        $('#detailGrid').innerHTML = items.map(([l, v, cls]) => `
    <div class="detail-item">
      <div class="detail-item__label">${l}</div>
      <div class="detail-item__value ${cls}">${v}</div>
    </div>
  `).join('');
        $('#detailRoles').innerHTML = `<span class="role-badge role-badge--${roleKeyForName(u.nombreRol)}">${u.nombreRol || '—'}</span>`;
        showModal('#modalDetail');
    }

    function openRoles(userId) {
        const u = findUser(userId);
        if (!u) return;
        state.editingUserId = Number(userId);
        $('#rolesUsername').textContent = u.username;
        buildRolesSelect('#rolesCheckList', u.idRol, 'assignRolSelect');
        showModal('#modalRoles');
    }
    function saveRoles() {
        const u = findUser(state.editingUserId);
        if (!u) return;
        const newIdRol = getSelectedRol('assignRolSelect');
        callApi('CambiarRol', { idUsuario: u.id, idRol: newIdRol },
            () => reloadUsers(() => {
                hideAllModals();
                toast(`Rol actualizado para ${u.username}.`);
            }),
            (err) => toast(errMsg(err), true));
    }

    function askConfirm({ type, userId, msg, onConfirm }) {
        state.pendingAction = { type, userId, callback: onConfirm };
        $('#confirmMsg').innerHTML = msg;
        showModal('#modalConfirm');
    }
    function runPending() {
        if (state.pendingAction && state.pendingAction.callback) {
            state.pendingAction.callback();
        }
        state.pendingAction = null;
    }
    function actionDeactivate(userId) {
        const u = findUser(userId); if (!u) return;
        askConfirm({
            type: 'deactivate', userId,
            msg: `Vas a desactivar a <strong>${u.username}</strong>.<br/>El usuario no podrá iniciar sesión hasta ser reactivado.`,
            onConfirm: () => {
                callApi('CambiarEstado', { idUsuario: u.id, activo: false },
                    () => { hideAllModals(); reloadUsers(() => toast(`${u.username} fue desactivado.`)); },
                    (err) => toast(errMsg(err), true));
            },
        });
    }
    function actionActivate(userId) {
        const u = findUser(userId); if (!u) return;
        callApi('CambiarEstado', { idUsuario: u.id, activo: true },
            () => reloadUsers(() => toast(`${u.username} fue activado.`)),
            (err) => toast(errMsg(err), true));
    }
    function actionBlock(userId) {
        const u = findUser(userId); if (!u) return;
        askConfirm({
            type: 'block', userId,
            msg: `Vas a bloquear a <strong>${u.username}</strong>.<br/>El usuario perderá acceso al sistema inmediatamente.`,
            onConfirm: () => {
                callApi('CambiarBloqueo', { idUsuario: u.id, bloqueado: true },
                    () => { hideAllModals(); reloadUsers(() => toast(`${u.username} fue bloqueado.`)); },
                    (err) => toast(errMsg(err), true));
            },
        });
    }
    function actionUnblock(userId) {
        const u = findUser(userId); if (!u) return;
        askConfirm({
            type: 'unblock', userId,
            msg: `Vas a desbloquear a <strong>${u.username}</strong>.<br/>Se resetearán los intentos fallidos y el usuario podrá iniciar sesión.`,
            onConfirm: () => {
                callApi('CambiarBloqueo', { idUsuario: u.id, bloqueado: false },
                    () => { hideAllModals(); reloadUsers(() => toast(`${u.username} fue desbloqueado.`)); },
                    (err) => toast(errMsg(err), true));
            },
        });
    }

    function renderAll() { renderSummary(); renderTable(); }

    function populateRoleFilterOptions() {
        const sel = $('#filterRole');
        ROLES.forEach(r => {
            const opt = document.createElement('option');
            opt.value = r.key;
            opt.textContent = r.label;
            sel.appendChild(opt);
        });
    }
    function init() {
        initToggleGroups();
        wireEventHandlers();

        callApi('ObtenerRoles', {}, function (result) {
            ROLES = result.map(r => ({ key: r.IDRol, label: r.Nombre }));
            populateRoleFilterOptions();
            reloadUsers();
        }, function (err) { toast(errMsg(err), true); });
    }
    function wireEventHandlers() {
        $('#filterSearch').addEventListener('input', (e) => { state.filters.search = e.target.value; state.page = 1; renderTable(); });
        $('#filterRole').addEventListener('change', (e) => { state.filters.role = e.target.value; state.page = 1; renderTable(); });
        $('#filterEstado').addEventListener('change', (e) => { state.filters.estado = e.target.value; state.page = 1; renderTable(); });
        $('#filterBloqueo').addEventListener('change', (e) => { state.filters.bloqueo = e.target.value; state.page = 1; renderTable(); });
        $('#btnClearFilters').addEventListener('click', () => {
            state.filters = { search: '', role: '', estado: '', bloqueo: '' }; state.page = 1;
            $('#filterSearch').value = ''; $('#filterRole').value = ''; $('#filterEstado').value = ''; $('#filterBloqueo').value = '';
            renderTable();
        });

        $('#btnNewUser').addEventListener('click', openNewUser);
        $('#btnSaveNew').addEventListener('click', saveNewUser);

        $('#btnSaveEdit').addEventListener('click', saveEditUser);
        $('#btnResetAttempts').addEventListener('click', resetAttempts);

        $('#btnEditFromDetail').addEventListener('click', () => {
            const id = state.editingUserId;
            hideAllModals();
            if (id) setTimeout(() => openEditUser(id), 150);
        });

        $('#btnSaveRoles').addEventListener('click', saveRoles);

        $('#btnConfirmAction').addEventListener('click', runPending);

        document.addEventListener('click', (e) => {
            const btn = e.target.closest('[data-action]');
            if (btn) {
                const action = btn.dataset.action, userId = btn.dataset.user;
                if (action === 'view') openDetail(userId);
                else if (action === 'edit') openEditUser(userId);
                else if (action === 'roles') openRoles(userId);
                else if (action === 'deactivate') actionDeactivate(userId);
                else if (action === 'activate') actionActivate(userId);
                else if (action === 'block') actionBlock(userId);
                else if (action === 'unblock') actionUnblock(userId);
                return;
            }
            const pageBtn = e.target.closest('[data-page]');
            if (pageBtn) {
                const list = filteredUsers();
                const totalPages = Math.max(1, Math.ceil(list.length / PAGE_SIZE));
                const v = pageBtn.dataset.page;
                if (v === 'prev') state.page = Math.max(1, state.page - 1);
                else if (v === 'next') state.page = Math.min(totalPages, state.page + 1);
                else state.page = parseInt(v, 10);
                renderTable();
                return;
            }
            if (e.target.closest('[data-close]')) { hideAllModals(); return; }
            if (e.target.classList.contains('modal-overlay')) { hideAllModals(); }
        });

        document.addEventListener('keydown', (e) => { if (e.key === 'Escape') hideAllModals(); });
    }
    document.addEventListener('DOMContentLoaded', init);
</script>
</body>
</html>