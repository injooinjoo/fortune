import { test, expect } from '@playwright/test';

test.describe('시각적 회귀 테스트', () => {
  test('메인 페이지 스크린샷 비교', async ({ page }) => {
    await page.goto('/');
    
    // 페이지가 완전히 로드될 때까지 대기
    await expect(page.locator('input[name="name"]')).toBeVisible();
    
    // 전체 페이지 스크린샷
    await expect(page).toHaveScreenshot('main-page.png');
  });

  test('MBTI 선택 모달 스크린샷', async ({ page }) => {
    await page.goto('/');
    
    // 단계별 진행
    await page.fill('input[name="name"]', '시각 테스트');
    await page.click('text=다음');
    
    await page.selectOption('select:near(:text("년"))', '1990');
    await page.selectOption('select:near(:text("월"))', '5');
    await page.selectOption('select:near(:text("일"))', '15');
    await page.click('text=다음');
    
    // MBTI 모달 열기
    await page.click('text=MBTI 선택');
    await expect(page.locator('text=에너지')).toBeVisible();
    
    // 모달 스크린샷 - 애니메이션을 비활성화해 안정적인 비교 수행
    await expect(page).toHaveScreenshot('mbti-modal-screenshot.png', {
      animations: 'disabled',
    });
  });

  test('다크 모드 지원 확인', { colorScheme: 'dark' }, async ({ page }) => {
    await page.goto('/');
    
    await expect(page.locator('input[name="name"]')).toBeVisible();
    await expect(page).toHaveScreenshot('dark-mode.png');
  });

  test('모바일 뷰 스크린샷', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 667 });
    await page.goto('/');
    
    await expect(page.locator('input[name="name"]')).toBeVisible();
    await expect(page).toHaveScreenshot('mobile-view.png');
  });

  test('에러 상태 UI', async ({ page }) => {
    await page.goto('/');
    
    // 이름 없이 다음 버튼 클릭하여 에러 상태 유발
    await page.click('text=다음');
    
    // 에러 메시지가 표시되는지 확인하고 스크린샷
    await page.waitForTimeout(500); // 에러 메시지 표시 대기
    await expect(page).toHaveScreenshot('error-state.png');
  });

  test('로딩 상태 UI', async ({ page }) => {
    await page.goto('/');

    const apiPattern = '/api/**';
    await page.route(apiPattern, async () => {
      // Intercept the API call that triggers the loading indicator
      // and keep it pending to freeze the UI in the loading state
    });

    // 폼 작성 후 제출하여 로딩 상태 트리거
    await page.fill('input[name="name"]', '로딩 테스트');
    await page.click('text=다음');

    await page.selectOption('select:near(:text("년"))', '1990');
    await page.selectOption('select:near(:text("월"))', '5');
    await page.selectOption('select:near(:text("일"))', '15');
    await page.click('text=다음');

    await page.selectOption('select:near(:text("성별"))', '남성');
    await page.click('text=완료');

    // 로딩 인디케이터가 나타나는지 확인 후 스크린샷
    await expect(page.locator('[data-testid="loading"]')).toBeVisible({ timeout: 1000 });
    await expect(page).toHaveScreenshot('loading-state.png');

    await page.unroute(apiPattern);
  });
}); 