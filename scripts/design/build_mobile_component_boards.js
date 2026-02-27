#!/usr/bin/env node

/*
 * Build component-rich HTML boards from captured mobile screenshots.
 *
 * Input:
 *   artifacts/design/mobile/manifest.json
 *   artifacts/design/mobile/raw/<screen_id>/<theme>.png
 *
 * Output:
 *   artifacts/design/mobile/boards/<screen_id>/<theme>/index.html
 *   artifacts/design/mobile/boards/index.json
 */

const fs = require('fs');
const path = require('path');

const repoRoot = path.resolve(__dirname, '../..');
const manifestPath = path.join(repoRoot, 'artifacts/design/mobile/manifest.json');
const rawRoot = path.join(repoRoot, 'artifacts/design/mobile/raw');
const boardsRoot = path.join(repoRoot, 'artifacts/design/mobile/boards');
const dsColorsPath = path.join(
  repoRoot,
  'lib/core/design_system/tokens/ds_colors.dart'
);

function ensureDir(dirPath) {
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
  }
}

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function parseDsColors() {
  const fallback = {
    backgroundLight: '#FFFFFF',
    surfaceLight: '#F7F7F8',
    textPrimaryLight: '#000000',
    textSecondaryLight: '#2C2C2E',
    borderLight: '#E5E5EA',
    accentLight: '#000000',
    backgroundDark: '#000000',
    surfaceDark: '#1A1A1A',
    textPrimaryDark: '#FFFFFF',
    textSecondaryDark: '#C7C7CC',
    borderDark: '#2C2C2E',
    accentDark: '#FFFFFF',
  };

  if (!fs.existsSync(dsColorsPath)) return fallback;
  const raw = fs.readFileSync(dsColorsPath, 'utf8');
  const regex = /static const Color (\w+) = Color\(0x([0-9A-Fa-f]{8})\);/g;
  const values = {};
  let match = regex.exec(raw);
  while (match) {
    const [, name, argb] = match;
    const rgb = `#${argb.slice(2).toUpperCase()}`;
    values[name] = rgb;
    match = regex.exec(raw);
  }

  return {
    backgroundLight: values.backgroundDark || fallback.backgroundLight,
    surfaceLight: values.surfaceDark || fallback.surfaceLight,
    textPrimaryLight: values.textPrimaryDark || fallback.textPrimaryLight,
    textSecondaryLight: values.textSecondaryDark || fallback.textSecondaryLight,
    borderLight: values.borderDark || fallback.borderLight,
    accentLight: values.accentDark || fallback.accentLight,
    backgroundDark: values.background || fallback.backgroundDark,
    surfaceDark: values.surface || fallback.surfaceDark,
    textPrimaryDark: values.textPrimary || fallback.textPrimaryDark,
    textSecondaryDark: values.textSecondary || fallback.textSecondaryDark,
    borderDark: values.border || fallback.borderDark,
    accentDark: values.accent || fallback.accentDark,
  };
}

function inferComponents(screen) {
  const base = [
    'StatusBar',
    'AppHeader',
    'PrimaryContainer',
    'ContentCard',
    'InputOrCTA',
    'BottomNavigationOrFooter',
  ];

  const route = screen.path;
  const category = screen.category;
  const extra = [];

  if (route.includes('chat')) {
    extra.push(
      'ChatMessageBubble(AI)',
      'ChatMessageBubble(User)',
      'TypingIndicator',
      'RecommendationChips',
      'FloatingInputBar'
    );
  }
  if (route.includes('fortune')) {
    extra.push(
      'FortuneCategoryChip',
      'FortuneResultCard',
      'ScoreBadge',
      'ActionCTA'
    );
  }
  if (route.includes('profile')) {
    extra.push('ProfileHeader', 'InfoListTile', 'SettingsRow', 'ToggleControl');
  }
  if (route.includes('trend')) {
    extra.push('TrendCard', 'ProgressIndicator', 'ChoiceButton');
  }
  if (route.includes('interactive')) {
    extra.push('InteractiveCanvas', 'StepIndicator', 'ActionButton');
  }

  if (category === 'auth') {
    extra.push('SocialLoginButton', 'OnboardingStepHeader', 'FormInput');
  }
  if (category === 'fortune_health') {
    extra.push('HealthMetricCard', 'UploadSection', 'SelectorToggle');
  }

  return [...new Set([...base, ...extra])];
}

function normalizePath(p) {
  return p.split(path.sep).join('/');
}

function renderHtml({ screen, theme, imageRelPath, imageExists, components, ds }) {
  const isDark = theme === 'dark';
  const colors = {
    bg: isDark ? ds.backgroundDark : ds.backgroundLight,
    surface: isDark ? ds.surfaceDark : ds.surfaceLight,
    textPrimary: isDark ? ds.textPrimaryDark : ds.textPrimaryLight,
    textSecondary: isDark ? ds.textSecondaryDark : ds.textSecondaryLight,
    border: isDark ? ds.borderDark : ds.borderLight,
    accent: isDark ? ds.accentDark : ds.accentLight,
  };

  const componentRows = components
    .map(
      (name) => `
      <div class="component-item">
        <div class="component-dot"></div>
        <div>
          <div class="component-name">${name}</div>
          <div class="component-spec">Spec derived from ${screen.screen_id} (${theme})</div>
        </div>
      </div>`
    )
    .join('\n');

  const screenshotSection = imageExists
    ? `<img src="${imageRelPath}" alt="${screen.screen_id} ${theme}" class="screen-image" />`
    : `<div class="missing-shot">Missing screenshot: ${screen.screen_id}/${theme}.png</div>`;

  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>${screen.screen_id} / ${theme}</title>
  <script src="https://mcp.figma.com/mcp/html-to-design/capture.js" async></script>
  <style>
    :root {
      --bg: ${colors.bg};
      --surface: ${colors.surface};
      --text-primary: ${colors.textPrimary};
      --text-secondary: ${colors.textSecondary};
      --border: ${colors.border};
      --accent: ${colors.accent};
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
      background: var(--bg);
      color: var(--text-primary);
    }
    .frame {
      width: 1800px;
      min-height: 1100px;
      margin: 0 auto;
      padding: 36px;
      display: grid;
      grid-template-columns: 560px 1fr;
      gap: 28px;
    }
    .phone-shell {
      width: 520px;
      border-radius: 36px;
      border: 1px solid var(--border);
      background: var(--surface);
      box-shadow: 0 16px 48px rgba(0,0,0,0.14);
      padding: 20px;
      display: grid;
      gap: 12px;
      align-content: start;
    }
    .phone-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      font-size: 13px;
      color: var(--text-secondary);
    }
    .screen {
      width: 440px;
      height: 956px;
      border-radius: 28px;
      border: 1px solid var(--border);
      overflow: hidden;
      position: relative;
      background: var(--surface);
      margin: 0 auto;
    }
    .screen-image {
      width: 100%;
      height: 100%;
      object-fit: cover;
      display: block;
    }
    .screen-overlay {
      position: absolute;
      left: 10px;
      top: 10px;
      padding: 6px 10px;
      border-radius: 999px;
      background: rgba(0,0,0,0.55);
      color: #fff;
      font-size: 11px;
      letter-spacing: 0.01em;
    }
    .missing-shot {
      width: 100%;
      height: 100%;
      display: grid;
      place-items: center;
      color: #b42318;
      background: rgba(180, 35, 24, 0.08);
      padding: 16px;
      text-align: center;
      font-size: 14px;
    }
    .board {
      border: 1px solid var(--border);
      border-radius: 20px;
      background: var(--surface);
      padding: 22px;
      display: grid;
      grid-template-rows: auto auto 1fr;
      gap: 18px;
    }
    .title {
      display: grid;
      gap: 8px;
    }
    .title h1 {
      margin: 0;
      font-size: 26px;
      letter-spacing: -0.02em;
    }
    .subtitle {
      color: var(--text-secondary);
      font-size: 14px;
      line-height: 1.45;
    }
    .meta {
      display: grid;
      grid-template-columns: repeat(3, minmax(0, 1fr));
      gap: 10px;
    }
    .meta-item {
      border: 1px solid var(--border);
      border-radius: 12px;
      padding: 10px;
      font-size: 12px;
      color: var(--text-secondary);
      min-height: 68px;
    }
    .meta-label {
      font-size: 11px;
      color: var(--text-secondary);
      margin-bottom: 4px;
      text-transform: uppercase;
      letter-spacing: 0.04em;
    }
    .meta-value {
      font-size: 13px;
      color: var(--text-primary);
      font-weight: 600;
      word-break: break-word;
    }
    .component-panel {
      border: 1px solid var(--border);
      border-radius: 14px;
      padding: 14px;
      background: rgba(127, 127, 127, 0.06);
      display: grid;
      align-content: start;
      gap: 10px;
    }
    .component-panel h2 {
      margin: 0;
      font-size: 16px;
      letter-spacing: -0.01em;
    }
    .component-item {
      display: grid;
      grid-template-columns: 10px 1fr;
      gap: 10px;
      align-items: start;
      border: 1px solid var(--border);
      border-radius: 10px;
      background: var(--surface);
      padding: 10px;
    }
    .component-dot {
      width: 10px;
      height: 10px;
      border-radius: 999px;
      margin-top: 5px;
      background: var(--accent);
    }
    .component-name {
      font-size: 14px;
      color: var(--text-primary);
      font-weight: 600;
      line-height: 1.25;
    }
    .component-spec {
      margin-top: 3px;
      font-size: 12px;
      color: var(--text-secondary);
    }
  </style>
</head>
<body>
  <main class="frame" data-screen-id="${screen.screen_id}" data-theme="${theme}">
    <section class="phone-shell">
      <div class="phone-header">
        <span>iPhone 16 Pro Max</span>
        <span>${theme.toUpperCase()}</span>
      </div>
      <div class="screen">
        ${screenshotSection}
        <div class="screen-overlay">Reference Overlay</div>
      </div>
    </section>

    <section class="board">
      <div class="title">
        <h1>${screen.screen_id} / ${theme}</h1>
        <div class="subtitle">
          Route: <strong>${screen.path}</strong><br />
          Category: <strong>${screen.category_name_ko}</strong><br />
          Component board aligned to DS tokens and mobile frame.
        </div>
      </div>

      <div class="meta">
        <div class="meta-item">
          <div class="meta-label">Figma Page</div>
          <div class="meta-value">${screen.figma_page}</div>
        </div>
        <div class="meta-item">
          <div class="meta-label">Priority</div>
          <div class="meta-value">${screen.priority}</div>
        </div>
        <div class="meta-item">
          <div class="meta-label">Deep Link</div>
          <div class="meta-value">${screen.deeplink_screen}</div>
        </div>
      </div>

      <div class="component-panel">
        <h2>Component Panel</h2>
        ${componentRows}
      </div>
    </section>
  </main>
</body>
</html>`;
}

function buildBoards() {
  if (!fs.existsSync(manifestPath)) {
    throw new Error(`Manifest not found: ${manifestPath}`);
  }

  const manifest = readJson(manifestPath);
  const ds = parseDsColors();
  ensureDir(boardsRoot);

  const index = {
    generated_at: new Date().toISOString(),
    total_screens: manifest.screens.length,
    total_targets: manifest.screens.length * 2,
    items: [],
  };

  for (const screen of manifest.screens) {
    const components = inferComponents(screen);
    for (const theme of screen.themes) {
      const boardDir = path.join(boardsRoot, screen.screen_id, theme);
      ensureDir(boardDir);

      const screenshotPath = path.join(rawRoot, screen.screen_id, `${theme}.png`);
      const imageExists = fs.existsSync(screenshotPath);
      const imageRelPath = normalizePath(path.relative(boardDir, screenshotPath));

      const html = renderHtml({
        screen,
        theme,
        imageRelPath,
        imageExists,
        components,
        ds,
      });

      const htmlPath = path.join(boardDir, 'index.html');
      fs.writeFileSync(htmlPath, html);

      index.items.push({
        screen_id: screen.screen_id,
        theme,
        html: normalizePath(path.relative(repoRoot, htmlPath)),
        screenshot: normalizePath(path.relative(repoRoot, screenshotPath)),
        screenshot_exists: imageExists,
        components_count: components.length,
      });
    }
  }

  fs.writeFileSync(
    path.join(boardsRoot, 'index.json'),
    `${JSON.stringify(index, null, 2)}\n`
  );

  console.log(`Boards generated: ${index.items.length}`);
  console.log(`Output root: ${boardsRoot}`);
}

buildBoards();
