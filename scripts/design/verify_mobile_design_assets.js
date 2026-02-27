#!/usr/bin/env node

/*
 * Verify mobile design pipeline assets:
 * - screenshots count (61 * 2 expected)
 * - HTML boards count (61 * 2 expected)
 * - missing/blocked items
 *
 * Output:
 *   artifacts/design/mobile/verification_report.json
 *   artifacts/design/mobile/verification_report.md
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const repoRoot = path.resolve(__dirname, '../..');
const baseDir = path.join(repoRoot, 'artifacts/design/mobile');
const manifestPath = path.join(baseDir, 'manifest.json');
const rawRoot = path.join(baseDir, 'raw');
const boardsRoot = path.join(baseDir, 'boards');
const blockedPath = path.join(rawRoot, 'blocked.ndjson');
const reportJsonPath = path.join(baseDir, 'verification_report.json');
const reportMdPath = path.join(baseDir, 'verification_report.md');

function exists(filePath) {
  return fs.existsSync(filePath);
}

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function readNdjson(filePath) {
  if (!exists(filePath)) return [];
  return fs
    .readFileSync(filePath, 'utf8')
    .split('\n')
    .map((line) => line.trim())
    .filter(Boolean)
    .map((line) => JSON.parse(line));
}

function pngSize(filePath) {
  try {
    const output = execSync(`sips -g pixelWidth -g pixelHeight "${filePath}"`, {
      stdio: ['ignore', 'pipe', 'ignore'],
    }).toString();
    const widthMatch = output.match(/pixelWidth:\s+(\d+)/);
    const heightMatch = output.match(/pixelHeight:\s+(\d+)/);
    return {
      width: widthMatch ? Number(widthMatch[1]) : null,
      height: heightMatch ? Number(heightMatch[1]) : null,
    };
  } catch (_e) {
    return { width: null, height: null };
  }
}

function verify() {
  if (!exists(manifestPath)) {
    throw new Error(`Missing manifest: ${manifestPath}`);
  }

  const manifest = readJson(manifestPath);
  const expectedScreens = manifest.screens.length;
  const expectedTargets = expectedScreens * 2;
  const missingScreenshots = [];
  const missingBoards = [];
  const invalidBoards = [];

  let screenshotCount = 0;
  let boardCount = 0;

  for (const screen of manifest.screens) {
    for (const theme of screen.themes) {
      const shotPath = path.join(rawRoot, screen.screen_id, `${theme}.png`);
      const boardPath = path.join(boardsRoot, screen.screen_id, theme, 'index.html');

      if (exists(shotPath)) screenshotCount += 1;
      else {
        missingScreenshots.push({
          screen_id: screen.screen_id,
          theme,
          path: path.relative(repoRoot, shotPath),
        });
      }

      if (exists(boardPath)) {
        boardCount += 1;
        const html = fs.readFileSync(boardPath, 'utf8');
        if (!html.includes('class="component-panel"') || !html.includes('Component Panel')) {
          invalidBoards.push({
            screen_id: screen.screen_id,
            theme,
            reason: 'component_panel_missing',
            path: path.relative(repoRoot, boardPath),
          });
        }
      } else {
        missingBoards.push({
          screen_id: screen.screen_id,
          theme,
          path: path.relative(repoRoot, boardPath),
        });
      }
    }
  }

  const blocked = readNdjson(blockedPath);
  const sampleIds = manifest.screens.slice(0, 10).map((x) => x.screen_id);
  const sampleDimensionChecks = [];

  for (const id of sampleIds) {
    for (const theme of ['light', 'dark']) {
      const p = path.join(rawRoot, id, `${theme}.png`);
      if (!exists(p)) continue;
      sampleDimensionChecks.push({
        screen_id: id,
        theme,
        path: path.relative(repoRoot, p),
        ...pngSize(p),
      });
    }
  }

  const report = {
    generated_at: new Date().toISOString(),
    expected: {
      screens: expectedScreens,
      targets: expectedTargets,
    },
    actual: {
      screenshots: screenshotCount,
      boards: boardCount,
      blocked: blocked.length,
    },
    pass: {
      screenshots_complete: screenshotCount === expectedTargets,
      boards_complete: boardCount === expectedTargets,
      boards_component_panel_valid: invalidBoards.length === 0,
    },
    missing_screenshots: missingScreenshots,
    missing_boards: missingBoards,
    invalid_boards: invalidBoards,
    blocked,
    sample_dimension_checks: sampleDimensionChecks,
    notes: [
      'Figma frame-count verification is manual in MCP workflow.',
      'Box-only frame detection in Figma is approximated by HTML component-panel integrity.',
    ],
  };

  fs.writeFileSync(reportJsonPath, `${JSON.stringify(report, null, 2)}\n`);

  const md = [
    '# Mobile Design Verification Report',
    '',
    `- Generated: ${report.generated_at}`,
    `- Expected targets: ${expectedTargets}`,
    `- Screenshots: ${screenshotCount}`,
    `- Boards: ${boardCount}`,
    `- Blocked: ${blocked.length}`,
    '',
    '## Pass Flags',
    `- screenshots_complete: ${report.pass.screenshots_complete}`,
    `- boards_complete: ${report.pass.boards_complete}`,
    `- boards_component_panel_valid: ${report.pass.boards_component_panel_valid}`,
    '',
    '## Missing Screenshots',
    `${missingScreenshots.length}`,
    '',
    '## Missing Boards',
    `${missingBoards.length}`,
    '',
    '## Invalid Boards',
    `${invalidBoards.length}`,
  ].join('\n');

  fs.writeFileSync(reportMdPath, `${md}\n`);

  console.log(JSON.stringify(report, null, 2));
}

verify();
