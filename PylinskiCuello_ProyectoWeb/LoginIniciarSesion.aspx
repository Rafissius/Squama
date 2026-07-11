<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LoginIniciarSesion.aspx.cs" Inherits="PylinskiCuello_ProyectoWeb.LoginIniciarSesion" %>

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>SQUAMA — Iniciar Sesión</title>
  <link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@400;600;700;900&family=IM+Fell+English:ital@0;1&display=swap" rel="stylesheet" />
  <link rel="stylesheet" href="Styles/login-form.css" />
</head>
<body>
<form id="form1" runat="server">
<div class="page">

  <!-- FONDO -->
  <div class="bg-stripes"  aria-hidden="true"></div>
  <div class="bg-vignette" aria-hidden="true"></div>
  <div class="bg-glow"     aria-hidden="true"></div>
  <div class="bg-sides"    aria-hidden="true"></div>

  <!-- BORDE DORADO -->
  <div class="border-frame" aria-hidden="true"></div>

  <!-- CONTENIDO -->
  <div class="content">

    <!-- HEADER -->
    <header class="header">
      <div class="hline" aria-hidden="true"></div>
      <div class="logo-wrap">
        <img
    class="logo-s-img"
    src="<%= ResolveUrl("~/Imagenes/titulo.png") %>"
    alt="S"
    loading="eager" />
        <span class="logo-name">QUAMA</span>
      </div>
      <p class="logo-sub">Iniciar Sesión</p>
      <div class="hline-sm" aria-hidden="true"></div>
    </header>

    <!-- BODY ROW -->
    <div class="body-row">

      <!-- Features a la izquierda (absolutas) -->
      <aside class="features" aria-label="Características del juego">
        <div class="feat-item"><span class="dot"></span><span>Combates automáticos</span></div>
        <div class="feat-item"><span class="dot"></span><span>Sistema Gacha</span></div>
        <div class="feat-item"><span class="dot"></span><span>Clanes</span></div>
        <div class="feat-item"><span class="dot"></span><span>Progresión de nivel</span></div>
      </aside>

      <!-- Card centrada -->
      <div class="card-wrap">
        <div class="card-shadow" aria-hidden="true"></div>
        <div class="card" role="main">

          <p class="card-title">Bienvenido de vuelta</p>

          <%-- 
            PÁRRAFO DINÁMICO: 
            - runat="server" permite modificarlo desde el .cs
            - La clase CSS se cambia desde code-behind según el resultado
          --%>
          <p id="pMensaje" runat="server" class="card-desc">
            Ingresa tus credenciales para continuar tu aventura
          </p>

          <div class="card-divider" aria-hidden="true"></div>

          <%-- CAMPO USUARIO / EMAIL — runat="server" para leerlo en el .cs --%>
          <div class="field">
            <label for="username">Usuario o correo electrónico</label>
            <input id="username" runat="server" type="text"
                   placeholder="Tu nombre de usuario..."
                   autocomplete="username" />
          </div>

          <%-- CAMPO CONTRASEÑA — runat="server" para leerlo en el .cs --%>
          <div class="field">
            <label for="password">Contraseña</label>
            <input id="password" runat="server" type="password"
                   placeholder="••••••••"
                   autocomplete="current-password" />
          </div>

          <a class="forgot" href="#">¿Olvidaste tu contraseña?</a>

          <%-- 
            BOTÓN PRINCIPAL:
            - runat="server" convierte el botón en control de servidor
            - onserverclick dispara el método btnIngresar_Click en el .cs
            - Se elimina el onclick de JavaScript
          --%>
          <button class="btn btn-primary"
                  runat="server"
                  onserverclick="btnIngresar_Click">
            Ingresar al Reino
          </button>

          <div class="or-row" aria-hidden="true">
            <span class="line"></span><span>o</span><span class="line"></span>
          </div>

          <p class="new-text">¿Eres nuevo en Squama?</p>

          <button class="btn btn-secondary"
                runat="server"
                  onserverclick="btnRegistrar_Click">
            Crear una cuenta nueva
          </button>

          <a class="back-link" href="Login.aspx">← Volver al inicio</a>

          <div class="card-bottom-line" aria-hidden="true"></div>
        </div>
      </div>

    </div><!-- .body-row -->

    <!-- QUOTE -->
    <div class="quote-wrap">
      <p class="quote">"Solo los valientes merecen entrar a la arena"</p>
    </div>

  </div><!-- .content -->

</div><!-- .page -->
</form>
</body>
</html>
