import { test, expect } from '@playwright/test';
import { OnboardingNamePage } from './pages/OnboardingNamePage';

test.describe('운세 앱 기본 동작 테스트', () => {
  test('메인 페이지 로딩 및 기본 요소 확인', async ({ page }) => {
    await page.goto('/onboarding');
    await page.waitForLoadState('networkidle');
    
    // 페이지 타이틀 확인
    await expect(page).toHaveTitle(/운세/);
    
    // 주요 폼 요소들이 존재하는지 확인
    await expect(page.locator('input[name="name"]')).toBeVisible();
    await expect(page.getByRole('button', { name: '다음' })).toBeVisible();
  });

  test('이름 입력 및 다음 단계 진행', async ({ page }) => {
    await page.goto('/onboarding');
    await page.waitForLoadState('networkidle');
    
    // 이름 입력
    await page.fill('input[name="name"]', '테스트 사용자');
    
    // 생년월일 선택
    await page.locator('button[role="combobox"]').first().click(); // 생년 선택
    await page.getByText('1990년').click();
    
    await page.locator('button[role="combobox"]').nth(1).click(); // 생월 선택
    await page.getByText('5월').click();
    
    await page.locator('button[role="combobox"]').nth(2).click(); // 생일 선택
    await page.getByText('15일').click();
    
    // 다음 버튼 클릭
    await page.getByRole('button', { name: '다음' }).click();
    
    // 약간의 대기 시간
    await page.waitForTimeout(1000);

    // 두 번째 단계로 이동했는지 확인 (프로그레스 바로 확인)
    await expect(page.getByText('2 / 3 단계')).toBeVisible();
  });

  test('생년월일 선택 기능', async ({ page }) => {
    await page.goto('/onboarding/birthdate');

    await page.getByRole('button', { name: '생년월일 입력' }).click();
    await page.getByRole('button', { name: '20' }).click();
    await page.getByRole('button', { name: '확인' }).click();

    await expect(page.getByTestId('birthdate-display')).toContainText('20');
  });

  test('MBTI 선택 모달 동작', async ({ page }) => {
    await page.goto('/onboarding');
    await page.waitForLoadState('networkidle');
    
    // 1단계: 이름 및 생년월일 입력
    await page.fill('input[name=\"name\"]', '테스트 사용자');
    
    // 생년월일 선택
    await page.locator('button[role="combobox"]').first().click();
    await page.getByText('1990년').click();
    
    await page.locator('button[role="combobox"]').nth(1).click();
    await page.getByText('5월').click();
    
    await page.locator('button[role="combobox"]').nth(2).click();
    await page.getByText('15일').click();
    
    await page.getByRole('button', { name: '다음' }).click();
    await page.waitForTimeout(1000);

    // 2단계로 넘어갔는지 확인
    await expect(page.getByText('2 / 3 단계')).toBeVisible();

    // 성별 선택 (있다면)
    const genderRadio = page.locator('input[type="radio"]').first();
    if (await genderRadio.isVisible()) {
      await genderRadio.click();
    }

    // MBTI 선택이 있다면 테스트
    const mbtiButton = page.getByText('MBTI 선택');
    if (await mbtiButton.isVisible()) {
      await mbtiButton.click();
      
      // MBTI 옵션 중 하나 선택
      const mbtiOption = page.getByText('INTJ');
      if (await mbtiOption.isVisible()) {
        await mbtiOption.click();
      }
    }
    
    // 다음 단계가 존재한다면 진행
    const nextButton = page.getByRole('button', { name: '다음' });
    if (await nextButton.isVisible()) {
      await nextButton.click();
      await page.waitForTimeout(500);
    }
  });
});
