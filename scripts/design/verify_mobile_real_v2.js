#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

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

function listFilesRecursive(dirPath) {
  if (!fs.existsSync(dirPath)) return [];
  const results = [];
  function walk(current) {
    for (const entry of fs.readdirSync(current, { withFileTypes: true })) {
      const full = path.join(current, entry.name);
      if (entry.isDirectory()) {
        walk(full);
      } else {
        results.push(full);
      }
    }
  }
  walk(dirPath);
  return results;
}

function fileHash(filePath) {
  const bytes = fs.readFileSync(filePath);
  return crypto.createHash('sha256').update(bytes).digest('hex');
}

function readNdjson(filePath) {
  if (!fs.existsSync(filePath)) return [];
  return fs
    .readFileSync(filePath, 'utf8')
    .split('\n')
    .filter(Boolean)
    .map((line) => JSON.parse(line));
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  const repoRoot = path.resolve(__dirname, '..', '..');

  const inventoryPath = path.resolve(args.inventory || path.join(repoRoot, 'artifacts/design/mobile/v2/live_inventory.json'));
  const rawRoot = path.resolve(args['raw-root'] || path.join(repoRoot, 'artifacts/design/mobile/v2/raw'));
  const figmaFramesIndexPath = path.resolve(args['frames-index'] || path.join(repoRoot, 'artifacts/design/mobile/v2/figma_frames/index.json'));
  const componentsIndexPath = path.resolve(args['components-index'] || path.join(repoRoot, 'artifacts/design/mobile/v2/components/index.json'));
  const old61Path = path.resolve(args['old61-mapping'] || path.join(repoRoot, 'artifacts/design/mobile/v2/old61_mapping.json'));
  const reportPath = path.resolve(args.out || path.join(repoRoot, 'artifacts/design/mobile/v2/verification_report.json'));

  const inventory = JSON.parse(fs.readFileSync(inventoryPath, 'utf8'));
  const reachable = (inventory.surfaces || []).filter((surface) => surface.inventory_status === 'reachable');
  const expectedFrames = reachable.length * 2;

  const screenshotFiles = listFilesRecursive(rawRoot).filter((file) => file.endsWith('.png'));
  const blocked = readNdjson(path.join(rawRoot, 'blocked.ndjson'));
  const captureLog = readNdjson(path.join(rawRoot, 'capture_log.ndjson'));

  const byTheme = {
    light: screenshotFiles.filter((file) => file.endsWith('/light.png')).length,
    dark: screenshotFiles.filter((file) => file.endsWith('/dark.png')).length,
  };

  const bySurfaceType = {
    route: 0,
    chat_rep: 0,
  };

  for (const surface of reachable) {
    const lightPath = path.join(rawRoot, surface.surface_id, 'light.png');
    const darkPath = path.join(rawRoot, surface.surface_id, 'dark.png');
    if (fs.existsSync(lightPath)) bySurfaceType[surface.surface_type] += 1;
    if (fs.existsSync(darkPath)) bySurfaceType[surface.surface_type] += 1;
  }

  const missingCaptures = [];
  const identicalThemePairs = [];

  for (const surface of reachable) {
    const lightPath = path.join(rawRoot, surface.surface_id, 'light.png');
    const darkPath = path.join(rawRoot, surface.surface_id, 'dark.png');

    if (!fs.existsSync(lightPath)) {
      missingCaptures.push({ surface_id: surface.surface_id, theme: 'light' });
    }
    if (!fs.existsSync(darkPath)) {
      missingCaptures.push({ surface_id: surface.surface_id, theme: 'dark' });
    }

    if (fs.existsSync(lightPath) && fs.existsSync(darkPath)) {
      const lightHash = fileHash(lightPath);
      const darkHash = fileHash(darkPath);
      if (lightHash === darkHash) {
        identicalThemePairs.push({
          surface_id: surface.surface_id,
          light_hash: lightHash,
          dark_hash: darkHash,
        });
      }
    }
  }

  const framesIndex = fs.existsSync(figmaFramesIndexPath)
    ? JSON.parse(fs.readFileSync(figmaFramesIndexPath, 'utf8'))
    : { total_targets: 0, targets: [] };

  const componentsIndex = fs.existsSync(componentsIndexPath)
    ? JSON.parse(fs.readFileSync(componentsIndexPath, 'utf8'))
    : { total_targets: 0, targets: [] };

  const old61 = fs.existsSync(old61Path)
    ? JSON.parse(fs.readFileSync(old61Path, 'utf8'))
    : { summary: { total: 0, kept: 0, replaced: 0, excluded: 0 } };

  const report = {
    generated_at: new Date().toISOString(),
    expected_frames: expectedFrames,
    captured_count: screenshotFiles.length,
    blocked_count: blocked.length,
    by_theme: byTheme,
    by_surface_type: bySurfaceType,
    reachable_surface_count: reachable.length,
    missing_captures: missingCaptures,
    identical_theme_pairs: identicalThemePairs,
    figma_frames: {
      index_path: figmaFramesIndexPath,
      total_targets: framesIndex.total_targets || 0,
    },
    components_pages: {
      index_path: componentsIndexPath,
      total_targets: componentsIndex.total_targets || 0,
      has_light: Boolean((componentsIndex.targets || []).find((target) => target.theme === 'light')),
      has_dark: Boolean((componentsIndex.targets || []).find((target) => target.theme === 'dark')),
    },
    old61_mapping: {
      path: old61Path,
      summary: old61.summary || null,
    },
    logs: {
      capture_log_entries: captureLog.length,
      blocked_entries: blocked.length,
    },
    pass: {
      captures_complete: screenshotFiles.length >= expectedFrames && missingCaptures.length === 0,
      no_popup_or_notfound_blocked: blocked.length === 0,
      theme_variation_detected: identicalThemePairs.length === 0,
      components_ready: Boolean((componentsIndex.targets || []).length >= 2),
      old61_mapping_ready: Boolean(old61.summary && old61.summary.total > 0),
    },
  };

  writeJson(reportPath, report);
  process.stdout.write(`${JSON.stringify(report, null, 2)}\n`);
}

main();
