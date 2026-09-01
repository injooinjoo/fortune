import { expect, test } from '@playwright/test';

const VIEWPORTS = [
  { width: 1440, height: 900 },
  { width: 1280, height: 800 },
] as const;

/**
 * `/운세` 는 한글 세그먼트 라우트다. Next 는 요청으로 들어온 퍼센트 인코딩
 * 경로(`/%EC%9A%B4%EC%84%B8`)를 디코딩해서 앱 라우터 세그먼트에 맞추지 않는다
 * (vercel/next.js#62292). 그래서 `next start`/`next dev` 로 띄운 로컬 서버는
 * 이 경로를 항상 404 로 돌려주고, 배포된 Vercel 라우팅에서만 200 이 된다.
 * 같은 이유로 daily.spec.ts / fortune-input-journey.spec.ts 도 이미
 * `WEB_BASE_URL` 이 있을 때만 실행한다.
 */
const DEPLOYED_KOREAN_PATH_ONLY = '배포된 한글 경로에서 실행하는 반응형 스모크입니다.';

async function enterFortuneIndexFromHome(page: import('@playwright/test').Page) {
  await page.goto('/');

  if (await page.locator('details.ondo-mobile-menu').isVisible()) {
    await page.locator('details.ondo-mobile-menu > summary').click();
    await page
      .getByRole('navigation', { name: '모바일 사이트 메뉴' })
      .getByRole('link', { name: '운세', exact: true })
      .click();
  } else {
    await page
      .getByRole('navigation', { name: '사이트 메뉴' })
      .getByRole('link', { name: '운세', exact: true })
      .click();
  }

  await expect(page).toHaveURL(/%EC%9A%B4%EC%84%B8|운세/);
  await expect(page.getByRole('heading', { name: '무엇을 볼까요?' })).toBeVisible();
}

test.describe('운세 목록의 반응형 선택 안내', () => {
  for (const viewport of VIEWPORTS) {
    test(`${viewport.width} 데스크톱은 선택 기준을 바로 보여준다`, async ({ page }) => {
      test.skip(!process.env.WEB_BASE_URL, DEPLOYED_KOREAN_PATH_ONLY);
      await page.setViewportSize(viewport);
      await enterFortuneIndexFromHome(page);

      const desktopGuide = page.locator('section[aria-labelledby="fortune-guide-title"]');
      await expect(
        desktopGuide.getByRole('heading', { name: '지금 궁금한 깊이에 맞춰 골라보세요' }),
      ).toBeVisible();
      await expect(desktopGuide.getByText('관계나 마음을 더 깊게', { exact: true })).toBeVisible();
      await expect(page.locator('summary').filter({ hasText: '고르는 기준' })).toBeHidden();

      const dimensions = await page.evaluate(() => ({
        innerWidth: window.innerWidth,
        scrollWidth: document.documentElement.scrollWidth,
      }));
      expect(dimensions.scrollWidth).toBeLessThanOrEqual(dimensions.innerWidth);
    });
  }

  test('390 모바일은 선택 기준을 접고 첫 리딩을 앞당기되 필요할 때 펼친다', async ({ page }) => {
    test.skip(!process.env.WEB_BASE_URL, DEPLOYED_KOREAN_PATH_ONLY);
    await page.setViewportSize({ width: 390, height: 844 });
    await enterFortuneIndexFromHome(page);

    const guide = page.locator('details').filter({ has: page.locator('summary').filter({ hasText: '고르는 기준' }) });
    const summary = guide.locator('summary');
    const firstReading = page.getByRole('link', { name: /오늘의 운세.*온도 1개/ });

    await expect(summary).toBeVisible();
    await expect(guide).not.toHaveAttribute('open', '');
    await expect(guide.getByText('관계나 마음을 더 깊게', { exact: true })).toBeHidden();

    const summaryBox = await summary.boundingBox();
    const collapsedCardBox = await firstReading.boundingBox();
    expect(summaryBox?.height ?? 0).toBeGreaterThanOrEqual(44);
    expect(collapsedCardBox?.y ?? Number.POSITIVE_INFINITY).toBeLessThanOrEqual(560);

    await summary.focus();
    await expect(summary).toBeFocused();
    await page.keyboard.press('Enter');
    await expect(guide).toHaveAttribute('open', '');
    await expect(guide.getByText('관계나 마음을 더 깊게', { exact: true })).toBeVisible();

    const expandedCardBox = await firstReading.boundingBox();
    expect(expandedCardBox?.y ?? 0).toBeGreaterThan(collapsedCardBox?.y ?? 0);

    const dimensions = await page.evaluate(() => ({
      innerWidth: window.innerWidth,
      scrollWidth: document.documentElement.scrollWidth,
    }));
    expect(dimensions.scrollWidth).toBeLessThanOrEqual(dimensions.innerWidth);
  });
});
