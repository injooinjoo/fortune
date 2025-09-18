const { chromium } = require('playwright');

(async () => {
  console.log('🚀 고화질 브라우저 시작...');
  const browser = await chromium.launch({
    headless: false,
    slowMo: 500,
    args: [
      '--disable-web-security',
      '--disable-features=VizDisplayCompositor',
      '--force-device-scale-factor=2',  // 고해상도
      '--high-dpi-support=1'
    ]
  });

  const page = await browser.newPage();

  // 고해상도 설정
  await page.setViewportSize({ width: 1920, height: 1080 });
  await page.setExtraHTTPHeaders({
    'Accept-Language': 'ko-KR,ko;q=0.9,en;q=0.8'
  });

  console.log('📱 http://localhost:8080 접속 중...');

  try {
    await page.goto('http://localhost:8080', {
      waitUntil: 'networkidle',
      timeout: 30000
    });

    console.log('✅ 페이지 로드 완료');

    // 고화질 스크린샷 캡처 - PNG는 무손실 압축이므로 quality 옵션 불필요
    console.log('📸 고화질 라이트모드 스크린샷 캡처...');
    await page.screenshot({
      path: './screenshots/hq-01-light-mode.png',
      fullPage: true
    });

    // 시작하기 버튼 찾아서 클릭
    console.log('🔍 시작하기 버튼 찾는 중...');

    const startButton = page.locator('button:has-text("시작하기")').first();
    if (await startButton.count() > 0) {
      console.log('🎯 시작하기 버튼 클릭...');
      await startButton.click();
      await page.waitForTimeout(3000);

      console.log('📸 메인 화면 고화질 스크린샷 캡처...');
      await page.screenshot({
        path: './screenshots/hq-02-main-screen.png',
        fullPage: true
      });

      // 현재 URL 확인
      const currentUrl = page.url();
      console.log(`📍 현재 URL: ${currentUrl}`);

      // 설정 또는 프로필 메뉴 찾기
      console.log('🔍 설정/프로필 메뉴 찾는 중...');

      const menuSelectors = [
        '.settings',
        '.profile',
        '[class*="profile"]',
        '[class*="settings"]',
        '[class*="menu"]',
        'button[aria-label*="메뉴"]',
        'button[aria-label*="설정"]',
        'button[aria-label*="프로필"]'
      ];

      let menuFound = false;

      for (const selector of menuSelectors) {
        try {
          const element = page.locator(selector).first();
          if (await element.count() > 0) {
            console.log(`✅ 메뉴 발견: ${selector}`);

            // 메뉴 클릭 전 스크린샷
            await page.screenshot({
              path: './screenshots/hq-03-before-menu.png',
              fullPage: true,
              quality: 100,
              type: 'png'
            });

            await element.click();
            await page.waitForTimeout(2000);
            menuFound = true;

            // 메뉴 열린 후 스크린샷
            await page.screenshot({
              path: './screenshots/hq-04-menu-opened.png',
              fullPage: true,
              quality: 100,
              type: 'png'
            });

            // 다크모드 관련 요소 찾기
            const darkModeSelectors = [
              'button:has-text("다크모드")',
              'button:has-text("테마")',
              '.theme-toggle',
              '.dark-mode-toggle',
              'input[type="checkbox"]',
              '.switch'
            ];

            for (const dmSelector of darkModeSelectors) {
              try {
                const dmElement = page.locator(dmSelector).first();
                if (await dmElement.count() > 0) {
                  console.log(`🌙 다크모드 토글 발견: ${dmSelector}`);

                  // 다크모드 토글 클릭
                  await dmElement.click();
                  await page.waitForTimeout(2000);

                  // 다크모드 적용 후 고화질 스크린샷
                  console.log('📸 다크모드 고화질 스크린샷 캡처...');
                  await page.screenshot({
                    path: './screenshots/hq-05-dark-mode.png',
                    fullPage: true,
                    quality: 100,
                    type: 'png'
                  });

                  // 라이트모드로 복원
                  await dmElement.click();
                  await page.waitForTimeout(2000);

                  await page.screenshot({
                    path: './screenshots/hq-06-light-restored.png',
                    fullPage: true,
                    quality: 100,
                    type: 'png'
                  });

                  console.log('✅ 다크모드 테스트 완료!');
                  return;
                }
              } catch (e) {
                // 계속 찾기
              }
            }
            break;
          }
        } catch (e) {
          // 다음 선택자 시도
        }
      }

      if (!menuFound) {
        console.log('❌ 설정/프로필 메뉴를 찾을 수 없습니다.');

        // 모든 클릭 가능한 요소들 확인
        const allClickables = await page.evaluate(() => {
          const elements = Array.from(document.querySelectorAll('button, [role="button"], .clickable, a, input'));
          return elements.map(el => ({
            text: el.textContent?.trim() || '',
            tagName: el.tagName,
            className: el.className || '',
            id: el.id || '',
            type: el.type || ''
          })).slice(0, 20);
        });

        console.log('📋 클릭 가능한 요소들:');
        allClickables.forEach((item, index) => {
          console.log(`🔘 ${index+1}. ${item.tagName}: "${item.text}" (class: ${item.className}, id: ${item.id}, type: ${item.type})`);
        });
      }

    } else {
      console.log('❌ 시작하기 버튼을 찾을 수 없습니다.');
    }

    console.log('🔍 브라우저를 열어둔 상태로 유지합니다.');

  } catch (error) {
    console.error('❌ 오류 발생:', error.message);
    await page.screenshot({
      path: './screenshots/hq-error.png',
      fullPage: true,
      quality: 100,
      type: 'png'
    });
  }

})();