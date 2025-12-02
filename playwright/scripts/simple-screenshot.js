/**
 * 간단한 스크린샷 캡처 스크립트
 * 로그인 없이 접근 가능한 화면들만 캡처
 */

const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const CONFIG = {
  baseUrl: 'http://localhost:3000',
  viewport: { width: 393, height: 852 },
  outputDir: path.join(__dirname, '../../screenshots/figma'),
  waitTime: 4000,
  timeout: 60000, // 60초로 늘림
};

// 로그인 없이 접근 가능한 핵심 화면들
const PAGES = [
  // 인증 없이 접근 가능
  { path: '/', name: '01_landing', category: 'core' },
  { path: '/signup', name: '02_signup', category: 'auth' },
  { path: '/onboarding', name: '03_onboarding', category: 'auth' },

  // 메인 화면들 (일부는 리다이렉트될 수 있음)
  { path: '/home', name: '04_home', category: 'core' },
  { path: '/fortune', name: '05_fortune_list', category: 'core' },
  { path: '/trend', name: '06_trend', category: 'core' },
  { path: '/premium', name: '07_premium', category: 'core' },

  // 운세 입력 화면들 (대부분 로그인 없이 접근 가능)
  { path: '/tarot', name: '10_tarot', category: 'fortune' },
  { path: '/compatibility', name: '11_compatibility', category: 'fortune' },
  { path: '/mbti', name: '12_mbti', category: 'fortune' },
  { path: '/dream', name: '13_dream', category: 'fortune' },
  { path: '/love', name: '14_love', category: 'fortune' },
  { path: '/career', name: '15_career', category: 'fortune' },
  { path: '/health-toss', name: '16_health', category: 'fortune' },
  { path: '/biorhythm', name: '17_biorhythm', category: 'fortune' },
  { path: '/face-reading', name: '18_face_reading', category: 'fortune' },
  { path: '/traditional-saju', name: '19_traditional_saju', category: 'fortune' },
  { path: '/lucky-items', name: '20_lucky_items', category: 'fortune' },
  { path: '/daily-calendar', name: '21_daily_calendar', category: 'fortune' },
  { path: '/moving', name: '22_moving', category: 'fortune' },
  { path: '/personality-dna', name: '23_personality_dna', category: 'fortune' },
  { path: '/wish', name: '24_wish', category: 'fortune' },
  { path: '/celebrity', name: '25_celebrity', category: 'fortune' },

  // 프로필/설정 (리다이렉트될 수 있음)
  { path: '/profile', name: '30_profile', category: 'profile' },
  { path: '/settings', name: '31_settings', category: 'profile' },
  { path: '/subscription', name: '32_subscription', category: 'profile' },
  { path: '/token-purchase', name: '33_token_purchase', category: 'profile' },

  // 인터랙티브
  { path: '/interactive', name: '40_interactive', category: 'interactive' },
  { path: '/interactive/dream', name: '41_dream_chat', category: 'interactive' },
  { path: '/interactive/tarot', name: '42_tarot_chat', category: 'interactive' },
];

async function main() {
  console.log('='.repeat(60));
  console.log('Fortune App - Simple Screenshot Capture');
  console.log('='.repeat(60));
  console.log(`총 ${PAGES.length}개 페이지 캡처 예정`);
  console.log(`출력 폴더: ${CONFIG.outputDir}`);
  console.log('='.repeat(60));

  // 출력 폴더 생성
  if (!fs.existsSync(CONFIG.outputDir)) {
    fs.mkdirSync(CONFIG.outputDir, { recursive: true });
  }

  // 브라우저 시작
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: CONFIG.viewport,
    deviceScaleFactor: 2, // Retina
  });
  const page = await context.newPage();

  const results = { success: 0, failed: 0, errors: [] };

  for (const pageInfo of PAGES) {
    const url = `${CONFIG.baseUrl}${pageInfo.path}`;
    const filename = `${pageInfo.name}.png`;
    const outputPath = path.join(CONFIG.outputDir, filename);

    try {
      console.log(`📸 캡처 중: ${pageInfo.name} (${pageInfo.path})`);

      await page.goto(url, { waitUntil: 'load', timeout: CONFIG.timeout });
      await page.waitForTimeout(CONFIG.waitTime);

      await page.screenshot({ path: outputPath, fullPage: false });

      console.log(`   ✅ 저장됨: ${filename}`);
      results.success++;
    } catch (error) {
      console.log(`   ❌ 실패: ${error.message}`);
      results.failed++;
      results.errors.push({ page: pageInfo.name, error: error.message });
    }
  }

  await browser.close();

  // 결과 출력
  console.log('\n' + '='.repeat(60));
  console.log('완료!');
  console.log('='.repeat(60));
  console.log(`✅ 성공: ${results.success}`);
  console.log(`❌ 실패: ${results.failed}`);
  console.log(`📁 저장 위치: ${CONFIG.outputDir}`);

  if (results.errors.length > 0) {
    console.log('\n실패한 페이지:');
    results.errors.forEach(e => console.log(`  - ${e.page}: ${e.error}`));
  }

  // 결과 JSON 저장
  fs.writeFileSync(
    path.join(CONFIG.outputDir, '_manifest.json'),
    JSON.stringify({ timestamp: new Date().toISOString(), results, pages: PAGES }, null, 2)
  );
}

main().catch(console.error);
