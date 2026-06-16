<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="HomeWebmaster.aspx.cs" Inherits="PylinskiCuello_ProyectoWeb.HomeWebmaster" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>SQUAMA &mdash; Panel Webmaster</title>
  <link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@400;600;700;900&family=IM+Fell+English:ital@0;1&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="Styles/base.css" />
  <link rel="stylesheet" href="Styles/navbar.css" />
  <link rel="stylesheet" href="Styles/home-webmaster.css" />
  <style>
    :root {
      --c-role:        #b86bf2;
      --c-role-border: rgba(184,107,242,.70);
      --c-role-bg:     rgba(184,107,242,.20);
      --glow-bg:       rgba(184,107,242,.25);
      --c-usuarios:    #b86bf2;
      --c-roles:       #5999f2;
      --c-bitacora:    #f29e38;
      --c-backup:      #47d96b;
      --c-dv:          #f2522e;
    }
    .bg-glow {
      background: radial-gradient(ellipse at center, rgba(184,107,242,.25) 0%, rgba(92,54,121,.15) 55%, transparent 100%);
    }
    .nav-avatar {
      background: linear-gradient(135deg, rgba(184,107,242,.8), rgba(92,54,121,.8));
      color: #fff;
    }
  </style>
</head>
<body>
    <form id="form1" runat="server">

<div class="page">
  <div class="bg-stripes"   aria-hidden="true"></div>
  <div class="bg-vignette"  aria-hidden="true"></div>
  <div class="bg-glow"      aria-hidden="true"></div>
  <div class="bg-sides"     aria-hidden="true"></div>
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
        <a href="HomeWebmaster.aspx" class="active">Inicio</a>
        <a href="EnConstruccionWebmaster.aspx">Usuarios</a>
        <a href="EnConstruccionWebmaster.aspx">Perfiles</a>
        <a href="BitacoraEventos.aspx">Bit&aacute;cora</a>
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
          
          <asp:Button ID="BtnLogout" runat="server"
    CssClass="nav-logout"
    Text="Salir"
    OnClick="BtnLogout_Click"
    ToolTip="Cerrar sesión" />

         </div>

      <div class="nav-dropdown" id="navDropdown">
        <a href="HomeWebmaster.aspx" class="active">Inicio</a>
        <a href="EnConstruccionWebmaster.aspx">Usuarios</a>
        <a href="EnConstruccionWebmaster.aspx">Perfiles</a>
        <a href="BitacoraEventos.aspx">Bit&aacute;cora</a>
        <a href="EnConstruccionWebmaster.aspx">Backup / Restore</a>
        <a href="EnConstruccionWebmaster.aspx">Seguridad</a>
      </div>
    </nav>

    <!-- HERO -->
    <section class="hero">
      <span class="hero-badge">PANEL DEL WEBMASTER</span>
      <h1 class="hero-title">SQUAMA</h1>
      <p class="hero-sub">Control t&eacute;cnico, seguridad e integridad del sistema</p>
      <p class="hero-desc">Administra usuarios, revisa la bit&aacute;cora, ejecuta backups y verifica la integridad de datos.</p>
      <div class="hero-divider" aria-hidden="true"></div>
    </section>

    <!-- STATS BAR -->
    <div class="stats-bar" role="region" aria-label="Estado del sistema">
      <div class="stat-item"><span class="stat-val" style="color:var(--c-usuarios)">320</span><span class="stat-lbl">Usuarios totales</span></div>
      <div class="stat-item"><span class="stat-val" style="color:var(--c-roles)">3</span><span class="stat-lbl">Roles activos</span></div>
      <div class="stat-item"><span class="stat-val" style="color:var(--c-bitacora)">142</span><span class="stat-lbl">Eventos hoy</span></div>
      <div class="stat-item"><span class="stat-val" style="color:var(--c-backup)">OK</span><span class="stat-lbl">&Uacute;ltimo backup</span></div>
      <div class="stat-item"><span class="stat-val" style="color:var(--c-dv)">2</span><span class="stat-lbl">Alertas DV</span></div>
    </div>

    <!-- CARDS -->
    <main class="cards-section">
      <div class="cards-grid">

        <div class="card" style="border-color:rgba(184,107,242,.50)">
          <div class="card-top" style="background:var(--c-usuarios)"></div>
          <div class="card-body">
            <p class="card-title">Gesti&oacute;n de Usuarios</p>
            <p class="card-desc">ABM completo de usuarios. Crear, modificar, activar, desactivar, bloquear y asignar roles.</p>
            <div class="card-status" style="background:rgba(184,107,242,.15);border:1px solid rgba(184,107,242,.45);color:var(--c-usuarios)">320 usuarios &mdash; 3 bloqueados &mdash; 5 inactivos</div>
            <button type="button" class="card-btn" style="background:rgba(184,107,242,.85);color:#1f1205" onclick="location.href='EnConstruccionWebmaster.aspx'">Gestionar usuarios</button>
          </div>
        </div>

        <div class="card" style="border-color:rgba(89,153,242,.50)">
          <div class="card-top" style="background:var(--c-roles)"></div>
          <div class="card-body">
            <p class="card-title">Perfiles y Roles</p>
            <p class="card-desc">Gesti&oacute;n de perfiles, roles, familias y permisos. Asigna accesos granulares a cada usuario.</p>
            <div class="card-status" style="background:rgba(89,153,242,.15);border:1px solid rgba(89,153,242,.45);color:var(--c-roles)">3 roles &mdash; 8 perfiles &mdash; 24 permisos</div>
            <button type="button" class="card-btn" style="background:rgba(89,153,242,.85);color:#fff" onclick="location.href='EnConstruccionWebmaster.aspx'">Gestionar perfiles</button>
          </div>
        </div>

        <div class="card" style="border-color:rgba(242,158,56,.50)">
          <div class="card-top" style="background:var(--c-bitacora)"></div>
          <div class="card-body">
            <p class="card-title">Bit&aacute;cora de Eventos</p>
            <p class="card-desc">Registro de logins, errores, cambios cr&iacute;ticos, bloqueos y verificaciones de integridad.</p>
            <div class="card-status" style="background:rgba(242,158,56,.15);border:1px solid rgba(242,158,56,.45);color:var(--c-bitacora)">1.840 eventos &mdash; 3 alertas hoy</div>
            <button type="button" class="card-btn" style="background:rgba(242,158,56,.85);color:#1f1205" onclick="location.href='BitacoraEventos.aspx'">Ver bit&aacute;cora</button>
          </div>
        </div>

        <div class="card" style="border-color:rgba(71,217,107,.50)">
          <div class="card-top" style="background:var(--c-backup)"></div>
          <div class="card-body">
            <p class="card-title">Backup / Restore</p>
            <p class="card-desc">Genera copias de seguridad de la base de datos y restaura desde versiones anteriores.</p>
            <div class="card-status" style="background:rgba(71,217,107,.15);border:1px solid rgba(71,217,107,.45);color:var(--c-backup)">&Uacute;ltimo backup: hoy 03:00 &mdash; OK</div>
            <button type="button" class="card-btn" style="background:rgba(71,217,107,.85);color:#0a2010" onclick="location.href='EnConstruccionWebmaster.aspx'">Gestionar backups</button>
          </div>
        </div>

        <div class="card" style="border-color:rgba(242,82,46,.50)">
          <div class="card-top" style="background:var(--c-dv)"></div>
          <div class="card-body">
            <p class="card-title">D&iacute;gito Verificador</p>
            <p class="card-desc">Controla la integridad de registros mediante DVH y DVV. Detecta modificaciones no autorizadas.</p>
            <div class="card-status" style="background:rgba(242,82,46,.15);border:1px solid rgba(242,82,46,.45);color:var(--c-dv)">DVV: OK &mdash; DVH: 2 inconsistencias</div>
            <button type="button" class="card-btn" style="background:rgba(242,82,46,.85);color:#fff" onclick="location.href='EnConstruccionWebmaster.aspx'">Verificar integridad</button>
          </div>
        </div>

      </div>
    </main>
  </div>
</div>

<script src="Scripts/nav.js"></script>
        </form>

</body>
</html>