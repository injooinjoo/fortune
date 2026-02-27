#!/usr/bin/env node

/*
 * Build mobile capture manifest from screen-metadata-v2.js
 *
 * Output:
 *   artifacts/design/mobile/manifest.json
 */

const fs = require('fs');
const path = require('path');

const repoRoot = path.resolve(__dirname, '../..');
const metadataPath = path.join(
  repoRoot,
  'playwright/scripts/screen-metadata-v2.js'
);

const outputDir = path.join(repoRoot, 'artifacts/design/mobile');
const outputPath = path.join(outputDir, 'manifest.json');

function normalizePath(routePath) {
  if (!routePath || routePath === '/') return '/chat';
  return routePath.startsWith('/') ? routePath : `/${routePath}`;
}

function toDeepLinkScreen(routePath) {
  const normalized = normalizePath(routePath);
  return normalized.replace(/^\//, '');
}

function ensureDir(dir) {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
}

function buildManifest() {
  // eslint-disable-next-line global-require, import/no-dynamic-require
  const metadata = require(metadataPath);
  const screens = metadata.getAllScreens();

  const manifestScreens = screens.map((screen) => {
    const routePath = normalizePath(screen.path);
    const deeplinkScreen = toDeepLinkScreen(routePath);

    return {
      screen_id: screen.id,
      name: screen.name,
      name_ko: screen.nameKo,
      path: routePath,
      deeplink_screen: deeplinkScreen,
      category: screen.categoryKey,
      category_name: screen.category,
      category_name_ko: screen.categoryKo,
      themes: ['light', 'dark'],
      priority: screen.priority,
      figma_page: screen.figmaPage,
      source: screen.source || null,
    };
  });

  return {
    generated_at: new Date().toISOString(),
    device: {
      name: 'iPhone 16 Pro Max',
      width: 440,
      height: 956,
    },
    totals: {
      screens: manifestScreens.length,
      screenshot_targets: manifestScreens.length * 2,
    },
    screens: manifestScreens,
  };
}

function main() {
  const manifest = buildManifest();
  ensureDir(outputDir);
  fs.writeFileSync(outputPath, `${JSON.stringify(manifest, null, 2)}\n`);
  console.log(`Manifest written: ${outputPath}`);
  console.log(`Screens: ${manifest.totals.screens}`);
  console.log(`Targets (light+dark): ${manifest.totals.screenshot_targets}`);
}

main();
