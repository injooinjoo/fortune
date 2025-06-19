import { Page, expect } from '@playwright/test';

/**
 * 프로필 설정 전체 과정을 완료하는 헬퍼 함수
 */
export async function completeProfileSetup(
  page: Page,
  userData = {
    name: '테스트 사용자',
    year: '1990',
    month: '5',
    day: '15',
    gender: '남성',
    birthTime: '오전',
    mbti: ['E', 'N', 'F', 'P']
  }
) {
  await page.goto('/');
  
  // 1단계: 이름 입력
  await page.fill('input[name="name"]', userData.name);
  await page.click('text=다음');
  
  // 2단계: 생년월일 선택
  await page.selectOption('select:near(:text("년"))', userData.year);
  await page.selectOption('select:near(:text("월"))', userData.month);
  await page.selectOption('select:near(:text("일"))', userData.day);
  await page.click('text=다음');
  
  // 3단계: 성별, MBTI, 출생시간 선택
  await page.selectOption('select:near(:text("성별"))', userData.gender);
  await page.selectOption('select:near(:text("출생시간"))', userData.birthTime);
  
  // MBTI 설정
  await page.click('text=MBTI 선택');
  for (const letter of userData.mbti) {
    await page.click(`text=${letter} (`);
  }
  await page.click('text=확인');
  
  // 완료 버튼 클릭
  await page.click('text=완료');
}

/**
 * 페이지 로딩 완료까지 대기
 */
export async function waitForPageLoad(page: Page, selector: string) {
  await expect(page.locator(selector)).toBeVisible();
  await page.waitForLoadState('networkidle');
}

/**
 * API 응답 모킹 헬퍼
 */
export async function mockApiResponse(
  page: Page,
  endpoint: string,
  response: any,
  status = 200
) {
  await page.route(endpoint, async (route) => {
    await route.fulfill({
      status,
      contentType: 'application/json',
      body: JSON.stringify(response)
    });
  });
}

/**
 * 네트워크 오류 시뮬레이션
 */
export async function simulateNetworkError(page: Page, pattern: string) {
  await page.route(pattern, (route) => {
    route.abort('internetdisconnected');
  });
}

/**
 * 로딩 상태 확인
 */
export async function waitForLoadingToComplete(page: Page) {
  try {
    await expect(page.locator('[data-testid="loading"]')).toBeVisible({ timeout: 1000 });
    await expect(page.locator('[data-testid="loading"]')).toBeHidden({ timeout: 10000 });
  } catch {
    // 로딩 인디케이터가 없거나 빠르게 사라진 경우
  }
}

/**
 * 폼 검증 에러 확인
 */
export async function expectValidationError(page: Page, fieldName: string) {
  const errorMessage = page.locator(`[data-testid="${fieldName}-error"]`);
  await expect(errorMessage).toBeVisible();
}

/**
 * 토스트 메시지 확인
 */
export async function expectToastMessage(page: Page, message: string) {
  await expect(page.locator(`text=${message}`)).toBeVisible();
}

/**
 * 다양한 뷰포트 크기 테스트
 */
export const VIEWPORT_SIZES = {
  mobile: { width: 375, height: 667 },
  tablet: { width: 768, height: 1024 },
  desktop: { width: 1280, height: 720 },
  largeDesktop: { width: 1920, height: 1080 }
};

/**
 * 접근성 테스트 헬퍼
 */
export async function checkAccessibility(page: Page) {
  // 기본 접근성 검사
  const focusableElements = await page.locator('button, input, select, textarea, [tabindex]').all();
  
  for (const element of focusableElements) {
    // 각 요소가 접근 가능한지 확인
    await expect(element).toBeVisible();
  }
}

/**
 * 성능 메트릭 수집
 */
export async function collectPerformanceMetrics(page: Page) {
  return await page.evaluate(() => {
    const navigation = performance.getEntriesByType('navigation')[0] as PerformanceNavigationTiming;
    const paint = performance.getEntriesByType('paint');
    
    return {
      loadTime: navigation.loadEventEnd - navigation.loadEventStart,
      domContentLoaded: navigation.domContentLoadedEventEnd - navigation.domContentLoadedEventStart,
      firstContentfulPaint: paint.find(p => p.name === 'first-contentful-paint')?.startTime,
      largestContentfulPaint: paint.find(p => p.name === 'largest-contentful-paint')?.startTime
    };
  });
} 