import { test, expect } from '@playwright/test';
import { OnboardingNamePage } from './pages/OnboardingNamePage';

test.describe('운세 앱 기본 동작 테스트', () => {
  test('메인 페이지 로딩 및 기본 요소 확인', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    
    // 페이지 타이틀 확인
    await expect(page).toHaveTitle(/운세 탐험/);
    
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

    // 두 번째 단계로 이동했는지 확인
    await expect(page.locator('text=생년월일')).toBeVisible();
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
    await expect(page.getByRole('dialog')).toBeVisible();

    // MBTI 옵션 선택
    await page.getByRole('button', { name: 'INFP' }).click();

    // 모달이 사라질 때까지 대기
    await expect(page.getByRole('dialog')).not.toBeVisible();

    // 결과가 표시되는 요소 확인
    await expect(page.getByTestId('mbti-result')).toHaveText('INFP');
  });
});
