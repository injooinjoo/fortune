import { expect, test } from '@playwright/test';

for (const viewport of [{ width: 1280, height: 720 }, { width: 390, height: 844 }, { width: 360, height: 740 }]) {
  test(`첫 화면에서 비용과 시작 버튼을 확인한다 (${viewport.width})`, async ({ page }) => {
    await page.setViewportSize(viewport);
    await page.goto('/');
    const primary = page.getByRole('link', { name: '오늘의 운세 보기', exact: true });
    await expect(primary).toBeInViewport({ ratio: 1 });
    await expect(page.getByRole('navigation', { name: '사이트 메뉴', exact: true })).toBeVisible();
    await expect(page.getByRole('navigation', { name: '사이트 메뉴', exact: true }).getByRole('link', { name: '오늘', exact: true })).toHaveAttribute('aria-current', 'page');
    const widths = await page.evaluate(() => ({ content: document.documentElement.scrollWidth, viewport: innerWidth }));
    expect(widths.content).toBeLessThanOrEqual(widths.viewport);
  });
}

test('모바일 메뉴는 Escape로 닫고 초점을 돌려준다', async ({ page }) => {
  await page.setViewportSize({ width: 390, height: 844 });
  await page.goto('/');
  const menu = page.locator('.ondo-mobile-menu');
  await menu.locator('summary').click();
  await expect(menu).toHaveAttribute('open', '');
  await menu.getByRole('link', { name: '로그인', exact: true }).focus();
  await page.keyboard.press('Escape');
  await expect(menu).not.toHaveAttribute('open');
  await expect(menu.locator('summary')).toBeFocused();
});

test.describe('실제 상세 경로의 입력과 탐색', () => {
  test.skip(!process.env.WEB_BASE_URL, '한글 경로를 제공하는 미리보기 환경에서 검증');

  test('운세 검색과 분류를 조합하고 빈 결과에서 복구한다', async ({ page }) => {
    await page.goto('/운세');
    const search = page.getByRole('searchbox', { name: '운세 검색' });
    await search.fill('타로');
    await expect(page.locator('.ondo-fortune-link')).toHaveCount(1);
    await expect(page.locator('.ondo-fortune-link')).toContainText('오늘의 타로');
    await search.fill('찾을수없는운세');
    await expect(page.getByText('조건에 맞는 운세가 없어요.')).toBeVisible();
    await page.getByRole('button', { name: '전체 운세 보기', exact: true }).click();
    await expect(search).toHaveValue('');
    await expect(page.locator('.ondo-fortune-link')).toHaveCount(13);
  });

  test('키보드로 출생 연도를 열고 선택한 뒤 월로 이동한다', async ({ page }) => {
    await page.goto('/운세/오늘');
    const year = page.getByRole('combobox', { name: '출생 연도' });
    await year.focus();
    await page.keyboard.press('ArrowDown');
    await expect(page.getByRole('listbox', { name: '출생 연도' })).toBeVisible();
    await page.getByRole('option', { name: '1990년', exact: true }).click();
    await year.press('ArrowDown');
    await page.keyboard.press('Tab');
    await expect(page.getByRole('listbox', { name: '출생 연도' })).toHaveCount(0);
    await expect(page.getByRole('combobox', { name: '출생 월' })).toBeFocused();
  });

  test('상세 화면에서도 현재 메뉴를 알려준다', async ({ page }) => {
    await page.goto('/운세/오늘');
    const nav = page.getByRole('navigation', { name: '사이트 메뉴', exact: true });
    await expect(nav.getByRole('link', { name: '운세', exact: true })).toHaveAttribute('aria-current', 'page');
  });

  test('읽는 동안 입력을 잠그고 실패 복구와 결과 재입력까지 이어진다', async ({ page }) => {
    await page.setViewportSize({ width: 390, height: 844 });
    await page.route('**/auth/v1/signup*', (route) => route.fulfill({
      status: 400, contentType: 'application/json', body: JSON.stringify({ message: 'Disabled in test.' }),
    }));
    await page.route('**/rest/v1/rpc/record_web_analytics_event', (route) => route.fulfill({ status: 204 }));
    await page.route('**/rest/v1/rpc/save_web_fortune_history', (route) => route.fulfill({
      status: 200, contentType: 'application/json', body: JSON.stringify('00000000-0000-0000-0000-000000000001'),
    }));
    let releaseFirst!: () => void;
    const waiting = new Promise<void>((resolve) => { releaseFirst = resolve; });
    let requests = 0;
    await page.route('**/functions/v1/fortune-daily', async (route) => {
      requests += 1;
      if (requests === 1) {
        await waiting;
        await route.fulfill({ status: 500, contentType: 'application/json', body: JSON.stringify({ error: '잠시 후 다시 시도해 주세요.' }) });
      } else {
        await route.fulfill({ status: 200, contentType: 'application/json', body: JSON.stringify({ fortune: { overall_score: 84, summary: '오늘은 한 가지 일에 집중해 보세요.' }, cached: false }) });
      }
    });
    await page.goto('/운세/오늘');
    const year = page.getByRole('combobox', { name: '출생 연도' });
    await year.click();
    await page.getByRole('option', { name: '1990년', exact: true }).click();
    await page.getByRole('combobox', { name: '출생 월' }).selectOption('2');
    await page.getByRole('combobox', { name: '출생 일' }).selectOption('28');
    await page.getByRole('button', { name: '오늘의 운세 보기', exact: true }).click();
    await expect(year).toBeDisabled();
    await expect(page.getByRole('status')).toContainText('오늘의 흐름을 읽고 있어요');
    releaseFirst();
    await expect(page.locator('.ondo-notice[role="alert"]')).toBeFocused();
    await expect(year).toBeEnabled();
    await expect(year).toHaveText('1990년');
    await page.getByRole('button', { name: '오늘의 운세 보기', exact: true }).click();
    await expect(page.getByRole('region', { name: '오늘의 운세 결과' })).toBeFocused();
    await page.getByRole('button', { name: '정보 다시 입력' }).click();
    await expect(year).toBeFocused();
    await expect(year).toHaveText('1990년');
    expect(requests).toBe(2);
  });
});
