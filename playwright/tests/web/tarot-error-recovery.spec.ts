import { expect, test } from '@playwright/test';

const MOBILE_VIEWPORT = { width: 390, height: 844 };

test('타로 잔액 부족 안내에서 모바일 사용자가 로그인 복구 경로를 바로 선택할 수 있다', async ({ page }) => {
  test.setTimeout(90000);
  test.skip(!process.env.WEB_BASE_URL, '배포된 한글 경로에서 실행하는 여정 테스트입니다.');

  await page.setViewportSize(MOBILE_VIEWPORT);
  await page.route('**/rest/v1/rpc/record_web_analytics_event', async (route) => {
    await route.fulfill({ status: 204 });
  });
  await page.route('**/auth/v1/signup*', async (route) => {
    await route.fulfill({
      status: 400,
      contentType: 'application/json',
      body: JSON.stringify({
        code: 'anonymous_provider_disabled',
        message: 'Anonymous sign-ins are disabled for this test.',
      }),
    });
  });
  await page.route('**/functions/v1/fortune-tarot', async (route) => {
    await route.fulfill({
      status: 402,
      contentType: 'application/json',
      body: JSON.stringify({ code: 'insufficient_tokens', required: 5, available: 0 }),
    });
  });

  await page.goto('/');
  await page.getByRole('link', { name: '운세 전체 보기' }).click();
  await page.getByRole('link', { name: /오늘의 타로/ }).click();
  await expect(page.getByRole('heading', { name: '카드를 뽑아볼까요?' })).toBeVisible();
  const firstCard = page.getByRole('button', { name: '1번 카드', exact: true });
  await expect
    .poll(
      () => firstCard.evaluate((element) => Object.keys(element).some((key) => key.startsWith('__reactProps$'))),
      { timeout: 30000 },
    )
    .toBe(true);

  for (const slot of [1, 2, 3]) {
    const card = page.getByRole('button', { name: `${slot}번 카드`, exact: true });
    await card.click();
    await expect(card).toHaveAttribute('aria-pressed', 'true');
  }
  await expect(page.getByRole('button', { name: '타로 리딩 보기' })).toBeEnabled();
  await page.getByRole('button', { name: '타로 리딩 보기' }).click();

  const alert = page.getByRole('alert').filter({ hasText: '온도가 부족해요' });
  await expect(alert).toContainText('로그인하면 계정에 남은 온도를 확인하고 이어서 볼 수 있어요.');
  await expect(alert).not.toContainText('앱에서 온도를 충전');
  await expect(alert).toBeFocused();

  const recoveryLink = alert.getByRole('link', { name: '로그인하고 온도 확인하기' });
  await expect(recoveryLink).toBeVisible();
  await expect(recoveryLink).toHaveAttribute(
    'href',
    '/auth/login?next=%2F%EC%9A%B4%EC%84%B8%2F%ED%83%80%EB%A1%9C',
  );
  await expect
    .poll(() => recoveryLink.evaluate((element) => element.getBoundingClientRect().height))
    .toBeGreaterThanOrEqual(44);

  await expect
    .poll(() => alert.evaluate((element) => element.getBoundingClientRect().top))
    .toBeGreaterThanOrEqual(0);
  await expect
    .poll(() => alert.evaluate((element) => element.getBoundingClientRect().bottom))
    .toBeLessThanOrEqual(MOBILE_VIEWPORT.height + 1);

  for (const slot of [1, 2, 3]) {
    await expect(page.getByRole('button', { name: `${slot}번 카드`, exact: true })).toHaveAttribute('aria-pressed', 'true');
  }
  await expect(page.getByRole('button', { name: '타로 리딩 보기' })).toBeEnabled();

  await recoveryLink.click();
  await expect(page).toHaveURL(/\/auth\/login\?next=/);
  expect(new URL(page.url()).searchParams.get('next')).toBe('/운세/타로');
});
