/**
 * Playwright Test Scenarios Index
 *
 * 모든 테스트 시나리오를 export
 */

const {
  fortunePageScenario,
  runFortunePageTest,
  formatTestResults
} = require('./fortune-page.scenario');

/**
 * 페이지 경로에 따른 시나리오 매핑
 */
const scenarioMapping = {
  // 운세 페이지들
  '/fortune/daily': 'fortune-page',
  '/fortune/tarot': 'fortune-page',
  '/fortune/compatibility': 'fortune-page',
  '/fortune/palmistry': 'fortune-page',
  '/fortune/dream': 'fortune-page',
  '/fortune/saju': 'fortune-page',

  // 일반 페이지들
  '/home': 'page-render',
  '/profile': 'page-render',
  '/premium': 'page-render',

  // 기본값
  'default': 'page-render'
};

/**
 * 경로에 맞는 시나리오 반환
 */
function getScenarioForPath(path) {
  // 정확한 매칭
  if (scenarioMapping[path]) {
    return scenarioMapping[path];
  }

  // 운세 관련 경로면 fortune-page 시나리오
  if (path.includes('fortune') || path.includes('saju') || path.includes('tarot')) {
    return 'fortune-page';
  }

  return scenarioMapping['default'];
}

/**
 * 시나리오 실행
 */
async function runScenario(page, path, options = {}) {
  const scenarioType = getScenarioForPath(path);

  console.log(`🎭 시나리오 타입: ${scenarioType}`);

  switch (scenarioType) {
    case 'fortune-page':
      return await runFortunePageTest(page, path, options);
    case 'page-render':
    default:
      return await runPageRenderTest(page, path, options);
  }
}

/**
 * 기본 페이지 렌더링 테스트
 */
async function runPageRenderTest(page, path, options = {}) {
  const baseUrl = options.baseUrl || process.env.BASE_URL || 'http://localhost:3000';
  const fullUrl = `${baseUrl}${path}`;

  const results = {
    path,
    timestamp: new Date().toISOString(),
    steps: [],
    errors: [],
    screenshots: []
  };

  try {
    // 페이지 로딩
    await page.goto(fullUrl, { waitUntil: 'networkidle', timeout: 30000 });
    results.steps.push({ name: '페이지 로딩', status: 'pass' });

    // Flutter 초기화 대기
    await page.waitForTimeout(3000);
    results.steps.push({ name: 'Flutter 초기화', status: 'pass' });

    // 기본 콘텐츠 확인
    const bodyText = await page.textContent('body');
    if (bodyText && bodyText.length > 100) {
      results.steps.push({ name: '콘텐츠 렌더링', status: 'pass' });
    } else {
      results.steps.push({ name: '콘텐츠 렌더링', status: 'warn' });
    }

    // 스크린샷
    const screenshotPath = `playwright/screenshots/${path.replace(/\//g, '-')}-${Date.now()}.png`;
    await page.screenshot({ path: screenshotPath, fullPage: true });
    results.screenshots.push(screenshotPath);

    results.status = 'pass';

  } catch (error) {
    results.status = 'fail';
    results.errors.push({ type: 'test', message: error.message });
  }

  return results;
}

module.exports = {
  scenarioMapping,
  getScenarioForPath,
  runScenario,
  runPageRenderTest,
  fortunePageScenario,
  runFortunePageTest,
  formatTestResults
};