import { expect, test } from '@playwright/test';

const VIEWPORTS = [
  { name: 'large desktop', width: 1440, height: 900, targetFloor: 40 },
  { name: 'compact desktop', width: 1280, height: 800, targetFloor: 40 },
  { name: 'mobile', width: 390, height: 844, targetFloor: 44 },
] as const;

test.describe('Ondo tarot card slot sizing', () => {
  for (const viewport of VIEWPORTS) {
    test(`keeps every numbered card target usable at ${viewport.name}`, async ({ page }) => {
      await page.setViewportSize(viewport);
      await page.goto('/');
      const fixture = page.locator('main').first();
      await fixture.evaluate((main) => {
        main.innerHTML = `
          <fieldset style="border: 0; margin: 0; padding: 0">
            <legend class="ondo-label">카드 고르기 (0/3)</legend>
            <div class="ondo-row">
              ${Array.from({ length: 12 }, (_, index) => `
                <button
                  aria-label="${index + 1}번 카드"
                  aria-pressed="false"
                  class="ondo-chip ondo-tarot-card-slot"
                  type="button"
                >${index + 1}</button>
              `).join('')}
            </div>
          </fieldset>
        `;
      });

      const picker = fixture.getByRole('group', { name: /카드 고르기/ });
      const cards = picker.getByRole('button');
      await expect(cards).toHaveCount(12);

      for (const card of await cards.all()) {
        const box = await card.boundingBox();
        expect(box).not.toBeNull();
        expect(box!.width).toBeGreaterThanOrEqual(viewport.targetFloor);
        expect(box!.height).toBeGreaterThanOrEqual(viewport.targetFloor);
      }

      await expect(page.getByRole('button', { name: '1번 카드', exact: true })).toHaveAttribute('aria-pressed', 'false');
      const overflow = await page.evaluate(() => ({
        clientWidth: document.documentElement.clientWidth,
        scrollWidth: document.documentElement.scrollWidth,
      }));
      expect(overflow.scrollWidth).toBeLessThanOrEqual(overflow.clientWidth);
    });
  }
});
