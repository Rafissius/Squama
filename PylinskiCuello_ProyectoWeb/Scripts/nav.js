/* ============================================================
   nav.js — SQUAMA shared navbar toggle
   Shared across all interior pages
   ============================================================ */

function toggleNav() {
  document.getElementById('navDropdown').classList.toggle('open');
}

document.addEventListener('click', function(e) {
  if (!e.target.closest('.navbar')) {
    document.getElementById('navDropdown').classList.remove('open');
  }
});
