import { test, expect } from '@playwright/test';

test.describe('환영 메시지 컴포넌트 시각적 회귀 테스트', () => {
  test('환영 메시지 UI 변경 감지', async ({ page }) => {
    await page.goto('/');
    
    // 사용자 정보 입력 단계
    await page.fill('input[name="name"]', '김운세');
    await page.click('text=다음');
    
    await page.selectOption('select:near(:text("년"))', '1990');
    await page.selectOption('select:near(:text("월"))', '5');
    await page.selectOption('select:near(:text("일"))', '15');
    await page.click('text=다음');
    
    // 환영 메시지가 표시되는 상태까지 진행
    await page.selectOption('select:near(:text("성별"))', '남성');
    await page.click('text=완료');
    
    // 환영 메시지 컴포넌트가 렌더링될 때까지 대기
    const welcomeMessage = page.getByTestId('welcome-message');
    await expect(welcomeMessage).toBeVisible();
    
    // 환영 메시지 컴포넌트만 스크린샷 비교
    await expect(welcomeMessage).toHaveScreenshot('welcome-message.png', {
      animations: 'disabled', // 애니메이션 비활성화로 안정적인 비교
      clip: { x: 0, y: 0, width: 400, height: 200 } // 필요시 영역 제한
    });
  });

  test('환영 메시지 다양한 이름 길이 테스트', async ({ page }) => {
    const testCases = [
      { name: '김' }, // 짧은 이름
      { name: '김운세타로' }, // 긴 이름
      { name: 'John Smith' } // 영문 이름
    ];

    for (const testCase of testCases) {
      await page.goto('/');
      
      await page.fill('input[name="name"]', testCase.name);
      await page.click('text=다음');
      
      await page.selectOption('select:near(:text("년"))', '1990');
      await page.selectOption('select:near(:text("월"))', '5');
      await page.selectOption('select:near(:text("일"))', '15');
      await page.click('text=다음');
      
      await page.selectOption('select:near(:text("성별"))', '남성');
      await page.click('text=완료');
      
      const welcomeMessage = page.getByTestId('welcome-message');
      await expect(welcomeMessage).toBeVisible();
      
      // 이름 길이별로 다른 스크린샷 파일 저장
      const fileName = `welcome-message-${testCase.name.replace(/\s+/g, '-')}.png`;
      await expect(welcomeMessage).toHaveScreenshot(fileName, {
        animations: 'disabled'
      });
    }
  });

  test('환영 메시지 반응형 레이아웃 테스트', async ({ page }) => {
    const viewports = [
      { width: 375, height: 667, name: 'mobile' },
      { width: 768, height: 1024, name: 'tablet' },
      { width: 1920, height: 1080, name: 'desktop' }
    ];

    for (const viewport of viewports) {
      await page.setViewportSize({ width: viewport.width, height: viewport.height });
      await page.goto('/');
      
      await page.fill('input[name="name"]', '반응형테스트');
      await page.click('text=다음');
      
      await page.selectOption('select:near(:text("년"))', '1990');
      await page.selectOption('select:near(:text("월"))', '5');
      await page.selectOption('select:near(:text("일"))', '15');
      await page.click('text=다음');
      
      await page.selectOption('select:near(:text("성별"))', '남성');
      await page.click('text=완료');
      
      const welcomeMessage = page.getByTestId('welcome-message');
      await expect(welcomeMessage).toBeVisible();
      
      // 디바이스별 스크린샷 저장
      await expect(welcomeMessage).toHaveScreenshot(`welcome-message-${viewport.name}.png`, {
        animations: 'disabled'
      });
    }
  });
});

/*
시각적 회귀 테스트의 이점:

1. CSS 변경 감지:
   - 개발자가 CSS를 수정했을 때 의도치 않은 UI 변경을 자동으로 감지
   - 예: margin, padding, font-size, color 등의 변경사항

2. 레이아웃 깨짐 방지:
   - 새로운 CSS 클래스 추가나 스타일 시스템 변경 시 기존 컴포넌트에 미치는 영향 확인
   - 반응형 디자인 변경 시 다양한 화면 크기에서의 레이아웃 검증

3. 브라우저 호환성:
   - 다른 브라우저에서 렌더링 차이 감지
   - 폰트 렌더링, CSS 지원 차이 등으로 인한 시각적 차이 발견

4. 일관성 유지:
   - 디자인 시스템 가이드라인 준수 여부 자동 검증
   - 브랜드 컬러, 타이포그래피 일관성 확인

사용법:
1. 첫 실행 시 기준(baseline) 스크린샷 생성
2. 이후 테스트에서 현재 UI와 기준 스크린샷 픽셀 단위 비교
3. 차이 발견 시 테스트 실패 및 diff 이미지 생성
4. 의도된 변경이라면 기준 스크린샷 업데이트
*/ 