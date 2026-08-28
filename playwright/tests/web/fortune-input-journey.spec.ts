import { expect, test } from '@playwright/test';

const VIEWPORTS = [
  { name: 'desktop', width: 1440, height: 900 },
  { name: 'mobile', width: 390, height: 844 },
] as const;

const runsDeployedJourney = process.env.WEB_BASE_URL?.startsWith('https://') === true;

test.describe('운세 입력 여정', () => {
  for (const viewport of VIEWPORTS) {
    test(`${viewport.name} 공통 운세 제목이 두 줄에서도 포개지지 않는다`, async ({ page }) => {
      await page.setViewportSize(viewport);
      await page.goto('/');
      const fixture = page.locator('main').first();
      await fixture.evaluate((main) => {
        main.setAttribute('class', 'ondo-shell ondo-stack ondo-fortune-shell');
        main.innerHTML = `
          <header class="ondo-stack ondo-fortune-heading">
            <p class="ondo-kicker">연애운</p>
            <h1 class="ondo-h2">지금 연애는 어떤가요?</h1>
            <p class="ondo-muted">지금 상태에 맞춰 연애 흐름과 조언을 정리해 드려요.</p>
          </header>
        `;
      });

      const heading = fixture.locator('h1.ondo-h2');
      const metrics = await heading.evaluate((element) => {
        const style = getComputedStyle(element);
        return {
          fontSize: Number.parseFloat(style.fontSize),
          lineHeight: Number.parseFloat(style.lineHeight),
          height: element.getBoundingClientRect().height,
          clientWidth: document.documentElement.clientWidth,
          scrollWidth: document.documentElement.scrollWidth,
        };
      });

      expect(metrics.lineHeight).toBeGreaterThanOrEqual(metrics.fontSize * 1.08);
      expect(metrics.height).toBeGreaterThanOrEqual(metrics.lineHeight);
      expect(metrics.scrollWidth).toBeLessThanOrEqual(metrics.clientWidth);
    });

    test(`${viewport.name} 선택 칩은 충분한 터치 영역을 가진다`, async ({ page }) => {
      await page.setViewportSize(viewport);
      await page.goto('/');
      const fixture = page.locator('main').first();
      await fixture.evaluate((main) => {
        main.innerHTML = '<button class="ondo-chip" type="button">연애 중</button>';
      });

      const height = await fixture.locator('.ondo-chip').evaluate((chip) => chip.getBoundingClientRect().height);
      expect(height).toBeGreaterThanOrEqual(viewport.name === 'mobile' ? 44 : 40);
    });
  }

  test('생년월일은 1990 기준 연도·월·일 선택기로 입력한다', async ({ page }) => {
    test.skip(!runsDeployedJourney, '배포된 한글 경로에서 실행하는 여정 테스트입니다.');
    await page.goto('/운세/오늘');

    await expect(page.locator('input[type="date"]')).toHaveCount(0);
    const year = page.getByRole('combobox', { name: '출생 연도' });
    const month = page.getByRole('combobox', { name: '출생 월' });
    const day = page.getByRole('combobox', { name: '출생 일' });
    await expect(year.locator('option').nth(1)).toHaveText('1990년');

    await year.selectOption('1990');
    await month.selectOption('2');
    await day.selectOption('28');
    await expect(page.locator('input[name="birthDate"]')).toHaveValue('1990-02-28');
  });

  test('입력한 생년월일과 성별을 연애운에서 다시 묻지 않는다', async ({ page }) => {
    test.skip(!runsDeployedJourney, '배포된 한글 경로에서 실행하는 여정 테스트입니다.');
    await page.goto('/운세/오늘');
    await page.getByRole('combobox', { name: '출생 연도' }).selectOption('1990');
    await page.getByRole('combobox', { name: '출생 월' }).selectOption('2');
    await page.getByRole('combobox', { name: '출생 일' }).selectOption('28');
    await page.getByRole('button', { name: '여성' }).click();

    await page.goto('/운세/연애');
    await expect(page.getByRole('spinbutton', { name: '나이' })).toHaveCount(0);
    await expect(page.getByRole('combobox', { name: '출생 연도' })).toHaveValue('1990');
    await expect(page.getByRole('combobox', { name: '출생 월' })).toHaveValue('2');
    await expect(page.getByRole('combobox', { name: '출생 일' })).toHaveValue('28');
    await expect(page.getByRole('button', { name: '여성' })).toHaveAttribute('aria-pressed', 'true');
    await expect(page.getByText('앞에서 입력한 정보를 불러왔어요.')).toBeVisible();
  });
});
