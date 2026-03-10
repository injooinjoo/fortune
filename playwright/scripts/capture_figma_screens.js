const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');

const {
  IPHONE_15_PRO,
  SCREENS,
} = require('./figma_capture_manifest');

const BASE_URL = process.env.FIGMA_CAPTURE_BASE_URL || 'http://127.0.0.1:3001';
const OUTPUT_DIR = path.join(__dirname, '../../artifacts/figma_capture/live');
const MANIFEST_PATH = path.join(
  __dirname,
  '../../artifacts/figma_capture/capture-manifest.json'
);

function ensureDir(dirPath) {
  fs.mkdirSync(dirPath, { recursive: true });
}

function getLiveScreens() {
  return SCREENS.filter((screen) => screen.status === 'live');
}

async function captureScreen(browser, screen) {
  const context = await browser.newContext({
    viewport: { width: IPHONE_15_PRO.width, height: IPHONE_15_PRO.height },
    deviceScaleFactor: IPHONE_15_PRO.scale,
    serviceWorkers: 'block',
  });

  const storage = screen.buildStorage ? screen.buildStorage() : {};

  await context.addInitScript((storageOverrides) => {
    localStorage.clear();
    for (const [key, value] of Object.entries(storageOverrides)) {
      localStorage.setItem(key, value);
    }
  }, storage);

  const page = await context.newPage();
  const url = `${BASE_URL}/?test_mode=true${screen.routeHash}`;

  await page.goto(url, {
    waitUntil: 'domcontentloaded',
    timeout: 60000,
  });
  await page.waitForTimeout(screen.waitMs || 8000);

  const outputPath = path.join(OUTPUT_DIR, `${screen.id}.png`);
  await page.screenshot({
    path: outputPath,
    fullPage: false,
  });

  const finalUrl = await page.evaluate(() => window.location.href);
  await context.close();

  return {
    id: screen.id,
    pageKey: screen.pageKey,
    frameName: screen.frameName,
    outputPath,
    routeHash: screen.routeHash,
    requestedUrl: url,
    finalUrl,
    capturedAt: new Date().toISOString(),
  };
}

async function main() {
  ensureDir(OUTPUT_DIR);
  ensureDir(path.dirname(MANIFEST_PATH));

  const liveScreens = getLiveScreens();
  const browser = await chromium.launch({ headless: true });
  const results = [];

  try {
    for (const screen of liveScreens) {
      process.stdout.write(`Capturing ${screen.id}...\n`);
      const result = await captureScreen(browser, screen);
      results.push(result);
    }
  } finally {
    await browser.close();
  }

  const manifest = {
    generatedAt: new Date().toISOString(),
    baseUrl: BASE_URL,
    device: IPHONE_15_PRO,
    totalScreens: results.length,
    screens: results,
  };

  fs.writeFileSync(MANIFEST_PATH, JSON.stringify(manifest, null, 2));
  process.stdout.write(
    `Saved ${results.length} screenshots to ${OUTPUT_DIR}\n` +
      `Saved manifest to ${MANIFEST_PATH}\n`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
