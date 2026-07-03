<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ResolverIntegridad.aspx.cs" Inherits="PylinskiCuello_ProyectoWeb.Webmaster.ResolverIntegridad" %>
<!DOCTYPE html>
<html lang="es">
<head runat="server">
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>SQUAMA &mdash; Resolver Integridad</title>
  <link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@400;600;700;900&family=IM+Fell+English:ital@0;1&family=Inter:wght@400;700&display=swap" rel="stylesheet" />
  <link rel="stylesheet" href="../Styles/base.css" />
  <link rel="stylesheet" href="../Styles/navbar.css" />
  <style>
    :root {
      --c-role:        #f2522e;
      --c-role-border: rgba(242,82,46,.70);
      --c-role-bg:     rgba(242,82,46,.20);
      --glow-bg:       rgba(242,82,46,.25);
    }
    .nav-avatar {
      background: linear-gradient(135deg, rgba(242,82,46,.8), rgba(120,30,20,.8));
      color: #fff;
    }
    .resumen-box {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 16px;
      margin: 24px 0;
    }
    .resumen-card {
      border: 1px solid rgba(242,82,46,.45);
      background: rgba(242,82,46,.08);
      border-radius: 8px;
      padding: 16px;
    }
    .resumen-card .lbl { display:block; font-size:.8rem; opacity:.75; margin-bottom:6px; }
    .resumen-card .val { display:block; font-size:1.1rem; font-weight:600; }
    .accion-box {
      border: 1px solid rgba(255,255,255,.15);
      border-radius: 8px;
      padding: 20px;
      margin-bottom: 20px;
    }
    .accion-box h3 { margin-top: 0; }
    .accion-box .btn-accion {
      background: rgba(242,82,46,.85);
      color: #fff;
      border: none;
      border-radius: 6px;
      padding: 10px 18px;
      cursor: pointer;
      font-weight: 600;
    }
    .accion-box select { margin-right: 10px; padding: 6px 10px; }
    #pMensaje { font-weight: 600; margin: 16px 0; }
    table.grilla-inconsistencias { width: 100%; border-collapse: collapse; margin-top: 12px; }
    table.grilla-inconsistencias th, table.grilla-inconsistencias td {
      border: 1px solid rgba(255,255,255,.15);
      padding: 8px 10px;
      font-size: .85rem;
      text-align: left;
    }
    table.grilla-inconsistencias th { background: rgba(242,82,46,.15); }
  </style>
</head>
<body>
  <form id="form1" runat="server">
    <div class="page">
      <div class="bg-stripes" aria-hidden="true"></div>
      <div class="bg-vignette" aria-hidden="true"></div>
      <div class="bg-glow" aria-hidden="true"></div>
      <div class="bg-sides" aria-hidden="true"></div>
      <div class="border-frame" aria-hidden="true"></div>

      <div class="content">
        <nav class="navbar" role="navigation">
          <div class="nav-brand">
            <span class="name">SQUAMA</span>
            <span class="sub">Forja tu Leyenda</span>
          </div>
          <div class="nav-role">WEBMASTER</div>
          <div class="nav-links">
            <a href="../HomeWebmaster.aspx">Inicio</a>
            <a href="../BitacoraEventos.aspx">Bit&aacute;cora</a>
            <a href="ResolverIntegridad.aspx" class="active">D&iacute;gito Verificador</a>
          </div>
          <div class="nav-right">
            <div class="nav-avatar">W</div>
            <div class="nav-user">
              <span class="uname">Webmaster</span>
              <span class="urole">WEBMASTER</span>
            </div>
          </div>
        </nav>

        <main class="main-content">
          <header class="page-header">
            <div class="page-badge">D&Iacute;GITO VERIFICADOR</div>
            <h1 class="page-title">Resolver Integridad</h1>
            <p class="page-subtitle">El sistema detect&oacute; una inconsistencia y est&aacute; bloqueado para el resto de los roles. Eleg&iacute; c&oacute;mo resolverlo.</p>
          </header>

          <p id="pMensaje" runat="server"></p>

          <div class="resumen-box">
            <div class="resumen-card">
              <span class="lbl">Inconsistencias detectadas</span>
              <span class="val"><asp:Label ID="lblCantidadInconsistencias" runat="server" Text="0" /></span>
            </div>
            <div class="resumen-card">
              <span class="lbl">Fecha del bloqueo</span>
              <span class="val"><asp:Label ID="lblFechaBloqueo" runat="server" Text="N/D" /></span>
            </div>
            <div class="resumen-card">
              <span class="lbl">Motivo</span>
              <span class="val"><asp:Label ID="lblMotivoBloqueo" runat="server" Text="N/D" /></span>
            </div>
          </div>

          <div class="accion-box">
            <h3>Recalcular todos los d&iacute;gitos verificadores</h3>
            <p>Asume que los datos est&aacute;n correctos y que los DV estaban desactualizados. Recalcula DVH y DVV de todas las entidades registradas y desbloquea el sistema.</p>
            <asp:Button ID="btnRecalcular" runat="server" Text="Recalcular todos los DV" CssClass="btn-accion"
                        OnClick="BtnRecalcular_Click"
                        OnClientClick="return confirm('Esta acción asume que los datos están correctos y los DV estaban desactualizados. ¿Continuar?');" />
          </div>

          <div class="accion-box">
            <h3>Restaurar desde backup</h3>
            <p>Restaura la base de datos completa desde un backup anterior. Usar cuando se sospecha que los DATOS (no solo los DV) fueron alterados.</p>
            <asp:DropDownList ID="ddlBackups" runat="server" />
            <asp:Button ID="btnRestaurar" runat="server" Text="Restaurar desde backup" CssClass="btn-accion"
                        OnClick="BtnRestaurar_Click"
                        OnClientClick="return confirm('Esta acción restaura la base de datos completa desde el backup seleccionado. ¿Continuar?');" />
            <asp:Panel ID="pnlSinBackups" runat="server" Visible="false">
              No hay backups disponibles.
            </asp:Panel>
          </div>

          <div class="section-sep"></div>
          <div class="section-title">&Uacute;ltimas inconsistencias detectadas</div>

          <table class="grilla-inconsistencias">
            <thead>
              <tr>
                <th>ID</th>
                <th>Tabla</th>
                <th>Registro</th>
                <th>Atributo</th>
                <th>Tipo</th>
                <th>Valor esperado</th>
                <th>Valor calculado</th>
                <th>Fecha detecci&oacute;n</th>
              </tr>
            </thead>
            <tbody>
              <asp:Repeater ID="rptInconsistencias" runat="server">
                <ItemTemplate>
                  <tr>
                    <td><%# Eval("IDInconsistenciaIntegridad") %></td>
                    <td><%# Eval("NombreTabla") %></td>
                    <td><%# Eval("IDRegistro") ?? "N/D" %></td>
                    <td><%# Eval("NombreAtributo") ?? "N/D" %></td>
                    <td><%# Eval("TipoDigito") %></td>
                    <td><%# Eval("ValorEsperado") %></td>
                    <td><%# Eval("ValorCalculado") %></td>
                    <td><%# Eval("FechaDeteccion", "{0:dd/MM/yyyy HH:mm:ss}") %></td>
                  </tr>
                </ItemTemplate>
              </asp:Repeater>
            </tbody>
          </table>
          <asp:Panel ID="pnlSinInconsistencias" runat="server" Visible="false">
            No hay inconsistencias registradas.
          </asp:Panel>

        </main>
      </div>
    </div>
  </form>
</body>
</html>
