#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const {
  runCommand,
  detectBootedUdid,
  openRouteByDeepLink,
  openChatRepresentative,
  evaluateQuality,
} = require('./lib/mobile_v2_runtime');

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

function appendNdjson(filePath, payload) {
  ensureDir(path.dirname(filePath));
  fs.appendFileSync(filePath, `${JSON.stringify(payload)}\n`);
}

function fileSha256(filePath) {
  const bytes = fs.readFileSync(filePath);
  return crypto.createHash('sha256').update(bytes).digest('hex');
}

function setAppearance(udid, theme) {
  runCommand(`xcrun simctl ui '${udid}' appearance ${theme}`, { allowFail: true });
}

async function navigateSurface({ udid, config, surface, representativeMap, waitMs }) {
  if (surface.surface_type === 'route') {
    const routePath = surface.route_path;
    const nav = await openRouteByDeepLink({
      udid,
      appScheme: config.appScheme,
      appHost: config.appHost,
      routePath,
      popupPatterns: config.popupPatterns || [],
      waitMs,
    });

    const quality = evaluateQuality({
      nodes: nav.nodes,
      errorPatterns: config.errorPatterns || [],
      popupPatterns: config.popupPatterns || [],
    });

    return {
      nav,
      quality,
      representative: null,
    };
  }

  const representative = representativeMap.get(surface.surface_id);
  if (!representative) {
    return {
      nav: null,
      quality: {
        ok: false,
        issues: ['chat_rep_config_missing'],
        label_count: 0,
        top_labels: [],
      },
      representative: null,
    };
  }

  const chat = await openChatRepresentative({
    udid,
    appScheme: config.appScheme,
    appHost: config.appHost,
    representative,
    popupPatterns: config.popupPatterns || [],
    waitMs,
  });

  if (!chat.target) {
    return {
      nav: chat,
      quality: {
        ok: false,
        issues: ['chat_rep_not_found_on_chat_list'],
        label_count: chat.nodes.length,
        top_labels: chat.nodes.slice(0, 10).map((n) => n.AXLabel).filter(Boolean),
      },
      representative,
    };
  }

  const quality = evaluateQuality({
    nodes: chat.nodes,
    errorPatterns: config.errorPatterns || [],
    popupPatterns: config.popupPatterns || [],
  });

  return {
    nav: chat,
    quality,
    representative,
  };
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  const repoRoot = path.resolve(__dirname, '..', '..');

  const configPath = path.resolve(args.config || path.join(__dirname, 'config/mobile_v2_surfaces.json'));
  const inventoryPath = path.resolve(args.inventory || path.join(repoRoot, 'artifacts/design/mobile/v2/live_inventory.json'));
  const outRoot = path.resolve(args['out-root'] || path.join(repoRoot, 'artifacts/design/mobile/v2/raw'));
  const waitMs = Math.max(500, Math.floor(Number(args['wait-seconds'] || '1.4') * 1000));
  const retryCount = Math.max(0, Number(args['retry-count'] || '2'));
  const themes = String(args.themes || 'light,dark')
    .split(',')
    .map((x) => x.trim())
    .filter(Boolean);

  const udid = args.udid || detectBootedUdid();
  if (!udid) {
    throw new Error('No booted simulator UDID detected. Pass --udid explicitly.');
  }

  const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
  const inventory = JSON.parse(fs.readFileSync(inventoryPath, 'utf8'));
  const reachable = (inventory.surfaces || []).filter((surface) => surface.inventory_status === 'reachable');
  const representativeMap = new Map((config.chatRepresentatives || []).map((rep) => [rep.id, rep]));

  ensureDir(outRoot);
  const blockedPath = path.join(outRoot, 'blocked.ndjson');
  const captureLogPath = path.join(outRoot, 'capture_log.ndjson');
  fs.writeFileSync(blockedPath, '');
  fs.writeFileSync(captureLogPath, '');

  const screenshotResults = [];

  for (const theme of themes) {
    setAppearance(udid, theme);

    for (const surface of reachable) {
      let captured = false;
      let lastReason = 'unknown';

      for (let attempt = 1; attempt <= retryCount + 1; attempt += 1) {
        // eslint-disable-next-line no-await-in-loop
        const navResult = await navigateSurface({
          udid,
          config,
          surface,
          representativeMap,
          waitMs,
        });

        if (!navResult.quality.ok) {
          lastReason = navResult.quality.issues.join('|') || 'quality_gate_failed';
          appendNdjson(captureLogPath, {
            timestamp: new Date().toISOString(),
            surface_id: surface.surface_id,
            surface_type: surface.surface_type,
            theme,
            attempt,
            status: 'retry',
            reason: lastReason,
          });
          continue;
        }

        const outDir = path.join(outRoot, surface.surface_id);
        ensureDir(outDir);
        const outPath = path.join(outDir, `${theme}.png`);

        runCommand(`idb screenshot --udid '${udid}' '${outPath}'`, { allowFail: true });

        if (!fs.existsSync(outPath)) {
          lastReason = 'screenshot_file_missing';
          appendNdjson(captureLogPath, {
            timestamp: new Date().toISOString(),
            surface_id: surface.surface_id,
            surface_type: surface.surface_type,
            theme,
            attempt,
            status: 'retry',
            reason: lastReason,
          });
          continue;
        }

        const stat = fs.statSync(outPath);
        if (stat.size < 1024) {
          lastReason = 'screenshot_file_too_small';
          appendNdjson(captureLogPath, {
            timestamp: new Date().toISOString(),
            surface_id: surface.surface_id,
            surface_type: surface.surface_type,
            theme,
            attempt,
            status: 'retry',
            reason: lastReason,
          });
          continue;
        }

        const hash = fileSha256(outPath);
        appendNdjson(captureLogPath, {
          timestamp: new Date().toISOString(),
          surface_id: surface.surface_id,
          surface_type: surface.surface_type,
          theme,
          attempt,
          status: 'captured',
          path: path.relative(repoRoot, outPath),
          sha256: hash,
          label_count: navResult.quality.label_count,
        });

        screenshotResults.push({
          surface_id: surface.surface_id,
          surface_type: surface.surface_type,
          theme,
          path: outPath,
          sha256: hash,
        });

        captured = true;
        break;
      }

      if (!captured) {
        appendNdjson(blockedPath, {
          timestamp: new Date().toISOString(),
          surface_id: surface.surface_id,
          surface_type: surface.surface_type,
          theme,
          reason: lastReason,
        });
      }
    }
  }

  const blockedLines = fs
    .readFileSync(blockedPath, 'utf8')
    .split('\n')
    .filter(Boolean)
    .map((line) => JSON.parse(line));

  const summary = {
    generated_at: new Date().toISOString(),
    udid,
    themes,
    total_reachable_surfaces: reachable.length,
    expected_captures: reachable.length * themes.length,
    captured_count: screenshotResults.length,
    blocked_count: blockedLines.length,
    by_theme: Object.fromEntries(
      themes.map((theme) => [theme, screenshotResults.filter((row) => row.theme === theme).length]),
    ),
    by_surface_type: {
      route: screenshotResults.filter((row) => row.surface_type === 'route').length,
      chat_rep: screenshotResults.filter((row) => row.surface_type === 'chat_rep').length,
    },
    output_root: outRoot,
  };

  writeJson(path.join(outRoot, 'capture_summary.json'), summary);
  process.stdout.write(`${JSON.stringify(summary, null, 2)}\n`);
}

main().catch((error) => {
  process.stderr.write(`${error.stack || error.message}\n`);
  process.exit(1);
});
