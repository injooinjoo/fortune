import { expect, test, type Page } from '@playwright/test';

const MOBILE_VIEWPORT = { width: 390, height: 844 };

async function openTarot(page: Page) {
  await page.goto('/');
  await page.getByRole('link', { name: '운세 전체 보기' }).click();
  await page.getByRole('link', { name: /오늘의 타로/ }).click();
  await expect(page.getByRole('heading', { name: '카드를 뽑아볼까요?' })).toBeVisible();
}

test('타로 선택 질문을 목적 바로 뒤에서 필요할 때만 펼치고 다시 접을 수 있다', async ({ page }) => {
  await page.setViewportSize(MOBILE_VIEWPORT);
  await openTarot(page);

  const trigger = page.getByRole('button', { name: '더 구체적으로 적을래요 (선택)' });
  const question = page.getByLabel('질문 (선택)');

  await expect(trigger).toBeVisible();
  await expect(trigger).toHaveAttribute('aria-expanded', 'false');
  await expect(trigger).toHaveAttribute('aria-controls', 'tarot-question-panel');
  await expect(question).not.toBeVisible();

  const triggerBox = await trigger.boundingBox();
  expect(triggerBox).not.toBeNull();
  expect(triggerBox!.height).toBeGreaterThanOrEqual(44);

  await trigger.click();
  await expect(question).toBeVisible();
  await expect(question).toBeFocused();

  const typedQuestion = '이직 제안을 받아도 괜찮을까요?';
  await question.fill(typedQuestion);
  await page.getByRole('button', { name: '질문 접기' }).click();

  const reopen = page.getByRole('button', { name: `질문 수정: ${typedQuestion}` });
  await expect(reopen).toBeVisible();
  await expect(reopen).toBeFocused();
  await expect(question).not.toBeVisible();

  await reopen.click();
  await expect(question).toHaveValue(typedQuestion);
  await expect(question).toBeFocused();
  await page.getByRole('button', { name: '질문 지우기' }).click();
  await expect(question).toHaveValue('');
  await expect(question).toBeFocused();
});

test('타로 필수 선택과 단일 CTA를 모든 대상 뷰포트에서 유지한다', async ({ page }) => {
  for (const viewport of [
    { width: 1440, height: 900 },
    { width: 1280, height: 800 },
    MOBILE_VIEWPORT,
  ]) {
    await page.setViewportSize(viewport);
    await openTarot(page);

    await expect(page.getByText('무엇이 궁금한가요?', { exact: true })).toBeVisible();
    await expect(page.getByText('스프레드', { exact: true })).toBeVisible();
    await expect(page.getByRole('group', { name: /카드 고르기/ })).toBeVisible();
    await expect(page.getByRole('button', { name: '타로 리딩 보기' })).toHaveCount(1);
    await expect(page.getByLabel('질문 (선택)')).not.toBeVisible();

    const layout = await page.evaluate(() => ({
      clientWidth: document.documentElement.clientWidth,
      scrollWidth: document.documentElement.scrollWidth,
    }));
    expect(layout.scrollWidth).toBeLessThanOrEqual(layout.clientWidth);
  }
});
