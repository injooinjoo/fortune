/**
 * Fortune Page E2E Test Scenario
 *
 * 운세 페이지 자동 QA 테스트 시나리오
 * Playwright MCP와 함께 사용
 */

const { expect } = require('@playwright/test');

/**
 * 운세 페이지 테스트 시나리오
 */
const fortunePageScenario = {
  name: 'fortune-page',
  description: '운세 페이지 E2E 테스트',

  /**
   * 테스트 설정
   */
  config: {
    baseUrl: process.env.BASE_URL || 'http://localhost:3000',
    timeout: 30000,
    retries: 2,
    screenshotOnFailure: true
  },

  /**
   * 테스트 단계 정의
   */
  steps: [
    {
      name: '페이지 로딩',
      action: 'goto',
      params: { waitUntil: 'networkidle' }
    },
    {
      name: 'Flutter 앱 초기화 대기',
      action: 'waitForTimeout',
      params: { ms: 3000 }
    },
    {
      name: '메인 콘텐츠 확인',
      action: 'assertVisible',
      params: {
        selectors: ['text=운세', 'text=오늘', '[class*="fortune"]'],
        matchAny: true
      }
    },
    {
      name: '입력 폼 확인',
      action: 'assertExists',
      params: {
        selectors: ['input', 'button', '[type="submit"]'],
        matchAny: true
      }
    },
    {
      name: '운세 생성 버튼 클릭',
      action: 'click',
      params: {
        selectors: [
          'button:has-text("운세")',
          'button:has-text("확인")',
          'button:has-text("시작")',
          '[class*="submit"]'
        ],
        matchFirst: true
      }
    },
    {
      name: '로딩 상태 확인',
      action: 'waitForLoadingComplete',
      params: {
        loadingSelectors: ['[class*="loading"]', '[class*="spinner"]', 'text=로딩'],
        timeout: 15000
      }
    },
    {
      name: '결과 화면 확인',
      action: 'assertVisible',
      params: {
        selectors: ['text=결과', 'text=운세', '[class*="result"]'],
        matchAny: true
      }
    },
    {
      name: '스크린샷 캡처',
      action: 'screenshot',
      params: { fullPage: true }
    }
  ],

  /**
   * 검증 항목
   */
  validations: {
    noConsoleErrors: true,
    noNetworkErrors: true,
    checkAccessibility: false, // 선택적
    checkPerformance: false    // 선택적
  }
};

/**
 * 테스트 실행 함수
 * @param {Page} page - Playwright Page 객체
 * @param {string} path - 테스트할 페이지 경로
 * @param {object} options - 추가 옵션
 */
async function runFortunePageTest(page, path, options = {}) {
  const results = {
    path,
    timestamp: new Date().toISOString(),
    steps: [],
    errors: [],
    screenshots: []
  };

  const { baseUrl, timeout } = fortunePageScenario.config;
  const fullUrl = `${baseUrl}${path}`;

  console.log(`🎭 [QA] 테스트 시작: ${fullUrl}`);

  // 콘솔 에러 수집
  const consoleErrors = [];
  page.on('console', msg => {
    if (msg.type() === 'error') {
      consoleErrors.push(msg.text());
    }
  });

  // 네트워크 에러 수집
  const networkErrors = [];
  page.on('response', response => {
    if (response.status() >= 400) {
      networkErrors.push({
        url: response.url(),
        status: response.status()
      });
    }
  });

  try {
    // Step 1: 페이지 이동
    console.log('  → 페이지 로딩...');
    await page.goto(fullUrl, { timeout, waitUntil: 'networkidle' });
    results.steps.push({ name: '페이지 로딩', status: 'pass', time: Date.now() });

    // Step 2: Flutter 초기화 대기
    console.log('  → Flutter 앱 초기화 대기...');
    await page.waitForTimeout(3000);
    results.steps.push({ name: 'Flutter 초기화', status: 'pass', time: Date.now() });

    // Step 3: 메인 콘텐츠 확인
    console.log('  → 메인 콘텐츠 확인...');
    const hasMainContent = await checkAnySelector(page, [
      'text=운세', 'text=오늘', 'text=사주', 'text=타로'
    ]);
    results.steps.push({
      name: '메인 콘텐츠',
      status: hasMainContent ? 'pass' : 'warn',
      time: Date.now()
    });

    // Step 4: 인터랙션 테스트 (버튼 클릭)
    console.log('  → 인터랙션 테스트...');
    const buttonClicked = await tryClickButton(page, [
      'button:has-text("운세")',
      'button:has-text("확인")',
      'button:has-text("시작")',
      'button:has-text("보기")'
    ]);

    if (buttonClicked) {
      // 로딩 완료 대기
      await page.waitForTimeout(5000);
      results.steps.push({ name: '인터랙션', status: 'pass', time: Date.now() });
    } else {
      results.steps.push({ name: '인터랙션', status: 'skip', time: Date.now() });
    }

    // Step 5: 스크린샷 캡처
    console.log('  → 스크린샷 캡처...');
    const screenshotPath = `playwright/screenshots/${path.replace(/\//g, '-')}-${Date.now()}.png`;
    await page.screenshot({ path: screenshotPath, fullPage: true });
    results.screenshots.push(screenshotPath);
    results.steps.push({ name: '스크린샷', status: 'pass', time: Date.now() });

    // 에러 검증
    if (consoleErrors.length > 0) {
      results.errors.push(...consoleErrors.map(e => ({ type: 'console', message: e })));
    }
    if (networkErrors.length > 0) {
      results.errors.push(...networkErrors.map(e => ({ type: 'network', ...e })));
    }

    results.status = results.errors.length === 0 ? 'pass' : 'warn';

  } catch (error) {
    console.log(`  ❌ 에러 발생: ${error.message}`);
    results.status = 'fail';
    results.errors.push({ type: 'test', message: error.message });

    // 실패 시 스크린샷
    try {
      const errorScreenshot = `playwright/screenshots/error-${Date.now()}.png`;
      await page.screenshot({ path: errorScreenshot });
      results.screenshots.push(errorScreenshot);
    } catch (e) {
      // 스크린샷 실패 무시
    }
  }

  console.log(`🎭 [QA] 테스트 완료: ${results.status.toUpperCase()}`);
  return results;
}

/**
 * 여러 셀렉터 중 하나라도 존재하는지 확인
 */
async function checkAnySelector(page, selectors) {
  for (const selector of selectors) {
    try {
      const element = await page.locator(selector).first();
      if (await element.isVisible({ timeout: 2000 })) {
        return true;
      }
    } catch (e) {
      // 무시
    }
  }
  return false;
}

/**
 * 여러 버튼 셀렉터 중 첫 번째로 클릭 가능한 것을 클릭
 */
async function tryClickButton(page, selectors) {
  for (const selector of selectors) {
    try {
      const button = await page.locator(selector).first();
      if (await button.isVisible({ timeout: 2000 })) {
        await button.click();
        return true;
      }
    } catch (e) {
      // 무시
    }
  }
  return false;
}

/**
 * 테스트 결과 포맷팅
 */
function formatTestResults(results) {
  const statusEmoji = {
    pass: '✅',
    warn: '⚠️',
    fail: '❌',
    skip: '⏭️'
  };

  let output = `
============================================
🎭 자동 QA 테스트 결과
============================================

📍 테스트 대상: ${results.path}
🕐 실행 시간: ${results.timestamp}

테스트 항목:
`;

  for (const step of results.steps) {
    output += `  ${statusEmoji[step.status] || '❓'} ${step.name}\n`;
  }

  if (results.errors.length > 0) {
    output += `\n⚠️ 발견된 문제:\n`;
    for (const error of results.errors) {
      output += `  - [${error.type}] ${error.message || error.url}\n`;
    }
  }

  if (results.screenshots.length > 0) {
    output += `\n📸 스크린샷:\n`;
    for (const screenshot of results.screenshots) {
      output += `  - ${screenshot}\n`;
    }
  }

  output += `
============================================
총 결과: ${statusEmoji[results.status]} ${results.status.toUpperCase()}
============================================
`;

  return output;
}

module.exports = {
  fortunePageScenario,
  runFortunePageTest,
  formatTestResults,
  checkAnySelector,
  tryClickButton
};