<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BitacoraEventos.aspx.cs" Inherits="PylinskiCuello_ProyectoWeb.BitacoraEventos" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>SQUAMA — Bitácora de Eventos</title>
  <link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@400;600;700;900&family=IM+Fell+English:ital@0;1&family=Inter:wght@400;700&display=swap" rel="stylesheet" />
  <link rel="stylesheet" href="Styles/base.css" />
  <link rel="stylesheet" href="Styles/navbar.css" />
  <link rel="stylesheet" href="Styles/bitacora.css" />
  <style>
    :root {
      --c-role:        #b86bf2;
      --c-role-border: rgba(184,107,242,.70);
      --c-role-bg:     rgba(184,107,242,.20);
      --glow-bg:       rgba(184,107,242,.25);
    }
    .nav-avatar {
      background: linear-gradient(135deg, rgba(184,107,242,.8), rgba(92,54,121,.8));
      color: #fff;
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

  <div class="content">
  <!-- NAVBAR -->
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
      <a href="BitacoraEventos.aspx" class="active">Bit&aacute;cora</a>
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
      <button class="nav-logout" onclick="location.href='Login.aspx'">Salir</button>
    </div>
    <div class="nav-dropdown" id="navDropdown">
      <a href="HomeWebmaster.aspx">Inicio</a>
      <a href="EnConstruccionWebmaster.aspx">Usuarios</a>
      <a href="EnConstruccionWebmaster.aspx">Perfiles</a>
      <a href="BitacoraEventos.aspx" class="active">Bit&aacute;cora</a>
      <a href="EnConstruccionWebmaster.aspx">Backup / Restore</a>
      <a href="EnConstruccionWebmaster.aspx">Seguridad</a>
    </div>
  </nav>

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
        <span class="stat-number"><asp:Label ID="lblUltimoEvento" runat="server" Text="N/D" /></span>
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
          <button type="button" class="pg-btn" id="btnPrimera" onclick="irPagina(1)" title="Primera">&laquo;</button>
          <button type="button" class="pg-btn" id="btnAnterior" onclick="irPaginaAnterior()" title="Anterior">&lt;</button>
          <span id="pgNums"></span>
          <button type="button" class="pg-btn" id="btnSiguiente" onclick="irPaginaSiguiente()" title="Siguiente">&gt;</button>
          <button type="button" class="pg-btn" id="btnUltima" onclick="irPaginaUltima()" title="Última">&raquo;</button>
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
  </div><!-- /.content -->
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
  function toggleNav() {
    document.getElementById('navDropdown').classList.toggle('open');
  }
  document.addEventListener('click', function(e) {
    if (!e.target.closest('.navbar')) {
      document.getElementById('navDropdown').classList.remove('open');
    }
  });

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
    b.type = 'button';
    b.className = 'pg-btn' + (p === currentPage ? ' active' : '');
    b.textContent = p;
    b.onclick = () => irPagina(p);
    return b;
  }
  function crearSep(t) {
    const s = document.createElement('button');
    s.type = 'button';
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

    document.getElementById('mId').textContent         = d.id || 'N/D';
    document.getElementById('mFecha').textContent       = d.fecha || 'N/D';
    document.getElementById('mUsuario').textContent     = d.usuario || 'N/D';
    document.getElementById('mTipo').textContent        = d.tipo || 'N/D';
    document.getElementById('mIdRegistro').textContent  = d.idRegistro || 'N/D';
    document.getElementById('mIp').textContent          = d.ip || 'N/D';
    document.getElementById('mModulo').textContent      = d.modulo || 'N/D';
    document.getElementById('mDescripcion').textContent = d.descripcion || 'N/D';

    const critData = critColors[crit] || { badge: 'crit-info', text: 'info-val' };
    const mCrit = document.getElementById('mCriticidad');
    mCrit.textContent = crit;
    mCrit.className = 'modal-field-value ' + critData.text;

    document.getElementById('modalTitle').textContent = 'Detalle de evento - ' + (d.id || '');

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
