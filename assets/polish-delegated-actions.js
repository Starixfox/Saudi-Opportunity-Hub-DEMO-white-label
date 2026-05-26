/* ============================================================================
   Saudi Opportunity Hub — delegated action handler
   ----------------------------------------------------------------------------
   Replaces the 17 inline onclick="…" attributes on static sidebar / topbar
   / home-screen buttons with a single document-level click listener that
   routes by data-action / data-arg attributes.

   Why: inline event handlers prevent tightening the CSP off
   'unsafe-inline' for script-src. They also make the markup harder to
   read and audit. Routing by data-* attributes keeps the same surface
   semantics (auto-discoverable, declarative) without the inline-JS
   smell.

   Supported actions:
     data-action="open-panel"        data-arg="watchlist"|"searches"|"recent"
     data-action="open-settings"
     data-action="set-route"         data-arg="opportunities"|"dashboard"|
                                              "sectors"|"saved"|"about"
     data-action="new-this-week"
     data-action="reload"            page reload (used by error retry buttons)
     data-action="reset-filters"     triggers a click on #resetBtn
     data-action="toggle-bookmark"   forwards to WS.toggleBookmark(trigger)
     data-action="la-compare"        forwards to window._laCompare(trigger)
============================================================================ */

(function () {
  'use strict';

  function handle(action, arg, trigger) {
    switch (action) {
      case 'open-panel':
        if (window.WS && typeof window.WS.openPanel === 'function') {
          window.WS.openPanel(arg);
        }
        break;
      case 'open-settings':
        if (window.WS && typeof window.WS.openSettings === 'function') {
          window.WS.openSettings();
        }
        break;
      case 'set-route':
        if (typeof window.setRoute === 'function') {
          window.setRoute(arg);
        }
        break;
      case 'new-this-week':
        window.__newThisWeekFilter = true;
        if (typeof window.setRoute === 'function') {
          window.setRoute('opportunities');
        }
        break;
      case 'reload':
        window.location.reload();
        break;
      case 'reset-filters': {
        var reset = document.getElementById('resetBtn');
        if (reset) reset.click();
        break;
      }
      case 'toggle-bookmark':
        if (window.WS && typeof window.WS.toggleBookmark === 'function') {
          window.WS.toggleBookmark(trigger);
        }
        break;
      case 'la-compare':
        if (typeof window._laCompare === 'function') {
          window._laCompare(trigger);
        }
        break;
      default:
        // Unknown actions are silently ignored — same defensive posture as
        // the inline onclicks they replace.
        break;
    }
  }

  document.addEventListener('click', function (event) {
    // closest() walks up from the actual click target so clicks on an
    // <i> icon or text node inside the button still resolve to the button.
    var trigger = event.target && event.target.closest ? event.target.closest('[data-action]') : null;
    if (!trigger) return;
    var action = trigger.getAttribute('data-action');
    var arg = trigger.getAttribute('data-arg');
    if (!action) return;
    // Don't prevent default on links that should still navigate; only the
    // buttons we own here are tagged with data-action, and they don't have
    // an href to follow.
    handle(action, arg, trigger);
  });
})();
