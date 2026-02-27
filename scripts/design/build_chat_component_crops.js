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

function resolveChatSourceImage(rawRoot, inventory, theme) {
  const chatRoute = path.join(rawRoot, 'route_chat', `${theme}.png`);
  if (fs.existsSync(chatRoute)) {
    return { path: chatRoute, source_surface_id: 'route_chat' };
  }

  const chatReps = (inventory.surfaces || []).filter((s) => s.surface_type === 'chat_rep' && s.inventory_status === 'reachable');
  for (const rep of chatReps) {
    const candidate = path.join(rawRoot, rep.surface_id, `${theme}.png`);
    if (fs.existsSync(candidate)) {
      return { path: candidate, source_surface_id: rep.surface_id };
    }
  }

  return null;
}

function buildCropHtml({ theme, imageRelativePath, sourceSurfaceId, cropSpecs }) {
  const isDark = theme === 'dark';
  const bg = isDark ? '#060606' : '#f8fafc';
  const card = isDark ? '#111827' : '#ffffff';
  const border = isDark ? '#374151' : '#d1d5db';
  const text = isDark ? '#f9fafb' : '#111827';
  const sub = isDark ? '#9ca3af' : '#6b7280';

  const rows = cropSpecs
    .map((spec) => `
      <article class="tile">
        <div class="crop" style="--x:${spec.x};--y:${spec.y};--w:${spec.w};--h:${spec.h};--img-w:1320;--img-h:2868;">
          <img src="${imageRelativePath}" alt="${spec.id}" />
        </div>
        <div class="meta">
          <div class="name">${spec.name}</div>
          <div class="desc">${spec.description}</div>
        </div>
      </article>
    `)
    .join('');

  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>chat_components / ${theme}</title>
  <script src="https://mcp.figma.com/mcp/html-to-design/capture.js" async></script>
  <style>
    * { box-sizing: border-box; }
    body {
      margin: 0;
      font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
      background: ${bg};
      color: ${text};
    }
    .stage {
      width: 1800px;
      min-height: 1100px;
      margin: 0 auto;
      padding: 36px;
      display: grid;
      gap: 16px;
      align-content: start;
    }
    .header {
      display: grid;
      gap: 4px;
    }
    .header h1 {
      margin: 0;
      font-size: 28px;
      letter-spacing: -0.02em;
    }
    .header p {
      margin: 0;
      color: ${sub};
      font-size: 13px;
    }
    .grid {
      display: grid;
      grid-template-columns: repeat(4, minmax(0, 1fr));
      gap: 14px;
    }
    .tile {
      background: ${card};
      border: 1px solid ${border};
      border-radius: 14px;
      padding: 10px;
      display: grid;
      gap: 8px;
      align-content: start;
    }
    .crop {
      --scale: 0.26;
      width: calc(var(--w) * var(--scale) * 1px);
      height: calc(var(--h) * var(--scale) * 1px);
      border-radius: 10px;
      overflow: hidden;
      border: 1px solid ${border};
      background: #000;
      position: relative;
    }
    .crop img {
      position: absolute;
      left: calc(var(--x) * var(--scale) * -1px);
      top: calc(var(--y) * var(--scale) * -1px);
      width: calc(var(--img-w) * var(--scale) * 1px);
      height: calc(var(--img-h) * var(--scale) * 1px);
      object-fit: cover;
      display: block;
    }
    .meta { display: grid; gap: 2px; }
    .name { font-size: 13px; font-weight: 700; color: ${text}; }
    .desc { font-size: 12px; color: ${sub}; line-height: 1.35; }
  </style>
</head>
<body>
  <main class="stage" data-section="Mobile Components v2 / ${theme === 'light' ? 'Light' : 'Dark'}" data-theme="${theme}" data-source-surface-id="${sourceSurfaceId}">
    <section class="header">
      <h1>chat_components / ${theme}</h1>
      <p>Real-capture crop tiles sourced from <strong>${sourceSurfaceId}</strong> (${theme})</p>
    </section>
    <section class="grid">${rows}
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
  const outRoot = path.resolve(args['out-root'] || path.join(repoRoot, 'artifacts/design/mobile/v2/components'));
  const outIndex = path.resolve(args.out || path.join(outRoot, 'index.json'));

  const inventory = JSON.parse(fs.readFileSync(inventoryPath, 'utf8'));

  const cropSpecs = [
    { id: 'status_bar', name: 'Status Bar', description: 'Top status indicators', x: 0, y: 0, w: 1320, h: 150 },
    { id: 'chat_header', name: 'Chat Header', description: 'Title + actions area', x: 0, y: 150, w: 1320, h: 230 },
    { id: 'chip_row', name: 'Suggestion Chips', description: 'Horizontal chip row', x: 0, y: 360, w: 1320, h: 170 },
    { id: 'bubble_ai_1', name: 'AI Bubble 1', description: 'Primary assistant message bubble', x: 150, y: 560, w: 880, h: 220 },
    { id: 'bubble_ai_2', name: 'AI Bubble 2', description: 'Secondary assistant bubble variant', x: 150, y: 810, w: 900, h: 220 },
    { id: 'bubble_user', name: 'User Bubble', description: 'User-side reply bubble', x: 420, y: 1160, w: 780, h: 190 },
    { id: 'result_card', name: 'Insight Card', description: 'Rich result card cluster', x: 130, y: 1360, w: 1040, h: 620 },
    { id: 'chat_input', name: 'Input Bar', description: 'Message input + voice action', x: 50, y: 2600, w: 1220, h: 200 },
  ];

  const targets = [];
  for (const theme of ['light', 'dark']) {
    const source = resolveChatSourceImage(rawRoot, inventory, theme);
    if (!source) continue;

    const outDir = path.join(outRoot, theme);
    ensureDir(outDir);

    const relativeImage = path.relative(outDir, source.path).split(path.sep).join('/');
    const html = buildCropHtml({
      theme,
      imageRelativePath: relativeImage,
      sourceSurfaceId: source.source_surface_id,
      cropSpecs,
    });

    const htmlPath = path.join(outDir, 'index.html');
    fs.writeFileSync(htmlPath, html);

    const relativePath = path.relative(path.join(repoRoot, 'artifacts/design/mobile/v2'), htmlPath).split(path.sep).join('/');
    targets.push({
      theme,
      section: `Mobile Components v2 / ${theme === 'light' ? 'Light' : 'Dark'}`,
      frame_name: `chat_components / ${theme}`,
      source_surface_id: source.source_surface_id,
      relative_path: relativePath,
    });
  }

  const payload = {
    generated_at: new Date().toISOString(),
    inventory_path: inventoryPath,
    raw_root: rawRoot,
    output_root: outRoot,
    total_targets: targets.length,
    crop_count_per_theme: cropSpecs.length,
    targets,
  };

  writeJson(outIndex, payload);
  process.stdout.write(`${JSON.stringify({ index: outIndex, total_targets: targets.length }, null, 2)}\n`);
}

main();
