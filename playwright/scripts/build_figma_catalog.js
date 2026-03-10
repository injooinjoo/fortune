const fs = require('fs');
const path = require('path');

const {
  COMPONENT_CARDS,
  FIGMA_PAGES,
  IPHONE_15_PRO,
  SCREENS,
  getScreensByPage,
  getStatusCounts,
} = require('./figma_capture_manifest');

const CAPTURE_DIR = path.join(__dirname, '../../artifacts/figma_capture/live');
const CATALOG_DIR = path.join(__dirname, '../../artifacts/figma_catalog');
const SCREEN_ASSET_DIR = path.join(CATALOG_DIR, 'assets/screens');

function ensureDir(dirPath) {
  fs.mkdirSync(dirPath, { recursive: true });
}

function escapeHtml(value) {
  return String(value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

function copyScreenshots() {
  ensureDir(SCREEN_ASSET_DIR);

  const copied = new Map();
  for (const screen of SCREENS.filter((item) => item.status === 'live')) {
    const source = path.join(CAPTURE_DIR, `${screen.id}.png`);
    if (!fs.existsSync(source)) continue;

    const target = path.join(SCREEN_ASSET_DIR, `${screen.id}.png`);
    fs.copyFileSync(source, target);
    copied.set(screen.id, `assets/screens/${screen.id}.png`);
  }

  return copied;
}

function renderStatusBadge(status) {
  const labels = {
    live: 'Live Capture',
    placeholder: 'Placeholder Spec',
  };
  return `<span class="status status-${status}">${escapeHtml(
    labels[status] || status
  )}</span>`;
}

function renderScreenCard(screen, imagePath) {
  const sources = (screen.sources || [])
    .map((source) => `<code>${escapeHtml(source)}</code>`)
    .join('');
  const metadataLines = [
    screen.routeHash ? `<div><strong>Route</strong> ${escapeHtml(screen.routeHash)}</div>` : '',
    screen.note ? `<div><strong>Note</strong> ${escapeHtml(screen.note)}</div>` : '',
    screen.blocker ? `<div><strong>Blocker</strong> ${escapeHtml(screen.blocker)}</div>` : '',
  ]
    .filter(Boolean)
    .join('');

  const deviceFrame =
    imagePath != null
      ? `<div class="phone-frame"><img src="${escapeHtml(imagePath)}" alt="${escapeHtml(
          screen.frameName
        )}" /></div>`
      : `<div class="phone-frame placeholder-frame">
          <div class="placeholder-title">${escapeHtml(screen.title)}</div>
          <div class="placeholder-body">${escapeHtml(
            screen.blocker || 'No live screenshot generated for this screen yet.'
          )}</div>
        </div>`;

  return `<article class="screen-card">
    <header class="screen-header">
      <div>
        <div class="eyebrow">${escapeHtml(screen.frameName)}</div>
        <h2>${escapeHtml(screen.title)}</h2>
      </div>
      ${renderStatusBadge(imagePath ? 'live' : screen.status)}
    </header>
    ${deviceFrame}
    <div class="metadata">
      ${metadataLines}
      <div class="source-list">${sources}</div>
    </div>
  </article>`;
}

function renderComponentCard(card) {
  return `<article class="component-card">
    <h2>${escapeHtml(card.title)}</h2>
    <div class="source-list">
      ${card.sources
        .map((source) => `<code>${escapeHtml(source)}</code>`)
        .join('')}
    </div>
  </article>`;
}

function renderPageShell(title, description, content) {
  return `<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>${escapeHtml(title)}</title>
  <script src="https://mcp.figma.com/mcp/html-to-design/capture.js" async></script>
  <style>
    :root {
      --bg: #f4f1ea;
      --panel: rgba(255, 255, 255, 0.88);
      --panel-border: rgba(24, 24, 27, 0.08);
      --text: #18181b;
      --muted: #71717a;
      --accent: #1f2937;
      --accent-soft: #e4ded3;
      --live: #0f766e;
      --placeholder: #92400e;
      --shadow: 0 24px 60px rgba(15, 23, 42, 0.08);
      --phone-bg: #ffffff;
    }

    * {
      box-sizing: border-box;
    }

    body {
      margin: 0;
      font-family: "Pretendard", "Apple SD Gothic Neo", "Noto Sans KR", sans-serif;
      color: var(--text);
      background:
        radial-gradient(circle at top left, rgba(216, 180, 140, 0.26), transparent 28%),
        radial-gradient(circle at top right, rgba(148, 163, 184, 0.16), transparent 22%),
        linear-gradient(180deg, #f7f4ee 0%, #efe8dc 100%);
    }

    .page {
      padding: 40px 36px 72px;
      max-width: 1660px;
      margin: 0 auto;
    }

    .page-header {
      display: flex;
      justify-content: space-between;
      gap: 24px;
      align-items: flex-end;
      margin-bottom: 28px;
    }

    .page-header h1 {
      margin: 0 0 8px;
      font-size: 34px;
      line-height: 1.08;
      letter-spacing: -0.04em;
    }

    .page-header p {
      margin: 0;
      max-width: 720px;
      color: var(--muted);
      font-size: 15px;
      line-height: 1.6;
    }

    .spec-pill {
      display: inline-flex;
      align-items: center;
      padding: 10px 14px;
      border-radius: 999px;
      background: rgba(255, 255, 255, 0.76);
      border: 1px solid var(--panel-border);
      box-shadow: var(--shadow);
      font-size: 13px;
      color: var(--muted);
      white-space: nowrap;
    }

    .screen-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(432px, 1fr));
      gap: 28px;
    }

    .screen-card,
    .component-card,
    .info-card {
      background: var(--panel);
      border: 1px solid var(--panel-border);
      border-radius: 28px;
      box-shadow: var(--shadow);
      backdrop-filter: blur(18px);
    }

    .screen-card {
      padding: 24px;
    }

    .screen-header {
      display: flex;
      justify-content: space-between;
      gap: 16px;
      align-items: flex-start;
      margin-bottom: 18px;
    }

    .screen-header h2,
    .component-card h2,
    .info-card h2 {
      margin: 4px 0 0;
      font-size: 21px;
      line-height: 1.2;
      letter-spacing: -0.03em;
    }

    .eyebrow {
      color: var(--muted);
      text-transform: uppercase;
      letter-spacing: 0.12em;
      font-size: 11px;
      font-weight: 700;
    }

    .status {
      display: inline-flex;
      align-items: center;
      padding: 7px 11px;
      border-radius: 999px;
      font-size: 12px;
      font-weight: 700;
      white-space: nowrap;
    }

    .status-live {
      color: var(--live);
      background: rgba(13, 148, 136, 0.12);
    }

    .status-placeholder {
      color: var(--placeholder);
      background: rgba(217, 119, 6, 0.14);
    }

    .phone-frame {
      width: ${IPHONE_15_PRO.width}px;
      min-height: ${IPHONE_15_PRO.height}px;
      margin: 0 auto 18px;
      border-radius: 36px;
      overflow: hidden;
      background: var(--phone-bg);
      border: 12px solid #111827;
      box-shadow:
        0 24px 60px rgba(15, 23, 42, 0.16),
        inset 0 0 0 1px rgba(255, 255, 255, 0.12);
    }

    .phone-frame img {
      display: block;
      width: 100%;
      height: auto;
    }

    .placeholder-frame {
      display: flex;
      flex-direction: column;
      justify-content: center;
      padding: 32px;
      background:
        linear-gradient(180deg, rgba(241, 245, 249, 0.92), rgba(226, 232, 240, 0.88));
      color: #334155;
      text-align: left;
    }

    .placeholder-title {
      font-size: 24px;
      font-weight: 700;
      line-height: 1.2;
      margin-bottom: 16px;
      letter-spacing: -0.03em;
    }

    .placeholder-body {
      font-size: 15px;
      line-height: 1.65;
      color: #475569;
    }

    .metadata {
      display: flex;
      flex-direction: column;
      gap: 10px;
      font-size: 13px;
      color: var(--muted);
    }

    .metadata strong {
      color: var(--text);
      margin-right: 8px;
    }

    .source-list {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
    }

    code {
      display: inline-flex;
      padding: 7px 10px;
      border-radius: 999px;
      background: rgba(17, 24, 39, 0.06);
      border: 1px solid rgba(17, 24, 39, 0.06);
      color: #1f2937;
      font-size: 12px;
      line-height: 1.3;
    }

    .info-grid {
      display: grid;
      grid-template-columns: repeat(3, minmax(0, 1fr));
      gap: 20px;
    }

    .info-card,
    .component-card {
      padding: 24px;
    }

    .info-card p,
    .component-card p,
    .component-card ul {
      margin: 12px 0 0;
      color: var(--muted);
      font-size: 14px;
      line-height: 1.65;
    }

    .link-list {
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
      margin-top: 18px;
    }

    .link-list a {
      display: inline-flex;
      padding: 10px 14px;
      border-radius: 999px;
      background: rgba(255, 255, 255, 0.76);
      color: var(--text);
      text-decoration: none;
      border: 1px solid var(--panel-border);
    }
  </style>
</head>
<body>
  <main class="page">
    <header class="page-header">
      <div>
        <h1>${escapeHtml(title)}</h1>
        <p>${escapeHtml(description)}</p>
      </div>
      <div class="spec-pill">${escapeHtml(
        `${IPHONE_15_PRO.name} · ${IPHONE_15_PRO.width}×${IPHONE_15_PRO.height} · @${IPHONE_15_PRO.scale}x`
      )}</div>
    </header>
    ${content}
  </main>
</body>
</html>`;
}

function renderCoverPage() {
  const counts = getStatusCounts();
  const pages = FIGMA_PAGES.filter((page) => page.key !== '00-cover-governance')
    .map(
      (page) =>
        `<a href="${escapeHtml(`${page.key}.html`)}">${escapeHtml(page.name)}</a>`
    )
    .join('');

  const content = `<section class="info-grid">
    <article class="info-card">
      <div class="eyebrow">Official File</div>
      <h2>Single Figma Source of Truth</h2>
      <p>Every route-backed screen and each key result state is tracked in one official file only. Live screenshots and placeholder specs are both derived from the same router-backed manifest.</p>
    </article>
    <article class="info-card">
      <div class="eyebrow">Capture Modes</div>
      <h2>Hybrid Screen Catalog</h2>
      <p><strong>Live Capture</strong> is used where the current app can render deterministically. <strong>Placeholder Spec</strong> is used when runtime auth, backend content, or <code>state.extra</code> data blocks direct capture.</p>
    </article>
    <article class="info-card">
      <div class="eyebrow">Current Coverage</div>
      <h2>${counts.live || 0} live / ${counts.placeholder || 0} placeholder</h2>
      <p>Live screens were regenerated from the current router manifest. Placeholder screens remain explicitly listed so the Figma file stays complete even when the runtime is blocked.</p>
    </article>
  </section>
  <section class="info-grid" style="margin-top: 20px;">
    <article class="info-card">
      <div class="eyebrow">Device Standard</div>
      <h2>iPhone 15 Pro Only</h2>
      <p>All frames are normalized to <code>393×852</code> at <code>@3x</code>, light theme, Korean locale. No desktop-width captures are treated as official.</p>
    </article>
    <article class="info-card">
      <div class="eyebrow">Routing Notes</div>
      <h2>Hash Router and Nested Paths</h2>
      <p>Local capture uses hash routes. Interactive flows resolve from <code>#/fortune/interactive/*</code>, not direct <code>#/interactive/*</code> paths, so the catalog stores the working runtime URL for each screen.</p>
    </article>
    <article class="info-card">
      <div class="eyebrow">Runtime Blockers</div>
      <h2>Auth / Backend / Extra State</h2>
      <p>Profile subroutes require authenticated user data. Trend detail routes require seeded backend content. History detail and medical-document result require explicit <code>state.extra</code> payloads.</p>
    </article>
  </section>
  <section class="info-card" style="margin-top: 20px;">
    <div class="eyebrow">Figma Pages</div>
    <h2>Catalog Structure</h2>
    <div class="link-list">${pages}</div>
  </section>`;

  return renderPageShell(
    '00 Cover & Governance',
    'Official governance for the Fortune screen catalog, including device standard, capture modes, and current runtime blockers.',
    content
  );
}

function renderScreenPage(page, imageMap) {
  const pageScreens = getScreensByPage().find((entry) => entry.key === page.key)?.screens || [];
  const cards = pageScreens
    .map((screen) => renderScreenCard(screen, imageMap.get(screen.id) || null))
    .join('');

  return renderPageShell(
    page.name,
    page.description,
    `<section class="screen-grid">${cards}</section>`
  );
}

function renderComponentsPage() {
  const cards = COMPONENT_CARDS.map(renderComponentCard).join('');
  return renderPageShell(
    '90 Components',
    'Component family inventory mapped back to Flutter source files that should stay aligned with the official Figma library.',
    `<section class="screen-grid">${cards}</section>`
  );
}

function renderArchivePage() {
  const cards = [
    {
      title: 'Superseded Summary-only File',
      sources: ['Previous registry-style official file is superseded by this screen-level catalog.'],
    },
    {
      title: 'Invalid Direct Interactive Paths',
      sources: [
        'Direct hash paths like #/interactive/dream are archived as invalid in the current runtime.',
        'Official live capture uses #/fortune/interactive/* routes instead.',
      ],
    },
  ]
    .map(renderComponentCard)
    .join('');

  return renderPageShell(
    '99 Archive',
    'Archived patterns and superseded references that should not be treated as the active official workflow.',
    `<section class="screen-grid">${cards}</section>`
  );
}

function buildIndexPage() {
  const links = FIGMA_PAGES.map(
    (page) =>
      `<a href="${escapeHtml(`${page.key}.html`)}">${escapeHtml(page.name)}</a>`
  ).join('');

  return renderPageShell(
    'Fortune Figma Catalog',
    'Local entry point for verifying the generated screen catalog before pushing it into the official Figma file.',
    `<section class="info-card"><div class="link-list">${links}</div></section>`
  );
}

function main() {
  ensureDir(CATALOG_DIR);
  const imageMap = copyScreenshots();

  fs.writeFileSync(path.join(CATALOG_DIR, 'index.html'), buildIndexPage());
  fs.writeFileSync(
    path.join(CATALOG_DIR, '00-cover-governance.html'),
    renderCoverPage()
  );

  for (const page of FIGMA_PAGES) {
    if (page.key === '00-cover-governance') continue;
    if (page.key === '90-components') {
      fs.writeFileSync(
        path.join(CATALOG_DIR, `${page.key}.html`),
        renderComponentsPage()
      );
      continue;
    }
    if (page.key === '99-archive') {
      fs.writeFileSync(
        path.join(CATALOG_DIR, `${page.key}.html`),
        renderArchivePage()
      );
      continue;
    }

    fs.writeFileSync(
      path.join(CATALOG_DIR, `${page.key}.html`),
      renderScreenPage(page, imageMap)
    );
  }

  process.stdout.write(`Catalog generated at ${CATALOG_DIR}\n`);
}

main();
