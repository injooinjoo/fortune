import { test, expect } from '@playwright/test';

// 메인 사용자 플로우: 로그인 후 운세 보기
// 사용자가 로그인하여 대시보드로 이동한 뒤 운세 결과를 확인하는 시나리오를 검증합니다.

test.describe('로그인 후 운세 조회 플로우', () => {
  test('사용자가 로그인 후 운세를 조회할 수 있다', async ({ page }) => {
    // 1. 홈페이지로 이동
    await page.goto('/');

    // 2. '로그인' 버튼 클릭
    await page.getByRole('button', { name: '로그인' }).click();

    // 3. 이메일 입력
    await page.getByLabel('이메일').fill('test@example.com');

    // 4. 비밀번호 입력
    await page.getByLabel('비밀번호').fill('password123');

    // 5. '로그인 제출' 버튼 클릭
    await page.getByRole('button', { name: '로그인 제출' }).click();

    // 6. 로그인 성공 후 URL이 /dashboard 로 변경되는지 확인
    await expect(page).toHaveURL('/dashboard');

    // 7. 대시보드에서 '생년월일' 입력 필드에 값을 입력
    await page.getByLabel('생년월일').fill('1990-01-01');

    // 8. '운세 보기' 버튼 클릭
    await page.getByRole('button', { name: '운세 보기' }).click();

    // 9. 운세 결과 요소가 나타날 때까지 대기
    const result = page.getByTestId('fortune-result');
    await expect(result).toBeVisible();

    // 10. 결과 텍스트가 비어 있지 않은지 검증
    await expect(result).not.toHaveText('');
  });
});
