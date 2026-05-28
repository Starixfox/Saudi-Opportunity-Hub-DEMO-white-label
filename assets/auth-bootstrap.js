/* ============================================================================
   Saudi Opportunity Hub — head bootstrap
   ----------------------------------------------------------------------------
   Extracted from index.html's inline <script> block (head-position) on
   2026-05-26 as part of the polish pass.

   Contents (in order):
     - Supabase auth session check + redirect-to-login gate
     - Super-admin (owner UID) elevation flag
     - window.OH_THEMES registry (8 white-label tenants)
     - applyTheme() function (overrides --accent and friends per tenant)
     - Document-attribute observer for live theme switching

   Why this is a synchronous (non-deferred) external <script> reference:
     The auth check redirects unauthenticated visitors to /login.html
     before any UI renders, preventing flash-of-protected-content. Using
     `defer` here would let the body render before the redirect fires.
     A synchronous external <script> blocks parsing the same way the
     inline block used to, so behaviour is byte-identical.

   This extraction makes the bootstrap browser-cacheable AND is the
   prerequisite for the issue #14 CSP-tightening work (dropping
   'unsafe-inline' from script-src once every inline <script> in the
   SPA is also externalised — that's a bigger refactor tracked separately).
============================================================================ */

// ── Super-admin / owner gate — only this UID gets the Theme Manager
window.__OH_OWNER_UID = '72f017e5-b4f0-4ef2-9083-65e3d9961548';
window.__ohIsSuperAdmin = false;
function checkSuperAdmin(uid) {
  window.__ohIsSuperAdmin = !!(uid && uid === window.__OH_OWNER_UID);
  return window.__ohIsSuperAdmin;
}

(function() {
  var SUPA_URL = 'https://dshrbbnjahjcwxzvzygh.supabase.co';
  var SUPA_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRzaHJiYm5qYWhqY3d4enZ6eWdoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg0ODE3OTgsImV4cCI6MjA5NDA1Nzc5OH0.OpUGgfL91m7STsZpE6fnX281KN_Ge8oytR-2lM-3qTo';
  var _supabase = window.supabase.createClient(SUPA_URL, SUPA_KEY);
  // Expose globally so other scripts can use it (e.g. sign-out button)
  window._supabase = _supabase;
  // Check session on every page load
  _supabase.auth.getSession().then(function(result) {
    var session = result.data && result.data.session;
    if (!session) {
      window.location.href = 'login.html';
      return;
    }
    // ── Admin role check — drives the admin sidebar entry + #admin view
    window.__ohSession = session;
    /* Resolve super-admin flag immediately from the session UID. */
    checkSuperAdmin(session.user && session.user.id);
    _supabase
      .from('user_prefs')
      .select('role')
      .eq('user_id', session.user.id)
      .single()
      .then(function(res) {
        var isAdmin = !!(res && res.data && res.data.role === 'admin');
        window.__ohIsAdmin = isAdmin;
        /* Re-confirm super-admin flag with the freshly-resolved user. */
        checkSuperAdmin(session.user && session.user.id);
        try { window.dispatchEvent(new CustomEvent('oh:role-ready', { detail: { isAdmin: isAdmin, isSuperAdmin: window.__ohIsSuperAdmin } })); } catch (e) {}
      })
      .catch(function() {
        window.__ohIsAdmin = false;
        try { window.dispatchEvent(new CustomEvent('oh:role-ready', { detail: { isAdmin: false, isSuperAdmin: window.__ohIsSuperAdmin } })); } catch (e) {}
      });
  }).catch(function(err) {
    console.warn('[Auth] getSession error:', err);
    window.location.href = 'login.html';
  });
})();

/* ════════════════════════════════════════════════════════════
   WHITE-LABEL THEME REGISTRY + applyTheme()
   Public: applyTheme() is callable anywhere (URL ?theme=xxx is a
   legitimate demo feature). The *management UI* is owner-gated.
   ════════════════════════════════════════════════════════════ */
/* ═══════════════════════════════════════════════════════════════════════
   GOLD-ONLY PALETTE (User: "all themes should be changed to gold so no
   other theme colors anymore.")

   Every tenant theme below shares the same accent palette: calligraphy
   gold (#C9A66B = color-gold-500) for light mode, lifted gold (#e3bd6c
   = color-gold-300) for dark mode so it reads above WCAG AA on the dark
   surface tokens. The tenant LABELS, LOGOS, and NAMES stay tenant-
   specific — only the colour token unifies.

   These hex values match the canonical gold ramp in tokens.css:34-43.
   ═══════════════════════════════════════════════════════════════════════ */
var GOLD_ACCENT = {
  accent:           '#C9A66B',
  accentHover:      '#a88947',
  accentLight:      'rgba(201,166,107,0.10)',
  accentGlow:       'rgba(201,166,107,0.25)',
  accentDim:        'rgba(201,166,107,0.08)',
  darkAccent:       '#e3bd6c',
  darkAccentHover:  '#d4ab48',
  darkAccentLight:  'rgba(227,189,108,0.14)',
  darkAccentGlow:   'rgba(227,189,108,0.30)',
  darkAccentDim:    'rgba(227,189,108,0.10)'
};

/* ═══════════════════════════════════════════════════════════════════════
   ABDUL LATIF JAMEEL — brand blue (from the company's pentagon mark).
   Light-mode #1B75BB ≈ the ALJ corporate blue; dark mode lifts to
   #4FA3E8 so the accent stays bright/legible on the dark surface tokens
   (a mid blue goes muddy on dark). The grey wordmark is just text, not
   an accent, so it isn't tokenised here. This is the one tenant that
   keeps its own colour instead of the shared gold. */
var ALJ_BLUE = {
  accent:           '#1B75BB',
  accentHover:      '#145C94',
  accentLight:      'rgba(27,117,187,0.10)',
  accentGlow:       'rgba(27,117,187,0.25)',
  accentDim:        'rgba(27,117,187,0.08)',
  darkAccent:       '#4FA3E8',
  darkAccentHover:  '#6FB6EE',
  darkAccentLight:  'rgba(79,163,232,0.14)',
  darkAccentGlow:   'rgba(79,163,232,0.30)',
  darkAccentDim:    'rgba(79,163,232,0.10)'
};

window.OH_THEMES = {
  'default': Object.assign({}, GOLD_ACCENT, {
    label: 'Saudi Opportunity Hub (Default)',
    labelAr: 'منصة الفرص السعودية',
    tagline: 'Aligned with Vision 2030',
    taglineAr: 'متوافق مع رؤية 2030',
    navName: 'Opportunity Hub',
    navNameAr: 'منصة الفرص',
    logo: null,
    logoDark: null,
    logoHeight: 28
  }),
  'misa': Object.assign({}, GOLD_ACCENT, {
    label: 'MISA — Ministry of Investment',
    labelAr: 'هيئة الاستثمار — وزارة الاستثمار',
    tagline: 'Ministry of Investment — Saudi Arabia',
    taglineAr: 'وزارة الاستثمار — المملكة العربية السعودية',
    navName: 'MISA Intelligence',
    navNameAr: 'ذكاء الفرص — هيئة الاستثمار',
    logo: 'https://misa.gov.sa/app/uploads/2023/11/logo.png',
    logoDark: 'https://misa.gov.sa/app/uploads/2023/11/logo.png',
    logoHeight: 32
  }),
  'monshaat': Object.assign({}, GOLD_ACCENT, {
    label: "Monsha'at — SME Authority",
    labelAr: 'منشآت — الهيئة العامة للمنشآت',
    tagline: "Saudi SME & Entrepreneurship Authority",
    taglineAr: 'الهيئة العامة للمنشآت الصغيرة والمتوسطة',
    navName: "Monsha'at Hub",
    navNameAr: 'منصة منشآت',
    logo: 'https://upload.wikimedia.org/wikipedia/commons/2/27/Small_and_Medium_Enterprises_General_Authority_Logo.svg',
    logoDark: 'https://upload.wikimedia.org/wikipedia/commons/2/27/Small_and_Medium_Enterprises_General_Authority_Logo.svg',
    logoHeight: 30
  }),
  'adio': Object.assign({}, GOLD_ACCENT, {
    label: 'ADIO — Abu Dhabi Investment Office',
    labelAr: 'مكتب أبوظبي للاستثمار',
    tagline: 'Abu Dhabi Investment Office',
    taglineAr: 'مكتب أبوظبي للاستثمار',
    navName: 'ADIO Intelligence',
    navNameAr: 'منصة أبوظبي للفرص',
    logo: 'https://www.investwithabudhabi.com/images/default-source/logos/logo-new-light535748fa25b44e1e838390e8f149d21d.svg',
    logoDark: 'https://www.investwithabudhabi.com/images/default-source/logos/logo-dark55d48f3d417f414a910936cc42cb8022.svg',
    logoHeight: 28
  }),
  'neom': Object.assign({}, GOLD_ACCENT, {
    label: 'NEOM — The Line Investment Zone',
    labelAr: 'نيوم — منطقة الاستثمار',
    tagline: 'Building the future. NEOM.',
    taglineAr: 'نبني المستقبل. نيوم.',
    navName: 'NEOM Opportunity Hub',
    navNameAr: 'منصة نيوم للفرص',
    logo: 'https://upload.wikimedia.org/wikipedia/commons/1/13/NEOM_Text_Logo.svg',
    logoDark: 'https://upload.wikimedia.org/wikipedia/commons/1/13/NEOM_Text_Logo.svg',
    logoHeight: 22
  }),
  'sdb': Object.assign({}, GOLD_ACCENT, {
    label: 'Saudi Development Bank',
    labelAr: 'بنك التنمية السعودي',
    tagline: 'Financing the Future of Saudi Arabia',
    taglineAr: 'تمويل مستقبل المملكة',
    navName: 'SDB Intelligence',
    navNameAr: 'بنك التنمية — منصة الفرص',
    logo: 'https://www.sdb.gov.sa/SiteFiles/images/logo.svg',
    logoDark: 'https://www.sdb.gov.sa/SiteFiles/images/logo.svg',
    logoHeight: 30
  }),
  'swift-solve': Object.assign({}, GOLD_ACCENT, {
    label: 'Swift Solve',
    labelAr: 'سويفت سولف',
    tagline: 'Investment Intelligence Platform',
    taglineAr: 'منصة ذكاء الاستثمار',
    navName: 'Swift Solve',
    navNameAr: 'سويفت سولف',
    /* Drop the real brand asset at assets/logo-swift-solve.png and the
       sidebar + theme-manager card pick it up automatically. While the
       file is missing, the existing onerror handlers fall back to the
       gold swatch + text, so the theme still looks on-brand. */
    logo: 'assets/logo-swift-solve.png',
    logoDark: 'assets/logo-swift-solve.png',
    logoHeight: 30,
    /* Swift Solve's mark is icon-only (no wordmark), so render the
       brand name alongside it in white. NEOM/MISA/etc. don't set this
       because their logo files already contain their wordmark. */
    showName: true,
    pageTitle: 'Swift Solve — Investment Intelligence Platform'
  }),
  'abdul-latif-jameel': Object.assign({}, ALJ_BLUE, {
    label: 'Abdul Latif Jameel',
    labelAr: 'عبداللطيف جميل',
    tagline: 'Investing in opportunity since 1945',
    taglineAr: 'نستثمر في الفرص منذ عام 1945',
    navName: 'Abdul Latif Jameel',
    navNameAr: 'عبداللطيف جميل',
    /* Official ALJ lockup (grey wordmark + blue pentagon mark). The asset
       has a white background and already contains the wordmark, so
       showName is false (no duplicate text) and the brand area renders it
       on a white chip — see the .app-sidebar-brand override in
       polish-overrides.css. */
    logo: 'assets/logo-abdul-latif-jameel.png',
    logoDark: 'assets/logo-abdul-latif-jameel.png',
    logoHeight: 26,
    showName: false,
    pageTitle: 'Abdul Latif Jameel — Opportunity Intelligence'
  })
};

window.__ohActiveTheme = 'default';

window.applyTheme = function (key) {
  var t = window.OH_THEMES[key] || window.OH_THEMES['default'];
  var r = document.documentElement;

  /* Per-mode accent palette. Themes may opt-in to a brighter dark-mode
     variant via `darkAccent*` fields — pure-navy primaries like Swift
     Solve are invisible against dark surface tokens, so we swap. Themes
     without darkAccent* fields keep the legacy single-palette behaviour. */
  var isDarkMode  = r.getAttribute('data-theme') === 'dark';
  var accent      = (isDarkMode && t.darkAccent)       ? t.darkAccent       : t.accent;
  var accentHover = (isDarkMode && t.darkAccentHover)  ? t.darkAccentHover  : t.accentHover;
  var accentLight = (isDarkMode && t.darkAccentLight)  ? t.darkAccentLight  : t.accentLight;
  var accentGlow  = (isDarkMode && t.darkAccentGlow)   ? t.darkAccentGlow   : t.accentGlow;
  var accentDim   = (isDarkMode && t.darkAccentDim)    ? t.darkAccentDim    : t.accentDim;

  /* Legacy --green* tokens (original brand palette) */
  r.style.setProperty('--green',           accent);
  r.style.setProperty('--green-hover',     accentHover);
  r.style.setProperty('--green-highlight', accentLight);
  r.style.setProperty('--green-glow',      accentGlow);
  r.style.setProperty('--green-dim',       accentDim);
  /* New design-system --accent* tokens (used by Phase D + admin views) */
  r.style.setProperty('--accent',          accent);
  r.style.setProperty('--accent-hover',    accentHover);
  r.style.setProperty('--accent-light',    accentLight);
  r.style.setProperty('--accent-glow',     accentGlow);
  /* Sidebar active-state + focus ring derive from the same accent */
  r.style.setProperty('--sidebar-active-bg',     accentLight);
  r.style.setProperty('--sidebar-active-border', accent);
  r.style.setProperty('--shadow-focus',          '0 0 0 3px ' + accentGlow);

  /* Brand text in the sidebar (data-ar holds Arabic) */
  var brandSpan = document.querySelector('.app-sidebar-brand span[data-ar]');
  if (brandSpan) {
    var isAr = document.documentElement.lang === 'ar' || document.body.dir === 'rtl';
    brandSpan.textContent = isAr ? t.navNameAr : t.navName;
    brandSpan.setAttribute('data-ar', t.navNameAr);
    brandSpan.setAttribute('data-en', t.navName);
  }

  /* ── Logo swap (institution image replaces brand-dot + text) */
  var navLogo     = document.querySelector('.app-sidebar-brand');
  var navLogoText = brandSpan;
  var brandDot    = navLogo && navLogo.querySelector('.brand-dot');
  var isDark      = isDarkMode;
  var logoUrl     = isDark ? (t.logoDark || t.logo) : t.logo;

  /* Brand container background should track the resolved accent (so the
     dark-mode brighter variant shows in dark mode, navy in light mode). */
  if (navLogo) navLogo.style.background = accent;

  if (logoUrl && navLogo) {
    var navLogoImg = document.getElementById('ohThemeLogoImg');
    if (!navLogoImg) {
      navLogoImg = document.createElement('img');
      navLogoImg.id = 'ohThemeLogoImg';
      navLogoImg.style.cssText = 'height:' + (t.logoHeight || 28) + 'px;max-width:160px;width:auto;object-fit:contain;display:block;flex-shrink:0;';
      navLogo.insertBefore(navLogoImg, navLogo.firstChild);
    }
    navLogoImg.src = logoUrl;
    navLogoImg.alt = t.label;
    navLogoImg.style.height = (t.logoHeight || 28) + 'px';
    navLogoImg.style.maxWidth = '160px';
    navLogoImg.style.flexShrink = '0';
    navLogoImg.style.display = 'block';
    if (brandDot) brandDot.style.display = 'none';
    /* showName=true keeps the wordmark visible next to icon-only logos
       (e.g. Swift Solve); themes with wordmark logo files leave it
       hidden so the name isn't duplicated. */
    if (navLogoText) {
      if (t.showName) {
        navLogoText.style.display = '';
        navLogoText.style.color = '#fff';
        navLogoText.textContent = (document.documentElement.lang === 'ar' || document.body.dir === 'rtl') ? t.navNameAr : t.navName;
      } else {
        navLogoText.style.display = 'none';
        navLogoText.style.color = '';
      }
    }
    /* Broken image → restore text + dot */
    navLogoImg.onerror = function () {
      this.style.display = 'none';
      if (brandDot)    brandDot.style.display = '';
      if (navLogoText) {
        navLogoText.style.display = '';
        navLogoText.style.color = t.showName ? '#fff' : '';
        navLogoText.textContent = (document.documentElement.lang === 'ar' || document.body.dir === 'rtl') ? t.navNameAr : t.navName;
      }
    };
  } else {
    /* No logo URL — restore platform brand-dot + text */
    var themeImg = document.getElementById('ohThemeLogoImg');
    if (themeImg) themeImg.style.display = 'none';
    if (brandDot)    brandDot.style.display = '';
    if (navLogoText) {
      navLogoText.style.display = '';
      navLogoText.style.color = '';
    }
  }

  /* Page title — themes may override the full string via t.pageTitle
     (used by Swift Solve to read "Investment Intelligence Platform"). */
  document.title = t.pageTitle || (t.label + ' — Intelligence Platform');

  /* Hero/dash tagline if any matching element exists (graceful no-op otherwise) */
  var tagEl = document.querySelector('.hero-tagline, .hero-sub, .hero-subtitle, .dash-sub');
  if (tagEl) {
    var isAr2 = document.documentElement.lang === 'ar' || document.body.dir === 'rtl';
    tagEl.textContent = isAr2 ? t.taglineAr : t.tagline;
  }

  window.__ohActiveTheme = key;
  /* Expose the active theme key on <html> so per-tenant CSS can target it
     (e.g. a white brand-pill for logos that ship on a white background). */
  r.setAttribute('data-oh-theme', key);
  try { localStorage.setItem('oh_theme', key); } catch(e) {}

  /* Refresh the admin theme manager UI if open */
  document.querySelectorAll('.oh-tm-card.oh-tm-card--active').forEach(function (c) {
    c.classList.remove('oh-tm-card--active');
  });
  document.querySelectorAll('.oh-tm-card-check').forEach(function (c) { c.textContent = ''; });
  var newCard = document.querySelector('.oh-tm-card[data-theme-key="' + key + '"]');
  if (newCard) {
    newCard.classList.add('oh-tm-card--active');
    var chk = newCard.querySelector('.oh-tm-card-check');
    if (chk) chk.textContent = '✓';
  }
};

/* Restore on load — also support ?theme=xxx URL param for shareable demo links */
(function () {
  try {
    var urlTheme = new URLSearchParams(window.location.search).get('theme');
    var saved = localStorage.getItem('oh_theme') || 'default';
    window.applyTheme(urlTheme || saved);
  } catch(e) { window.applyTheme('default'); }
})();

/* Re-resolve the accent palette when light↔dark toggles, so themes
   that opt into a brighter dark-mode variant (e.g. Swift Solve)
   swap their primary tokens at the same time the surface tokens flip. */
(function watchThemeMode() {
  var obs = new MutationObserver(function (muts) {
    for (var i = 0; i < muts.length; i++) {
      if (muts[i].type === 'attributes' && muts[i].attributeName === 'data-theme') {
        if (typeof window.applyTheme === 'function') {
          window.applyTheme(window.__ohActiveTheme || 'default');
        }
        break;
      }
    }
  });
  obs.observe(document.documentElement, { attributes: true });
})();
