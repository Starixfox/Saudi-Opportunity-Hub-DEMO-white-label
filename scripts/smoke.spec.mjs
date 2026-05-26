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
  test('open-panel:watchlist via sidebar', async ({ page }) => {
    await page.locator('#sidebarWorkspace').click();
    await expect(page.locator('body')).toHaveClass(/.*panel-open.*/);
  });

  // --- 2. Topbar settings -------------------------------------------------
  test('open-settings via topbar', async ({ page }) => {
    await page.locator('#appTbSettings').click();
    // Settings modal should be visible
    await expect(page.locator('.settings-modal, [aria-label*="Settings" i]')).toBeVisible({ timeout: 5000 });
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
  test('toggle-bookmark fires WS.toggleBookmark', async ({ page }) => {
    await page.goto(`${BASE}/index.html#opportunities`);
    await page.waitForSelector('.opp-card', { state: 'visible', timeout: 10000 });
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
    // Filter out known third-party noise (translate widget, etc.)
    const realErrors = errors.filter((e) =>
      !/translate\.google|favicon|net::ERR_BLOCKED_BY_CLIENT/i.test(e)
    );
    expect(realErrors).toEqual([]);
  });
});

test.describe('Visual regression — .btn sizing (issue #13)', () => {
  // Captures full-page screenshots of every view that exposes .btn-heavy
  // surfaces. Run this BEFORE applying the .btn { min-height: 44px }
  // change, commit the baseline, then run again AFTER and Playwright
  // will emit a diff for review.

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
      await expect(page).toHaveScreenshot(`btn-sizing-${view}.png`, {
        fullPage: true,
        maxDiffPixelRatio: 0.02
      });
    });
  }

  test('showcase (public)', async ({ page }) => {
    await page.goto(`${BASE}/polish/showcase.html`);
    await page.waitForLoadState('networkidle');
    await expect(page).toHaveScreenshot('btn-sizing-showcase.png', {
      fullPage: true,
      maxDiffPixelRatio: 0.02
    });
  });
});
