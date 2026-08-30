const { test, expect } = require('@playwright/test');

const TODAY_PATH = '/운세/오늘';

async function layoutMetrics(page) {
  return page.locator('[data-testid="daily-layout"]').evaluate((layout) => {
    const panel = layout.querySelector('[data-testid="daily-form-panel"]');
    const context = layout.querySelector('[data-testid="daily-context"]');
    const submit = layout.querySelector('button[type="submit"]');
    const readingGuide = layout.querySelector('.ondo-daily-guide');
    const birthYear = layout.querySelector('[aria-label="출생 연도"]');
    if (!panel || !context || !submit || !readingGuide || !birthYear) {
      throw new Error('daily layout landmarks are missing');
    }

    const layoutRect = layout.getBoundingClientRect();
    const contextRect = context.getBoundingClientRect();
    const panelRect = panel.getBoundingClientRect();
    const submitRect = submit.getBoundingClientRect();
    const birthYearRect = birthYear.getBoundingClientRect();

    return {
      columns: getComputedStyle(layout).gridTemplateColumns,
      layoutWidth: layoutRect.width,
      contextLeft: contextRect.left,
      contextTop: contextRect.top,
      panelLeft: panelRect.left,
      panelTop: panelRect.top,
      panelWidth: panelRect.width,
      readingGuideDisplay: getComputedStyle(readingGuide).display,
      birthYearTop: birthYearRect.top,
      submitBottom: submitRect.bottom,
      submitTop: submitRect.top,
      submitWidth: submitRect.width,
      clientWidth: document.documentElement.clientWidth,
      scrollWidth: document.documentElement.scrollWidth,
    };
  });
}

test.describe('Ondo daily fortune responsive journey', () => {
  for (const [width, height] of [[1440, 900], [1280, 800]]) {
    test(`uses a focused desktop form instead of stretching mobile controls at ${width}px`, async ({ page }) => {
      await page.setViewportSize({ width, height });
      await page.goto(TODAY_PATH);
      await expect(page.getByRole('form', { name: '오늘의 운세 입력' })).toBeVisible();

      const metrics = await layoutMetrics(page);
      expect(metrics.columns.split(' ').length).toBe(2);
      expect(metrics.contextLeft).toBeLessThan(metrics.panelLeft);
      expect(metrics.panelWidth).toBeLessThanOrEqual(620);
      expect(metrics.submitWidth).toBeLessThanOrEqual(560);
      expect(metrics.readingGuideDisplay).not.toBe('none');
      expect(metrics.submitBottom).toBeLessThanOrEqual(height);
      expect(metrics.scrollWidth).toBeLessThanOrEqual(metrics.clientWidth);

      const timeOptions = page.getByRole('group', { name: '태어난 시간 (선택)' }).getByRole('button');
      const first = await timeOptions.nth(0).boundingBox();
      const second = await timeOptions.nth(1).boundingBox();
      const third = await timeOptions.nth(2).boundingBox();
      const fourth = await timeOptions.nth(3).boundingBox();
      const fifth = await timeOptions.nth(4).boundingBox();
      expect(first).not.toBeNull();
      expect(second).not.toBeNull();
      expect(third).not.toBeNull();
      expect(fourth).not.toBeNull();
      expect(fifth).not.toBeNull();
      expect(Math.abs(first.y - second.y)).toBeLessThan(2);
      expect(Math.abs(first.y - third.y)).toBeLessThan(2);
      expect(Math.abs(first.y - fourth.y)).toBeLessThan(2);
      expect(fifth.y).toBeGreaterThan(first.y);
    });
  }

  test('keeps the mobile flow compact and free of horizontal overflow', async ({ page }) => {
    await page.setViewportSize({ width: 390, height: 844 });
    await page.goto(TODAY_PATH);
    await expect(page.getByRole('form', { name: '오늘의 운세 입력' })).toBeVisible();

    const metrics = await layoutMetrics(page);
    expect(metrics.columns.split(' ').length).toBe(1);
    expect(metrics.panelTop).toBeGreaterThan(metrics.contextTop);
    expect(metrics.panelWidth).toBeLessThanOrEqual(358);
    expect(metrics.readingGuideDisplay).toBe('none');
    expect(metrics.birthYearTop).toBeLessThanOrEqual(500);
    expect(metrics.submitBottom).toBeLessThanOrEqual(844);
    expect(metrics.scrollWidth).toBeLessThanOrEqual(metrics.clientWidth);

    const timeDisclosure = page.getByRole('button', { name: '태어난 시간을 알고 있어요' });
    const mobileTimeField = page.locator('.ondo-birth-time-mobile');
    await expect(timeDisclosure).toBeVisible();
    await expect(mobileTimeField.getByRole('button', { name: '10:00~12:00', exact: true })).toHaveCount(0);

    await timeDisclosure.click();
    await expect(mobileTimeField.getByRole('button', { name: '10:00~12:00', exact: true })).toBeVisible();
    await mobileTimeField.getByRole('button', { name: '10:00~12:00', exact: true }).click();
    await expect(mobileTimeField.getByRole('button', { name: '10:00~12:00', exact: true })).toHaveCount(0);
    await expect(page.getByRole('button', { name: '10:00~12:00 선택됨 · 바꾸기' })).toBeVisible();

    await expect(page.getByRole('button', { name: '오늘의 운세 보기' })).toBeVisible();
  });

  test('lets people enter first and explains account connection only at the value boundary', async ({ page }) => {
    await page.goto(TODAY_PATH);
    await expect(page.getByRole('form', { name: '오늘의 운세 입력' })).toBeVisible();

    const form = page.getByRole('form', { name: '오늘의 운세 입력' });
    await expect(form).toBeVisible();
    await expect(form.getByText(/로그인 없이 바로 확인/)).toBeVisible();
    await expect(form.getByText(/결과를 저장하거나 온도가 더 필요할 때만 계정을 연결/)).toBeVisible();
    await expect(form.getByRole('link', { name: '개인정보처리방침' })).toHaveAttribute('href', '/privacy');
    await expect(form.getByRole('link', { name: /로그인/ })).toHaveCount(0);
  });

  test('moves a scrolled mobile user to the start of a completed reading', async ({ page }) => {
    await page.setViewportSize({ width: 390, height: 844 });
    await page.route('**/rest/v1/rpc/record_web_analytics_event', (route) =>
      route.fulfill({ status: 204 }),
    );
    await page.route('**/auth/v1/signup*', (route) =>
      route.fulfill({
        status: 400,
        contentType: 'application/json',
        body: JSON.stringify({ code: 'anonymous_provider_disabled', message: 'Disabled in test.' }),
      }),
    );
    await page.route('**/functions/v1/fortune-daily', (route) =>
      route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          fortune: {
            overall_score: 84,
            summary: '오늘은 우선순위를 정하면 흐름이 안정적으로 이어져요.',
            advice: '가장 중요한 일부터 시작해 보세요.',
            caution: '한꺼번에 너무 많은 일을 벌이지 마세요.',
          },
          cached: false,
        }),
      }),
    );
    await page.route('**/rest/v1/rpc/save_web_fortune_history', (route) =>
      route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify('00000000-0000-0000-0000-000000000001'),
      }),
    );

    await page.goto(TODAY_PATH);
    await page.getByRole('combobox', { name: '출생 연도' }).click();
    await page.getByRole('listbox', { name: '출생 연도' }).getByRole('option', { name: '1990년' }).click();
    await page.getByRole('combobox', { name: '출생 월' }).selectOption('1');
    await page.getByRole('combobox', { name: '출생 일' }).selectOption('1');

    await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
    await expect.poll(() => page.evaluate(() => window.scrollY)).toBeGreaterThan(0);
    await page.locator('form').evaluate((form) => form.requestSubmit());

    const result = page.getByRole('region', { name: '오늘의 운세 결과' });
    await expect(result).toBeVisible();
    await expect(result).toBeFocused();
    await expect.poll(() => page.evaluate(() => window.scrollY)).toBeLessThanOrEqual(1);
    await expect.poll(() => result.evaluate((element) => element.getBoundingClientRect().top)).toBeGreaterThanOrEqual(0);
    await expect.poll(() => result.evaluate((element) => element.getBoundingClientRect().top)).toBeLessThan(844);
  });

  for (const [width, height, desktop] of [[1280, 800, true], [390, 844, false]]) {
    test(`expands the result into a ${desktop ? 'desktop-wide' : 'mobile-stacked'} reading at ${width}px`, async ({ page }) => {
      await page.setViewportSize({ width, height });
      await page.goto('/');
      const layout = page.locator('main').first();
      await layout.evaluate((element) => {
        element.setAttribute('class', 'ondo-shell ondo-daily-page');
        element.setAttribute('data-testid', 'daily-layout');
        element.innerHTML = `
          <div class="ondo-daily-layout">
            <section class="ondo-daily-context" data-testid="daily-context"></section>
            <section class="ondo-card ondo-daily-form-panel" data-testid="daily-form-panel">
              <section class="ondo-daily-result">
                <div class="ondo-result-hero ondo-stack"><p class="ondo-kicker">오늘의 운세</p><p class="ondo-h1">82점</p><p>오늘은 우선순위를 정하면 흐름이 안정적으로 이어져요.</p><p class="ondo-muted">상위 18%</p></div>
                <div class="ondo-daily-result-categories"><div></div><div></div><div></div></div>
                <div class="ondo-daily-result-body"><div></div><div></div></div>
              </section>
            </section>
          </div>`;
      });

      const metrics = await layout.evaluate((element) => {
        const grid = element.querySelector('.ondo-daily-layout');
        const panel = element.querySelector('[data-testid="daily-form-panel"]');
        const categories = element.querySelector('.ondo-daily-result-categories');
        const body = element.querySelector('.ondo-daily-result-body');
        const hero = element.querySelector('.ondo-result-hero');
        return {
          columns: getComputedStyle(grid).gridTemplateColumns.split(' ').length,
          panelWidth: panel.getBoundingClientRect().width,
          categoryColumns: getComputedStyle(categories).gridTemplateColumns.split(' ').length,
          bodyColumns: getComputedStyle(body).gridTemplateColumns.split(' ').length,
          heroDisplay: getComputedStyle(hero).display,
          heroColumns: getComputedStyle(hero).gridTemplateColumns.split(' ').length,
          clientWidth: document.documentElement.clientWidth,
          scrollWidth: document.documentElement.scrollWidth,
        };
      });

      expect(metrics.columns).toBe(1);
      if (desktop) {
        expect(metrics.panelWidth).toBeGreaterThanOrEqual(1120);
      } else {
        expect(metrics.panelWidth).toBe(358);
      }
      expect(metrics.categoryColumns).toBe(desktop ? 3 : 1);
      expect(metrics.bodyColumns).toBe(desktop ? 2 : 1);
      if (desktop) {
        expect(metrics.heroDisplay).toBe('grid');
        expect(metrics.heroColumns).toBe(2);
      } else {
        expect(metrics.heroDisplay).toBe('flex');
      }
      expect(metrics.scrollWidth).toBeLessThanOrEqual(metrics.clientWidth);
    });
  }
});
