const { chromium } = require('playwright');

(async () => {
  console.log('🚀 랜딩 페이지 다크모드 테스트 시작...');
  const browser = await chromium.launch({
    headless: false,
    slowMo: 1500,
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

    // 1. 랜딩 페이지 초기 상태 스크린샷
    console.log('📸 랜딩 페이지 라이트모드 스크린샷...');
    await page.screenshot({
      path: './screenshots/landing-01-light-mode.png',
      fullPage: true
    });

    // 2. 우상단 다크모드 버튼 찾기 (분석 결과에 따르면 원형 버튼)
    console.log('🔍 우상단 다크모드 토글 버튼 찾기...');

    // 다크모드 버튼 선택자들 - 랜딩 페이지 우상단 기준
    const darkModeSelectors = [
      // 아이콘 기반 (light_mode_outlined / dark_mode_outlined)
      '[data-icon="light_mode_outlined"]',
      '[data-icon="dark_mode_outlined"]',
      'button[aria-label*="다크"]',
      'button[aria-label*="라이트"]',
      'button[aria-label*="테마"]',
      'button[title*="다크"]',
      'button[title*="라이트"]',
      'button[title*="테마"]',

      // CSS 클래스 기반
      '.theme-toggle',
      '.dark-mode-toggle',
      '.mode-toggle',
      '.theme-button',

      // 구조적 선택자 (우상단 영역)
      'header button',
      '.header button',
      '.app-bar button',
      '.top-bar button',

      // 원형 버튼 (분석 결과: Container with CircleShape)
      'button[style*="border-radius"]',
      '.circle-button',

      // 아이콘 포함 버튼
      'button:has([data-icon])',
      'button:has(svg)',
      'button[class*="icon"]'
    ];

    let darkModeButton = null;
    let foundSelector = null;

    // 각 선택자로 시도
    for (const selector of darkModeSelectors) {
      try {
        const elements = await page.locator(selector).all();
        console.log(`🔍 선택자 "${selector}": ${elements.length}개 요소 발견`);

        if (elements.length > 0) {
          // 여러 요소가 있으면 우상단에 있는 것 찾기
          for (let i = 0; i < elements.length; i++) {
            const element = elements[i];

            // 요소의 위치 확인 (우상단인지)
            const boundingBox = await element.boundingBox();
            if (boundingBox) {
              console.log(`  요소 ${i+1} 위치: x=${boundingBox.x}, y=${boundingBox.y}, width=${boundingBox.width}, height=${boundingBox.height}`);

              // 우상단 영역인지 확인 (x > 1500, y < 200 정도)
              if (boundingBox.x > 1500 && boundingBox.y < 200) {
                darkModeButton = element;
                foundSelector = selector;
                console.log(`✅ 우상단 다크모드 버튼 발견: ${selector} (${i+1}번째 요소)`);
                break;
              }
            }
          }

          if (darkModeButton) break;
        }
      } catch (e) {
        // 선택자가 작동하지 않음, 다음으로
      }
    }

    // 모든 버튼의 위치와 속성 확인
    if (!darkModeButton) {
      console.log('🔍 페이지의 모든 버튼 분석...');

      const buttonAnalysis = await page.evaluate(() => {
        const buttons = Array.from(document.querySelectorAll('button'));
        return buttons.map((btn, index) => {
          const rect = btn.getBoundingClientRect();
          const styles = getComputedStyle(btn);

          return {
            index: index + 1,
            text: btn.textContent?.trim() || '',
            className: btn.className || '',
            id: btn.id || '',
            ariaLabel: btn.getAttribute('aria-label') || '',
            title: btn.getAttribute('title') || '',
            position: {
              x: Math.round(rect.x),
              y: Math.round(rect.y),
              width: Math.round(rect.width),
              height: Math.round(rect.height)
            },
            borderRadius: styles.borderRadius,
            backgroundColor: styles.backgroundColor,
            hasIcon: btn.querySelector('svg, [data-icon]') ? true : false,
            innerHTML: btn.innerHTML.substring(0, 100)
          };
        });
      });

      console.log('📋 모든 버튼 정보:');
      buttonAnalysis.forEach(btn => {
        console.log(`🔘 버튼 ${btn.index}: "${btn.text}"`);
        console.log(`   위치: (${btn.position.x}, ${btn.position.y}) 크기: ${btn.position.width}x${btn.position.height}`);
        console.log(`   클래스: ${btn.className}`);
        console.log(`   아이콘: ${btn.hasIcon ? 'Yes' : 'No'}`);
        console.log(`   HTML: ${btn.innerHTML.substring(0, 50)}...`);
        console.log('');
      });

      // 우상단에 있는 버튼들 찾기
      const topRightButtons = buttonAnalysis.filter(btn =>
        btn.position.x > 1400 && btn.position.y < 300
      );

      if (topRightButtons.length > 0) {
        console.log('🎯 우상단 영역의 버튼들:');
        topRightButtons.forEach(btn => {
          console.log(`  버튼 ${btn.index}: "${btn.text}" at (${btn.position.x}, ${btn.position.y})`);
        });

        // 첫 번째 우상단 버튼을 다크모드 버튼으로 시도
        const firstTopRightBtn = topRightButtons[0];
        darkModeButton = page.locator('button').nth(firstTopRightBtn.index - 1);
        foundSelector = `button:nth-child(${firstTopRightBtn.index})`;
        console.log(`✅ 우상단 버튼을 다크모드 토글로 시도: 버튼 ${firstTopRightBtn.index}`);
      }
    }

    if (darkModeButton) {
      console.log(`🎯 다크모드 버튼 클릭 시도 (${foundSelector})`);

      // 버튼이 보이는지 확인
      await darkModeButton.scrollIntoViewIfNeeded();
      await page.waitForTimeout(1000);

      // 3. 다크모드 활성화
      console.log('🌙 다크모드 활성화...');
      await darkModeButton.click();
      await page.waitForTimeout(3000); // 테마 전환 대기

      // 다크모드 활성화 후 스크린샷
      console.log('📸 다크모드 활성화 후 스크린샷...');
      await page.screenshot({
        path: './screenshots/landing-02-dark-mode.png',
        fullPage: true
      });

      // 4. 색상 변화 분석
      console.log('🎨 색상 변화 분석...');
      const colorAnalysis = await page.evaluate(() => {
        const elements = [
          document.body,
          document.querySelector('header'),
          document.querySelector('main'),
          document.querySelector('.landing-content'),
          document.querySelector('h1'),
          document.querySelector('button')
        ].filter(el => el);

        return elements.map(el => {
          const styles = getComputedStyle(el);
          return {
            element: el.tagName + (el.className ? '.' + el.className.split(' ')[0] : ''),
            backgroundColor: styles.backgroundColor,
            color: styles.color,
            borderColor: styles.borderColor
          };
        });
      });

      colorAnalysis.forEach(item => {
        console.log(`🎨 ${item.element}: bg=${item.backgroundColor}, text=${item.color}`);
      });

      // 5. 라이트모드로 복원
      console.log('☀️ 라이트모드로 복원...');
      await darkModeButton.click();
      await page.waitForTimeout(3000);

      // 라이트모드 복원 후 스크린샷
      console.log('📸 라이트모드 복원 후 스크린샷...');
      await page.screenshot({
        path: './screenshots/landing-03-light-restored.png',
        fullPage: true
      });

      console.log('✅ 랜딩 페이지 다크모드 테스트 완료!');

    } else {
      console.log('❌ 다크모드 토글 버튼을 찾을 수 없습니다.');

      // 페이지 구조 확인을 위한 HTML 덤프
      const pageStructure = await page.evaluate(() => {
        return {
          title: document.title,
          bodyClass: document.body.className,
          headerExists: !!document.querySelector('header'),
          buttonsCount: document.querySelectorAll('button').length,
          firstButtons: Array.from(document.querySelectorAll('button')).slice(0, 5).map(btn => ({
            text: btn.textContent?.trim(),
            className: btn.className,
            innerHTML: btn.innerHTML.substring(0, 100)
          }))
        };
      });

      console.log('📝 페이지 구조:', pageStructure);
    }

    console.log('🔍 브라우저를 열어둔 상태로 유지합니다.');

  } catch (error) {
    console.error('❌ 오류 발생:', error.message);
    await page.screenshot({
      path: './screenshots/error-landing-test.png',
      fullPage: true
    });
  }

  // 브라우저를 열어둔 채로 유지
})();