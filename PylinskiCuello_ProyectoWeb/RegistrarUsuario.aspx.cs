using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using BE;
using BLL;

namespace PylinskiCuello_ProyectoWeb
{
    public partial class RegistrarUsuario : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

       

        protected void btnRegistrar_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;

            if (!chkTerminos.Checked)
            {
                MostrarError("Debes aceptar los terminos y condiciones.");
                return;
            }

            // La GUI arma el BE con los datos crudos.
            // El campo PasswordHash viaja con la clave SIN hashear todavia:
            // el hasheo lo hace la BLL antes de guardar.
            BE_Usuario nuevoUsuario = new BE_Usuario
            {
                NombreUsuario = txtNombreUsuario.Text.Trim(),
                Email = txtEmail.Text.Trim(),
                PasswordHash = txtClave.Text
            };

            try
            {
                BLL_Usuario bllUsuario = new BLL_Usuario();
                int idGenerado = bllUsuario.RegistrarUsuario(nuevoUsuario);

                MostrarExito("¡Cuenta creada con exito! Ya podes iniciar sesion.");
                LimpiarCampos();
            }
            catch (Exception ex)
            {
                MostrarError(ex.Message);
            }
        }

        private void MostrarExito(string mensaje)
        {
            lblMensaje.CssClass = "mensaje mensaje-exito";
            lblMensaje.Text = mensaje;
        }

        private void MostrarError(string mensaje)
        {
            lblMensaje.CssClass = "mensaje mensaje-error";
            lblMensaje.Text = mensaje;
        }

        private void LimpiarCampos()
        {
            txtNombreUsuario.Text = "";
            txtEmail.Text = "";
            txtClave.Text = "";
            txtConfirmarClave.Text = "";
            chkTerminos.Checked = false;
        }

    }
}