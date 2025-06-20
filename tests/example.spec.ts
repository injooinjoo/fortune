import { test, expect } from '@playwright/test';
import { OnboardingNamePage } from './pages/OnboardingNamePage';

test.describe('운세 앱 기본 동작 테스트', () => {
  test('메인 페이지 로딩 및 기본 요소 확인', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    
    // 페이지 타이틀 확인
    await expect(page).toHaveTitle(/운세/);
    
    // 주요 폼 요소들이 존재하는지 확인
    await expect(page.locator('input[name="name"]')).toBeVisible();
    await expect(page.locator('text=다음')).toBeVisible();
  });

  test('이름 입력 및 다음 단계 진행', async ({ page }) => {
    const namePage = new OnboardingNamePage(page);
    await namePage.goto();
    // 필요한 경우 여기서 디버깅용 일시 중지를 사용할 수 있습니다.
    // await page.pause();
    await namePage.enterName('테스트 사용자');
    await namePage.submitName();

    // URL이 생년월일 페이지로 변경될 때까지 대기
    await page.waitForURL(/.*onboarding\/birthdate/, { timeout: 10000 });
    
    // 약간의 추가 대기 시간
    await page.waitForTimeout(500);

    // 두 번째 단계로 이동했는지 확인 - 더 구체적인 셀렉터 사용
    await expect(page.getByRole('heading', { name: '생년월일을 알려주세요' })).toBeVisible();
  });

  test('생년월일 선택 기능', async ({ page }) => {
    await page.goto('/onboarding/birthdate');

    await page.getByRole('button', { name: '생년월일 입력' }).click();
    await page.getByRole('button', { name: '20' }).click();
    await page.getByRole('button', { name: '확인' }).click();

    await expect(page.getByTestId('birthdate-display')).toContainText('20');
  });

  test('MBTI 선택 모달 동작', async ({ page }) => {
    await page.goto('/');
    
    // 이름 입력 및 다음 단계 진행
    await page.fill('input[name=\"name\"]', '테스트 사용자');
    await page.click('text=다음');

    // webkit/Safari 호환성을 위해 더 안정적인 셀렉터 사용
    await page.selectOption('#birth-year', '1990');
    await page.selectOption('#birth-month', '5');
    await page.selectOption('#birth-day', '15');
    await page.click('text=다음');

    // 성별과 출생시간도 먼저 선택
    await page.selectOption('select', { index: 1 }); // 첫 번째 select에서 첫 번째 옵션 (남성)
    await page.selectOption('select >> nth=1', { index: 1 }); // 두 번째 select에서 첫 번째 옵션 (오전)

    // MBTI 선택 버튼 클릭하여 모달 열기
    await page.click('text=MBTI 선택');
    
    // 모달이 열릴 때까지 대기
    await page.waitForSelector('[role="dialog"]');

    // 모달 안에서 INTJ 선택
    await page.click('text=INTJ');

    // MBTI 결과 확인
    await expect(page.getByTestId('mbti-result')).toContainText('INTJ');
  });
});
