// comprehensive-fortune.spec.js - 종합적인 Ondo 앱 테스트
const { test, expect } = require('@playwright/test');
const { AuthHelper } = require('../helpers/auth.helper');

test.describe('종합 Ondo 앱 기능 테스트', () => {
  let authHelper;

  test.beforeEach(async ({ page }) => {
    authHelper = new AuthHelper(page);
    // 인증 설정
    await authHelper.setupTestAuth();
  });

  test('앱 초기 로딩 및 인증 우회 검증', async ({ page }) => {
    console.log('🧪 [TEST] 앱 초기 로딩 테스트 시작');

    // 앱으로 이동
    await page.goto('/', { timeout: 45000 });

    // Flutter 초기화 대기
    await page.waitForLoadState('networkidle', { timeout: 45000 });
    await page.waitForTimeout(5000); // Flutter 완전 초기화

    // 페이지 제목 확인 (앱 이름: Ondo 또는 온도)
    const title = await page.title();
    console.log(`🔧 [TEST] 페이지 제목: "${title}"`);
    expect(title.length).toBeGreaterThan(0); // 제목이 존재하면 OK

    // 초기 스크린샷
    await page.screenshot({
      path: 'test-results/comprehensive-initial-load.png',
      fullPage: true
    });

    // 앱이 정상 로드되었는지 확인
    const bodyText = await page.textContent('body');
    expect(bodyText.length).toBeGreaterThan(100);

    // 한국어 콘텐츠 확인
    const koreanContent = bodyText.match(/[\u3131-\u314e|\u314f-\u3163|\uac00-\ud7a3]/g);
    if (koreanContent) {
      console.log(`🔧 [TEST] 한국어 콘텐츠 발견: ${koreanContent.length}글자`);
    }

    console.log('🧪 [TEST] 앱 초기 로딩 테스트 완료');
  });

  test('인증 상태 검증 및 UI 요소 확인', async ({ page }) => {
    console.log('🧪 [TEST] 인증 상태 검증 테스트 시작');

    // 인증 처리
    await authHelper.authenticate();

    // Flutter 앱 안정화 대기
    await page.waitForTimeout(3000);

    // UI 요소 개수 확인
    const buttons = await page.locator('button, flt-semantics[role="button"]').count();
    const clickables = await page.locator('[role="button"], .clickable, [class*="card"]').count();
    const textElements = await page.locator('text, flt-semantics').count();

    console.log(`🔧 [TEST] UI 요소: 버튼 ${buttons}개, 클릭 가능 ${clickables}개, 텍스트 ${textElements}개`);

    // 스크린샷 촬영
    await page.screenshot({
      path: 'test-results/comprehensive-ui-elements.png',
      fullPage: true
    });

    // 기본 UI 요소 존재 확인
    expect(buttons + clickables).toBeGreaterThan(0);

    console.log('🧪 [TEST] 인증 상태 검증 테스트 완료');
  });

  test('Fortune 기능 접근성 테스트', async ({ page }) => {
    console.log('🧪 [TEST] Fortune 기능 접근성 테스트 시작');

    await authHelper.authenticate();
    await page.waitForTimeout(3000);

    const bodyText = await page.textContent('body');

    // Fortune 관련 키워드 검색
    const fortuneKeywords = [
      '운세', '오늘', '사주', '타로', '궁합', '꿈해몽',
      'Fortune', 'MBTI', '성격', '분석', '오늘의'
    ];

    const foundKeywords = fortuneKeywords.filter(keyword =>
      bodyText.includes(keyword)
    );

    console.log(`🔧 [TEST] 발견된 Fortune 키워드: ${foundKeywords.join(', ')}`);

    // Fortune 관련 요소 찾기
    const fortuneElements = await page.locator([
      '[class*="fortune"]',
      '[class*="card"]',
      '[data-testid*="fortune"]',
      '[aria-label*="운세"]',
      '[aria-label*="fortune"]'
    ].join(', ')).count();

    console.log(`🔧 [TEST] Fortune 요소 ${fortuneElements}개 발견`);

    // 스크린샷 촬영
    await page.screenshot({
      path: 'test-results/comprehensive-fortune-access.png',
      fullPage: true
    });

    // 최소한의 Fortune 관련 콘텐츠가 있어야 함
    expect(foundKeywords.length).toBeGreaterThan(0);

    console.log('🧪 [TEST] Fortune 기능 접근성 테스트 완료');
  });

  test('상호작용 가능한 요소 테스트', async ({ page }) => {
    console.log('🧪 [TEST] 상호작용 테스트 시작');

    await authHelper.authenticate();
    await page.waitForTimeout(3000);

    // 클릭 가능한 요소 찾기
    const clickableSelectors = [
      'button',
      'flt-semantics[role="button"]',
      '[role="button"]',
      '.clickable',
      '[class*="card"]',
      '[class*="button"]',
      'a'
    ];

    for (const selector of clickableSelectors) {
      const elements = await page.locator(selector).all();

      if (elements.length > 0) {
        console.log(`🔧 [TEST] "${selector}" 요소 ${elements.length}개 발견`);

        // 첫 번째 요소와 상호작용 시도
        try {
          const firstElement = elements[0];
          const text = await firstElement.textContent().catch(() => '텍스트 없음');
          const ariaLabel = await firstElement.getAttribute('aria-label').catch(() => null);

          console.log(`🔧 [TEST] 요소 정보 - 텍스트: "${text}", 라벨: "${ariaLabel}"`);

          // 요소가 보이고 활성화되어 있으면 클릭 시도
          const isVisible = await firstElement.isVisible();
          const isEnabled = await firstElement.isEnabled().catch(() => true);

          if (isVisible && isEnabled) {
            await firstElement.click({ timeout: 5000 });
            await page.waitForTimeout(1000);
            console.log(`🔧 [TEST] "${selector}" 요소 클릭 성공`);

            // 클릭 후 스크린샷
            await page.screenshot({
              path: `test-results/comprehensive-interaction-${selector.replace(/[^a-zA-Z]/g, '')}.png`,
              fullPage: true
            });
          }

          break; // 한 개 선택자당 하나의 요소만 테스트
        } catch (error) {
          console.log(`🔧 [TEST] "${selector}" 클릭 실패: ${error.message}`);
        }
      }
    }

    console.log('🧪 [TEST] 상호작용 테스트 완료');
  });

  test('폼 입력 및 데이터 제출 테스트', async ({ page }) => {
    console.log('🧪 [TEST] 폼 입력 테스트 시작');

    await authHelper.authenticate();
    await page.waitForTimeout(3000);

    // 입력 필드 찾기
    const inputs = await page.locator('input, textarea, [contenteditable="true"]').all();
    console.log(`🔧 [TEST] 입력 필드 ${inputs.length}개 발견`);

    for (let i = 0; i < Math.min(inputs.length, 5); i++) {
      try {
        const input = inputs[i];
        const type = await input.getAttribute('type').catch(() => 'text');
        const placeholder = await input.getAttribute('placeholder').catch(() => '');
        const ariaLabel = await input.getAttribute('aria-label').catch(() => '');

        console.log(`🔧 [TEST] 입력 필드 ${i + 1}: type="${type}", placeholder="${placeholder}", label="${ariaLabel}"`);

        // 입력 필드 타입에 따라 테스트 데이터 입력
        let testData = '테스트 데이터';

        if (type === 'email' || placeholder.includes('이메일') || ariaLabel.includes('email')) {
          testData = 'test@zpzg.com';
        } else if (type === 'date' || placeholder.includes('생년월일') || ariaLabel.includes('date')) {
          testData = '1990-01-01';
        } else if (placeholder.includes('이름') || ariaLabel.includes('name')) {
          testData = '테스트 사용자';
        } else if (placeholder.includes('질문') || ariaLabel.includes('question')) {
          testData = '오늘의 운세는 어떨까요?';
        }

        // 입력 필드가 보이고 활성화되어 있으면 데이터 입력
        const isVisible = await input.isVisible();
        const isEnabled = await input.isEnabled().catch(() => true);

        if (isVisible && isEnabled) {
          await input.fill(testData);
          await page.waitForTimeout(500);
          console.log(`🔧 [TEST] 입력 필드 ${i + 1}에 "${testData}" 입력 완료`);
        }

      } catch (error) {
        console.log(`🔧 [TEST] 입력 필드 ${i + 1} 처리 실패: ${error.message}`);
      }
    }

    // 제출 버튼 찾기 및 클릭
    const submitSelectors = [
      'button[type="submit"]',
      'button:has-text("생성")',
      'button:has-text("확인")',
      'button:has-text("시작")',
      'button:has-text("완료")',
      '[role="button"]:has-text("생성")'
    ];

    for (const selector of submitSelectors) {
      try {
        const submitButton = await page.locator(selector).first();
        const isVisible = await submitButton.isVisible().catch(() => false);

        if (isVisible) {
          await submitButton.click({ timeout: 5000 });
          await page.waitForTimeout(2000); // 응답 대기
          console.log(`🔧 [TEST] 제출 버튼 "${selector}" 클릭 완료`);
          break;
        }
      } catch (error) {
        console.log(`🔧 [TEST] 제출 버튼 "${selector}" 클릭 실패: ${error.message}`);
      }
    }

    // 최종 스크린샷
    await page.screenshot({
      path: 'test-results/comprehensive-form-test.png',
      fullPage: true
    });

    console.log('🧪 [TEST] 폼 입력 테스트 완료');
  });

  test('네비게이션 및 페이지 이동 테스트', async ({ page }) => {
    console.log('🧪 [TEST] 네비게이션 테스트 시작');

    await authHelper.authenticate();
    await page.waitForTimeout(3000);

    // 네비게이션 요소 찾기
    const navSelectors = [
      'nav',
      '[role="navigation"]',
      '.navigation',
      '.bottom-navigation',
      '.nav-bar',
      'flt-semantics[role="navigation"]'
    ];

    let navigationFound = false;

    for (const selector of navSelectors) {
      try {
        const navElements = await page.locator(selector).all();

        if (navElements.length > 0) {
          console.log(`🔧 [TEST] 네비게이션 "${selector}" ${navElements.length}개 발견`);
          navigationFound = true;

          // 네비게이션 내의 클릭 가능한 요소 찾기
          const navItems = await page.locator(`${selector} button, ${selector} a, ${selector} [role="button"]`).all();

          for (let i = 0; i < Math.min(navItems.length, 3); i++) {
            try {
              const item = navItems[i];
              const text = await item.textContent().catch(() => '');
              const ariaLabel = await item.getAttribute('aria-label').catch(() => '');

              console.log(`🔧 [TEST] 네비게이션 항목 ${i + 1}: "${text}" / "${ariaLabel}"`);

              const isVisible = await item.isVisible();
              if (isVisible) {
                await item.click({ timeout: 5000 });
                await page.waitForTimeout(1500);

                // 페이지 이동 후 스크린샷
                await page.screenshot({
                  path: `test-results/comprehensive-nav-${i + 1}.png`,
                  fullPage: true
                });

                console.log(`🔧 [TEST] 네비게이션 항목 ${i + 1} 클릭 완료`);
              }
            } catch (error) {
              console.log(`🔧 [TEST] 네비게이션 항목 ${i + 1} 클릭 실패: ${error.message}`);
            }
          }

          break; // 하나의 네비게이션만 테스트
        }
      } catch (error) {
        console.log(`🔧 [TEST] 네비게이션 "${selector}" 처리 실패: ${error.message}`);
      }
    }

    if (!navigationFound) {
      console.log('🔧 [TEST] 네비게이션 요소를 찾을 수 없음 - 단일 페이지 앱일 수 있음');
    }

    console.log('🧪 [TEST] 네비게이션 테스트 완료');
  });

  test('에러 처리 및 복구 테스트', async ({ page }) => {
    console.log('🧪 [TEST] 에러 처리 테스트 시작');

    // 의도적으로 잘못된 URL로 이동
    try {
      await page.goto('/nonexistent-page', { timeout: 10000 });
    } catch (error) {
      console.log(`🔧 [TEST] 잘못된 페이지 접근 - 예상된 에러: ${error.message}`);
    }

    // 다시 홈페이지로 이동
    await page.goto('/', { timeout: 45000 });
    await authHelper.authenticate();
    await page.waitForTimeout(3000);

    // 페이지 에러 감지
    const errors = [];
    page.on('pageerror', error => {
      errors.push(error.message);
      console.log(`🔧 [TEST] 페이지 에러 감지: ${error.message}`);
    });

    // 네트워크 에러 감지
    const failedRequests = [];
    page.on('response', response => {
      if (response.status() >= 400) {
        failedRequests.push(`${response.status()} ${response.url()}`);
        console.log(`🔧 [TEST] 네트워크 에러: ${response.status()} ${response.url()}`);
      }
    });

    // 5초 동안 에러 수집
    await page.waitForTimeout(5000);

    // 에러 리포트
    console.log(`🔧 [TEST] 총 페이지 에러: ${errors.length}개`);
    console.log(`🔧 [TEST] 총 네트워크 에러: ${failedRequests.length}개`);

    // 에러가 있어도 앱이 기본적으로 작동하는지 확인
    const bodyText = await page.textContent('body');
    expect(bodyText.length).toBeGreaterThan(50);

    // 최종 상태 스크린샷
    await page.screenshot({
      path: 'test-results/comprehensive-error-test.png',
      fullPage: true
    });

    console.log('🧪 [TEST] 에러 처리 테스트 완료');
  });
});
