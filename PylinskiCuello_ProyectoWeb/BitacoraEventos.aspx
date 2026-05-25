<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BitacoraEventos.aspx.cs" Inherits="PylinskiCuello_ProyectoWeb.BitacoraEventos" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>SQUAMA — Bitácora de Eventos</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;700&display=swap" rel="stylesheet" />
  <style>
    /* ── RESET ── */
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    html, body { width: 100%; min-height: 100dvh; background: #2e1a0a; font-family: 'Inter', sans-serif; }

    /* ── FONDO ── */
    .page { position: relative; width: 100%; min-height: 100dvh; display: flex; flex-direction: column; overflow-x: hidden; }
    .bg-stripes { position: fixed; inset: 0; z-index: 0; pointer-events: none;
      background: repeating-linear-gradient(to bottom, rgba(82,46,20,.14) 0, rgba(82,46,20,.14) 26px, transparent 26px, transparent 54px); }
    .bg-vignette { position: fixed; inset: 0; z-index: 1; pointer-events: none;
      background: radial-gradient(ellipse at 50% 50%, transparent 25%, rgba(0,0,0,.30) 60%, rgba(0,0,0,.80) 100%); }
    .bg-glow { position: fixed; z-index: 1; pointer-events: none; top: 68px; left: 0; right: 0; height: 280px;
      background: rgba(89,153,242,.14); }
    .bg-sides { position: fixed; inset: 0; z-index: 1; pointer-events: none;
      background: linear-gradient(to right, rgba(46,26,10,.60) 0%, transparent 18%),
                  linear-gradient(to left,  rgba(46,26,10,.60) 0%, transparent 18%); }
    .border-frame { position: fixed; inset: 10px; z-index: 2; pointer-events: none;
      border: 1px solid rgba(217,173,38,.18); border-radius: 4px; }

    /* ── NAVBAR ── */
    .navbar { position: sticky; top: 0; z-index: 100; background: rgba(15,8,3,.97);
      border-top: 3px solid #d9ad26; border-bottom: 3px solid rgba(217,173,38,.30);
      height: 68px; display: flex; align-items: center; padding: 0 28px; gap: 0; }
    .nav-brand { display: flex; flex-direction: column; flex-shrink: 0; }
    .nav-brand-name { font-weight: 700; font-size: 22px; color: #d9ad26; line-height: 1; }
    .nav-brand-sub { font-weight: 400; font-size: 10px; color: rgba(245,232,191,.65); margin-top: 2px; }
    .nav-badge { background: rgba(184,107,242,.22); border: 1px solid rgba(184,107,242,.70);
      border-radius: 11px; padding: 3px 10px; font-weight: 700; font-size: 9px; color: #b86bf2;
      margin-left: 12px; white-space: nowrap; flex-shrink: 0; }
    .nav-links { display: flex; gap: 0; margin-left: 40px; flex: 1; }
    .nav-link { font-weight: 400; font-size: 14px; color: rgba(245,232,191,.75); padding: 24px 16px;
      text-decoration: none; position: relative; transition: color .2s; white-space: nowrap; }
    .nav-link:hover { color: #ffe066; }
    .nav-link.active { font-weight: 700; color: #ffe066; }
    .nav-link.active::after { content: ''; position: absolute; bottom: 0; left: 16px;
      width: calc(100% - 32px); height: 3px; background: #ffe066; border-radius: 2px; }
    .nav-right { margin-left: auto; display: flex; align-items: center; gap: 10px; }
    .nav-avatar { width: 44px; height: 44px; border-radius: 50%; background: rgba(184,107,242,.3);
      border: 2px solid rgba(184,107,242,.5); display: flex; align-items: center; justify-content: center;
      font-weight: 700; font-size: 16px; color: #b86bf2; flex-shrink: 0; }
    .nav-user { display: flex; flex-direction: column; }
    .nav-user-name { font-weight: 700; font-size: 13px; color: #ffe066; }
    .nav-user-role { font-weight: 700; font-size: 10px; color: #b86bf2; }
    .nav-logout { display: flex; align-items: center; gap: 6px; margin-left: 10px; padding: 6px 14px;
      background: transparent; border: 1.5px solid rgba(217,173,38,.40); border-radius: 8px;
      color: rgba(245,232,191,.70); font-family: 'Inter', sans-serif; font-size: 12px; font-weight: 700;
      cursor: pointer; transition: background .2s, border-color .2s, color .2s; white-space: nowrap; }
    .nav-logout:hover { background: rgba(242,82,46,.15); border-color: rgba(242,82,46,.70); color: #f2522e; }
    .nav-hamburger { display: none; background: none; border: 1.5px solid rgba(217,173,38,.4);
      border-radius: 6px; padding: 6px 10px; color: rgba(245,232,191,.7); cursor: pointer; margin-left: auto; }
    .nav-menu-mobile { display: none; flex-direction: column; background: rgba(15,8,3,.99);
      border-bottom: 1px solid rgba(217,173,38,.2); padding: 8px 0; position: sticky; top: 68px; z-index: 99; }
    .nav-menu-mobile.open { display: flex; }
    .nav-menu-mobile .nav-link { padding: 12px 28px; }

    /* ── CONTENIDO PRINCIPAL ── */
    .main-content { position: relative; z-index: 3; flex: 1; padding: 0 28px 40px; max-width: 1440px;
      margin: 0 auto; width: 100%; }

    /* ── HEADER ── */
    .page-header { text-align: center; padding-top: 24px; padding-bottom: 20px; }
    .page-badge { display: inline-block; background: rgba(89,153,242,.18); border: 1px solid rgba(89,153,242,.70);
      border-radius: 13px; padding: 4px 18px; font-weight: 700; font-size: 11px; color: #5999f2;
      letter-spacing: 1px; margin-bottom: 10px; }
    .page-title { font-weight: 700; font-size: clamp(28px, 4vw, 40px); color: #ffe066; margin-bottom: 8px; }
    .page-subtitle { font-size: 12px; color: rgba(245,232,191,.72); margin-bottom: 14px; }
    .header-sep { width: 600px; max-width: 90%; height: 2px; background: rgba(217,173,38,.4); margin: 0 auto 4px; }
    .header-sep2 { width: 400px; max-width: 70%; height: 1px; background: rgba(217,173,38,.2); margin: 0 auto; }

    /* ── STATS CARDS ── */
    .stats-row { display: flex; gap: 16px; margin-top: 20px; flex-wrap: wrap; }
    .stat-card { flex: 1; min-width: 160px; background: rgba(38,21,7,.97);
      border-radius: 10px; padding: 16px; position: relative; overflow: hidden;
      box-shadow: 4px 4px 0 rgba(0,0,0,.45); }
    .stat-card::before { content: ''; position: absolute; top: 0; left: 0; right: 0;
      height: 4px; border-radius: 3px 3px 0 0; }
    .stat-card.blue { border: 1.5px solid rgba(89,153,242,.5); }
    .stat-card.blue::before { background: #5999f2; }
    .stat-card.red { border: 1.5px solid rgba(242,82,46,.5); }
    .stat-card.red::before { background: #f2522e; }
    .stat-card.orange { border: 1.5px solid rgba(242,158,56,.5); }
    .stat-card.orange::before { background: #f29e38; }
    .stat-card.purple { border: 1.5px solid rgba(184,107,242,.5); }
    .stat-card.purple::before { background: #b86bf2; }
    .stat-card.green { border: 1.5px solid rgba(71,217,107,.5); }
    .stat-card.green::before { background: #47d96b; }
    .stat-number { font-weight: 700; font-size: 26px; text-align: center; display: block; margin-top: 6px; }
    .stat-label { font-weight: 700; font-size: 10px; color: #ffe066; text-align: center; display: block; margin-top: 2px; }
    .stat-badge { display: block; margin: 8px auto 0; width: fit-content; padding: 2px 12px;
      border-radius: 8px; font-size: 9px; font-weight: 400; text-align: center; }
    .stat-card.blue .stat-number { color: #5999f2; }
    .stat-card.blue .stat-badge { background: rgba(89,153,242,.08); border: 1px solid rgba(89,153,242,.3); color: rgba(89,153,242,.7); }
    .stat-card.red .stat-number { color: #f2522e; }
    .stat-card.red .stat-badge { background: rgba(242,82,46,.08); border: 1px solid rgba(242,82,46,.3); color: rgba(242,82,46,.7); }
    .stat-card.orange .stat-number { color: #f29e38; }
    .stat-card.orange .stat-badge { background: rgba(242,158,56,.08); border: 1px solid rgba(242,158,56,.3); color: rgba(242,158,56,.7); }
    .stat-card.purple .stat-number { color: #b86bf2; }
    .stat-card.purple .stat-badge { background: rgba(184,107,242,.08); border: 1px solid rgba(184,107,242,.3); color: rgba(184,107,242,.7); }
    .stat-card.green .stat-number { color: #47d96b; }
    .stat-card.green .stat-badge { background: rgba(71,217,107,.08); border: 1px solid rgba(71,217,107,.3); color: rgba(71,217,107,.7); }

    /* ── FILTROS ── */
    .filters-bar { display: flex; gap: 8px; margin-top: 16px; align-items: center; flex-wrap: wrap; }
    .filter-search { flex: 1; min-width: 200px; background: rgba(15,8,3,.90);
      border: 1px solid rgba(89,153,242,.3); border-radius: 8px; padding: 0 12px;
      height: 34px; color: rgba(245,232,191,.9); font-size: 10px; font-family: 'Inter', sans-serif; }
    .filter-search::placeholder { color: rgba(245,232,191,.35); }
    .filter-select { background: rgba(15,8,3,.90); border: 1px solid rgba(217,173,38,.3);
      border-radius: 7px; padding: 0 22px 0 8px; height: 34px; color: rgba(245,232,191,.65);
      font-size: 8px; font-family: 'Inter', sans-serif; cursor: pointer;
      appearance: none; -webkit-appearance: none;
      background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='8' height='5' viewBox='0 0 8 5'%3E%3Cpath d='M0 0l4 5 4-5z' fill='rgba(217,173,38,0.5)'/%3E%3C/svg%3E");
      background-repeat: no-repeat; background-position: right 8px center; min-width: 80px; }
    .filter-select option { background: #1a0e05; color: rgba(245,232,191,.9); font-size: 12px; }
    .btn-buscar { height: 34px; padding: 0 16px; background: rgba(89,153,242,.9); border-radius: 8px;
      font-weight: 700; font-size: 11px; color: #fff; cursor: pointer; border: none;
      font-family: 'Inter', sans-serif; transition: background .2s; white-space: nowrap; }
    .btn-buscar:hover { background: #5999f2; }
    .btn-limpiar { height: 34px; padding: 0 14px; background: transparent;
      border: 1px solid rgba(217,173,38,.3); border-radius: 8px; font-size: 11px;
      color: rgba(217,173,38,.8); cursor: pointer; font-family: 'Inter', sans-serif;
      transition: background .2s, border-color .2s; white-space: nowrap; }
    .btn-limpiar:hover { background: rgba(217,173,38,.1); border-color: rgba(217,173,38,.6); }
    .btn-exportar { height: 34px; padding: 0 14px; background: rgba(71,217,107,.15);
      border: 1px solid rgba(71,217,107,.5); border-radius: 8px; font-weight: 700; font-size: 11px;
      color: #47d96b; cursor: pointer; font-family: 'Inter', sans-serif; transition: background .2s; white-space: nowrap; }
    .btn-exportar:hover { background: rgba(71,217,107,.25); }
    .btn-alertas { height: 34px; padding: 0 14px; background: rgba(89,153,242,.15);
      border: 1px solid rgba(89,153,242,.5); border-radius: 8px; font-weight: 700; font-size: 10px;
      color: #5999f2; cursor: pointer; font-family: 'Inter', sans-serif; transition: background .2s; white-space: nowrap; }
    .btn-alertas:hover { background: rgba(89,153,242,.25); }

    /* ── TABLA ── */
    .table-container { background: rgba(15,8,3,.90); border: 1px solid rgba(217,173,38,.18);
      border-radius: 10px; margin-top: 12px; overflow: hidden; }
    .table-header-row { display: grid;
      grid-template-columns: 60px 120px 110px 90px 1fr 100px 110px 70px;
      padding: 0 16px; height: 38px; align-items: center;
      background: rgba(89,153,242,.1); border-top: 3px solid #5999f2; }
    .table-header-cell { font-weight: 700; font-size: 10px; color: #5999f2; }
    .table-body { }
    .table-row { display: grid;
      grid-template-columns: 60px 120px 110px 90px 1fr 100px 110px 70px;
      padding: 0 16px; min-height: 38px; align-items: center; border-top: 1px solid rgba(217,173,38,.1);
      transition: background .15s; }
    .table-row:nth-child(odd) { background: rgba(89,153,242,.03); }
    .table-row:hover { background: rgba(89,153,242,.07); }
    .table-cell { font-size: 10px; color: rgba(245,232,191,.7); padding: 8px 0; overflow: hidden;
      text-overflow: ellipsis; white-space: nowrap; }
    .table-cell.id { color: rgba(245,232,191,.6); }
    .table-cell.usuario { font-weight: 700; color: #ffe066; }
    .table-cell.descripcion { color: rgba(245,232,191,.65); font-size: 9px; }
    .table-cell.entidad { color: rgba(245,232,191,.65); font-size: 9px; }
    .table-cell.ip { color: rgba(245,232,191,.55); font-size: 9px; }
    .tipo-badge, .crit-badge { display: inline-block; padding: 2px 8px; border-radius: 9px;
      font-weight: 700; font-size: 7px; white-space: nowrap; }
    .tipo-sistema { background: rgba(184,107,242,.1); border: 1px solid rgba(184,107,242,.45); color: #b86bf2; }
    .tipo-seguridad { background: rgba(242,82,46,.1); border: 1px solid rgba(242,82,46,.45); color: #f2522e; }
    .tipo-cambio { background: rgba(242,158,56,.1); border: 1px solid rgba(242,158,56,.45); color: #f29e38; }
    .tipo-login { background: rgba(89,153,242,.1); border: 1px solid rgba(89,153,242,.45); color: #5999f2; }
    .tipo-integridad { background: rgba(242,82,46,.1); border: 1px solid rgba(242,82,46,.45); color: #f2522e; }
    .tipo-info { background: rgba(89,153,242,.1); border: 1px solid rgba(89,153,242,.45); color: #5999f2; }
    .crit-critico { background: rgba(242,82,46,.12); border: 1px solid rgba(242,82,46,.55); color: #f2522e; }
    .crit-advertencia { background: rgba(242,158,56,.12); border: 1px solid rgba(242,158,56,.55); color: #f29e38; }
    .crit-info { background: rgba(89,153,242,.12); border: 1px solid rgba(89,153,242,.55); color: #5999f2; }
    .crit-sistema { background: rgba(184,107,242,.12); border: 1px solid rgba(184,107,242,.55); color: #b86bf2; }
    .btn-ver { background: rgba(89,153,242,.1); border: 1px solid rgba(89,153,242,.5); border-radius: 5px;
      padding: 2px 10px; font-weight: 700; font-size: 9px; color: #5999f2; cursor: pointer;
      font-family: 'Inter', sans-serif; transition: background .2s; white-space: nowrap; }
    .btn-ver:hover { background: rgba(89,153,242,.25); }
    .table-empty { padding: 40px; text-align: center; color: rgba(245,232,191,.35);
      font-size: 13px; border-top: 1px solid rgba(217,173,38,.1); }

    /* ── PAGINACION ── */
    .pagination-row { display: flex; align-items: center; padding: 8px 16px; border-top: 1px solid rgba(217,173,38,.15); }
    .pagination-info { font-size: 11px; color: rgba(245,232,191,.45); flex: 1; }
    .pagination-btns { display: flex; gap: 4px; }
    .pg-btn { width: 22px; height: 22px; border-radius: 4px; border: 1px solid rgba(217,173,38,.25);
      background: transparent; color: rgba(245,232,191,.6); font-size: 10px; cursor: pointer;
      display: flex; align-items: center; justify-content: center; font-family: 'Inter', sans-serif;
      transition: background .15s; }
    .pg-btn:hover { background: rgba(217,173,38,.15); }
    .pg-btn.active { background: rgba(89,153,242,.7); border-color: rgba(89,153,242,.7); color: #ffe066; font-weight: 700; }
    .pg-btn:disabled { opacity: .3; cursor: default; }

    /* ── ÚLTIMOS EVENTOS ── */
    .section-sep { height: 1px; background: rgba(217,173,38,.18); margin: 24px 0 16px; }
    .section-title { font-weight: 700; font-size: 12px; color: #ffe066; margin-bottom: 12px; }
    .recent-events { display: flex; gap: 16px; flex-wrap: wrap; }
    .recent-card { flex: 1; min-width: 180px; background: transparent; border-radius: 10px;
      padding: 12px 12px 10px; position: relative; overflow: hidden; }
    .recent-card::before { content: ''; position: absolute; top: 0; left: 0; right: 0; height: 3px; border-radius: 2px; }
    .recent-card.red { background: rgba(242,82,46,.08); border: 1px solid rgba(242,82,46,.35); }
    .recent-card.red::before { background: #f2522e; }
    .recent-card.purple { background: rgba(184,107,242,.08); border: 1px solid rgba(184,107,242,.35); }
    .recent-card.purple::before { background: #b86bf2; }
    .recent-card.orange { background: rgba(242,158,56,.08); border: 1px solid rgba(242,158,56,.35); }
    .recent-card.orange::before { background: #f29e38; }
    .recent-card.blue { background: rgba(89,153,242,.08); border: 1px solid rgba(89,153,242,.35); }
    .recent-card.blue::before { background: #5999f2; }
    .recent-badge { display: inline-block; padding: 2px 10px; border-radius: 9px;
      font-weight: 700; font-size: 8px; margin-bottom: 6px; }
    .recent-badge.red { background: rgba(242,82,46,.12); border: 1px solid rgba(242,82,46,.45); color: rgba(242,82,46,.9); }
    .recent-badge.purple { background: rgba(184,107,242,.12); border: 1px solid rgba(184,107,242,.45); color: rgba(184,107,242,.9); }
    .recent-badge.orange { background: rgba(242,158,56,.12); border: 1px solid rgba(242,158,56,.45); color: rgba(242,158,56,.9); }
    .recent-badge.blue { background: rgba(89,153,242,.12); border: 1px solid rgba(89,153,242,.45); color: rgba(89,153,242,.9); }
    .recent-desc { font-size: 10px; color: rgba(245,232,191,.8); display: block; margin-bottom: 4px; }
    .recent-time { font-size: 9px; color: rgba(245,232,191,.45); }

    /* ── MODAL ── */
    .modal-overlay { display: none; position: fixed; inset: 0; z-index: 200;
      background: rgba(0,0,0,.62); align-items: flex-start; justify-content: center;
      padding-top: 72px; overflow-y: auto; }
    .modal-overlay.open { display: flex; }
    .modal-box { background: rgba(15,8,3,.99); border-radius: 12px; width: 960px; max-width: 96vw;
      position: relative; border: 1.5px solid rgba(242,82,46,.65); overflow: hidden; margin-bottom: 40px; }
    .modal-box.tipo-sistema { border-color: rgba(184,107,242,.65); }
    .modal-box.tipo-cambio { border-color: rgba(242,158,56,.65); }
    .modal-box.tipo-login, .modal-box.tipo-info { border-color: rgba(89,153,242,.65); }
    .modal-box.tipo-integridad { border-color: rgba(242,82,46,.65); }
    .modal-top-bar { height: 4px; }
    .modal-box.crit-critico .modal-top-bar, .modal-box.tipo-seguridad .modal-top-bar, .modal-box.tipo-integridad .modal-top-bar { background: #f2522e; }
    .modal-box.tipo-sistema .modal-top-bar { background: #b86bf2; }
    .modal-box.tipo-cambio .modal-top-bar { background: #f29e38; }
    .modal-box.tipo-login .modal-top-bar, .modal-box.tipo-info .modal-top-bar { background: #5999f2; }
    .modal-header { background: rgba(242,82,46,.08); padding: 14px 20px;
      display: flex; align-items: center; gap: 12px; border-bottom: 1px solid rgba(242,82,46,.3); }
    .modal-box.tipo-sistema .modal-header { background: rgba(184,107,242,.08); border-bottom-color: rgba(184,107,242,.3); }
    .modal-box.tipo-cambio .modal-header { background: rgba(242,158,56,.08); border-bottom-color: rgba(242,158,56,.3); }
    .modal-box.tipo-login .modal-header, .modal-box.tipo-info .modal-header { background: rgba(89,153,242,.08); border-bottom-color: rgba(89,153,242,.3); }
    .modal-title { font-weight: 700; font-size: 15px; color: #ffe066; flex: 1; }
    .modal-crit-badge { padding: 3px 14px; border-radius: 11px; font-weight: 700; font-size: 9px; }
    .modal-close { width: 24px; height: 24px; background: rgba(245,232,191,.1);
      border: 1px solid rgba(245,232,191,.3); border-radius: 7px; cursor: pointer;
      display: flex; align-items: center; justify-content: center; color: rgba(245,232,191,.5);
      font-size: 12px; font-weight: 700; font-family: 'Inter', sans-serif; transition: background .2s; }
    .modal-close:hover { background: rgba(242,82,46,.2); color: #f2522e; border-color: rgba(242,82,46,.5); }
    .modal-note { padding: 8px 20px; font-size: 10px; color: rgba(245,232,191,.45);
      border-bottom: 2px solid rgba(242,82,46,.25); }
    .modal-box.tipo-sistema .modal-note { border-bottom-color: rgba(184,107,242,.25); }
    .modal-box.tipo-cambio .modal-note { border-bottom-color: rgba(242,158,56,.25); }
    .modal-box.tipo-login .modal-note, .modal-box.tipo-info .modal-note { border-bottom-color: rgba(89,153,242,.25); }
    .modal-body { padding: 20px; display: grid; grid-template-columns: 1fr 1fr; gap: 0; }
    .modal-field { padding: 16px 16px; border-bottom: 1px solid rgba(217,173,38,.08); }
    .modal-field:nth-last-child(-n+2) { border-bottom: none; }
    .modal-field-label { font-size: 9px; color: rgba(245,232,191,.45); margin-bottom: 4px; }
    .modal-field-value { font-weight: 700; font-size: 11px; color: rgba(245,232,191,.9); }
    .modal-field-value.critico { color: rgba(242,82,46,.9); }
    .modal-field-value.advertencia { color: rgba(242,158,56,.9); }
    .modal-field-value.info-val { color: rgba(89,153,242,.9); }
    .modal-desc-section { padding: 0 20px 20px; grid-column: 1 / -1; }
    .modal-desc-label { font-size: 9px; color: rgba(245,232,191,.45); margin-bottom: 6px; }
    .modal-desc-box { background: rgba(15,8,3,.85); border: 1px solid rgba(242,82,46,.2);
      border-radius: 6px; padding: 10px 14px; font-size: 10px; color: rgba(245,232,191,.8);
      line-height: 1.5; min-height: 44px; }
    .modal-box.tipo-sistema .modal-desc-box { border-color: rgba(184,107,242,.2); }
    .modal-box.tipo-cambio .modal-desc-box { border-color: rgba(242,158,56,.2); }
    .modal-box.tipo-login .modal-desc-box, .modal-box.tipo-info .modal-desc-box { border-color: rgba(89,153,242,.2); }
    .modal-footer { margin: 0 20px 20px; background: rgba(89,153,242,.06); border-radius: 8px;
      padding: 8px 14px; display: flex; align-items: center; gap: 8px; }
    .modal-footer-bar { width: 3px; height: 28px; background: rgba(89,153,242,.6); border-radius: 2px; flex-shrink: 0; }
    .modal-footer-text { font-size: 11px; color: rgba(245,232,191,.65); }
    .modal-sep { height: 1px; background: rgba(217,173,38,.2); margin: 0 20px 16px; }

    /* ── RESPONSIVE ── */
    @media (max-width: 1100px) {
      .table-header-row, .table-row { grid-template-columns: 55px 110px 100px 80px 1fr 80px 95px 0 65px; }
      .table-header-cell:nth-child(8), .table-cell:nth-child(8) { display: none; }
    }
    @media (max-width: 900px) {
      .nav-links { display: none; }
      .nav-hamburger { display: flex; align-items: center; }
      .nav-badge { display: none; }
      .stats-row { gap: 10px; }
      .stat-card { min-width: 130px; }
      .table-header-row, .table-row { grid-template-columns: 50px 100px 90px 80px 1fr 85px 65px; }
      .table-header-cell:nth-child(7), .table-cell:nth-child(7),
      .table-header-cell:nth-child(8), .table-cell:nth-child(8) { display: none; }
      .modal-body { grid-template-columns: 1fr; }
    }
    @media (max-width: 600px) {
      .main-content { padding: 0 12px 30px; }
      .navbar { padding: 0 16px; }
      .stats-row { gap: 8px; }
      .stat-card { min-width: 120px; }
      .stat-number { font-size: 20px; }
      .filters-bar { gap: 6px; }
      .filter-search { min-width: 100%; }
      .table-header-row, .table-row { grid-template-columns: 50px 1fr 80px 65px; }
      .table-header-cell:nth-child(3), .table-cell:nth-child(3),
      .table-header-cell:nth-child(4), .table-cell:nth-child(4),
      .table-header-cell:nth-child(6), .table-cell:nth-child(6),
      .table-header-cell:nth-child(7), .table-cell:nth-child(7),
      .table-header-cell:nth-child(8), .table-cell:nth-child(8) { display: none; }
      .recent-events { flex-direction: column; }
    }

    .filter-date {
    background: rgba(15,8,3,.90);
    border: 1px solid rgba(217,173,38,.3);
    border-radius: 7px;
    padding: 0 10px;
    height: 34px;
    color: rgba(245,232,191,.65);
    font-size: 10px;
    font-family: 'Inter', sans-serif;
    cursor: pointer;
    color-scheme: dark;  /* hace que el calendario del browser use tema oscuro */
    min-width: 130px;
}
.filter-date::-webkit-calendar-picker-indicator {
    filter: invert(0.7) sepia(1) saturate(3) hue-rotate(5deg);  /* lo vuelve dorado */
    cursor: pointer;
}



  </style>
</head>
<body>
    <form id="frmBitacora" runat="server">
<div class="page">
  <div class="bg-stripes" aria-hidden="true"></div>
  <div class="bg-vignette" aria-hidden="true"></div>
  <div class="bg-glow"    aria-hidden="true"></div>
  <div class="bg-sides"   aria-hidden="true"></div>
  <div class="border-frame" aria-hidden="true"></div>

  <!-- NAVBAR -->
  <nav class="navbar">
    <div class="nav-brand">
      <span class="nav-brand-name">SQUAMA</span>
      <span class="nav-brand-sub">Forjá tu Leyenda</span>
    </div>
    <span class="nav-badge">WEBMASTER</span>
    <div class="nav-links">
      <a href="HomeWebmaster.aspx"      class="nav-link">Inicio</a>
      <a href="EnConstruccionWebmaster.aspx"    class="nav-link">Usuarios</a>
      <a href="BitacoraEventos.aspx"    class="nav-link active">Bitácora</a>
      <a href="EnConstruccionWebmaster.aspx"            class="nav-link">Sistema</a>
      <a href="EnConstruccionWebmaster.aspx"          class="nav-link">Seguridad</a>
    </div>
    <div class="nav-right">
      <div class="nav-avatar">W</div>
      <div class="nav-user">
        <span class="nav-user-name">Webmaster</span>
        <span class="nav-user-role">WEBMASTER</span>
      </div>
      <button class="nav-logout" onclick="location.href='Login.aspx'">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
          <polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/>
        </svg>
        <span>Salir</span>
      </button>
    </div>
    <button class="nav-hamburger" onclick="toggleMenu()" aria-label="Menú">&#9776;</button>
  </nav>
  <div class="nav-menu-mobile" id="mobileMenu">
    <a href="HomeWebmaster.aspx"    class="nav-link">Inicio</a>
    <a href="EnConstruccionWebmaster.aspx"  class="nav-link">Usuarios</a>
    <a href="BitacoraEventos.aspx"  class="nav-link active">Bitácora</a>
    <a href="EnConstruccionWebmaster.aspx"          class="nav-link">Sistema</a>
    <a href="EnConstruccionWebmaster.aspx"        class="nav-link">Seguridad</a>
  </div>

  <!-- CONTENIDO -->
  <main class="main-content">

    <!-- HEADER -->
    <header class="page-header">
      <div class="page-badge">BITÁCORA DE EVENTOS</div>
      <h1 class="page-title">Bitácora de Eventos</h1>
      <p class="page-subtitle">Consultá accesos, errores, cambios críticos y acciones registradas en el sistema.</p>
      <div class="header-sep"></div>
      <div class="header-sep2"></div>
    </header>

    <!-- STATS -->
    <div class="stats-row">
      <div class="stat-card blue">
        <span class="stat-number"><asp:Label ID="lblEventosHoy" runat="server" Text="0" /></span>
        <span class="stat-label">Eventos hoy</span>
        <span class="stat-badge">activo</span>
      </div>
      <div class="stat-card red">
        <span class="stat-number"><asp:Label ID="lblAlertas" runat="server" Text="0" /></span>
        <span class="stat-label">Alertas críticas</span>
        <span class="stat-badge">activo</span>
      </div>
      <div class="stat-card orange">
        <span class="stat-number"><asp:Label ID="lblFallidos" runat="server" Text="0" /></span>
        <span class="stat-label">Intentos fallidos</span>
        <span class="stat-badge">activo</span>
      </div>
      <div class="stat-card purple">
        <span class="stat-number"><asp:Label ID="lblSeguridad" runat="server" Text="0" /></span>
        <span class="stat-label">Cambios seguridad</span>
        <span class="stat-badge">activo</span>
      </div>
      <div class="stat-card green">
        <span class="stat-number"><asp:Label ID="lblUltimoEvento" runat="server" Text="—" /></span>
        <span class="stat-label">Último evento</span>
        <span class="stat-badge">activo</span>
      </div>
    </div>

    <!-- FILTROS -->
    <div class="filters-bar">
      <input type="text" class="filter-search" placeholder="Buscar descripción, usuario o ID..."
             id="txtBuscar" runat="server" />
      <input type="date" class="filter-date" id="txtFechaDesde" runat="server" />
        <input type="date" class="filter-date" id="txtFechaHasta" runat="server" />

      <asp:DropDownList ID="ddlUsuario" runat="server" CssClass="filter-select" >
              <asp:ListItem Value="" Text="Usuario" />
            </asp:DropDownList>

        <asp:DropDownList ID="ddlCriticidad" runat="server" CssClass="filter-select" >
                <asp:ListItem Value="" Text="Criticidad" />
            </asp:DropDownList>

         <asp:DropDownList ID="ddlModulo" runat="server" CssClass="filter-select">
                <asp:ListItem Value="" Text="Modulo" />
            </asp:DropDownList>

      <asp:Button ID="btnBuscar"   runat="server" Text="Buscar"    CssClass="btn-buscar"   OnClick="BtnBuscar_Click" />
      <asp:Button ID="btnLimpiar"  runat="server" Text="Limpiar"   CssClass="btn-limpiar"  OnClick="BtnLimpiar_Click" />
      <asp:Button ID="btnExportar" runat="server" Text="Exportar"  CssClass="btn-exportar" OnClick="BtnExportar_Click" />
    </div>

    <!-- TABLA -->
    <div class="table-container">
      <div class="table-header-row">
        <div class="table-header-cell">ID</div>
        <div class="table-header-cell">Fecha/Hora</div>
        <div class="table-header-cell">Usuario</div>
        <div class="table-header-cell">Tipo</div>
        <div class="table-header-cell">Descripción</div>
        <div class="table-header-cell">Criticidad</div>
        <div class="table-header-cell">IP Origen</div>
        <div class="table-header-cell">Acciones</div>
      </div>
      <div class="table-body" id="tableBody">
        <asp:Repeater ID="rptEventos" runat="server">
         

            <ItemTemplate>
  <div class="table-row"
       data-id="<%# Eval("IDEvento") %>"
       data-fecha="<%# Eval("FechaHora", "{0:dd/MM/yyyy HH:mm:ss}") %>"
       data-usuario="<%# Eval("NombreUsuario") %>"
       data-tipo="<%# Eval("TipoEvento") %>"
       data-descripcion="<%# Eval("Descripcion") %>"
       data-criticidad="<%# Eval("Criticidad") %>"
       data-ip="<%# Eval("IPOrigen") %>"
       data-modulo="<%# Eval("ModuloRelacionado") %>">
    <div class="table-cell id"><%# Eval("IDEvento") %></div>
    <div class="table-cell"><%# Eval("FechaHora", "{0:dd/MM HH:mm}") %></div>
    <div class="table-cell usuario"><%# Eval("NombreUsuario") %></div>
    <div class="table-cell">
      <span class="tipo-badge tipo-<%# Eval("TipoEvento").ToString().ToLower() %>">
        <%# Eval("TipoEvento") %>
      </span>
    </div>
    <div class="table-cell descripcion"><%# Eval("Descripcion") %></div>
    <div class="table-cell">
      <span class="crit-badge crit-<%# Eval("Criticidad").ToString().ToLower() %>">
        <%# Eval("Criticidad") %>
      </span>
    </div>
    <div class="table-cell ip"><%# Eval("IPOrigen") %></div>
    <div class="table-cell">
      <button type="button" class="btn-ver"
              onclick="abrirDetalle(this.closest('.table-row'))">Ver</button>
    </div>
  </div>
</ItemTemplate>










        </asp:Repeater>
        <asp:Panel ID="pnlEmpty" runat="server" CssClass="table-empty">
          No hay eventos registrados para el período seleccionado.
        </asp:Panel>
      </div>
      <!-- Paginacion -->
      <div class="pagination-row">
        <span class="pagination-info">
          <asp:Label ID="lblPaginacionInfo" runat="server" Text="" />
        </span>
        <div class="pagination-btns" id="paginacionBtns">
          <button class="pg-btn" id="btnPrimera" onclick="irPagina(1)" title="Primera">&laquo;</button>
          <button class="pg-btn" id="btnAnterior" onclick="irPaginaAnterior()" title="Anterior">&lt;</button>
          <span id="pgNums"></span>
          <button class="pg-btn" id="btnSiguiente" onclick="irPaginaSiguiente()" title="Siguiente">&gt;</button>
          <button class="pg-btn" id="btnUltima" onclick="irPaginaUltima()" title="Última">&raquo;</button>
        </div>
      </div>
    </div>

    <!-- ULTIMOS EVENTOS RELEVANTES -->
    <div class="section-sep"></div>
    <div class="section-title">Últimos eventos relevantes</div>
    <div class="recent-events" id="recentEvents">
      <asp:Repeater ID="rptRecientes" runat="server">
        <ItemTemplate>
          <div class="recent-card <%# GetColorClass(Eval("Criticidad").ToString(), Eval("TipoEvento").ToString()) %>">
            <span class="recent-badge <%# GetColorClass(Eval("Criticidad").ToString(), Eval("TipoEvento").ToString()) %>">
              <%# Eval("TipoEvento") %>
            </span>
            <span class="recent-desc"><%# Eval("Descripcion") %></span>
            <span class="recent-time"><%# Eval("TiempoRelativo") %></span>
          </div>
        </ItemTemplate>
      </asp:Repeater>
    </div>

  </main>
</div><!-- /.page -->

<!-- MODAL DETALLE -->
<div class="modal-overlay" id="modalOverlay" onclick="cerrarModalOverlay(event)">
  <div class="modal-box" id="modalBox">
    <div class="modal-top-bar" id="modalTopBar"></div>
    <div class="modal-header" id="modalHeader">
      <span class="modal-title" id="modalTitle">Detalle de evento</span>
      <span class="modal-crit-badge crit-badge crit-critico" id="modalCritBadge"></span>
      <button class="modal-close" onclick="cerrarModal()">x</button>
    </div>
    <p class="modal-note">Solo lectura &mdash; los eventos de bitácora no pueden modificarse ni eliminarse.</p>
    <div class="modal-body">
      <div class="modal-field">
        <div class="modal-field-label">ID del evento</div>
        <div class="modal-field-value" id="mId"></div>
      </div>
      <div class="modal-field">
        <div class="modal-field-label">Fecha y hora</div>
        <div class="modal-field-value" id="mFecha"></div>
      </div>
      <div class="modal-field">
        <div class="modal-field-label">Usuario asociado</div>
        <div class="modal-field-value" id="mUsuario"></div>
      </div>
      <div class="modal-field">
        <div class="modal-field-label">Tipo de evento</div>
        <div class="modal-field-value" id="mTipo"></div>
      </div>
      <div class="modal-field">
        <div class="modal-field-label">ID Registro afectado</div>
        <div class="modal-field-value" id="mIdRegistro"></div>
      </div>
      <div class="modal-field">
        <div class="modal-field-label">Criticidad</div>
        <div class="modal-field-value" id="mCriticidad"></div>
      </div>
      <div class="modal-field">
        <div class="modal-field-label">IP de origen</div>
        <div class="modal-field-value" id="mIp"></div>
      </div>
      <div class="modal-field" style="border-bottom:none;">
        <div class="modal-field-label">Módulo relacionado</div>
        <div class="modal-field-value" id="mModulo"></div>
      </div>
      <div class="modal-field" style="border-bottom:none;"></div>
    </div>
    <div class="modal-desc-section">
      <div class="modal-sep"></div>
      <div class="modal-desc-label">Descripción completa</div>
      <div class="modal-desc-box" id="mDescripcion"></div>
    </div>
    <div class="modal-footer">
      <div class="modal-footer-bar"></div>
      <span class="modal-footer-text">Registrado automáticamente. No requiere acción desde esta vista.</span>
    </div>
  </div>
</div>

<script>
  /* ── HAMBURGER ── */
  function toggleMenu() {
    document.getElementById('mobileMenu').classList.toggle('open');
  }

  /* ── PAGINACION ── */
  const ROWS_PER_PAGE = 10;
  let currentPage = 1;
  let allRows = [];
  let totalRows = 0;
  let totalPages = 1;

  function initPaginacion() {
    allRows = Array.from(document.querySelectorAll('.table-body .table-row'));
    totalRows = allRows.length;
    totalPages = Math.max(1, Math.ceil(totalRows / ROWS_PER_PAGE));
    mostrarPagina(1);
  }

  function mostrarPagina(page) {
    currentPage = page;
    const start = (page - 1) * ROWS_PER_PAGE;
    const end   = start + ROWS_PER_PAGE;
    allRows.forEach((row, i) => {
      row.style.display = (i >= start && i < end) ? '' : 'none';
    });
    actualizarControles();
  }

  function actualizarControles() {
    document.getElementById('btnPrimera').disabled   = currentPage === 1;
    document.getElementById('btnAnterior').disabled  = currentPage === 1;
    document.getElementById('btnSiguiente').disabled = currentPage === totalPages;
    document.getElementById('btnUltima').disabled    = currentPage === totalPages;
    const container = document.getElementById('pgNums');
    container.innerHTML = '';
    let start = Math.max(1, currentPage - 2);
    let end   = Math.min(totalPages, start + 4);
    start = Math.max(1, end - 4);
    if (start > 1) {
      container.appendChild(crearBtnPag(1));
      if (start > 2) container.appendChild(crearSep('...'));
    }
    for (let p = start; p <= end; p++) container.appendChild(crearBtnPag(p));
    if (end < totalPages) {
      if (end < totalPages - 1) container.appendChild(crearSep('...'));
      container.appendChild(crearBtnPag(totalPages));
    }
  }

  function crearBtnPag(p) {
    const b = document.createElement('button');
    b.className = 'pg-btn' + (p === currentPage ? ' active' : '');
    b.textContent = p;
    b.onclick = () => irPagina(p);
    return b;
  }
  function crearSep(t) {
    const s = document.createElement('button');
    s.className = 'pg-btn'; s.textContent = t; s.disabled = true; return s;
  }

  function irPagina(p)        { if (p >= 1 && p <= totalPages) mostrarPagina(p); }
  function irPaginaAnterior() { irPagina(currentPage - 1); }
  function irPaginaSiguiente(){ irPagina(currentPage + 1); }
  function irPaginaUltima()   { irPagina(totalPages); }

  /* ── MODAL ── */
  const critColors = {
    'CRITICO':    { badge: 'crit-critico',    text: 'critico' },
    'ADVERTENCIA':{ badge: 'crit-advertencia', text: 'advertencia' },
    'INFO':       { badge: 'crit-info',        text: 'info-val' },
    'SISTEMA':    { badge: 'crit-sistema',     text: 'info-val' }
  };
  const tipoClass = {
    'SISTEMA':   'tipo-sistema',
    'SEGURIDAD': 'tipo-seguridad',
    'CAMBIO':    'tipo-cambio',
    'LOGIN':     'tipo-login',
    'INTEGRIDAD':'tipo-integridad',
    'INFO':      'tipo-info'
  };

  function abrirDetalle(row) {
    const d = row.dataset;
    const crit = (d.criticidad || 'INFO').toUpperCase();
    const tipo = (d.tipo || '').toUpperCase();

    document.getElementById('mId').textContent         = d.id || '—';
    document.getElementById('mFecha').textContent       = d.fecha || '—';
    document.getElementById('mUsuario').textContent     = d.usuario || '—';
    document.getElementById('mTipo').textContent        = d.tipo || '—';
    document.getElementById('mIdRegistro').textContent  = d.idRegistro || '—';
    document.getElementById('mIp').textContent          = d.ip || '—';
    document.getElementById('mModulo').textContent      = d.modulo || '—';
    document.getElementById('mDescripcion').textContent = d.descripcion || '—';

    const critData = critColors[crit] || { badge: 'crit-info', text: 'info-val' };
    const mCrit = document.getElementById('mCriticidad');
    mCrit.textContent = crit;
    mCrit.className = 'modal-field-value ' + critData.text;

    document.getElementById('modalTitle').textContent = 'Detalle de evento — ' + (d.id || '');

    const badge = document.getElementById('modalCritBadge');
    badge.textContent = crit;
    badge.className = 'modal-crit-badge crit-badge ' + critData.badge;

    const box = document.getElementById('modalBox');
    box.className = 'modal-box ' + (tipoClass[tipo] || '') + ' ' + (critData.badge === 'crit-critico' ? 'crit-critico' : '');

    document.getElementById('modalOverlay').classList.add('open');
    document.body.style.overflow = 'hidden';
  }

  function cerrarModal() {
    document.getElementById('modalOverlay').classList.remove('open');
    document.body.style.overflow = '';
  }

  function cerrarModalOverlay(e) {
    if (e.target === document.getElementById('modalOverlay')) cerrarModal();
  }

  document.addEventListener('keydown', e => { if (e.key === 'Escape') cerrarModal(); });

  /* ── INIT ── */
  window.addEventListener('DOMContentLoaded', initPaginacion);
</script>
        </form> 
</body>
</html>
