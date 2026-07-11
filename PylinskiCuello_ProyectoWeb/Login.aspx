<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="PylinskiCuello_ProyectoWeb.Login" %>


<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>SQUAMA &mdash; Forja tu Leyenda</title>
  <link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@400;700;900&family=IM+Fell+English:ital@0;1&display=swap" rel="stylesheet" />
  <link rel="stylesheet" href="Styles/login.css" />
</head>
<body>
<div class="landing">

  <div class="stripes"              aria-hidden="true"></div>
  <div class="side-vignette left"   aria-hidden="true"></div>
  <div class="side-vignette right"  aria-hidden="true"></div>   
  <div class="center-glow"          aria-hidden="true"></div>
  <div class="radial-vignette"      aria-hidden="true"></div>
  <div class="border-outer"         aria-hidden="true"></div>
  <div class="border-inner"         aria-hidden="true"></div>
  <div class="corner-lines"         aria-hidden="true">
    <span class="tl"></span><span class="tr"></span>
    <span class="bl"></span><span class="br"></span>
  </div>

  <!-- ============================================================
       ORNAMENTOS DE ESQUINA
       Estructura identica al Figma original, redimensionada en vw.
       TL: landscape directo | TR/BL: portrait con inner rotado
       BR: landscape rotado 180deg
  ============================================================ -->

<!-- TL: landscape, sin rotacion -->
<div class="corner-tl" aria-hidden="true">
    <img
        src="<%= ResolveUrl("~/Imagenes/arder.png") %>"
        alt=""
        loading="eager" />
</div>

  <!-- TR: contenedor portrait, inner landscape rotate(90deg) -->
  <div class="corner-tr-wrap" aria-hidden="true">
    <div class="corner-tr-inner">
       <img
     src="<%= ResolveUrl("~/Imagenes/arder.png") %>"
     alt=""
     loading="eager" />
    </div>
  </div>

  <!-- BR: landscape rotate(180deg) -->
  <div class="corner-br-wrap" aria-hidden="true">
    <div class="corner-br-inner">
      <img
     src="<%= ResolveUrl("~/Imagenes/arder.png") %>"
     alt=""
     loading="eager" />
    </div>
  </div>

  <!-- BL: contenedor portrait, inner landscape rotate(-90deg) -->
  <div class="corner-bl-wrap" aria-hidden="true">
    <div class="corner-bl-inner">
       <img
     src="<%= ResolveUrl("~/Imagenes/arder.png") %>"
     alt=""
     loading="eager" />
    </div>
  </div>

  <!-- Dragones laterales -->
<div class="dragon-wrap dragon-left" aria-hidden="true">
    <img src="<%= ResolveUrl("~/Imagenes/g.png") %>"
         alt=""
         loading="lazy" />
</div>
 <div class="dragon-wrap dragon-right" aria-hidden="true">
    <img src="<%= ResolveUrl("~/Imagenes/g2.png") %>"
         alt=""
         loading="lazy" />
</div>

  <div class="divider-top"    aria-hidden="true"></div>
  <div class="divider-bottom" aria-hidden="true"></div>

  <!-- ============================================================
       CONTENIDO CENTRAL
  ============================================================ -->
  <main class="content">

    <h1 class="logo" aria-label="SQUAMA">
<img
    class="logo-s-img"
    src="<%= ResolveUrl("~/Imagenes/titulo.png") %>"
    alt="S"
    loading="eager" />
      <span class="logo-text">QUAMA</span>
    </h1>

    <div class="divider-mid" aria-hidden="true"></div>
    <p class="tagline">Forja tu Leyenda</p>

    <div class="btn-group">
      <button class="btn btn-primary"
              onclick="window.location.href='LoginIniciarSesion.aspx'">
        Ingresar a Squama
      </button>
      <div class="no-account-wrap" aria-hidden="true">
        <div class="sep-line"></div>
        <span class="no-account">&iquest;No tenes cuenta?</span>
        <div class="sep-line"></div>
      </div>
      <button class="btn btn-secondary"
              onclick="location.href='RegistrarUsuario.aspx'">
        Crear una cuenta
      </button>
    </div>

  </main>

  <div class="credits-wrap" aria-label="Creditos">
    <p class="credits">NATALIE PYLINSKI</p>
    <p class="credits">RAFAEL CUELLO</p>
  </div>

</div>
</body>
</html>