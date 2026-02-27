#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

function parseArgs(argv) {
  const args = {};
  for (let i = 0; i < argv.length; i += 1) {
    const token = argv[i];
    if (!token.startsWith('--')) continue;
    const [rawKey, rawValue] = token.split('=');
    const key = rawKey.slice(2);
    if (rawValue !== undefined) {
      args[key] = rawValue;
      continue;
    }
    const next = argv[i + 1];
    if (!next || next.startsWith('--')) {
      args[key] = 'true';
      continue;
    }
    args[key] = next;
    i += 1;
  }
  return args;
}

function ensureDir(dirPath) {
  fs.mkdirSync(dirPath, { recursive: true });
}

function writeJson(filePath, payload) {
  ensureDir(path.dirname(filePath));
  fs.writeFileSync(filePath, `${JSON.stringify(payload, null, 2)}\n`);
}

function buildHtml({ surface, theme, imageRelativePath }) {
  const isDark = theme === 'dark';
  const canvas = isDark ? '#000000' : '#f3f4f6';
  const shell = isDark ? '#111111' : '#ffffff';
  const border = isDark ? '#2f2f2f' : '#d1d5db';
  const text = isDark ? '#f3f4f6' : '#111827';
  const sub = isDark ? '#9ca3af' : '#6b7280';

  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>${surface.surface_id} / ${theme}</title>
  <script src="https://mcp.figma.com/mcp/html-to-design/capture.js" async></script>
  <style>
    * { box-sizing: border-box; }
    body {
      margin: 0;
      background: ${canvas};
      color: ${text};
      font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
    }
    .stage {
      width: 760px;
      min-height: 1180px;
      margin: 0 auto;
      padding: 40px 0;
      display: grid;
      justify-items: center;
      align-content: start;
      gap: 20px;
    }
    .meta {
      width: 520px;
      display: grid;
      gap: 6px;
    }
    .title {
      font-size: 24px;
      font-weight: 700;
      letter-spacing: -0.02em;
      color: ${text};
    }
    .subtitle {
      font-size: 13px;
      color: ${sub};
    }
    .phone-shell {
      width: 520px;
      border-radius: 36px;
      background: ${shell};
      border: 1px solid ${border};
      padding: 20px;
      box-shadow: 0 20px 40px rgba(0,0,0,0.16);
    }
    .screen {
      width: 440px;
      height: 956px;
      border-radius: 30px;
      overflow: hidden;
      margin: 0 auto;
      border: 1px solid ${border};
      background: ${shell};
    }
    .screen img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      display: block;
    }
  </style>
</head>
<body>
  <main class="stage" data-section="Mobile Real v2 / ${theme === 'light' ? 'Light' : 'Dark'}" data-surface-id="${surface.surface_id}" data-theme="${theme}">
    <section class="meta">
      <div class="title">${surface.surface_id} / ${theme}</div>
      <div class="subtitle">surface_type: ${surface.surface_type}${surface.route_path ? ` | route: ${surface.route_path}` : ''}${surface.representative_name ? ` | rep: ${surface.representative_name}` : ''}</div>
    </section>
    <section class="phone-shell">
      <div class="screen">
        <img src="${imageRelativePath}" alt="${surface.surface_id} ${theme}" />
      </div>
    </section>
  </main>
</body>
</html>
`;
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  const repoRoot = path.resolve(__dirname, '..', '..');

  const inventoryPath = path.resolve(args.inventory || path.join(repoRoot, 'artifacts/design/mobile/v2/live_inventory.json'));
  const rawRoot = path.resolve(args['raw-root'] || path.join(repoRoot, 'artifacts/design/mobile/v2/raw'));
  const outRoot = path.resolve(args['out-root'] || path.join(repoRoot, 'artifacts/design/mobile/v2/figma_frames'));
  const indexOut = path.resolve(args.out || path.join(outRoot, 'index.json'));

  const inventory = JSON.parse(fs.readFileSync(inventoryPath, 'utf8'));
  const themes = ['light', 'dark'];
  const targets = [];

  for (const surface of inventory.surfaces || []) {
    if (surface.inventory_status !== 'reachable') continue;

    for (const theme of themes) {
      const imagePath = path.join(rawRoot, surface.surface_id, `${theme}.png`);
      if (!fs.existsSync(imagePath)) continue;

      const htmlDir = path.join(outRoot, surface.surface_id, theme);
      ensureDir(htmlDir);

      const imageRelativePath = path.relative(htmlDir, imagePath).split(path.sep).join('/');
      const html = buildHtml({
        surface,
        theme,
        imageRelativePath,
      });

      const htmlPath = path.join(htmlDir, 'index.html');
      fs.writeFileSync(htmlPath, html);

      const relativePath = path.relative(path.join(repoRoot, 'artifacts/design/mobile/v2'), htmlPath).split(path.sep).join('/');

      targets.push({
        surface_id: surface.surface_id,
        surface_type: surface.surface_type,
        theme,
        section: `Mobile Real v2 / ${theme === 'light' ? 'Light' : 'Dark'}`,
        frame_name: `${surface.surface_id} / ${theme}`,
        relative_path: relativePath,
      });
    }
  }

  const payload = {
    generated_at: new Date().toISOString(),
    inventory_path: inventoryPath,
    raw_root: rawRoot,
    output_root: outRoot,
    total_targets: targets.length,
    targets,
  };

  writeJson(indexOut, payload);
  process.stdout.write(`${JSON.stringify({ index: indexOut, total_targets: targets.length }, null, 2)}\n`);
}

main();
