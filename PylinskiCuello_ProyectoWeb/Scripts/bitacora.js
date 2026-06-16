/* ============================================================
   bitacora.js — BitacoraEventos pagination and modal logic
   ============================================================ */

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
