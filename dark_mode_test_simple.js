const { chromium } = require('playwright');

(async () => {
  console.log('🚀 다크모드 테스트 시작...');
  const browser = await chromium.launch({
    headless: false,
    slowMo: 1000,
    args: [
      '--disable-web-security',
      '--disable-features=VizDisplayCompositor',
      '--force-device-scale-factor=2',
      '--high-dpi-support=1'
    ]
  });

  const page = await browser.newPage();
  await page.setViewportSize({ width: 1920, height: 1080 });

  try {
    console.log('📱 http://localhost:8080 접속...');
    await page.goto('http://localhost:8080', {
      waitUntil: 'networkidle',
      timeout: 30000
    });

    // 1. 랜딩 페이지 스크린샷
    console.log('📸 랜딩 페이지 스크린샷 캡처...');
    await page.screenshot({
      path: './screenshots/step1-landing-page.png',
      fullPage: true
    });

    // 2. 시작하기 버튼 클릭 - 더 간단한 접근
    console.log('🔍 시작하기 버튼 찾기...');

    // 페이지에서 모든 버튼 텍스트 확인
    const buttonTexts = await page.evaluate(() => {
      const buttons = Array.from(document.querySelectorAll('button'));
      return buttons.map(btn => btn.textContent?.trim()).filter(text => text);
    });

    console.log('📋 페이지의 모든 버튼 텍스트:', buttonTexts);

    // CSS 선택자로 버튼 찾기 - 텍스트 기반
    const startButton = await page.locator('button').filter({ hasText: '시작하기' }).first();

    if (await startButton.count() > 0) {
      console.log('✅ 시작하기 버튼 발견');
      await startButton.click();
      await page.waitForTimeout(3000);

      console.log('📸 메인 앱 화면 스크린샷...');
      await page.screenshot({
        path: './screenshots/step2-main-app.png',
        fullPage: true
      });

      console.log('📍 현재 URL:', page.url());

      // 3. 다크모드 토글 찾기 - 단계별 접근
      console.log('🔍 다크모드 설정 찾기...');

      // 먼저 설정 버튼이나 프로필 버튼 찾기
      const settingsButtons = [
        'button[aria-label*="Settings"]',
        'button[aria-label*="설정"]',
        'button[aria-label*="Profile"]',
        'button[aria-label*="프로필"]',
        'button[aria-label*="Menu"]',
        'button[aria-label*="메뉴"]',
        '.settings-button',
        '.profile-button',
        '.menu-button'
      ];

      let settingsFound = false;

      for (const selector of settingsButtons) {
        try {
          const element = page.locator(selector).first();
          if (await element.count() > 0) {
            console.log(`🎯 설정 버튼 발견: ${selector}`);
            await element.click();
            await page.waitForTimeout(1500);
            settingsFound = true;

            await page.screenshot({
              path: './screenshots/step3-settings-opened.png',
              fullPage: true
            });
            break;
          }
        } catch (e) {
          // 다음 선택자 시도
        }
      }

      // 4. 다크모드 토글 찾기
      const darkModeToggles = [
        'button[aria-label*="Dark"]',
        'button[aria-label*="다크"]',
        'button[aria-label*="Theme"]',
        'button[aria-label*="테마"]',
        '.theme-toggle',
        '.dark-mode-toggle',
        'input[type="checkbox"][name*="theme"]',
        'input[type="checkbox"][name*="dark"]'
      ];

      let darkModeButton = null;

      for (const selector of darkModeToggles) {
        try {
          const element = page.locator(selector).first();
          if (await element.count() > 0) {
            console.log(`🌙 다크모드 토글 발견: ${selector}`);
            darkModeButton = element;
            break;
          }
        } catch (e) {
          // 다음 선택자 시도
        }
      }

      if (darkModeButton) {
        // 5. 다크모드 전환 테스트
        console.log('🎯 다크모드 활성화...');
        await darkModeButton.click();
        await page.waitForTimeout(2000);

        await page.screenshot({
          path: './screenshots/step4-dark-mode-on.png',
          fullPage: true
        });

        // 6. 라이트모드로 복원
        console.log('🔄 라이트모드로 복원...');
        await darkModeButton.click();
        await page.waitForTimeout(2000);

        await page.screenshot({
          path: './screenshots/step5-light-mode-restored.png',
          fullPage: true
        });

        console.log('✅ 다크모드 테스트 완료!');

      } else {
        console.log('❌ 다크모드 토글을 찾을 수 없습니다.');

        // 페이지의 모든 요소 구조 확인
        const pageStructure = await page.evaluate(() => {
          const allElements = Array.from(document.querySelectorAll('*'));
          const relevantElements = allElements
            .filter(el => {
              const text = el.textContent?.toLowerCase() || '';
              const className = el.className?.toLowerCase() || '';
              const id = el.id?.toLowerCase() || '';

              return text.includes('dark') || text.includes('다크') ||
                     text.includes('theme') || text.includes('테마') ||
                     className.includes('dark') || className.includes('theme') ||
                     id.includes('dark') || id.includes('theme');
            })
            .slice(0, 10)
            .map(el => ({
              tag: el.tagName,
              text: el.textContent?.trim().substring(0, 50),
              className: el.className,
              id: el.id
            }));

          return relevantElements;
        });

        console.log('🔍 다크모드 관련 요소들:', pageStructure);
      }

    } else {
      console.log('❌ 시작하기 버튼을 찾을 수 없습니다.');
    }

    console.log('✅ 테스트 완료. 브라우저를 열어둔 상태로 유지합니다.');

  } catch (error) {
    console.error('❌ 오류 발생:', error.message);
    await page.screenshot({
      path: './screenshots/error-screenshot.png',
      fullPage: true
    });
  }

  // 브라우저를 열어둔 채로 유지하여 수동 확인 가능
})();