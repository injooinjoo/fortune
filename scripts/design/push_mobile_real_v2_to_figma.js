#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');
const { chromium } = require('playwright');

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

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function loadJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function writeJson(filePath, payload) {
  ensureDir(path.dirname(filePath));
  fs.writeFileSync(filePath, `${JSON.stringify(payload, null, 2)}\n`);
}

function orderedTargets(realIndex, componentIndex) {
  const all = [];
  for (const target of realIndex.targets || []) {
    all.push({ ...target, target_group: 'real' });
  }
  for (const target of componentIndex.targets || []) {
    all.push({ ...target, target_group: 'components' });
  }

  const order = {
    'Mobile Real v2 / Light': 1,
    'Mobile Real v2 / Dark': 2,
    'Mobile Components v2 / Light': 3,
    'Mobile Components v2 / Dark': 4,
  };

  return all.sort((a, b) => {
    const aRank = order[a.section] || 99;
    const bRank = order[b.section] || 99;
    if (aRank !== bRank) return aRank - bRank;
    return String(a.frame_name).localeCompare(String(b.frame_name));
  });
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  const repoRoot = path.resolve(__dirname, '..', '..');

  const initialCaptureId = args['initial-capture-id'];
  if (!initialCaptureId) {
    throw new Error('Missing required argument: --initial-capture-id');
  }

  const v2Root = path.resolve(args['v2-root'] || path.join(repoRoot, 'artifacts/design/mobile/v2'));
  const realIndexPath = path.resolve(args['frames-index'] || path.join(v2Root, 'figma_frames/index.json'));
  const componentIndexPath = path.resolve(args['components-index'] || path.join(v2Root, 'components/index.json'));
  const reportPath = path.resolve(args.out || path.join(v2Root, 'figma_upload_report.json'));

  const host = args.host || '127.0.0.1';
  const port = Number(args.port || '4174');
  const timeoutMs = Number(args['timeout-ms'] || '90000');

  const realIndex = loadJson(realIndexPath);
  const componentIndex = loadJson(componentIndexPath);
  const targets = orderedTargets(realIndex, componentIndex);

  if (targets.length === 0) {
    throw new Error('No upload targets found. Build figma frames/components first.');
  }

  const server = spawn('python3', ['-m', 'http.server', String(port), '--directory', v2Root], {
    stdio: 'ignore',
  });

  const report = {
    generated_at: new Date().toISOString(),
    initial_capture_id: initialCaptureId,
    final_capture_id: null,
    total_targets: targets.length,
    success_count: 0,
    failure_count: 0,
    results: [],
  };

  let captureId = initialCaptureId;
  let browser = null;

  async function cleanup(exitCode = 0) {
    report.final_capture_id = captureId;
    writeJson(reportPath, report);

    if (browser) {
      await browser.close().catch(() => {});
    }
    if (server && !server.killed) {
      server.kill('SIGTERM');
    }

    if (exitCode !== 0) {
      process.exit(exitCode);
    }
  }

  process.on('SIGINT', async () => {
    await cleanup(130);
  });

  await sleep(1200);
  browser = await chromium.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage'],
  });

  for (let i = 0; i < targets.length; i += 1) {
    const target = targets[i];
    const endpoint = `https://mcp.figma.com/mcp/capture/${captureId}/submit`;
    const url = `http://${host}:${port}/${target.relative_path}`;

    const result = {
      order: i + 1,
      frame_name: target.frame_name,
      section: target.section,
      target_group: target.target_group,
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

    const page = await browser.newPage();
    page.setDefaultTimeout(timeoutMs);

    try {
      await page.goto(url, { waitUntil: 'networkidle', timeout: timeoutMs });
      await page.waitForTimeout(700);

      const responsePromise = page.waitForResponse(
        (resp) => resp.url().includes(`/capture/${captureId}/submit`) && resp.request().method() === 'POST',
        { timeout: timeoutMs },
      );

      await page.evaluate(
        ({ inCaptureId, inEndpoint }) => {
          window.figma
            .captureForDesign({
              captureId: inCaptureId,
              endpoint: inEndpoint,
              selector: 'body',
              delayMs: 150,
              verbose: false,
            })
            .catch(() => {});
        },
        { inCaptureId: captureId, inEndpoint: endpoint },
      );

      const response = await responsePromise;
      const rawText = await response.text();

      let body = {};
      try {
        body = JSON.parse(rawText);
      } catch (_error) {
        body = { raw: rawText };
      }

      result.response_status = response.status();
      result.file_url = body.fileUrl || body.claimUrl || null;
      result.next_capture_id = body.nextCaptureId || null;

      if (!response.ok()) {
        throw new Error(`Capture submit failed (${response.status()}): ${rawText}`);
      }

      if (!result.next_capture_id) {
        throw new Error(`No nextCaptureId for ${target.frame_name}`);
      }

      result.status = 'success';
      report.success_count += 1;
      report.results.push(result);

      captureId = result.next_capture_id;
      process.stdout.write(`[${i + 1}/${targets.length}] success ${target.frame_name}\n`);
    } catch (error) {
      result.status = 'failed';
      result.error = error instanceof Error ? error.message : String(error);
      report.failure_count += 1;
      report.results.push(result);
      process.stderr.write(`[${i + 1}/${targets.length}] failed ${target.frame_name}: ${result.error}\n`);
      await page.close().catch(() => {});
      await cleanup(1);
      return;
    }

    await page.close().catch(() => {});
  }

  await cleanup(0);
}

main().catch(async (error) => {
  process.stderr.write(`${error.stack || error.message}\n`);
  process.exit(1);
});
