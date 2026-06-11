/* ============================================================================
   Saudi Opportunity Hub — shared EN/AR toggle for static pages
   ----------------------------------------------------------------------------
   Extracted from 404.html's inline <script> (2026-06-11). The 404 page's CSP
   has no script-src directive, so scripts fall back to default-src 'self' —
   which forbids inline scripts. The page's only script WAS inline, so the
   language toggle silently never wired up. Externalising it (plus adding
   script-src 'self' to the page CSP) fixes the button while keeping the
   404 page the strictest-CSP page on the site (no 'unsafe-inline' for
   scripts, unlike the other static pages — see issue #14, which tracks
   moving THEM to this file too).

   Contract (same as login/contact/guest):
     - persists the choice under localStorage 'oh-login-lang'
     - flips <html dir> and <html lang>
     - swaps every [data-en][data-ar] element's textContent
     - updates the #lang-label button text (العربية ↔ English)
     - restores the stored language on load

   Load with <script src="assets/oh-lang-toggle.js" defer> — it wires up
   immediately at execute time (defer = DOM already parsed).
============================================================================ */
(function () {
  'use strict';

  var LANG_KEY = 'oh-login-lang';

  function applyLang(lang) {
    var isAr = lang === 'ar';
    document.documentElement.setAttribute('dir',  isAr ? 'rtl' : 'ltr');
    document.documentElement.setAttribute('lang', isAr ? 'ar'  : 'en');
    var label = document.getElementById('lang-label');
    if (label) label.textContent = isAr ? 'English' : 'العربية';
    document.querySelectorAll('[data-en][data-ar]').forEach(function (el) {
      el.textContent = isAr ? el.dataset.ar : el.dataset.en;
    });
    try { localStorage.setItem(LANG_KEY, lang); } catch (e) {}
  }

  var toggle = document.getElementById('lang-toggle');
  if (toggle) {
    toggle.addEventListener('click', function () {
      var cur = document.documentElement.getAttribute('dir') === 'rtl' ? 'ar' : 'en';
      applyLang(cur === 'en' ? 'ar' : 'en');
    });
  }

  var stored = 'en';
  try { stored = localStorage.getItem(LANG_KEY) || 'en'; } catch (e) {}
  if (stored === 'ar') applyLang('ar');
})();
