<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BackUpYRestore.aspx.cs" Inherits="PylinskiCuello_ProyectoWeb.BackUpYRestore" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml" lang="es">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Backup y Restore — SQUAMA</title>
    <link rel="stylesheet" href="Styles/BackUpYRestore.css" />
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

<div class="page">

  <!-- BG glow -->
  <div class="bg-glow" aria-hidden="true"></div>

  <!-- ═══════════════════════════════════════════════════
       NAVBAR
  ═══════════════════════════════════════════════════ -->
  <nav class="navbar">
    <div class="navbar-brand">
      <span class="navbar-logo-name">SQUAMA</span>
      <span class="navbar-logo-sub">Forjá tu Leyenda</span>
    </div>

    <div class="navbar-badge"><span>WEBMASTER</span></div>

    <!-- Hamburger para mobile -->
    <button class="navbar-hamburger" type="button" onclick="toggleMenu(this)" aria-label="Menú">&#9776;</button>

    <div class="navbar-links" id="navLinks">
      <a href="HomeWebmaster.aspx">Inicio</a>
      <a href="EnConstruccionWebmaster.aspx">Usuarios</a>
        <a href="BitacoraEventos.aspx">Bit&aacute;cora</a>
        <a href="BackUpYRestore.aspx">Backup/Restore</a>
        <a href="EnConstruccionWebmaster.aspx">Seguridad</a>
    </div>

    <div class="navbar-user">
      <div class="navbar-avatar">W</div>
      <div>
        <div class="navbar-user-name">Webmaster</div>
        <div class="navbar-user-role">WEBMASTER</div>
      </div>
    </div>
  </nav>

  <!-- ═══════════════════════════════════════════════════
       CONTENIDO PRINCIPAL
  ═══════════════════════════════════════════════════ -->
  <div class="main-content">

    <!-- PAGE HEADER -->
    <div class="page-header">
      <div class="page-badge">BACKUP Y RESTORE</div>
      <h1 class="page-title">Backup y Restore</h1>
      <p class="page-sub">Gestioná copias de seguridad y restauraciones controladas del sistema.</p>
      <div class="page-divider-1"></div>
      <div class="page-divider-2"></div>
    </div>

    <!-- STAT CARDS -->
    <div class="stat-cards">

      <div class="stat-card card-green">
        <div class="stat-card-shadow"></div>
        <span class="stat-value">Hoy 03:00</span>
        <span class="stat-label">Último backup</span>
      </div>

      <div class="stat-card card-blue">
        <div class="stat-card-shadow"></div>
        <span class="stat-value">14</span>
        <span class="stat-label">Backups disponibles</span>
      </div>

      <div class="stat-card card-orange">
        <div class="stat-card-shadow"></div>
        <span class="stat-value">23/04</span>
        <span class="stat-label">Último restore</span>
      </div>

      <div class="stat-card card-green">
        <div class="stat-card-shadow"></div>
        <span class="stat-value">OK</span>
        <span class="stat-label">Estado sistema</span>
      </div>

      <div class="stat-card card-gold">
        <div class="stat-card-shadow"></div>
        <span class="stat-value">4.2 GB</span>
        <span class="stat-label">Espacio utilizado</span>
      </div>

      <div class="stat-card card-green">
        <div class="stat-card-shadow"></div>
        <span class="stat-value">OK</span>
        <span class="stat-label">Última verif. DV</span>
      </div>

    </div>

    <!-- PANELS ROW -->
    <div class="panels-row">

<!-- PANEL: Crear nueva copia de seguridad -->
<div class="panel panel-green">
  <div class="panel-top-bar"></div>
  <div class="panel-header">
    <span class="panel-title">Crear nueva copia de seguridad</span>
    <span class="panel-badge">Acción segura</span>
  </div>
  <div class="panel-divider"></div>
  <div class="panel-body">

    <div class="field">
      <label for="txtNombreArchivo">Nombre del archivo *</label>
      <input type="text" id="txtNombreArchivo" runat="server"
             placeholder="backup_squama_20260510"
             class="input-field" />
    </div>

    <div class="field">
      <label for="txtRutaDestino">Ruta de destino *</label>
      <div class="input-with-btn">
        <input type="text" id="txtRutaDestino" runat="server"
               placeholder="Ej: C:\Backups\Squama"
               class="input-field" />
        <button type="button" class="btn-browse"
                onclick="explorarCarpeta()">📁 Explorar</button>
      </div>
      <span class="field-hint">
        Ingresá la ruta completa o usá Explorar para elegir la carpeta.
      </span>
    </div>

    <div class="field">
      <label for="txtObservacion">Observación</label>
      <textarea id="txtObservacion" runat="server"
                placeholder="Backup programado automático diario."
                class="input-field"></textarea>
    </div>

    <!-- Mensaje de resultado -->
    <div id="divMensajeBackup" runat="server"
         class="msg-backup" style="display:none;"></div>

    <div class="inner-divider"></div>

    <asp:Button ID="btnGenerarBackup" runat="server"
                Text="Generar Backup"
                CssClass="btn-backup"
                OnClick="btnGenerarBackup_Click" />

  </div>
</div>
       <!-- MODIFIQUE ACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA -->  
     <!-- PANEL: Restaurar base de datos -->
<div class="panel panel-red">
  <div class="panel-top-bar"></div>
  <div class="panel-header">
    <span class="panel-title">Restaurar base de datos</span>
    <span class="panel-badge">Acción crítica</span>
  </div>
  <div class="panel-divider"></div>
  <div class="panel-body">

    <!-- INPUT FILE oculto — se activa con el botón "Seleccionar backup" -->
    <input type="file" id="filePickerBAK" class="file-input-hidden"
           accept=".bak" onchange="mostrarArchivoSeleccionado(this)" />

    <div class="field">
      <label>Seleccionar backup (.bak)</label>
      <div class="input-file-display">
        <input type="text" id="txtArchivoBAKDisplay"
               class="input-field" readonly="readonly"
               placeholder="Ningún archivo seleccionado..." />
        <button type="button" class="btn-file-pick"
                onclick="document.getElementById('filePickerBAK').click()">
          📂 Seleccionar
        </button>
      </div>
    </div>

    <!-- Campo oculto que guarda la ruta real para el servidor -->
    <input type="hidden" id="hdnRutaBAK" runat="server" />

    <div class="field">
      <label for="txtMotivoRestore">Motivo del restore *</label>
      <textarea id="txtMotivoRestore" runat="server"
                placeholder="Indicar motivo..."
                class="input-field"></textarea>
    </div>

    <!-- Mensaje resultado -->
    <div id="divMensajeRestore" runat="server"
         class="msg-restore" style="display:none;"></div>

    <div class="warn-box">
      <div class="warn-bar"></div>
      <span class="warn-text">
        Restaurar reemplaza la BD actual. Acción irreversible.
        Se solicitará confirmación antes de ejecutar.
      </span>
    </div>

    <div class="inner-divider"></div>

    <button type="button" class="btn-restore"
            onclick="abrirModalRestore()">
      Iniciar Restore
    </button>

  </div>
</div>

</div>
      </div><!-- .page -->

             <!-- MODIFIQUE ACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA -->  

    <!-- TABS -->
    <div class="tabs-row">
      <button class="tab active" type="button">Backups realizados</button>
      <button class="tab"        type="button">Restores realizados</button>
    </div>

    <!-- TABLE -->
    <div class="table-wrap">
      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>Archivo</th>
            <th>Fecha</th>
            <th>Ejecutado por</th>
            <th>Estado</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>B014</td>
            <td class="td-filename">backup_squama_20260510_0300</td>
            <td>backup_squama_20260510_0300</td>
            <td class="td-user">sistema</td>
            <td><span class="badge badge-green">COMPLETADO</span></td>
            <td>
              <div class="actions">
                <button class="btn-action btn-ver"       type="button">Ver</button>
                <button class="btn-action btn-restaurar" type="button">Restaurar</button>
              </div>
            </td>
          </tr>
          <tr>
            <td>B013</td>
            <td class="td-filename">backup_squama_20260509_0300</td>
            <td>backup_squama_20260509_0300</td>
            <td class="td-user">sistema</td>
            <td><span class="badge badge-green">COMPLETADO</span></td>
            <td>
              <div class="actions">
                <button class="btn-action btn-ver"       type="button">Ver</button>
                <button class="btn-action btn-restaurar" type="button">Restaurar</button>
              </div>
            </td>
          </tr>
          <tr>
            <td>B012</td>
            <td class="td-filename">backup_manual_20260505</td>
            <td>backup_manual_20260505</td>
            <td class="td-user">webmaster</td>
            <td><span class="badge badge-green">COMPLETADO</span></td>
            <td>
              <div class="actions">
                <button class="btn-action btn-ver"       type="button">Ver</button>
                <button class="btn-action btn-restaurar" type="button">Restaurar</button>
              </div>
            </td>
          </tr>
          <tr>
            <td>B011</td>
            <td class="td-filename">backup_squama_20260504_0300</td>
            <td>backup_squama_20260504_0300</td>
            <td class="td-user">sistema</td>
            <td><span class="badge badge-red">FALLIDO</span></td>
            <td>
              <div class="actions">
                <button class="btn-action btn-ver"       type="button">Ver</button>
                <button class="btn-action btn-restaurar" type="button">Restaurar</button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

  </div><!-- .main-content -->








      <!-- ═══════════════════════════════════════════════════
     MODAL CONFIRMACIÓN RESTORE
═══════════════════════════════════════════════════ -->
<div class="modal-overlay" id="modalRestoreOverlay">
  <div class="modal-restore">

    <div class="modal-header">
      <span class="modal-icon">⚠️</span>
      <div class="modal-header-text">
        <h2>Confirmar Restore</h2>
        <p>Esta acción reemplazará la base de datos actual. Es irreversible.</p>
      </div>
    </div>

    <div class="modal-body">

      <!-- Resumen -->
      <div class="modal-summary">
        <div class="modal-summary-row">
          <span class="lbl">Archivo:</span>
          <span class="val" id="modalNombreArchivo">—</span>
        </div>
        <div class="modal-summary-row">
          <span class="lbl">Motivo:</span>
          <span class="val" id="modalMotivo">—</span>
        </div>
      </div>

      <!-- Advertencia -->
      <div class="modal-warn">
        <div class="modal-warn-bar"></div>
        <span class="modal-warn-text">
          ⛔ Esta operación pondrá la BD en modo exclusivo, ejecutará el restore
          y sobrescribirá todos los datos actuales. No se puede deshacer.
        </span>
      </div>

      <!-- Campo de confirmación -->
      <label class="modal-confirm-label">
        Para confirmar, escribí exactamente:
        <span>RESTAURAR</span>
      </label>
      <input type="text" class="modal-confirm-input"
             id="inputConfirmacion"
             placeholder="Escribí RESTAURAR para habilitar..."
             oninput="verificarConfirmacion(this)" />

    </div>

    <div class="modal-footer">
      <button type="button" class="btn-modal-cancelar"
              onclick="cerrarModalRestore()">
        Cancelar
      </button>

      <!-- ══════════════════════════════════════════════════
           BOTÓN CONFIRMAR RESTORE — dispara el PostBack
           al servidor y ejecuta btnConfirmarRestore_Click
      ══════════════════════════════════════════════════ -->
      <asp:Button ID="btnConfirmarRestore" runat="server"
                  Text="⚡ Confirmar Restore"
                  CssClass="btn-modal-confirmar"
                  OnClick="btnConfirmarRestore_Click"
                  OnClientClick="return prepararRestore()" />
      <!-- ══════════════════════════════════════════════════
           FIN BOTÓN CONFIRMAR RESTORE
      ══════════════════════════════════════════════════ -->
    </div>

  </div>
</div>





<script>
    /* ── Tabs ── */
    document.querySelectorAll('.tab').forEach(function (tab) {
        tab.addEventListener('click', function () {
            document.querySelectorAll('.tab').forEach(function (t) { t.classList.remove('active'); });
            this.classList.add('active');
        });
    });

    /* ── Hamburger ── */
    function toggleMenu(btn) {
        document.getElementById('navLinks').classList.toggle('open');
    }
    document.querySelectorAll('.navbar-links a').forEach(function (a) {
        a.addEventListener('click', function () {
            document.getElementById('navLinks').classList.remove('open');
        });
    });

    /* ── Explorador de carpetas (panel backup) ── */
    function explorarCarpeta() {
        var rutasComunes = [
            "C:\\Backups\\Squama",
            "C:\\inetpub\\backups",
            "D:\\Backups",
            "C:\\Users\\Public\\Backups"
        ];
        var html = '<div style="font-family:Inter,sans-serif;padding:20px;background:#1a0d03;' +
            'border:2px solid rgba(217,173,38,0.5);border-radius:12px;min-width:400px;">' +
            '<p style="color:#ffe066;font-weight:700;margin-bottom:12px;">Rutas sugeridas:</p>';
        rutasComunes.forEach(function (r) {
            html += '<button onclick="seleccionarRuta(\'' + r.replace(/\\/g, '\\\\') + '\')" ' +
                'style="display:block;width:100%;margin:4px 0;padding:8px 14px;' +
                'background:rgba(217,173,38,0.12);border:1px solid rgba(217,173,38,0.4);' +
                'border-radius:6px;color:rgba(245,232,191,0.8);cursor:pointer;text-align:left;font-size:12px;">' + r + '</button>';
        });
        html += '<p style="color:rgba(245,232,191,0.5);font-size:11px;margin-top:12px;">O escribí la ruta directamente.</p>' +
            '<button onclick="document.getElementById(\'modalRutas\').style.display=\'none\'" ' +
            'style="margin-top:10px;padding:6px 18px;background:rgba(242,82,46,0.3);' +
            'border:1px solid rgba(242,82,46,0.5);border-radius:6px;color:#f2522e;cursor:pointer;">Cerrar</button></div>';
        var modal = document.getElementById('modalRutas');
        if (!modal) {
            modal = document.createElement('div');
            modal.id = 'modalRutas';
            modal.style.cssText = 'position:fixed;inset:0;background:rgba(0,0,0,0.7);display:flex;align-items:center;justify-content:center;z-index:9999;';
            document.body.appendChild(modal);
        }
        modal.innerHTML = html;
        modal.style.display = 'flex';
    }
    function seleccionarRuta(ruta) {
        document.getElementById('txtRutaDestino').value = ruta;
        document.getElementById('modalRutas').style.display = 'none';
    }

    /* ══════════════════════════════════════════════════════════
       RESTORE — selector de archivo .bak
    ══════════════════════════════════════════════════════════ */
    function mostrarArchivoSeleccionado(input) {
        if (input.files && input.files.length > 0) {
            var archivo = input.files[0];
            // Muestra solo el nombre en el campo de texto
            document.getElementById('txtArchivoBAKDisplay').value = archivo.name;
            // Guarda el nombre (en web no podemos obtener la ruta completa por seguridad del navegador)
            // El usuario deberá confirmar la ruta en el modal
            document.getElementById('hdnRutaBAK').value = archivo.name;
        }
    }

    /* ══════════════════════════════════════════════════════════
       MODAL DE CONFIRMACIÓN RESTORE
    ══════════════════════════════════════════════════════════ */
    function abrirModalRestore() {
        var archivo = document.getElementById('txtArchivoBAKDisplay').value.trim();
        var motivo = document.getElementById('txtMotivoRestore').value.trim();

        if (!archivo || archivo === 'Ningún archivo seleccionado...') {
            alert('⚠️ Seleccioná un archivo .bak primero.');
            return;
        }
        if (!motivo) {
            alert('⚠️ El motivo del restore es obligatorio.');
            return;
        }

        // Rellenar resumen del modal
        document.getElementById('modalNombreArchivo').textContent = archivo;
        document.getElementById('modalMotivo').textContent = motivo;

        // Limpiar campo de confirmación
        var inputConf = document.getElementById('inputConfirmacion');
        inputConf.value = '';
        inputConf.classList.remove('correcto');

        var btnConf = document.getElementById('<%= btnConfirmarRestore.ClientID %>');
        btnConf.classList.remove('habilitado');

        // Mostrar modal
        document.getElementById('modalRestoreOverlay').classList.add('visible');
    }

    function cerrarModalRestore() {
        document.getElementById('modalRestoreOverlay').classList.remove('visible');
        document.getElementById('inputConfirmacion').value = '';
        document.getElementById('inputConfirmacion').classList.remove('correcto');
        document.getElementById('<%= btnConfirmarRestore.ClientID %>').classList.remove('habilitado');
    }

    function verificarConfirmacion(input) {
        var btnConf = document.getElementById('<%= btnConfirmarRestore.ClientID %>');
        if (input.value === 'RESTAURAR') {
            input.classList.add('correcto');
            btnConf.classList.add('habilitado');
        } else {
            input.classList.remove('correcto');
            btnConf.classList.remove('habilitado');
        }
    }

    // Se ejecuta ANTES del PostBack del botón confirmar
    function prepararRestore() {
        // Doble verificación client-side
        if (document.getElementById('inputConfirmacion').value !== 'RESTAURAR') {
            return false; // cancela el submit
        }
        return true;
    }

    // Cerrar modal con Escape
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') cerrarModalRestore();
    });
</script>

</form>
</body>
</html>