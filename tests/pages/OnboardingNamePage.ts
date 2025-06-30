import { Locator, Page, expect } from '@playwright/test';

export class OnboardingNamePage {
  readonly page: Page;
  readonly nameInput: Locator;
  readonly nextButton: Locator;

  constructor(page: Page) {
    this.page = page;
    this.nameInput = page.locator('input[name="name"]');
    this.nextButton = page.getByRole('button', { name: '다음' });
  }

  async goto() {
    await this.page.goto('/onboarding');
    await this.page.waitForLoadState('networkidle');
  }

  async enterName(name: string) {
    await expect(this.nameInput).toBeVisible();
    await this.nameInput.fill(name);
  }

  async submitName() {
    await expect(this.nextButton).toBeEnabled();
    await this.nextButton.click();
    // 네트워크 요청이 끝날 때까지 대기
    await this.page.waitForLoadState('networkidle');
  }
}
