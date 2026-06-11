/* ============================================================================
   Saudi Opportunity Hub — guest mode (sales-demo preview)
   ----------------------------------------------------------------------------
   Client-side UX layer for the "Continue as Guest" flow. Inert unless
   auth-bootstrap.js has flagged this visitor as a guest
   (window.__ohIsGuest === true: sessionStorage 'oh_guest' + no Supabase
   session).

   What lives here:
     - the reusable upgrade modal ("You're browsing as a guest" →
       mailto founding-access CTA), bilingual EN/AR
     - the slim persistent preview banner (dismissible per session)
     - capture-phase click interceptors that route every member-only
       feature (watchlist/save, saved searches, exports, API links,
       alerts/notifications, settings/preferences, workspace, folders,
       compare print) into that one modal
     - the "Welcome, Guest" greeting
     - guest sign-out (clears the flag, back to login — no Supabase call)

   What does NOT live here: data protection. Guests browse the
   column-restricted public.opportunities_guest view as the anon role;
   the locked fields (description, funding amount, eligibility,
   application link) are never sent to the client. See
   supabase/migrations/2026_06_11_guest_mode_restricted_read.sql.

   Styling: the .oh-guest-* / .guest-lock-* rules live in
   assets/polish-overrides.css (guest-mode section at the end).
============================================================================ */
(function () {
  'use strict';

  var GUEST_FLAG_KEY     = 'oh_guest';
  var BANNER_DISMISS_KEY = 'oh_guest_banner_dismissed';
  var MAILTO_HREF = 'mailto:j.guzman@midnightspaceconsultancy.com?subject=' +
                    encodeURIComponent('Founding access — Saudi Opportunity Hub');

  function isGuest() { return window.__ohIsGuest === true; }
  function isAr() {
    return window.__lang === 'ar' ||
           document.documentElement.getAttribute('dir') === 'rtl' ||
           document.documentElement.lang === 'ar';
  }

  /* All copy authored in both languages — never machine-translated, so it
     bypasses the gtTranslate pipeline the same way data-ar elements do. */
  var STR = {
    bannerText:    { en: 'Guest preview — full details are reserved for members',
                     ar: 'معاينة كضيف — التفاصيل الكاملة محجوزة للأعضاء' },
    bannerCta:     { en: 'Request access',
                     ar: 'اطلب الوصول' },
    bannerDismiss: { en: 'Dismiss banner',
                     ar: 'إغلاق الشريط' },
    modalTitle:    { en: 'You’re browsing as a guest',
                     ar: 'أنت تتصفح كضيف' },
    modalSub:      { en: 'Founding members unlock the full intelligence layer:',
                     ar: 'الأعضاء المؤسسون يحصلون على طبقة المعلومات الكاملة:' },
    benefitDetails: { en: 'Full opportunity details — descriptions, funding amounts, eligibility and application links',
                      ar: 'التفاصيل الكاملة لكل فرصة — الوصف وقيمة التمويل وشروط الأهلية ورابط التقديم' },
    benefitAlerts:  { en: 'Weekly alerts for the sectors you follow',
                      ar: 'تنبيهات أسبوعية للقطاعات التي تتابعها' },
    benefitExports: { en: 'CSV and PDF exports of any list',
                      ar: 'تصدير أي قائمة بصيغة CSV أو PDF' },
    benefitWorkspace: { en: 'Watchlist, saved searches and a personal workspace',
                        ar: 'قائمة المتابعة والبحوث المحفوظة ومساحة عمل خاصة' },
    modalCta:      { en: 'Request founding access',
                     ar: 'اطلب عضوية تأسيسية' },
    modalLater:    { en: 'Continue browsing',
                     ar: 'متابعة التصفح' },
    modalClose:    { en: 'Close',
                     ar: 'إغلاق' },
    guestName:     { en: 'Guest',
                     ar: 'ضيف' },
    welcome:       { en: 'Welcome,',
                     ar: 'مرحباً بك،' }
  };
  function txt(key) {
    var pair = STR[key] || {};
    return (isAr() ? pair.ar : pair.en) || pair.en || '';
  }

  var LOCK_SVG = '<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" aria-hidden="true"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>';

  /* ════════════════════════════════════════════════════════════
     UPGRADE MODAL — one instance, content rebuilt per open so it
     always reflects the active language.
     ════════════════════════════════════════════════════════════ */
  var modalOverlay = null;
  var lastFocused  = null;

  function buildModal() {
    if (modalOverlay) return modalOverlay;
    modalOverlay = document.createElement('div');
    modalOverlay.className = 'oh-guest-modal-overlay';
    modalOverlay.id = 'guestUpgradeOverlay';
    modalOverlay.setAttribute('aria-hidden', 'true');
    document.body.appendChild(modalOverlay);
    modalOverlay.addEventListener('click', function (e) {
      if (e.target === modalOverlay) closeModal();
    });
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && modalOverlay && modalOverlay.classList.contains('open')) closeModal();
    });
    return modalOverlay;
  }

  function renderModalContent() {
    var benefits = ['benefitDetails', 'benefitAlerts', 'benefitExports', 'benefitWorkspace']
      .map(function (k) {
        return '<li><span class="oh-guest-modal-check" aria-hidden="true">' +
          '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4"><polyline points="20 6 9 17 4 12"/></svg>' +
          '</span><span>' + txt(k) + '</span></li>';
      }).join('');
    return '' +
      '<div class="oh-guest-modal" role="dialog" aria-modal="true" aria-labelledby="guestModalTitle" dir="' + (isAr() ? 'rtl' : 'ltr') + '">' +
        '<button type="button" class="oh-guest-modal-x" id="guestModalClose" aria-label="' + txt('modalClose') + '">&times;</button>' +
        '<div class="oh-guest-modal-lock" aria-hidden="true">' + LOCK_SVG + '</div>' +
        '<h2 class="oh-guest-modal-title" id="guestModalTitle">' + txt('modalTitle') + '</h2>' +
        '<p class="oh-guest-modal-sub">' + txt('modalSub') + '</p>' +
        '<ul class="oh-guest-modal-list">' + benefits + '</ul>' +
        '<a class="oh-guest-modal-cta" id="guestModalCta" href="' + MAILTO_HREF + '">' + txt('modalCta') + '</a>' +
        '<button type="button" class="oh-guest-modal-later" id="guestModalLater">' + txt('modalLater') + '</button>' +
      '</div>';
  }

  function openModal() {
    if (!isGuest()) return;
    var overlay = buildModal();
    overlay.innerHTML = renderModalContent();
    overlay.querySelector('#guestModalClose').addEventListener('click', closeModal);
    overlay.querySelector('#guestModalLater').addEventListener('click', closeModal);
    lastFocused = document.activeElement;
    overlay.classList.add('open');
    overlay.setAttribute('aria-hidden', 'false');
    document.body.classList.add('oh-guest-modal-open');
    var cta = overlay.querySelector('#guestModalCta');
    if (cta) { try { cta.focus(); } catch (e) {} }
  }

  function closeModal() {
    if (!modalOverlay) return;
    modalOverlay.classList.remove('open');
    modalOverlay.setAttribute('aria-hidden', 'true');
    document.body.classList.remove('oh-guest-modal-open');
    if (lastFocused && typeof lastFocused.focus === 'function') {
      try { lastFocused.focus(); } catch (e) {}
    }
    lastFocused = null;
  }

  /* Public hook so inline code (or the console during demos) can raise
     the same modal. */
  window.__ohGuestUpgrade = openModal;

  /* ════════════════════════════════════════════════════════════
     PREVIEW BANNER — slim fixed bar above the app shell. The grid
     offsets it triggers (.oh-guest-banner-on) live in
     polish-overrides.css. Dismissal is per browser session.
     ════════════════════════════════════════════════════════════ */
  var bannerEl = null;

  function bannerDismissed() {
    try { return sessionStorage.getItem(BANNER_DISMISS_KEY) === '1'; } catch (e) { return false; }
  }

  function renderBannerContent() {
    bannerEl.innerHTML = '' +
      '<span class="oh-guest-banner-lock" aria-hidden="true">' + LOCK_SVG + '</span>' +
      '<span class="oh-guest-banner-text">' + txt('bannerText') + '</span>' +
      '<button type="button" class="oh-guest-banner-cta" id="guestBannerCta">' + txt('bannerCta') + '</button>' +
      '<button type="button" class="oh-guest-banner-x" id="guestBannerDismiss" aria-label="' + txt('bannerDismiss') + '" title="' + txt('bannerDismiss') + '">&times;</button>';
    bannerEl.querySelector('#guestBannerCta').addEventListener('click', openModal);
    bannerEl.querySelector('#guestBannerDismiss').addEventListener('click', dismissBanner);
  }

  function buildBanner() {
    if (bannerEl || bannerDismissed()) return;
    bannerEl = document.createElement('div');
    bannerEl.className = 'oh-guest-banner';
    bannerEl.id = 'guestBanner';
    bannerEl.setAttribute('role', 'note');
    bannerEl.setAttribute('dir', isAr() ? 'rtl' : 'ltr');
    renderBannerContent();
    document.body.insertBefore(bannerEl, document.body.firstChild);
    document.body.classList.add('oh-guest-banner-on');
  }

  function dismissBanner() {
    try { sessionStorage.setItem(BANNER_DISMISS_KEY, '1'); } catch (e) {}
    if (bannerEl && bannerEl.parentNode) bannerEl.parentNode.removeChild(bannerEl);
    bannerEl = null;
    document.body.classList.remove('oh-guest-banner-on');
  }

  /* ════════════════════════════════════════════════════════════
     GREETING — "Welcome, Guest". The member username resolvers all
     no-op for guests (no session, no prefs), so a direct write is
     stable; the data-en/data-ar attributes keep the existing
     language-toggle pipeline in charge of subsequent flips.
     ════════════════════════════════════════════════════════════ */
  function applyGreeting() {
    if (!isGuest()) return;
    var nameEl = document.getElementById('homeUsername');
    if (nameEl) {
      nameEl.textContent = txt('guestName');
      nameEl.setAttribute('data-en', STR.guestName.en);
      nameEl.setAttribute('data-ar', STR.guestName.ar);
    }
    var heading = document.getElementById('homeHeading');
    if (heading) {
      var welcomeSpan = heading.querySelector('span[data-ar]');
      if (welcomeSpan && welcomeSpan !== nameEl) {
        welcomeSpan.textContent = txt('welcome');
        welcomeSpan.setAttribute('data-en', STR.welcome.en);
        welcomeSpan.setAttribute('data-ar', STR.welcome.ar);
      }
    }
  }

  /* ════════════════════════════════════════════════════════════
     FEATURE INTERCEPTORS — one capture-phase listener. Capture on
     document runs before the app's bubble-phase delegated handlers
     (polish-delegated-actions.js, router nav, WS bookmark sync), and
     stopPropagation() during capture prevents the event from ever
     reaching them. Every gated control funnels into the same modal.
     ════════════════════════════════════════════════════════════ */
  var GATED_SELECTOR = [
    '[data-action="guest-upgrade"]',          // lock affordances rendered on cards / compare
    '[data-action="toggle-bookmark"]',        // save/watchlist buttons on cards
    '.card-bookmark-btn',
    '[data-action="open-panel"]',             // workspace panel (watchlist / searches / recent tabs)
    '[data-action="open-settings"]',          // preferences (sidebar + topbar)
    '#saveSearchBtn',                         // saved searches
    '#exportCsvBtn',                          // CSV export of the filtered list
    '.oh-enh-compare-print',                  // compare → print / save as PDF
    '#notifBtn',                              // alerts / notifications
    '#addToFolderBtn',                        // folders (Phase B)
    '.opp-folder-btn',
    'a[href*="api.html"]',                    // API page links
    '.app-nav-item[data-view="saved"]',       // member-only routes (nav + bottom tabs);
    '.app-nav-item[data-view="workspace"]',   // raw #hash entry is covered by the router guard
    '.app-bottom-tab[data-view="saved"]',
    '.app-bottom-tab[data-view="workspace"]',
    '[data-action="set-route"][data-arg="saved"]'
  ].join(',');

  document.addEventListener('click', function (e) {
    if (!isGuest()) return;
    var trigger = e.target && e.target.closest ? e.target.closest(GATED_SELECTOR) : null;
    if (!trigger) return;
    e.preventDefault();
    e.stopPropagation();
    openModal();
  }, true);

  /* Sign out — clear the guest flag and return to login. No Supabase
     call: there is no session to revoke. Capture-phase so the member
     sign-out handler (which calls auth.signOut()) never runs. */
  document.addEventListener('click', function (e) {
    if (!isGuest()) return;
    var trigger = e.target && e.target.closest ? e.target.closest('#signout-btn, #sidebarLogout') : null;
    if (!trigger) return;
    e.preventDefault();
    e.stopPropagation();
    try {
      sessionStorage.removeItem(GUEST_FLAG_KEY);
      sessionStorage.removeItem(BANNER_DISMISS_KEY);
    } catch (err) {}
    window.location.replace('login.html');
  }, true);

  /* ════════════════════════════════════════════════════════════
     INIT — wait for auth-bootstrap's verdict, then assemble.
     ════════════════════════════════════════════════════════════ */
  var initialized = false;

  function init() {
    if (initialized || !isGuest()) return;
    initialized = true;
    document.body.classList.add('oh-guest');
    buildBanner();
    applyGreeting();
    /* initHome() / showView('home') repaint the greeting row after data
       loads — re-assert a few times, then on every route change. */
    setTimeout(applyGreeting, 600);
    setTimeout(applyGreeting, 2000);
    window.addEventListener('hashchange', function () { setTimeout(applyGreeting, 250); });
    /* Language toggle rebuilds chart/topbar copy; refresh ours too.
       (Modal content is rebuilt on every open, so it self-heals.) */
    var langBtn = document.getElementById('appLangToggle');
    if (langBtn) {
      langBtn.addEventListener('click', function () {
        setTimeout(function () {
          if (bannerEl) { bannerEl.setAttribute('dir', isAr() ? 'rtl' : 'ltr'); renderBannerContent(); }
          applyGreeting();
          /* Re-render the result cards in the new language. The toggle
             pipeline swaps static chrome in place but cards are not
             re-rendered, and its restore path replays text cached at
             translate-time — wrong for lock labels that were RENDERED
             under AR. A fresh render routes everything through t()
             with the correct language. Guest-scoped: members keep the
             stock toggle behaviour untouched. */
          if (typeof window.__renderCards === 'function') {
            try { window.__renderCards(); } catch (e) {}
          }
        }, 600);
      });
    }
  }

  function start() {
    if (isGuest()) { init(); return; }
    /* auth-bootstrap resolves asynchronously (getSession) — listen for
       its event and poll as a fallback for the missed-event race. */
    window.addEventListener('oh:role-ready', function () { if (isGuest()) init(); });
    var tries = 0;
    var iv = setInterval(function () {
      tries++;
      if (isGuest()) { clearInterval(iv); init(); return; }
      if (window.__ohAuthResolved === true || tries > 80) clearInterval(iv);
    }, 100);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', start);
  } else {
    start();
  }
})();
