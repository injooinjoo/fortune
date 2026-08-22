#!/usr/bin/env node
/**
 * Deterministic readiness checks for the Ondo public web hub (Vercel static site).
 *
 * Two modes:
 *   node scripts/validate-ondo-web-readiness.mjs          -> run all assertions, exit 1 on failure
 *   node scripts/validate-ondo-web-readiness.mjs --serve  -> start a local server that mirrors
 *                                                           vercel.json rewrite/header/404 semantics
 *
 * The `--serve` mode exists so the Playwright suite can assert routing, headers and 404 status
 * offline, without `vercel dev` or a deployment.
 */

import fs from 'node:fs';
import http from 'node:http';
import path from 'node:path';
import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';

const require = createRequire(import.meta.url);
const REPO_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const PUBLIC_DIR = path.join(REPO_ROOT, 'public');
const VERCEL_CONFIG_PATH = path.join(REPO_ROOT, 'vercel.json');
const APP_CONFIG_PATH = path.join(REPO_ROOT, 'apps', 'mobile-rn', 'app.config.js');

export const WEB_DOMAIN = 'fortune-mocha.vercel.app';

/** Public routes the static hub must answer with a real page. */
export const PUBLIC_PAGE_ROUTES = ['/', '/privacy', '/terms', '/support', '/delete-account'];

/** Native-only product routes that must land on the explicit "open in app" page. */
export const NATIVE_LANDING_ROUTES = [
  '/auth/callback',
  '/chat',
  '/onboarding',
  '/premium',
  '/account-deletion',
];

/** Deep-link paths claimed by the native app on WEB_DOMAIN. */
export const DEEP_LINK_PATHS = [
  '/auth/callback',
  '/chat',
  '/onboarding',
  '/premium',
  '/account-deletion',
];

/** Contact domain with no MX record - must not appear in published pages. */
export const DEAD_MAIL_DOMAIN = 'zpzg.co.kr';
export const SUPPORT_EMAIL = 'injooinjoo@gmail.com';

const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.png': 'image/png',
  '.txt': 'text/plain; charset=utf-8',
};

export function readVercelConfig() {
  return JSON.parse(fs.readFileSync(VERCEL_CONFIG_PATH, 'utf8'));
}

export function readAppConfig() {
  delete require.cache[require.resolve(APP_CONFIG_PATH)];
  return require(APP_CONFIG_PATH);
}

/**
 * Vercel `source` values use path-to-regexp. This hub only uses literal paths and the
 * catch-all `/(.*)`, so a narrow translation is enough - and `assertVercelConfig`
 * enforces that no other syntax sneaks in.
 */
export function sourceToRegExp(source) {
  const WILDCARD = ' wildcard ';
  const masked = source.split('/(.*)').join(WILDCARD);
  const escaped = masked.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  return new RegExp(`^${escaped.split(WILDCARD).join('(?:/.*)?')}$`);
}

function resolveStaticFile(pathname) {
  const relative = pathname.replace(/^\/+/, '');
  const candidate = path.join(PUBLIC_DIR, relative);

  if (!candidate.startsWith(PUBLIC_DIR)) return null;

  if (pathname.endsWith('/')) {
    const indexFile = path.join(candidate, 'index.html');
    return fs.existsSync(indexFile) ? indexFile : null;
  }

  if (fs.existsSync(candidate) && fs.statSync(candidate).isFile()) return candidate;

  const htmlFallback = `${candidate}.html`;
  if (fs.existsSync(htmlFallback) && fs.statSync(htmlFallback).isFile()) return htmlFallback;

  return null;
}

export function createVercelSemanticsServer() {
  const config = readVercelConfig();
  const rewrites = (config.rewrites ?? []).map((rule) => ({
    ...rule,
    matcher: sourceToRegExp(rule.source),
  }));
  const headerRules = (config.headers ?? []).map((rule) => ({
    ...rule,
    matcher: sourceToRegExp(rule.source),
  }));

  return http.createServer((req, res) => {
    const requestPath = decodeURIComponent(new URL(req.url, 'http://localhost').pathname);
    const rewrite = rewrites.find((rule) => rule.matcher.test(requestPath));
    const targetPath = rewrite ? rewrite.destination : requestPath;

    const headers = {};
    for (const rule of headerRules) {
      if (!rule.matcher.test(requestPath)) continue;
      for (const header of rule.headers) headers[header.key] = header.value;
    }

    let filePath = resolveStaticFile(targetPath);
    let statusCode = 200;

    if (!filePath) {
      statusCode = 404;
      filePath = path.join(PUBLIC_DIR, '404.html');
      if (!fs.existsSync(filePath)) {
        res.writeHead(404, { ...headers, 'Content-Type': MIME_TYPES['.txt'] });
        res.end('Not Found');
        return;
      }
      headers['Content-Type'] = MIME_TYPES['.html'];
    }

    const extension = path.extname(filePath);
    if (!headers['Content-Type']) {
      headers['Content-Type'] = MIME_TYPES[extension] ?? 'application/octet-stream';
    }

    const body = fs.readFileSync(filePath);
    res.writeHead(statusCode, { ...headers, 'Content-Length': body.length });
    res.end(req.method === 'HEAD' ? undefined : body);
  });
}

/* ------------------------------- assertions ------------------------------- */

class CheckRunner {
  constructor() {
    this.failures = [];
    this.passed = 0;
  }

  check(label, condition, detail = '') {
    if (condition) {
      this.passed += 1;
      return;
    }
    this.failures.push(detail ? `${label} [${detail}]` : label);
  }
}

export function assertVercelConfig(runner) {
  const config = readVercelConfig();
  const sources = [
    ...(config.headers ?? []).map((rule) => rule.source),
    ...(config.rewrites ?? []).map((rule) => rule.source),
  ];

  for (const source of sources) {
    runner.check(
      `vercel.json source "${source}" uses only literal or catch-all syntax`,
      source === '/(.*)' || !/[:*?()[\]]/.test(source),
    );
  }

  const globalHeaders = (config.headers ?? []).find((rule) => rule.source === '/(.*)');
  runner.check('vercel.json declares a site-wide header rule', Boolean(globalHeaders));

  const headerMap = new Map((globalHeaders?.headers ?? []).map((h) => [h.key, h.value]));
  const hsts = headerMap.get('Strict-Transport-Security') ?? '';

  runner.check(
    'HSTS is enabled for at least one year',
    /max-age=(\d+)/.test(hsts) && Number(/max-age=(\d+)/.exec(hsts)[1]) >= 31536000,
    `got ${hsts}`,
  );
  runner.check(
    'X-Content-Type-Options is nosniff',
    headerMap.get('X-Content-Type-Options') === 'nosniff',
  );
  runner.check(
    'Referrer-Policy is set to a non-leaking value',
    ['no-referrer', 'same-origin', 'strict-origin', 'strict-origin-when-cross-origin'].includes(
      headerMap.get('Referrer-Policy') ?? '',
    ),
    `got ${headerMap.get('Referrer-Policy')}`,
  );
  runner.check('X-Frame-Options denies framing', headerMap.get('X-Frame-Options') === 'DENY');

  const csp = headerMap.get('Content-Security-Policy') ?? '';
  runner.check('CSP is present', csp.length > 0);
  runner.check("CSP default-src is 'none'", /default-src 'none'/.test(csp), csp);
  runner.check("CSP frame-ancestors is 'none'", /frame-ancestors 'none'/.test(csp), csp);
  runner.check("CSP forbids script execution", /script-src 'none'/.test(csp), csp);
  runner.check("CSP permits same-origin metadata fetches", /connect-src 'self'/.test(csp), csp);
  runner.check(
    "CSP style-src is self-only (no 'unsafe-inline')",
    /style-src 'self'/.test(csp) && !/style-src[^;]*unsafe-inline/.test(csp),
    csp,
  );
  runner.check("CSP base-uri is 'none'", /base-uri 'none'/.test(csp), csp);
  runner.check("CSP form-action is 'none'", /form-action 'none'/.test(csp), csp);

  const wellKnownRules = (config.headers ?? []).filter((rule) =>
    rule.source.startsWith('/.well-known/'),
  );
  runner.check('.well-known files keep an explicit JSON content type', wellKnownRules.length === 2);
  for (const rule of wellKnownRules) {
    const value = rule.headers.find((h) => h.key === 'Content-Type')?.value ?? '';
    runner.check(`${rule.source} serves application/json`, value.startsWith('application/json'));
  }

  const rewriteMap = new Map((config.rewrites ?? []).map((rule) => [rule.source, rule.destination]));
  for (const route of ['/privacy', '/terms', '/support', '/delete-account']) {
    runner.check(
      `vercel.json rewrites ${route}`,
      rewriteMap.get(route) === `${route}.html`,
      `got ${rewriteMap.get(route)}`,
    );
  }
  for (const route of NATIVE_LANDING_ROUTES) {
    runner.check(
      `vercel.json routes ${route} to the open-in-app landing page`,
      rewriteMap.get(route) === '/open-in-app.html',
      `got ${rewriteMap.get(route)}`,
    );
  }

  // A path claimed by AASA / Android intent filters is still opened in a browser whenever the
  // app is not installed. Without a rewrite it would answer 404, so every claimed deep link
  // must have a web fallback.
  for (const deepLinkPath of DEEP_LINK_PATHS) {
    runner.check(
      `deep-linked ${deepLinkPath} has a web fallback instead of a 404`,
      rewriteMap.has(deepLinkPath),
      `no rewrite for ${deepLinkPath}`,
    );
  }
}

export function assertPublicAssets(runner) {
  const requiredFiles = [
    'index.html',
    'privacy.html',
    'terms.html',
    'support.html',
    'delete-account.html',
    'open-in-app.html',
    '404.html',
    'favicon.ico',
    'favicon.svg',
    'robots.txt',
    'assets/site.css',
    '.well-known/apple-app-site-association',
    '.well-known/assetlinks.json',
  ];

  for (const file of requiredFiles) {
    runner.check(`public/${file} exists`, fs.existsSync(path.join(PUBLIC_DIR, file)));
  }

  const robots = path.join(PUBLIC_DIR, 'robots.txt');
  if (fs.existsSync(robots)) {
    const contents = fs.readFileSync(robots, 'utf8');
    runner.check('robots.txt declares a wildcard user agent', /^User-agent:\s*\*$/im.test(contents));
    runner.check('robots.txt permits public crawling', /^Allow:\s*\/$/im.test(contents));
  }

  const favicon = path.join(PUBLIC_DIR, 'favicon.ico');
  if (fs.existsSync(favicon)) {
    const buffer = fs.readFileSync(favicon);
    runner.check(
      'favicon.ico has a valid ICO header',
      buffer.length > 22 && buffer.readUInt16LE(0) === 0 && buffer.readUInt16LE(2) === 1,
    );
    runner.check('favicon.ico is non-empty', buffer.length > 100, `${buffer.length} bytes`);
  }

  const htmlFiles = fs
    .readdirSync(PUBLIC_DIR)
    .filter((name) => name.endsWith('.html'))
    .map((name) => path.join(PUBLIC_DIR, name));

  runner.check('public/ exposes every expected HTML page', htmlFiles.length === 7, `${htmlFiles.length} pages`);

  for (const file of htmlFiles) {
    const html = fs.readFileSync(file, 'utf8');
    const name = path.basename(file);

    runner.check(`${name} declares a doctype`, /^<!doctype html>/i.test(html.trim()));
    runner.check(`${name} declares lang="ko"`, /<html lang="ko">/.test(html));
    runner.check(`${name} has a non-empty title`, /<title>[^<]+<\/title>/.test(html));
    runner.check(`${name} has a meta description`, /<meta\s+name="description"/.test(html));
    runner.check(`${name} has exactly one main landmark`, (html.match(/<main[\s>]/g) ?? []).length === 1);
    runner.check(`${name} has exactly one h1`, (html.match(/<h1[\s>]/g) ?? []).length === 1);
    runner.check(`${name} references the shared stylesheet`, html.includes('/assets/site.css'));
    runner.check(`${name} references /favicon.ico`, html.includes('/favicon.ico'));
    runner.check(`${name} has no inline style block`, !/<style[\s>]/.test(html));
    runner.check(`${name} has no style attribute`, !/\sstyle="/.test(html));
    runner.check(`${name} has no inline script`, !/<script[\s>]/.test(html));
    runner.check(`${name} does not reference ${DEAD_MAIL_DOMAIN}`, !html.includes(DEAD_MAIL_DOMAIN));
    runner.check(`${name} has a skip link to #main`, html.includes('href="#main"'));

    for (const tag of ['html', 'head', 'body', 'main', 'section', 'ul', 'li', 'p', 'h1', 'h2', 'a']) {
      const opened = (html.match(new RegExp(`<${tag}(?:\\s[^>]*)?>`, 'g')) ?? []).length;
      const closed = (html.match(new RegExp(`</${tag}>`, 'g')) ?? []).length;
      runner.check(
        `${name} balances <${tag}> tags`,
        opened === closed,
        `${opened} open / ${closed} close`,
      );
    }
  }

  for (const name of ['support.html', 'delete-account.html']) {
    const file = path.join(PUBLIC_DIR, name);
    if (!fs.existsSync(file)) continue;
    runner.check(
      `${name} publishes the canonical support address`,
      fs.readFileSync(file, 'utf8').includes(SUPPORT_EMAIL),
    );
  }

  const privacy = path.join(PUBLIC_DIR, 'privacy.html');
  if (fs.existsSync(privacy)) {
    const html = fs.readFileSync(privacy, 'utf8');
    runner.check('privacy.html drops the stale Firebase claim', !/Firebase/i.test(html));
    runner.check('privacy.html drops the stale location-collection claim', !html.includes('위치 정보'));
    runner.check('privacy.html does not claim an unused Mixpanel integration', !/Mixpanel/i.test(html));
    runner.check('privacy.html discloses Supabase', html.includes('Supabase'));
    runner.check('privacy.html discloses Sentry', html.includes('Sentry'));
  }
}

export function assertWellKnown(runner) {
  const aasaPath = path.join(PUBLIC_DIR, '.well-known', 'apple-app-site-association');
  const assetLinksPath = path.join(PUBLIC_DIR, '.well-known', 'assetlinks.json');

  const aasa = JSON.parse(fs.readFileSync(aasaPath, 'utf8'));
  runner.check(
    'AASA keeps the existing app identifier',
    aasa.applinks.details[0].appIDs.includes('5F7CN7Y54D.com.beyond.fortune'),
  );
  runner.check(
    'AASA keeps the existing webcredentials entry',
    aasa.webcredentials.apps.includes('5F7CN7Y54D.com.beyond.fortune'),
  );

  const claimedPaths = aasa.applinks.details[0].components.map((component) => component['/']);
  for (const deepLinkPath of DEEP_LINK_PATHS) {
    runner.check(`AASA claims ${deepLinkPath}`, claimedPaths.includes(deepLinkPath));
  }
  for (const webOnlyPath of ['/privacy', '/terms', '/support', '/delete-account']) {
    runner.check(
      `AASA leaves the web-only route ${webOnlyPath} to the browser`,
      !claimedPaths.includes(webOnlyPath) && !claimedPaths.includes('/*'),
    );
  }

  const assetLinks = JSON.parse(fs.readFileSync(assetLinksPath, 'utf8'));
  runner.check(
    'assetlinks.json keeps the existing Android package',
    assetLinks[0].target.package_name === 'com.beyond.fortune',
  );
  runner.check(
    'assetlinks.json keeps the existing signing fingerprint',
    assetLinks[0].target.sha256_cert_fingerprints.length === 1,
  );
}

export function assertExpoDeepLinkConfig(runner) {
  const config = readAppConfig();

  runner.check('Expo config keeps the custom scheme', config.scheme === 'com.beyond.fortune');
  runner.check(
    'Expo config keeps the iOS bundle identifier',
    config.ios.bundleIdentifier === 'com.beyond.fortune',
  );
  runner.check('Expo config keeps the Android package', config.android.package === 'com.beyond.fortune');
  runner.check('Expo config keeps the Android custom scheme', config.android.scheme === 'com.beyond.fortune');

  const associatedDomains = config.ios.associatedDomains ?? [];
  runner.check(
    'iOS declares the applinks associated domain',
    associatedDomains.includes(`applinks:${WEB_DOMAIN}`),
    JSON.stringify(associatedDomains),
  );
  runner.check(
    'iOS declares no unrelated associated domain',
    associatedDomains.every((entry) => entry.endsWith(`:${WEB_DOMAIN}`)),
    JSON.stringify(associatedDomains),
  );

  const intentFilters = config.android.intentFilters ?? [];
  const httpsFilter = intentFilters.find((filter) =>
    (filter.data ?? []).some((entry) => entry.scheme === 'https' && entry.host === WEB_DOMAIN),
  );
  runner.check('Android declares an HTTPS intent filter for the web domain', Boolean(httpsFilter));

  if (httpsFilter) {
    runner.check('Android HTTPS intent filter is autoVerify', httpsFilter.autoVerify === true);
    runner.check('Android HTTPS intent filter uses action VIEW', httpsFilter.action === 'VIEW');
    runner.check(
      'Android HTTPS intent filter is browsable',
      (httpsFilter.category ?? []).includes('BROWSABLE') &&
        (httpsFilter.category ?? []).includes('DEFAULT'),
    );
    runner.check(
      'Android HTTPS intent filter targets only the web domain',
      (httpsFilter.data ?? []).every((entry) => entry.host === WEB_DOMAIN && entry.scheme === 'https'),
    );

    const prefixes = (httpsFilter.data ?? []).map((entry) => entry.pathPrefix);
    for (const deepLinkPath of DEEP_LINK_PATHS) {
      runner.check(`Android claims ${deepLinkPath}`, prefixes.includes(deepLinkPath));
    }
    for (const webOnlyPath of ['/privacy', '/terms', '/support', '/delete-account', '/']) {
      runner.check(
        `Android leaves the web-only route ${webOnlyPath} to the browser`,
        !prefixes.includes(webOnlyPath),
      );
    }
  }
}

async function runValidation() {
  const runner = new CheckRunner();

  assertVercelConfig(runner);
  assertPublicAssets(runner);
  assertWellKnown(runner);
  assertExpoDeepLinkConfig(runner);

  if (runner.failures.length > 0) {
    console.error(`FAIL ${runner.failures.length} check(s), PASS ${runner.passed} check(s)`);
    for (const failure of runner.failures) console.error(`  FAIL: ${failure}`);
    process.exitCode = 1;
    return;
  }

  console.log(`PASS ${runner.passed} check(s)`);
}

const isDirectRun =
  process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);

if (isDirectRun) {
  if (process.argv.includes('--serve')) {
    const portArgument = process.argv.indexOf('--port');
    const port = portArgument >= 0 ? Number(process.argv[portArgument + 1]) : 0;
    const server = createVercelSemanticsServer();
    server.listen(port, '127.0.0.1', () => {
      console.log(`ONDO_WEB_SERVER_READY http://127.0.0.1:${server.address().port}`);
    });
  } else {
    await runValidation();
  }
}
