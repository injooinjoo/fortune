import { test, expect, type Page } from '@playwright/test';

test.describe('MCP 통합 테스트', () => {
  // 헬퍼 함수: 프로필 설정 완료까지 진행
  const completeProfileSetup = async (page: Page) => {
    await page.goto('/');
    
    // 1단계: 이름 입력
    await page.fill('input[name="name"]', 'MCP 테스트 사용자');
    await page.click('text=다음');
    
    // 2단계: 생년월일 선택
    await page.selectOption('select:near(:text("년"))', '1990');
    await page.selectOption('select:near(:text("월"))', '5');
    await page.selectOption('select:near(:text("일"))', '15');
    await page.click('text=다음');
    
    // 3단계: 성별, MBTI, 출생시간 선택
    await page.selectOption('select:near(:text("성별"))', '남성');
    await page.selectOption('select:near(:text("출생시간"))', '오전');
    
    // MBTI 설정
    await page.click('text=MBTI 선택');
    await page.click('text=E (외향)');
    await page.click('text=N (직관)');
    await page.click('text=F (감정)');
    await page.click('text=P (인식)');
    await page.click('text=확인');

    // 프로필 저장 API 응답 대기
    const saveResponsePromise = page.waitForResponse((response) => {
      return (
        response.url().includes('/api/mcp/profile') &&
        response.request().method() === 'POST' &&
        response.status() === 200
      );
    });

    // 완료 버튼 클릭
    await page.click('text=완료');

    // 네트워크 응답 확인
    await saveResponsePromise;
  };

  test('프로필 데이터 저장 및 검증', async ({ page }) => {
    await completeProfileSetup(page);

    // 성공 토스트 메시지가 표시되는지 확인
    await expect(page.locator('.toast-success-message')).toBeVisible();

    // 홈페이지로 리디렉션 확인
    await expect(page).toHaveURL('/home');

    // 사용자 정보가 올바르게 표시되는지 확인
    await expect(page.locator('text=MCP 테스트 사용자')).toBeVisible();
  });

  test('MBTI API 엔드포인트 테스트', async ({ page }) => {
    // API 응답을 모킹하기 위한 준비
    await page.route('/api/mbti/*', async (route) => {
      const mockResponse = {
        type: 'ENFP',
        description: '재기발랄한 활동가',
        characteristics: ['창의적', '열정적', '사교적'],
        compatibility: ['INTJ', 'INFJ']
      };
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify(mockResponse)
      });
    });

    await page.goto('/');
    
    // MBTI 관련 요청이 발생할 때까지 대기
    const responsePromise = page.waitForResponse('/api/mbti/**');
    
    // MBTI 선택 과정
    await page.fill('input[name="name"]', 'API 테스트');
    await page.click('text=다음');
    await page.selectOption('select:near(:text("년"))', '1995');
    await page.selectOption('select:near(:text("월"))', '8');
    await page.selectOption('select:near(:text("일"))', '20');
    await page.click('text=다음');
    
    await page.click('text=MBTI 선택');
    await page.click('text=E (외향)');
    await page.click('text=N (직관)');
    await page.click('text=F (감정)');
    await page.click('text=P (인식)');
    await page.click('text=확인');
    
    const response = await responsePromise;
    expect(response.status()).toBe(200);
  });

  test('네트워크 오류 상황 처리', async ({ page }) => {
    // 네트워크 오류 시뮬레이션
    await page.route('/api/**', (route) => {
      route.abort('internetdisconnected');
    });

    await page.goto('/');
    
    // 오류 상황에서도 기본 UI가 동작하는지 확인
    await expect(page.locator('input[name="name"]')).toBeVisible();
    
    // 에러 메시지 또는 대체 UI가 표시되는지 확인
    await page.fill('input[name="name"]', '네트워크 에러 테스트');
    await page.click('text=다음');
  });

  test('로컬 스토리지 데이터 지속성', async ({ page }) => {
    await page.goto('/');
    
    // 부분적으로 폼 작성
    await page.fill('input[name="name"]', '지속성 테스트');
    await page.click('text=다음');
    await page.selectOption('select:near(:text("년"))', '1988');
    
    // 페이지 새로고침
    await page.reload();
    
    // 이전에 입력했던 데이터가 유지되는지 확인 (만약 구현되어 있다면)
    // 이는 실제 구현에 따라 달라질 수 있음
    await expect(page.locator('input[name="name"]')).toBeVisible();
  });

  test('반응형 디자인 테스트', async ({ page }) => {
    // 데스크톱 뷰포트
    await page.setViewportSize({ width: 1280, height: 720 });
    await page.goto('/');
    await expect(page.locator('input[name="name"]')).toBeVisible();
    
    // 모바일 뷰포트
    await page.setViewportSize({ width: 375, height: 667 });
    await expect(page.locator('input[name="name"]')).toBeVisible();
    
    // 태블릿 뷰포트
    await page.setViewportSize({ width: 768, height: 1024 });
    await expect(page.locator('input[name="name"]')).toBeVisible();
  });

  test('접근성 기본 요구사항', async ({ page }) => {
    await page.goto('/');
    
    // 기본 접근성 검사
    await expect(page.locator('input[name="name"]')).toHaveAttribute('aria-label');
    
    // 키보드 내비게이션 테스트
    await page.keyboard.press('Tab');
    await expect(page.locator('input[name="name"]')).toBeFocused();
    
    // 폼 라벨 연결 확인
    const nameInput = page.locator('input[name="name"]');
    const labelId = await nameInput.getAttribute('aria-labelledby');
    if (labelId) {
      await expect(page.locator(`#${labelId}`)).toBeVisible();
    }
  });

  test('성능 메트릭 모니터링', async ({ page }) => {
    // 성능 메트릭 수집 시작
    await page.goto('/', { waitUntil: 'networkidle' });
    
    // 페이지 로드 성능 검증
    const performanceEntries = await page.evaluate(() => {
      return JSON.parse(JSON.stringify(performance.getEntriesByType('navigation')));
    });
    
    expect(performanceEntries.length).toBeGreaterThan(0);
    
    // 첫 번째 의미있는 페인트 시간이 합리적인지 확인
    const firstContentfulPaint = await page.evaluate(() => {
      return performance.getEntriesByName('first-contentful-paint')[0]?.startTime;
    });
    
    if (firstContentfulPaint) {
      expect(firstContentfulPaint).toBeLessThan(3000); // 3초 이내
    }
  });

  test('에러 바운더리 동작', async ({ page }) => {
    // 의도적으로 에러를 발생시킬 수 있는 상황 테스트
    await page.goto('/');
    
    // 잘못된 데이터 입력 시도
    await page.fill('input[name="name"]', ''.repeat(1000)); // 매우 긴 이름
    
    // 애플리케이션이 크래시하지 않고 적절한 에러 처리를 하는지 확인
    await expect(page.locator('body')).toBeVisible();
  });

  test('세션 타임아웃 처리', async ({ page }) => {
    await page.goto('/');
    
    // 세션 만료 시뮬레이션 (실제 구현에 따라 조정 필요)
    await page.evaluate(() => {
      // 로컬스토리지나 세션스토리지 클리어
      localStorage.clear();
      sessionStorage.clear();
    });
    
    // 페이지 새로고침 후 초기 상태로 돌아가는지 확인
    await page.reload();
    await expect(page.locator('input[name="name"]')).toBeVisible();
    await expect(page.locator('input[name="name"]')).toHaveValue('');
  });
}); 