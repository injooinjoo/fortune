import { expect, test, type Page } from '@playwright/test';

const viewports = [
  { name: 'large desktop', width: 1440, height: 900 },
  { name: 'compact desktop', width: 1280, height: 800 },
  { name: 'mobile', width: 390, height: 844 },
] as const;

async function selectBirthDate(
  page: Page,
  index: number,
  year: string,
  month: string,
  day: string,
) {
  await page.getByRole('combobox', { name: '출생 연도' }).nth(index).click();
  await page.getByRole('option', { name: `${year}년`, exact: true }).click();
  await page.getByRole('combobox', { name: '출생 월' }).nth(index).selectOption(month);
  await page.getByRole('combobox', { name: '출생 일' }).nth(index).selectOption(day);
}

for (const viewport of viewports) {
  test(`compatibility draft survives catalog back/forward on ${viewport.name}`, async ({ page }) => {
    await page.setViewportSize({ width: viewport.width, height: viewport.height });
    await page.goto('/%EC%9A%B4%EC%84%B8');
    await expect(page.getByRole('heading', { name: '무엇을 볼까요?' })).toBeVisible();
    await page.locator('a[href$="%EA%B6%81%ED%95%A9"]').first().click();
    await expect(page.getByRole('heading', { name: '두 사람의 케미가 궁금하다면' })).toBeVisible();

    await page.locator('#person1-name').fill('테스트A');
    await selectBirthDate(page, 0, '2000', '2', '29');
    await page.locator('#person2-name').fill('테스트B');
    await selectBirthDate(page, 1, '1999', '1', '1');
    await expect(page.getByRole('button', { name: '궁합 보기' })).toBeEnabled();

    await page.goBack();
    await expect(page.getByRole('heading', { name: '무엇을 볼까요?' })).toBeVisible();
    await page.goForward();
    await expect(page.getByRole('heading', { name: '두 사람의 케미가 궁금하다면' })).toBeVisible();

    await expect(page.locator('#person1-name')).toHaveValue('테스트A');
    await expect(page.locator('input[name="person1BirthDate"]')).toHaveValue('2000-02-29');
    await expect(page.locator('#person2-name')).toHaveValue('테스트B');
    await expect(page.locator('input[name="person2BirthDate"]')).toHaveValue('1999-01-01');
    await expect(page.getByRole('button', { name: '궁합 보기' })).toBeEnabled();
  });
}
