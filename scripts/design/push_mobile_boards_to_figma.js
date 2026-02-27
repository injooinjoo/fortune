#!/usr/bin/env node

/*
 * Pushes generated mobile component boards into an existing Figma file by
 * chaining nextCaptureId values returned from Figma capture submissions.
 */

const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');
const { chromium } = require('playwright');

function parseArgs(argv) {
  const args = {};
  for (let i = 0; i < argv.length; i += 1) {
    const token = argv[i];
    if (!token.startsWith('--')) {
      continue;
    }
    const [rawKey, rawValue] = token.split('=');
    const key = rawKey.slice(2);
    if (rawValue !== undefined) {
      args[key] = rawValue;
      continue;
    }
    const next = argv[i + 1];
    if (!next || next.startsWith('--')) {
      args[key] = true;
      continue;
    }
    args[key] = next;
    i += 1;
  }
  return args;
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function ensureDir(dirPath) {
  fs.mkdirSync(dirPath, { recursive: true });
}

function parseList(value, fallback = []) {
  if (!value) {
    return fallback;
  }
  return String(value)
    .split(',')
    .map((v) => v.trim())
    .filter(Boolean);
}

function buildTargets(manifest, selectedThemes, skipKeys, startIndex = 0, limit = null) {
  const targets = [];
  for (const screen of manifest.screens || []) {
    const screenThemes = Array.isArray(screen.themes) ? screen.themes : ['light', 'dark'];
    for (const theme of selectedThemes) {
      if (!screenThemes.includes(theme)) {
        continue;
      }
      const key = `${screen.screen_id}/${theme}`;
      if (skipKeys.has(key)) {
        continue;
      }
      targets.push({
        key,
        screenId: screen.screen_id,
        theme,
        category: screen.category,
        figmaPage: screen.figma_page,
      });
    }
  }

  const sliced = targets.slice(startIndex, limit ? startIndex + limit : undefined);
  return sliced;
}

function buildUrl(host, port, target) {
  return `http://${host}:${port}/${encodeURIComponent(target.screenId)}/${encodeURIComponent(target.theme)}/index.html`;
}

function readManifest(manifestPath) {
  if (!fs.existsSync(manifestPath)) {
    throw new Error(`Manifest not found: ${manifestPath}`);
  }
  return JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
}

function assertBoardExists(boardsDir, target) {
  const boardPath = path.join(boardsDir, target.screenId, target.theme, 'index.html');
  if (!fs.existsSync(boardPath)) {
    throw new Error(`Board missing for target ${target.key}: ${boardPath}`);
  }
}

async function run() {
  const args = parseArgs(process.argv.slice(2));
  const initialCaptureId = args['initial-capture-id'];
  if (!initialCaptureId) {
    throw new Error('Missing required --initial-capture-id');
  }

  const host = args.host || '127.0.0.1';
  const port = Number(args.port || '4173');
  const timeoutMs = Number(args['timeout-ms'] || '120000');
  const delayMs = Number(args['delay-ms'] || '200');
  const limit = args.limit ? Number(args.limit) : null;
  const startIndex = args['start-index'] ? Number(args['start-index']) : 0;
  const selectedThemes = parseList(args.themes, ['light', 'dark']);
  const skipKeys = new Set(parseList(args.skip));

  const manifestPath = path.resolve(args.manifest || 'artifacts/design/mobile/manifest.json');
  const boardsDir = path.resolve(args['boards-dir'] || 'artifacts/design/mobile/boards');
  const reportPath = path.resolve(args.report || 'artifacts/design/mobile/figma_capture_report.json');

  const manifest = readManifest(manifestPath);
  const targets = buildTargets(manifest, selectedThemes, skipKeys, startIndex, limit);

  if (targets.length === 0) {
    throw new Error('No targets to capture. Check --themes/--skip/--start-index/--limit options.');
  }

  for (const target of targets) {
    assertBoardExists(boardsDir, target);
  }

  ensureDir(path.dirname(reportPath));

  const report = {
    generated_at: new Date().toISOString(),
    host,
    port,
    manifest_path: manifestPath,
    boards_dir: boardsDir,
    initial_capture_id: initialCaptureId,
    final_capture_id: null,
    selected_themes: selectedThemes,
    skip: Array.from(skipKeys),
    start_index: startIndex,
    limit,
    total_targets: targets.length,
    success_count: 0,
    failure_count: 0,
    results: [],
  };

  const server = spawn('python3', ['-m', 'http.server', String(port), '--directory', boardsDir], {
    stdio: 'ignore',
  });

  let browser;
  let captureId = initialCaptureId;

  const finalize = async (exitCode = 0) => {
    report.final_capture_id = captureId;
    fs.writeFileSync(reportPath, JSON.stringify(report, null, 2));

    if (browser) {
      await browser.close().catch(() => {});
    }

    if (server && !server.killed) {
      server.kill('SIGTERM');
    }

    if (exitCode !== 0) {
      process.exit(exitCode);
    }
  };

  process.on('SIGINT', async () => {
    await finalize(130);
  });

  await sleep(1200);

  browser = await chromium.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage'],
  });

  for (let index = 0; index < targets.length; index += 1) {
    const target = targets[index];
    const endpoint = `https://mcp.figma.com/mcp/capture/${captureId}/submit`;
    const url = buildUrl(host, port, target);
    const page = await browser.newPage();
    page.setDefaultTimeout(timeoutMs);

    const result = {
      order: index + 1,
      key: target.key,
      screen_id: target.screenId,
      theme: target.theme,
      category: target.category,
      figma_page: target.figmaPage,
      capture_id: captureId,
      endpoint,
      url,
      status: 'pending',
      response_status: null,
      next_capture_id: null,
      file_url: null,
      error: null,
      timestamp: new Date().toISOString(),
    };

    try {
      await page.goto(url, { waitUntil: 'networkidle', timeout: timeoutMs });
      await page.addScriptTag({ url: 'https://mcp.figma.com/mcp/html-to-design/capture.js' });
      await page.waitForTimeout(600);

      const responsePromise = page.waitForResponse(
        (resp) => resp.url().includes(`/capture/${captureId}/submit`) && resp.request().method() === 'POST',
        { timeout: timeoutMs },
      );

      await page.evaluate(
        ({ inCaptureId, inEndpoint, inDelayMs }) => {
          window.figma
            .captureForDesign({
              captureId: inCaptureId,
              endpoint: inEndpoint,
              selector: 'body',
              delayMs: inDelayMs,
              verbose: false,
            })
            .catch(() => {});
        },
        { inCaptureId: captureId, inEndpoint: endpoint, inDelayMs: delayMs },
      );

      const response = await responsePromise;
      const bodyText = await response.text();
      let bodyJson = {};
      try {
        bodyJson = JSON.parse(bodyText);
      } catch (parseErr) {
        bodyJson = { raw: bodyText };
      }

      result.response_status = response.status();
      result.file_url = bodyJson.fileUrl || bodyJson.claimUrl || null;
      result.next_capture_id = bodyJson.nextCaptureId || null;

      if (!response.ok()) {
        throw new Error(`Capture submit failed (${response.status()}): ${bodyText}`);
      }

      if (!result.next_capture_id) {
        throw new Error(`No nextCaptureId in response for ${target.key}`);
      }

      result.status = 'success';
      report.success_count += 1;
      report.results.push(result);

      captureId = result.next_capture_id;
      process.stdout.write(`[${index + 1}/${targets.length}] success ${target.key}\n`);
    } catch (err) {
      result.status = 'failed';
      result.error = err instanceof Error ? err.message : String(err);
      report.failure_count += 1;
      report.results.push(result);
      process.stderr.write(`[${index + 1}/${targets.length}] failed ${target.key}: ${result.error}\n`);
      await page.close().catch(() => {});
      await finalize(1);
      return;
    }

    await page.close().catch(() => {});
  }

  await finalize(0);
}

run().catch(async (err) => {
  const message = err instanceof Error ? err.stack || err.message : String(err);
  process.stderr.write(`${message}\n`);
  process.exit(1);
});
