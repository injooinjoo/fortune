import { test, expect } from '@playwright/test';

test.describe('운세 앱 기본 동작 테스트', () => {
  test('메인 페이지 로딩 및 기본 요소 확인', async ({ page }) => {
    await page.goto('/');
    
    // 페이지 타이틀 확인
    await expect(page).toHaveTitle(/운세 탐험/);
    
    // 주요 폼 요소들이 존재하는지 확인
    await expect(page.locator('input[name="name"]')).toBeVisible();
    await expect(page.locator('text=다음')).toBeVisible();
  });

  test('이름 입력 및 다음 단계 진행', async ({ page }) => {
    await page.goto('/');
    
    // 이름 입력
    await page.fill('input[name="name"]', '테스트 사용자');
    
    // 다음 버튼 클릭
    await page.click('text=다음');
    
    // 두 번째 단계로 이동했는지 확인
    await expect(page.locator('text=생년월일')).toBeVisible();
  });

  test('생년월일 선택 기능', async ({ page }) => {
    await page.goto('/');
    
    // 첫 번째 단계 완료
    await page.fill('input[name="name"]', '테스트 사용자');
    await page.click('text=다음');
    
    // 생년월일 선택
    await page.selectOption('select:near(:text("년"))', '1990');
    await page.selectOption('select:near(:text("월"))', '5');
    await page.selectOption('select:near(:text("일"))', '15');
    
    // 다음 단계로 진행
    await page.click('text=다음');
    
    // 세 번째 단계 확인
    await expect(page.locator('text=성별')).toBeVisible();
  });

  test('MBTI 선택 모달 동작', async ({ page }) => {
    await page.goto('/');
    
    // 단계별 진행
    await page.fill('input[name="name"]', '테스트 사용자');
    await page.click('text=다음');
    
    await page.selectOption('select:near(:text("년"))', '1990');
    await page.selectOption('select:near(:text("월"))', '5');
    await page.selectOption('select:near(:text("일"))', '15');
    await page.click('text=다음');
    
    // MBTI 선택 버튼 클릭
    await page.getByRole('button', { name: 'MBTI 선택하기' }).click();

    // 모달이 화면에 나타날 때까지 대기
    await expect(page.locator('#mbti-selection-modal')).toBeVisible();

    // MBTI 옵션 선택
    await page.getByRole('button', { name: 'INFP' }).click();

    // 선택된 MBTI가 표시되는지 확인
    await expect(page.locator('.selected-mbti-display')).toHaveText('INFP');
  });
}); 