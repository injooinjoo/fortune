#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');

const repoRoot = path.resolve(__dirname, '../..');
const reportDir = path.join(repoRoot, 'artifacts/design/paper_sync');
const reportJsonPath = path.join(reportDir, 'report.json');
const reportMdPath = path.join(reportDir, 'report.md');

const inventoryPath = 'paper/catalog_inventory.json';
const tokensPath = 'paper/design-tokens.json';
const paperReadmePath = 'paper/README.md';
const sourceDocPath = 'docs/design/PAPER_SOURCE_OF_TRUTH.md';
const mappingDocPath = 'docs/design/PAPER_SCREEN_ROUTE_MAPPING.md';
const registryDocPath = 'docs/design/PAPER_SCREEN_COMPONENT_REGISTRY.md';
const changelogPath = 'docs/design/PAPER_SYNC_CHANGELOG.md';
const designReadmePath = 'docs/design/README.md';
const rootReadmePath = 'README.md';
const workflowPath = '.github/workflows/ci.yml';
const packageJsonPath = 'package.json';
const mcpConfigPath = '.mcp.json';

const contractFiles = [
  inventoryPath,
  tokensPath,
  paperReadmePath,
  sourceDocPath,
  mappingDocPath,
  registryDocPath,
  changelogPath,
  designReadmePath,
  rootReadmePath,
  workflowPath,
  packageJsonPath,
  mcpConfigPath,
];

const strictContractFiles = [
  paperReadmePath,
  sourceDocPath,
  mappingDocPath,
  registryDocPath,
  changelogPath,
  designReadmePath,
  rootReadmePath,
  workflowPath,
  packageJsonPath,
  mcpConfigPath,
  'docs/README.md',
  'docs/testing/TESTING_GUIDE.md',
  'docs/development/MCP_SETUP_GUIDE.md',
];

const routeFilePatterns = [/^lib\/routes\/.+\.dart$/];
const uiFilePatterns = [
  /^lib\/features\/.+\/presentation\/.+\.dart$/,
  /^lib\/screens\/.+\.dart$/,
  /^lib\/shared\/.+\.dart$/,
  /^lib\/core\/design_system\/components\/.+\.dart$/,
  /^lib\/core\/widgets\/paper_runtime_.+\.dart$/,
];
const designContractPatterns = [
  /^paper\/.+/,
  /^docs\/design\/PAPER_.+\.md$/,
  /^docs\/design\/README\.md$/,
  /^package\.json$/,
  /^\.github\/workflows\/ci\.yml$/,
  /^\.mcp\.json$/,
];

function ensureDir(dirPath) {
  fs.mkdirSync(dirPath, { recursive: true });
}

function readText(relativePath) {
  return fs.readFileSync(path.join(repoRoot, relativePath), 'utf8');
}

function normalizePath(filePath) {
  return filePath.replace(/\\/g, '/');
}

function git(args) {
  return execFileSync('git', args, {
    cwd: repoRoot,
    encoding: 'utf8',
    stdio: ['ignore', 'pipe', 'pipe'],
  }).trim();
}

function gitSafe(args) {
  try {
    return git(args);
  } catch (error) {
    return null;
  }
}

function parseGitLines(output) {
  return (output || '')
    .split('\n')
    .map((line) => line.trim())
    .filter(Boolean)
    .map(normalizePath);
}

function unique(values) {
  return [...new Set(values)];
}

function getCandidateDiffRanges() {
  const ranges = [];
  const eventPath = process.env.GITHUB_EVENT_PATH;

  if (eventPath && fs.existsSync(eventPath)) {
    try {
      const event = JSON.parse(fs.readFileSync(eventPath, 'utf8'));
      if (event.pull_request?.base?.sha && event.pull_request?.head?.sha) {
        ranges.push(`${event.pull_request.base.sha}...${event.pull_request.head.sha}`);
      }
      if (event.before && event.after && !/^0+$/.test(event.before)) {
        ranges.push(`${event.before}...${event.after}`);
      }
    } catch (error) {
      // Ignore malformed event payloads.
    }
  }

  if (process.env.GITHUB_BASE_REF) {
    ranges.push(`origin/${process.env.GITHUB_BASE_REF}...HEAD`);
  }

  ranges.push('HEAD~1..HEAD');
  return unique(ranges);
}

function resolveChangedFiles() {
  const workingTreeFiles = unique([
    ...parseGitLines(gitSafe(['diff', '--name-only', 'HEAD'])),
    ...parseGitLines(gitSafe(['diff', '--name-only', '--cached'])),
    ...parseGitLines(gitSafe(['ls-files', '--others', '--exclude-standard'])),
  ]);

  for (const range of getCandidateDiffRanges()) {
    const output = gitSafe(['diff', '--name-only', range]);
    if (output != null) {
      const rangeFiles = parseGitLines(output);
      return {
        mode: workingTreeFiles.length > 0 ? 'git-range+working-tree' : 'git-range',
        range,
        files: unique([...rangeFiles, ...workingTreeFiles]),
      };
    }
  }

  return {
    mode: 'working-tree',
    range: 'HEAD',
    files: workingTreeFiles,
  };
}

function matchesAny(filePath, patterns) {
  return patterns.some((pattern) => pattern.test(filePath));
}

function checkRequiredFiles(errors) {
  for (const relativePath of contractFiles) {
    if (!fs.existsSync(path.join(repoRoot, relativePath))) {
      errors.push(`Missing required Paper contract file: ${relativePath}`);
    }
  }
}

function checkInventory(errors) {
  const inventory = JSON.parse(readText(inventoryPath));
  const requiredSections = [
    '00 Cover & Governance',
    '10 Entry / Auth / Onboarding',
    '20 Chat Home / Character',
    '80 Admin / Policy / Utility',
    '90 Components',
    '99 Archive',
  ];

  if (inventory.counts?.totalArtboards !== inventory.source?.artboardCount) {
    errors.push(
      `paper/catalog_inventory.json totalArtboards mismatch: counts=${inventory.counts?.totalArtboards}, source=${inventory.source?.artboardCount}`
    );
  }

  if (inventory.counts?.mobileSurfaceArtboards !== inventory.mobileSurfaceArtboards?.length) {
    errors.push(
      `paper/catalog_inventory.json mobileSurfaceArtboards mismatch: counts=${inventory.counts?.mobileSurfaceArtboards}, list=${inventory.mobileSurfaceArtboards?.length}`
    );
  }

  if (inventory.counts?.catalogArtboards !== inventory.catalogArtboards?.length) {
    errors.push(
      `paper/catalog_inventory.json catalogArtboards mismatch: counts=${inventory.counts?.catalogArtboards}, list=${inventory.catalogArtboards?.length}`
    );
  }

  for (const section of requiredSections) {
    if (!inventory.canonicalCatalogSections?.includes(section)) {
      errors.push(`paper/catalog_inventory.json missing canonical section: ${section}`);
    }
  }
}

function checkActiveFiles(errors) {
  const legacyDesignPattern = new RegExp(
    String.raw`\\b${'F' + 'igma'}\\b|${'fig' + 'ma'}:`
  );

  for (const relativePath of strictContractFiles) {
    const absolutePath = path.join(repoRoot, relativePath);
    if (!fs.existsSync(absolutePath)) {
      continue;
    }

    const content = fs.readFileSync(absolutePath, 'utf8');
    if (legacyDesignPattern.test(content)) {
      errors.push(
        `Active Paper contract file still references the retired design source: ${relativePath}`
      );
    }
  }
}

function checkRequiredLinks(errors) {
  const designReadme = readText(designReadmePath);
  const rootReadme = readText(rootReadmePath);
  const workflow = readText(workflowPath);
  const packageJson = readText(packageJsonPath);

  for (const requiredLink of [
    'PAPER_SOURCE_OF_TRUTH.md',
    'PAPER_SCREEN_ROUTE_MAPPING.md',
    'PAPER_SCREEN_COMPONENT_REGISTRY.md',
    'PAPER_SYNC_CHANGELOG.md',
  ]) {
    if (!designReadme.includes(requiredLink)) {
      errors.push(`docs/design/README.md must reference ${requiredLink}.`);
    }
  }

  if (!rootReadme.includes('docs/design/PAPER_SOURCE_OF_TRUTH.md')) {
    errors.push('README.md must reference docs/design/PAPER_SOURCE_OF_TRUTH.md.');
  }

  if (!workflow.includes('paper-sync-report')) {
    errors.push('.github/workflows/ci.yml must upload the paper-sync-report artifact.');
  }

  if (!workflow.includes('npm run paper:guard')) {
    errors.push('.github/workflows/ci.yml must run npm run paper:guard.');
  }

  if (!packageJson.includes('"paper:guard"')) {
    errors.push('package.json must declare the paper:guard script.');
  }
}

function checkChangelog(errors, changedFiles) {
  const requiresChangelog = changedFiles.some(
    (filePath) =>
      matchesAny(filePath, routeFilePatterns) ||
      matchesAny(filePath, uiFilePatterns) ||
      matchesAny(filePath, designContractPatterns)
  );

  if (requiresChangelog && !changedFiles.includes(changelogPath)) {
    errors.push(
      `Route/UI/design contract changes detected but ${changelogPath} was not updated.`
    );
  }
}

function writeReport(report) {
  ensureDir(reportDir);
  fs.writeFileSync(reportJsonPath, `${JSON.stringify(report, null, 2)}\n`);

  const lines = [
    '# Paper Sync Guard',
    '',
    `- Status: ${report.ok ? 'pass' : 'fail'}`,
    `- Changed files mode: ${report.changedFiles.mode}`,
    `- Changed files range: ${report.changedFiles.range}`,
    '',
    '## Changed Files',
    '',
  ];

  if (report.changedFiles.files.length === 0) {
    lines.push('- none');
  } else {
    for (const filePath of report.changedFiles.files) {
      lines.push(`- ${filePath}`);
    }
  }

  lines.push('', '## Errors', '');

  if (report.errors.length === 0) {
    lines.push('- none');
  } else {
    for (const error of report.errors) {
      lines.push(`- ${error}`);
    }
  }

  fs.writeFileSync(reportMdPath, `${lines.join('\n')}\n`);
}

function main() {
  const changedFiles = resolveChangedFiles();
  const errors = [];

  checkRequiredFiles(errors);

  if (errors.length === 0) {
    checkInventory(errors);
    checkActiveFiles(errors);
    checkRequiredLinks(errors);
    checkChangelog(errors, changedFiles.files);
  }

  const report = {
    ok: errors.length === 0,
    errors,
    changedFiles,
    checkedAt: new Date().toISOString(),
  };

  writeReport(report);

  if (!report.ok) {
    for (const error of errors) {
      console.error(error);
    }
    process.exit(1);
  }

  console.log('Paper sync guard passed.');
}

main();
