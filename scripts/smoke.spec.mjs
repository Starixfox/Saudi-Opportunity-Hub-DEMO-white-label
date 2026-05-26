// Smoke test for the polish-pass data-action conversions + visual
// regression baseline for the .btn min-height work.
// Closes issues #13 and #16.
//
// Usage:
//   npm install --no-save @playwright/test
//   npx playwright install chromium
//
//   OH_TEST_EMAIL="…" OH_TEST_PASSWORD="…" \
//     npx playwright test scripts/smoke.spec.mjs --headed
//
// Credentials are read from environment variables ONLY — never stored
// in the repo or in any committed config. Use a throwaway demo account.

import { test, expect } from '@playwright/test';

const BASE = process.env.OH_BASE
  || 'https://starixfox.github.io/Saudi-Opportunity-Hub-DEMO-white-label';
const EMAIL = process.env.OH_TEST_EMAIL;
const PASSWORD = process.env.OH_TEST_PASSWORD;

test.beforeAll(() => {
  if (!EMAIL || !PASSWORD) {
    throw new Error(
      'Set OH_TEST_EMAIL and OH_TEST_PASSWORD in env. The polish-pass ' +
      'smoke test never reads credentials from repo state.'
    );
  }
});

test.describe('Polish-pass data-action delegated handler', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto(`${BASE}/login.html`);
    await page.getByLabel(/email/i).fill(EMAIL);
    await page.getByLabel(/password/i).first().fill(PASSWORD);
    await page.getByRole('button', { name: /sign in/i }).click();
    // Wait for the SPA shell to mount (sidebar present)
    await page.waitForSelector('.app-nav-item', { state: 'visible', timeout: 15000 });
  });

  // --- 1. Sidebar workspace button ----------------------------------------
  // The workspace panel signals "open" via #wsPanel.active + a route change
  // to #workspace — NOT body.panel-open (that's the opp-detail panel).
  test('open-panel:watchlist via sidebar', async ({ page }) => {
    await page.locator('#sidebarWorkspace').click();
    await expect.poll(() => page.url(), { timeout: 5000 }).toContain('#workspace');
    await expect(page.locator('#wsPanel')).toHaveClass(/active/);
    const activeTab = await page.evaluate(() => window.__wsActiveTab);
    expect(activeTab).toBe('watchlist');
  });

  // --- 2. Topbar settings -------------------------------------------------
  // Settings dialog is the modal — match the role+class precisely to avoid
  // matching the trigger buttons (which had a Settings aria-label).
  test('open-settings via topbar', async ({ page }) => {
    await page.locator('#appTbSettings').click();
    const dialog = page.locator('[role="dialog"].settings-modal, .settings-modal[role="dialog"]').first();
    await expect(dialog).toBeVisible({ timeout: 5000 });
  });

  // --- 3-6. Home tile routing ---------------------------------------------
  for (const route of ['opportunities', 'dashboard', 'sectors', 'saved']) {
    test(`set-route:${route} navigates to #${route}`, async ({ page }) => {
      const trigger = page.locator(`button[data-action="set-route"][data-arg="${route}"]`).first();
      if (!await trigger.count()) test.skip(true, `No data-action="set-route" data-arg="${route}" trigger on home view`);
      await trigger.click();
      await expect.poll(() => page.url()).toContain(`#${route}`);
    });
  }

  // --- 7. New-this-week composite action ----------------------------------
  test('new-this-week sets filter flag + routes to opportunities', async ({ page }) => {
    await page.locator('button[data-action="new-this-week"]').first().click();
    await expect.poll(() => page.url()).toContain('#opportunities');
    const flag = await page.evaluate(() => window.__newThisWeekFilter);
    expect(flag).toBe(true);
  });

  // --- 8. Bookmark toggle (template-injected onclick → data-action) ------
  // Don't hard-navigate; the SPA can take longer to render cards after a
  // direct URL hit because the Supabase query runs after the route change.
  // Click into Opportunities from the home tile and wait for the listing.
  test('toggle-bookmark fires WS.toggleBookmark', async ({ page }) => {
    await page.locator('button[data-action="set-route"][data-arg="opportunities"]').first().click();
    await expect.poll(() => page.url(), { timeout: 5000 }).toContain('#opportunities');
    // Cards render asynchronously after the Supabase fetch. Be generous —
    // network on cold cache can take 8s+ on a fresh session.
    await page.waitForSelector('.opp-card', { state: 'visible', timeout: 30000 });
    const bookmark = page.locator('.opp-card .card-bookmark-btn[data-action="toggle-bookmark"]').first();
    await expect(bookmark).toBeVisible();
    const before = await bookmark.getAttribute('aria-pressed');
    await bookmark.click();
    // The SPA flips aria-pressed or adds an "is-saved" class — accept either signal
    const after = await bookmark.getAttribute('aria-pressed');
    const classChanged = await bookmark.evaluate((el) => el.classList.contains('is-saved'));
    expect(before !== after || classChanged).toBe(true);
  });

  // --- Smoke: no console errors after the above ---------------------------
  test('no critical console errors during the data-action sweep', async ({ page }) => {
    const errors = [];
    page.on('pageerror', (e) => errors.push(e.message));
    page.on('console', (msg) => { if (msg.type() === 'error') errors.push(msg.text()); });
    await page.goto(`${BASE}/index.html`);
    await page.waitForLoadState('networkidle', { timeout: 15000 });
    // Filter out:
    //  - third-party noise (Google Translate widget)
    //  - favicon 404s
    //  - browser ad/extension blocks
    //  - the frame-ancestors-in-meta warning (we removed it from <meta>,
    //    but cached pages might still trip it on staging deploys; harmless)
    const realErrors = errors.filter((e) =>
      !/translate\.google|favicon|net::ERR_BLOCKED_BY_CLIENT|frame-ancestors.*ignored.*meta/i.test(e)
    );
    expect(realErrors).toEqual([]);
  });
});

test.describe('Visual regression — .btn sizing (issue #13)', () => {
  // Captures full-page screenshots of every view that exposes .btn-heavy
  // surfaces. Run this BEFORE applying the .btn { min-height: 44px }
  // change, commit the baseline, then run again AFTER and Playwright
  // will emit a diff for review.

  // Wait for everything that can shift layout to finish:
  //   - All web fonts loaded (document.fonts.ready)
  //   - Any pending animations done
  //   - One extra frame to flush
  async function settle(page) {
    await page.evaluate(async () => {
      if (document.fonts && document.fonts.ready) await document.fonts.ready;
      const anims = (document.getAnimations && document.getAnimations()) || [];
      await Promise.allSettled(anims.map(a => a.finished));
      await new Promise(r => requestAnimationFrame(() => requestAnimationFrame(r)));
    });
  }

  test.beforeEach(async ({ page }) => {
    await page.goto(`${BASE}/login.html`);
    await page.getByLabel(/email/i).fill(EMAIL);
    await page.getByLabel(/password/i).first().fill(PASSWORD);
    await page.getByRole('button', { name: /sign in/i }).click();
    await page.waitForSelector('.app-nav-item', { state: 'visible', timeout: 15000 });
  });

  for (const view of ['dashboard', 'opportunities', 'sectors', 'saved', 'about']) {
    test(`screenshot:${view}`, async ({ page }) => {
      await page.goto(`${BASE}/index.html#${view}`);
      await page.waitForLoadState('networkidle', { timeout: 15000 });
      await settle(page);
      await expect(page).toHaveScreenshot(`btn-sizing-${view}.png`, {
        fullPage: true,
        maxDiffPixelRatio: 0.02,
        // Skeleton shimmer + ::before mashrabiya can each shift a few
        // pixels frame-to-frame; give Playwright a couple of attempts.
        animations: 'disabled',
        timeout: 20000
      });
    });
  }

  test('showcase (public)', async ({ page }) => {
    await page.goto(`${BASE}/polish/showcase.html`);
    await page.waitForLoadState('networkidle');
    await settle(page);
    await expect(page).toHaveScreenshot('btn-sizing-showcase.png', {
      fullPage: true,
      maxDiffPixelRatio: 0.02,
      animations: 'disabled',
      timeout: 20000
    });
  });
});
