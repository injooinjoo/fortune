#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');

const repoRoot = path.resolve(__dirname, '../..');
const reportDir = path.join(repoRoot, 'artifacts/design/figma_sync');
const reportJsonPath = path.join(reportDir, 'report.json');
const reportMdPath = path.join(reportDir, 'report.md');

const manifestModule = require(path.join(
  repoRoot,
  'playwright/scripts/figma_capture_manifest.js'
));

const {
  COMPONENT_CARDS,
  SCREENS,
  getPlaceholderTriageCounts,
  getStatusCounts,
} = manifestModule;

const manifestPath = 'playwright/scripts/figma_capture_manifest.js';
const sourceDocPath = 'docs/design/FIGMA_SOURCE_OF_TRUTH.md';
const registryDocPath = 'docs/design/FIGMA_SCREEN_COMPONENT_REGISTRY.md';
const readmeDocPath = 'docs/design/README.md';
const changelogPath = 'docs/design/FIGMA_SYNC_CHANGELOG.md';

const knownTriage = new Set([
  'capture_next_auth',
  'capture_next_runtime',
  'capture_next_seed_data',
  'capture_next_state_extra',
]);

const routeFilePatterns = [/^lib\/routes\/.+\.dart$/];
const uiFilePatterns = [
  /^lib\/features\/.+\/presentation\/.+\.dart$/,
  /^lib\/screens\/.+\.dart$/,
  /^lib\/shared\/.+\.dart$/,
  /^lib\/core\/design_system\/components\/.+\.dart$/,
];
const ignoredDiffPrefixes = ['artifacts/design/figma_sync/'];

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

function filterIgnoredFiles(files) {
  return files.filter(
    (file) => !ignoredDiffPrefixes.some((prefix) => file.startsWith(prefix))
  );
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
      // Ignore malformed event payloads and continue with git-based fallbacks.
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
        files: filterIgnoredFiles(unique([...rangeFiles, ...workingTreeFiles])),
      };
    }
  }

  return {
    mode: 'working-tree',
    range: 'HEAD',
    files: filterIgnoredFiles(workingTreeFiles),
  };
}

function matchesAny(filePath, patterns) {
  return patterns.some((pattern) => pattern.test(filePath));
}

function extractDocsCounts() {
  const sourceDoc = readText(sourceDocPath);
  const readmeDoc = readText(readmeDocPath);
  const registryDoc = readText(registryDocPath);

  const sourceCounts = {
    total: Number(sourceDoc.match(/Managed surfaces: `(\d+)`/)?.[1] || NaN),
    live: Number(sourceDoc.match(/Live captures: `(\d+)`/)?.[1] || NaN),
    placeholder: Number(sourceDoc.match(/Placeholder specs: `(\d+)`/)?.[1] || NaN),
  };

  const readmeMatch = readmeDoc.match(
    /active route surface `(\d+)`개, live `(\d+)`, placeholder `(\d+)`/
  );
  const readmeCounts = {
    total: Number(readmeMatch?.[1] || NaN),
    live: Number(readmeMatch?.[2] || NaN),
    placeholder: Number(readmeMatch?.[3] || NaN),
  };

  const registryTriageCounts = {};
  const triageRegex = /\|\s*`([^`]+)`\s*\|\s*(\d+)\s*\|/g;
  for (const match of registryDoc.matchAll(triageRegex)) {
    if (knownTriage.has(match[1])) {
      registryTriageCounts[match[1]] = Number(match[2]);
    }
  }

  return {
    sourceCounts,
    readmeCounts,
    registryTriageCounts,
  };
}

function getTrackedSourcesIndex() {
  const screenIndex = new Map();
  const componentIndex = new Map();

  for (const screen of SCREENS) {
    for (const source of screen.sources || []) {
      if (!screenIndex.has(source)) {
        screenIndex.set(source, []);
      }
      screenIndex.get(source).push(screen.frameName);
    }
  }

  for (const component of COMPONENT_CARDS) {
    for (const source of component.sources || []) {
      if (!componentIndex.has(source)) {
        componentIndex.set(source, []);
      }
      componentIndex.get(source).push(component.title);
    }
  }

  return {
    screenIndex,
    componentIndex,
  };
}

function buildReport() {
  const errors = [];
  const warnings = [];
  const changed = resolveChangedFiles();
  const changedFiles = changed.files;
  const changedSet = new Set(changedFiles);

  const routeChangedFiles = changedFiles.filter((file) =>
    matchesAny(file, routeFilePatterns)
  );
  const uiChangedFiles = changedFiles.filter((file) =>
    matchesAny(file, uiFilePatterns)
  );
  const designChangedFiles = changedFiles.filter((file) =>
    [
      manifestPath,
      sourceDocPath,
      registryDocPath,
      readmeDocPath,
      changelogPath,
    ].includes(file)
  );

  const statusCounts = getStatusCounts();
  const triageCounts = getPlaceholderTriageCounts();
  const docsCounts = extractDocsCounts();
  const { screenIndex, componentIndex } = getTrackedSourcesIndex();

  const screenIds = new Set();
  const frameNames = new Set();
  for (const screen of SCREENS) {
    if (screenIds.has(screen.id)) {
      errors.push(`Duplicate screen id: ${screen.id}`);
    }
    screenIds.add(screen.id);

    if (frameNames.has(screen.frameName)) {
      errors.push(`Duplicate frame name: ${screen.frameName}`);
    }
    frameNames.add(screen.frameName);

    if (!Array.isArray(screen.sources) || screen.sources.length === 0) {
      errors.push(`Screen missing sources: ${screen.frameName}`);
    }

    if (screen.status === 'live' && !screen.routeHash) {
      errors.push(`Live screen missing routeHash: ${screen.frameName}`);
    }

    if (screen.status === 'placeholder') {
      if (!screen.blocker) {
        errors.push(`Placeholder missing blocker: ${screen.frameName}`);
      }
      if (!screen.triage) {
        errors.push(`Placeholder missing triage: ${screen.frameName}`);
      } else if (!knownTriage.has(screen.triage)) {
        errors.push(
          `Placeholder has unknown triage "${screen.triage}": ${screen.frameName}`
        );
      }
    }
  }

  const manifestTotal = (statusCounts.live || 0) + (statusCounts.placeholder || 0);
  if (docsCounts.sourceCounts.total !== manifestTotal) {
    errors.push(
      `FIGMA_SOURCE_OF_TRUTH total count mismatch: doc=${docsCounts.sourceCounts.total}, manifest=${manifestTotal}`
    );
  }
  if (docsCounts.sourceCounts.live !== (statusCounts.live || 0)) {
    errors.push(
      `FIGMA_SOURCE_OF_TRUTH live count mismatch: doc=${docsCounts.sourceCounts.live}, manifest=${statusCounts.live || 0}`
    );
  }
  if (docsCounts.sourceCounts.placeholder !== (statusCounts.placeholder || 0)) {
    errors.push(
      `FIGMA_SOURCE_OF_TRUTH placeholder count mismatch: doc=${docsCounts.sourceCounts.placeholder}, manifest=${statusCounts.placeholder || 0}`
    );
  }

  if (docsCounts.readmeCounts.total !== manifestTotal) {
    errors.push(
      `docs/design/README.md total count mismatch: doc=${docsCounts.readmeCounts.total}, manifest=${manifestTotal}`
    );
  }
  if (docsCounts.readmeCounts.live !== (statusCounts.live || 0)) {
    errors.push(
      `docs/design/README.md live count mismatch: doc=${docsCounts.readmeCounts.live}, manifest=${statusCounts.live || 0}`
    );
  }
  if (docsCounts.readmeCounts.placeholder !== (statusCounts.placeholder || 0)) {
    errors.push(
      `docs/design/README.md placeholder count mismatch: doc=${docsCounts.readmeCounts.placeholder}, manifest=${statusCounts.placeholder || 0}`
    );
  }

  for (const [triageKey, triageCount] of Object.entries(triageCounts)) {
    const docCount = docsCounts.registryTriageCounts[triageKey];
    if (docCount !== triageCount) {
      errors.push(
        `FIGMA_SCREEN_COMPONENT_REGISTRY triage mismatch for ${triageKey}: doc=${docCount}, manifest=${triageCount}`
      );
    }
  }

  const affectedScreens = unique(
    uiChangedFiles.flatMap((file) => screenIndex.get(file) || [])
  );
  const affectedComponents = unique(
    uiChangedFiles.flatMap((file) => componentIndex.get(file) || [])
  );

  const untrackedUiFiles = uiChangedFiles.filter(
    (file) => !screenIndex.has(file) && !componentIndex.has(file)
  );

  if (routeChangedFiles.length > 0) {
    for (const requiredFile of [manifestPath, sourceDocPath, registryDocPath, changelogPath]) {
      if (!changedSet.has(requiredFile)) {
        errors.push(
          `Route changes detected but ${requiredFile} was not updated.`
        );
      }
    }
  }

  if (uiChangedFiles.length > 0 && !changedSet.has(changelogPath)) {
    errors.push(
      `UI changes detected but ${changelogPath} was not updated with the Figma sync record.`
    );
  }

  if (untrackedUiFiles.length > 0) {
    errors.push(
      `Design-tracked source coverage is missing for: ${untrackedUiFiles.join(', ')}`
    );
  }

  if (
    changedSet.has(manifestPath) &&
    (!changedSet.has(sourceDocPath) || !changedSet.has(registryDocPath))
  ) {
    errors.push(
      `Manifest changed without syncing ${sourceDocPath} and ${registryDocPath}.`
    );
  }

  if (uiChangedFiles.length > 0 && affectedScreens.length === 0 && affectedComponents.length === 0) {
    warnings.push(
      'UI files changed but no affected screens/components were resolved. Review source mapping coverage.'
    );
  }

  return {
    generatedAt: new Date().toISOString(),
    diffMode: changed.mode,
    diffRange: changed.range,
    changedFiles,
    routeChangedFiles,
    uiChangedFiles,
    designChangedFiles,
    affectedScreens,
    affectedComponents,
    untrackedUiFiles,
    counts: {
      total: manifestTotal,
      ...statusCounts,
    },
    triageCounts,
    docsCounts,
    errors,
    warnings,
    success: errors.length === 0,
  };
}

function toMarkdown(report) {
  const lines = [
    '# Figma Sync Guard',
    '',
    `- Status: ${report.success ? 'PASS' : 'FAIL'}`,
    `- Diff mode: ${report.diffMode}`,
    `- Diff range: ${report.diffRange}`,
    `- Changed files: ${report.changedFiles.length}`,
    `- Route files changed: ${report.routeChangedFiles.length}`,
    `- UI files changed: ${report.uiChangedFiles.length}`,
    `- Design files changed: ${report.designChangedFiles.length}`,
    '',
    '## Coverage Snapshot',
    '',
    `- Managed surfaces: ${report.counts.total}`,
    `- Live: ${report.counts.live || 0}`,
    `- Placeholder: ${report.counts.placeholder || 0}`,
    '',
    '## Placeholder Triage',
    '',
  ];

  for (const [key, value] of Object.entries(report.triageCounts)) {
    lines.push(`- ${key}: ${value}`);
  }

  if (report.affectedScreens.length > 0) {
    lines.push('', '## Affected Screens', '');
    for (const screen of report.affectedScreens) {
      lines.push(`- ${screen}`);
    }
  }

  if (report.affectedComponents.length > 0) {
    lines.push('', '## Affected Components', '');
    for (const component of report.affectedComponents) {
      lines.push(`- ${component}`);
    }
  }

  if (report.errors.length > 0) {
    lines.push('', '## Errors', '');
    for (const error of report.errors) {
      lines.push(`- ${error}`);
    }
  }

  if (report.warnings.length > 0) {
    lines.push('', '## Warnings', '');
    for (const warning of report.warnings) {
      lines.push(`- ${warning}`);
    }
  }

  if (report.changedFiles.length > 0) {
    lines.push('', '## Changed Files', '');
    for (const file of report.changedFiles) {
      lines.push(`- ${file}`);
    }
  }

  return `${lines.join('\n')}\n`;
}

function writeReport(report) {
  ensureDir(reportDir);
  fs.writeFileSync(reportJsonPath, `${JSON.stringify(report, null, 2)}\n`);

  const markdown = toMarkdown(report);
  fs.writeFileSync(reportMdPath, markdown);

  if (process.env.GITHUB_STEP_SUMMARY) {
    fs.appendFileSync(process.env.GITHUB_STEP_SUMMARY, `${markdown}\n`);
  }
}

function main() {
  const report = buildReport();
  writeReport(report);

  process.stdout.write(toMarkdown(report));

  if (!report.success) {
    process.exitCode = 1;
  }
}

main();
