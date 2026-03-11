#!/usr/bin/env node

/*
 * Pushes the generated Figma catalog HTML pages into an existing Figma file by
 * chaining nextCaptureId values returned from the Figma capture endpoint.
 */

const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');
const { chromium } = require('playwright');

function parseArgs(argv) {
  const args = {};
  for (let index = 0; index < argv.length; index += 1) {
    const token = argv[index];
    if (!token.startsWith('--')) {
      continue;
    }

    const [rawKey, rawValue] = token.split('=');
    const key = rawKey.slice(2);
    if (rawValue !== undefined) {
      args[key] = rawValue;
      continue;
    }

    const next = argv[index + 1];
    if (!next || next.startsWith('--')) {
      args[key] = true;
      continue;
    }

    args[key] = next;
    index += 1;
  }

  return args;
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function ensureDir(dirPath) {
  fs.mkdirSync(dirPath, { recursive: true });
}

function parseList(value) {
  if (!value) {
    return [];
  }

  return String(value)
    .split(',')
    .map((entry) => entry.trim())
    .filter(Boolean);
}

function listCatalogPages(catalogDir) {
  return fs
    .readdirSync(catalogDir)
    .filter((entry) => entry.endsWith('.html'))
    .filter((entry) => entry !== 'index.html')
    .sort((left, right) => left.localeCompare(right, 'en'));
}

async function run() {
  const args = parseArgs(process.argv.slice(2));
  const repoRoot = path.resolve(__dirname, '..', '..');

  const initialCaptureId = args['initial-capture-id'];
  if (!initialCaptureId) {
    throw new Error('Missing required --initial-capture-id');
  }

  const catalogDir = path.resolve(
    args['catalog-dir'] || path.join(repoRoot, 'artifacts/figma_catalog')
  );
  if (!fs.existsSync(catalogDir)) {
    throw new Error(`Catalog directory not found: ${catalogDir}`);
  }

  const host = args.host || '127.0.0.1';
  const port = Number(args.port || '4181');
  const timeoutMs = Number(args['timeout-ms'] || '90000');
  const delayMs = Number(args['delay-ms'] || '300');
  const selector = args.selector || 'body';
  const include = new Set(parseList(args.include));
  const skip = new Set(parseList(args.skip));
  const reportPath = path.resolve(
    args.report || path.join(catalogDir, 'figma_push_report.json')
  );

  const pageFiles = listCatalogPages(catalogDir).filter((pageFile) => {
    if (include.size > 0 && !include.has(pageFile)) {
      return false;
    }
    return !skip.has(pageFile);
  });

  if (pageFiles.length === 0) {
    throw new Error('No catalog pages selected for capture.');
  }

  const report = {
    generated_at: new Date().toISOString(),
    catalog_dir: catalogDir,
    initial_capture_id: initialCaptureId,
    final_capture_id: null,
    total_targets: pageFiles.length,
    success_count: 0,
    failure_count: 0,
    selector,
    results: [],
  };

  const server = spawn(
    'python3',
    ['-m', 'http.server', String(port), '--directory', catalogDir],
    { stdio: 'ignore' }
  );

  let browser = null;
  let captureId = initialCaptureId;

  const finalize = async (exitCode = 0) => {
    report.final_capture_id = captureId;
    ensureDir(path.dirname(reportPath));
    fs.writeFileSync(reportPath, `${JSON.stringify(report, null, 2)}\n`);

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

  for (let index = 0; index < pageFiles.length; index += 1) {
    const pageFile = pageFiles[index];
    const endpoint = `https://mcp.figma.com/mcp/capture/${captureId}/submit`;
    const pageUrl = `http://${host}:${port}/${pageFile}`;
    const page = await browser.newPage();
    page.setDefaultTimeout(timeoutMs);

    const result = {
      order: index + 1,
      page_file: pageFile,
      capture_id: captureId,
      endpoint,
      page_url: pageUrl,
      status: 'pending',
      response_status: null,
      next_capture_id: null,
      file_url: null,
      error: null,
      timestamp: new Date().toISOString(),
    };

    try {
      await page.goto(pageUrl, { waitUntil: 'networkidle', timeout: timeoutMs });
      await page.waitForFunction(
        () => window.figma && typeof window.figma.captureForDesign === 'function',
        { timeout: timeoutMs }
      );
      await page.waitForTimeout(600);
      process.stdout.write(`[${index + 1}/${pageFiles.length}] capturing ${pageFile}\n`);

      const responsePromise = page.waitForResponse(
        (response) =>
          response.url().includes(`/capture/${captureId}/submit`) &&
          response.request().method() === 'POST',
        { timeout: timeoutMs }
      );

      await page.evaluate(
        ({ inCaptureId, inEndpoint, inSelector, inDelayMs }) => {
          window.figma
            .captureForDesign({
              captureId: inCaptureId,
              endpoint: inEndpoint,
              selector: inSelector,
              delayMs: inDelayMs,
              verbose: false,
            })
            .catch(() => {});
        },
        {
          inCaptureId: captureId,
          inEndpoint: endpoint,
          inSelector: selector,
          inDelayMs: delayMs,
        }
      );

      const response = await responsePromise;
      const bodyText = await response.text();
      let bodyJson = {};
      try {
        bodyJson = JSON.parse(bodyText);
      } catch (_error) {
        bodyJson = { raw: bodyText };
      }

      result.response_status = response.status();
      result.file_url = bodyJson.fileUrl || bodyJson.claimUrl || null;
      result.next_capture_id = bodyJson.nextCaptureId || null;

      if (!response.ok()) {
        throw new Error(`Capture submit failed (${response.status()}): ${bodyText}`);
      }

      if (!result.next_capture_id) {
        throw new Error(`No nextCaptureId returned for ${pageFile}`);
      }

      result.status = 'success';
      report.success_count += 1;
      report.results.push(result);
      captureId = result.next_capture_id;

      process.stdout.write(`[${index + 1}/${pageFiles.length}] success ${pageFile}\n`);
    } catch (error) {
      result.status = 'failed';
      result.error = error instanceof Error ? error.message : String(error);
      report.failure_count += 1;
      report.results.push(result);
      process.stderr.write(
        `[${index + 1}/${pageFiles.length}] failed ${pageFile}: ${result.error}\n`
      );
      await page.close().catch(() => {});
      await finalize(1);
      return;
    }

    await page.close().catch(() => {});
  }

  await finalize(0);
}

run().catch((error) => {
  const message = error instanceof Error ? error.stack || error.message : String(error);
  process.stderr.write(`${message}\n`);
  process.exit(1);
});
