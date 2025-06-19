import { Locator, Page } from '@playwright/test';

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
    await this.page.goto('/');
  }

  async enterName(name: string) {
    await this.nameInput.fill(name);
  }

  async submitName() {
    await this.nextButton.click();
  }
}
