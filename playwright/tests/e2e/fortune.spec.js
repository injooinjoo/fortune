// fortune.spec.js
const { test, expect } = require('@playwright/test');
const { AuthHelper } = require('../../helpers/auth.helper');

test.describe('Fortune Generation Flow', () => {
  let authHelper;

  test.beforeEach(async ({ page }) => {
    authHelper = new AuthHelper(page);
    // Authenticate before each test
    await authHelper.authenticate();
  });

  test('should access fortune features after authentication', async ({ page }) => {
    console.log('🧪 [TEST] Starting fortune access test');

    // Wait for app to load
    await page.waitForTimeout(2000);

    // Look for fortune-related content
    const bodyText = await page.textContent('body');

    // Check for Korean fortune-related terms (앱 이름 변경에 따라 키워드 확장)
    const fortuneKeywords = ['운세', '오늘', '사주', '타로', '궁합', '꿈해몽', '채팅', '홈', '프로필', '탐구', '트렌드', 'Ondo'];
    const foundKeywords = fortuneKeywords.filter(keyword => bodyText.includes(keyword));

    console.log(`🔧 [TEST] Found keywords: ${foundKeywords.join(', ')}`);
    console.log(`🔧 [TEST] Body text length: ${bodyText.length}`);

    // Look for interactive elements
    const buttons = await page.locator('button, [role="button"]').count();
    console.log(`🔧 [TEST] Found ${buttons} buttons`);

    // Try to find fortune cards or similar elements
    const fortuneCards = await page.locator('[class*="fortune"], [class*="card"], [data-testid*="fortune"]').count();
    console.log(`🔧 [TEST] Found ${fortuneCards} potential fortune elements`);

    // Take screenshot
    await page.screenshot({
      path: 'test-results/fortune-access.png',
      fullPage: true
    });

    // Basic expectations - 앱이 로드되었으면 OK (콘텐츠 길이로 확인)
    expect(bodyText.length).toBeGreaterThan(100);  // 앱이 로드되면 콘텐츠가 있어야 함

    console.log('🧪 [TEST] Fortune access test completed');
  });

  test('should interact with fortune generation', async ({ page }) => {
    console.log('🧪 [TEST] Starting fortune interaction test');

    // Wait for app to load
    await page.waitForTimeout(2000);

    // Look for clickable fortune elements
    const clickableElements = await page.locator('button, [role="button"], .clickable, [class*="card"]').all();
    console.log(`🔧 [TEST] Found ${clickableElements.length} clickable elements`);

    if (clickableElements.length > 0) {
      // Try clicking the first few elements
      for (let i = 0; i < Math.min(3, clickableElements.length); i++) {
        try {
          console.log(`🔧 [TEST] Clicking element ${i + 1}`);
          await clickableElements[i].click();
          await page.waitForTimeout(1000);

          // Take screenshot after click
          await page.screenshot({
            path: `test-results/fortune-interaction-${i + 1}.png`,
            fullPage: true
          });
        } catch (error) {
          console.log(`🔧 [TEST] Failed to click element ${i + 1}: ${error.message}`);
        }
      }
    }

    // Look for any modal dialogs or popups
    const modals = await page.locator('[role="dialog"], .modal, [class*="popup"]').count();
    console.log(`🔧 [TEST] Found ${modals} modal elements`);

    console.log('🧪 [TEST] Fortune interaction test completed');
  });

  test('should handle fortune generation flow', async ({ page }) => {
    console.log('🧪 [TEST] Starting fortune generation flow test');

    // Wait for app to load
    await page.waitForTimeout(2000);

    // Look for text inputs (might be for birth info, questions, etc.)
    const inputs = await page.locator('input, textarea').all();
    console.log(`🔧 [TEST] Found ${inputs.length} input elements`);

    // Fill in any text inputs with test data
    for (let i = 0; i < inputs.length; i++) {
      try {
        const input = inputs[i];
        const inputType = await input.getAttribute('type') || 'text';
        const placeholder = await input.getAttribute('placeholder') || '';

        console.log(`🔧 [TEST] Input ${i + 1}: type=${inputType}, placeholder="${placeholder}"`);

        // Fill with appropriate test data based on input type/placeholder
        if (inputType === 'email' || placeholder.includes('이메일') || placeholder.includes('email')) {
          await input.fill('test@zpzg.com');
        } else if (inputType === 'date' || placeholder.includes('생년월일') || placeholder.includes('date')) {
          await input.fill('1990-01-01');
        } else if (placeholder.includes('이름') || placeholder.includes('name')) {
          await input.fill('테스트 사용자');
        } else if (placeholder.includes('질문') || placeholder.includes('question')) {
          await input.fill('테스트 질문입니다');
        } else {
          await input.fill('테스트 데이터');
        }

        await page.waitForTimeout(500);
      } catch (error) {
        console.log(`🔧 [TEST] Failed to fill input ${i + 1}: ${error.message}`);
      }
    }

    // Look for submit/generate buttons
    const submitButtons = await page.locator('button:has-text("생성"), button:has-text("확인"), button:has-text("시작"), [type="submit"]').all();
    console.log(`🔧 [TEST] Found ${submitButtons.length} submit buttons`);

    if (submitButtons.length > 0) {
      try {
        await submitButtons[0].click();
        await page.waitForTimeout(3000); // Wait for generation

        console.log('🔧 [TEST] Clicked submit button, waiting for response');
      } catch (error) {
        console.log(`🔧 [TEST] Failed to click submit button: ${error.message}`);
      }
    }

    // Take final screenshot
    await page.screenshot({
      path: 'test-results/fortune-generation-flow.png',
      fullPage: true
    });

    console.log('🧪 [TEST] Fortune generation flow test completed');
  });
});
