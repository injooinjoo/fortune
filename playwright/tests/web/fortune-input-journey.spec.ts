import { expect, test } from '@playwright/test';

import { getYearListLayout } from '../../../apps/web/src/features/fortune/fields';

const VIEWPORTS = [
  { name: 'desktop', width: 1440, height: 900 },
  { name: 'mobile', width: 390, height: 844 },
] as const;

const runsTargetJourney = Boolean(process.env.WEB_BASE_URL);

test('연도 목록은 뷰포트에서 더 넓은 방향으로 열리고 실제 여유 높이를 넘지 않는다', () => {
  expect(getYearListLayout({ triggerTop: 681, triggerBottom: 733, viewportHeight: 844 })).toEqual({
    placement: 'above',
    maxHeight: 280,
  });
  expect(getYearListLayout({ triggerTop: 120, triggerBottom: 172, viewportHeight: 844 })).toEqual({
    placement: 'below',
    maxHeight: 280,
  });
  expect(getYearListLayout({ triggerTop: 140, triggerBottom: 192, viewportHeight: 300 })).toEqual({
    placement: 'above',
    maxHeight: 124,
  });
});

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

  for (const viewport of VIEWPORTS) {
    test(`${viewport.name} 연도는 전체 범위를 제공하고 첫 오픈에서 1990을 중앙에 둔다`, async ({ page }) => {
      test.skip(!runsTargetJourney, '명시한 웹 대상의 한글 경로에서 실행하는 여정 테스트입니다.');
      await page.setViewportSize(viewport);
      await page.goto('/운세/오늘');

      await expect(page.locator('input[type="date"]')).toHaveCount(0);
      const year = page.getByRole('combobox', { name: '출생 연도' });
      const month = page.getByRole('combobox', { name: '출생 월' });
      const day = page.getByRole('combobox', { name: '출생 일' });
      await expect(year).toHaveText('연도');
      await year.click();
      const listbox = page.getByRole('listbox', { name: '출생 연도' });
      await expect(listbox).toBeVisible();
      await expect(listbox.getByRole('option').first()).toHaveText('1900년');
      await expect(listbox.getByRole('option').last()).toContainText('년');
      await expect.poll(async () => {
        const listboxBox = await listbox.boundingBox();
        const preferredBox = await listbox.getByRole('option', { name: '1990년' }).boundingBox();
        if (!listboxBox || !preferredBox) return Number.POSITIVE_INFINITY;
        return Math.abs((preferredBox.y + preferredBox.height / 2) - (listboxBox.y + listboxBox.height / 2));
      }).toBeLessThan(viewport.name === 'mobile' ? 44 : 42);

      const listboxBox = await listbox.boundingBox();
      expect(listboxBox).not.toBeNull();
      expect(listboxBox!.y).toBeGreaterThanOrEqual(8);
      expect(listboxBox!.y + listboxBox!.height).toBeLessThanOrEqual(viewport.height - 8);

      await listbox.getByRole('option', { name: '1990년' }).click();
      await month.selectOption('2');
      await day.selectOption('28');
      await expect(page.locator('input[name="birthDate"]')).toHaveValue('1990-02-28');
    });
  }

  test('입력한 생년월일과 성별을 연애운에서 다시 묻지 않는다', async ({ page }) => {
    test.skip(!runsTargetJourney, '명시한 웹 대상의 한글 경로에서 실행하는 여정 테스트입니다.');
    await page.goto('/운세/오늘');
    await page.getByRole('combobox', { name: '출생 연도' }).click();
    await page.getByRole('listbox', { name: '출생 연도' }).getByRole('option', { name: '1990년' }).click();
    await page.getByRole('combobox', { name: '출생 월' }).selectOption('2');
    await page.getByRole('combobox', { name: '출생 일' }).selectOption('28');
    await page.getByRole('button', { name: '여성' }).click();

    await page.goto('/운세/연애');
    await expect(page.getByRole('spinbutton', { name: '나이' })).toHaveCount(0);
    await expect(page.getByRole('combobox', { name: '출생 연도' })).toHaveText('1990년');
    await expect(page.getByRole('combobox', { name: '출생 월' })).toHaveValue('2');
    await expect(page.getByRole('combobox', { name: '출생 일' })).toHaveValue('28');
    await expect(page.getByRole('button', { name: '여성' })).toHaveAttribute('aria-pressed', 'true');
    await expect(page.getByText('앞에서 입력한 정보를 불러왔어요.')).toBeVisible();
  });
});
