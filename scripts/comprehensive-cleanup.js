#!/usr/bin/env node

/**
 * Comprehensive code cleanup script
 * Removes console.log, alert(), and resolves TODO comments
 */

const fs = require('fs').promises;
const path = require('path');
const { exec } = require('child_process');
const { promisify } = require('util');

const execAsync = promisify(exec);

// Color codes
const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
};

// Patterns to search for
const patterns = {
  console: /console\.(log|error|warn|info|debug)\(/g,
  alert: /\balert\s*\(/g,
  todo: /\/\/\s*TODO[:\s](.+)|\/\*\s*TODO[:\s](.+?)\*\//gi,
};

// Directories to ignore
const ignoreDirs = [
  'node_modules',
  '.next',
  'dist',
  'build',
  '.git',
  'coverage',
  '.vercel',
  'scripts', // Don't modify this script itself
];

// Files to ignore
const ignoreFiles = [
  'logger.ts', // Logger service legitimately uses console
  'code-cleanup-report.json',
  '*.min.js',
  '*.map',
  '*.lock',
  '*.log',
];

async function findFiles() {
  const ignorePattern = ignoreDirs.map(dir => `-path "./${dir}" -prune -o`).join(' ');
  const command = `find . ${ignorePattern} -type f \\( -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" \\) -print`;
  
  try {
    const { stdout } = await execAsync(command);
    const files = stdout.trim().split('\n').filter(f => f && f !== '.');
    
    return files.filter(file => {
      const basename = path.basename(file);
      // Skip ignored files
      if (ignoreFiles.includes(basename)) return false;
      if (ignoreFiles.some(pattern => {
        if (pattern.startsWith('*')) {
          return basename.endsWith(pattern.slice(1));
        }
        return basename === pattern;
      })) return false;
      
      return true;
    });
  } catch (error) {
    console.error('File search failed:', error);
    return [];
  }
}

async function processFile(filePath, fix = false) {
  try {
    const content = await fs.readFile(filePath, 'utf-8');
    const lines = content.split('\n');
    const issues = [];
    let modified = false;
    let modifiedContent = content;

    // Find issues
    lines.forEach((line, index) => {
      const lineNumber = index + 1;

      // Check for console statements
      if (patterns.console.test(line)) {
        issues.push({
          type: 'console',
          file: filePath,
          line: lineNumber,
          content: line.trim(),
          severity: 'warning',
        });
      }

      // Check for alerts
      if (patterns.alert.test(line)) {
        issues.push({
          type: 'alert',
          file: filePath,
          line: lineNumber,
          content: line.trim(),
          severity: 'error',
        });
      }

      // Check for TODO comments
      if (patterns.todo.test(line)) {
        issues.push({
          type: 'TODO',
          file: filePath,
          line: lineNumber,
          content: line.trim(),
          severity: 'info',
        });
      }
    });

    // Apply fixes if requested
    if (fix && issues.length > 0) {
      // Remove console statements (comment them out)
      modifiedContent = modifiedContent.replace(
        /^(\s*)(console\.(log|error|warn|info|debug)\(.*\);?)\s*$/gm,
        '$1// $2 // REMOVED BY CLEANUP SCRIPT'
      );

      // Replace alerts with TODO comments
      modifiedContent = modifiedContent.replace(
        /\balert\s*\((.*?)\)/g,
        '// TODO: Replace with UI notification - alert($1)'
      );

      if (modifiedContent !== content) {
        await fs.writeFile(filePath, modifiedContent, 'utf-8');
        modified = true;
      }
    }

    return { issues, modified };
  } catch (error) {
    console.error(`Error processing ${filePath}:`, error);
    return { issues: [], modified: false };
  }
}

async function main(fix = false) {
  console.log(`${colors.cyan}🔍 Comprehensive code cleanup scan starting...${colors.reset}\n`);

  try {
    const files = await findFiles();
    console.log(`${colors.blue}📂 Files to scan: ${files.length}${colors.reset}\n`);

    const allIssues = [];
    let modifiedFiles = 0;
    let processedCount = 0;

    for (const file of files) {
      const { issues, modified } = await processFile(file, fix);
      allIssues.push(...issues);
      if (modified) modifiedFiles++;
      processedCount++;

      // Show progress
      if (processedCount % 50 === 0) {
        process.stdout.write(`\rProcessing... ${processedCount}/${files.length}`);
      }
    }

    process.stdout.write(`\r${colors.green}✅ Scan complete!${colors.reset}        \n\n`);

    // Analyze results
    const issuesByType = {};
    allIssues.forEach(issue => {
      if (!issuesByType[issue.type]) {
        issuesByType[issue.type] = [];
      }
      issuesByType[issue.type].push(issue);
    });

    // Output summary
    console.log(`${colors.cyan}📊 Issues found:${colors.reset}`);
    console.log('─'.repeat(50));

    Object.entries(issuesByType).forEach(([type, issues]) => {
      const color = issues[0].severity === 'error' ? colors.red :
                   issues[0].severity === 'warning' ? colors.yellow :
                   colors.blue;
      console.log(`${color}${type}: ${issues.length}${colors.reset}`);
    });

    console.log('─'.repeat(50));
    console.log(`Total issues: ${allIssues.length}\n`);

    if (fix) {
      console.log(`${colors.green}✅ Modified ${modifiedFiles} files${colors.reset}\n`);
    }

    // Save detailed report
    const report = {
      scanDate: new Date().toISOString(),
      totalFiles: files.length,
      totalIssues: allIssues.length,
      modifiedFiles: fix ? modifiedFiles : 0,
      issuesByType: Object.fromEntries(
        Object.entries(issuesByType).map(([type, issues]) => [
          type,
          {
            count: issues.length,
            files: [...new Set(issues.map(i => i.file))].length,
          }
        ])
      ),
      details: allIssues.slice(0, 100), // Limit details to first 100 to avoid huge files
    };

    await fs.writeFile(
      'comprehensive-cleanup-report.json',
      JSON.stringify(report, null, 2)
    );

    console.log(`${colors.blue}📄 Detailed report saved to comprehensive-cleanup-report.json${colors.reset}`);

    // Show sample issues
    if (!fix && allIssues.length > 0) {
      console.log(`\n${colors.cyan}📋 Sample issues:${colors.reset}\n`);
      
      ['console', 'alert', 'TODO'].forEach(type => {
        const typeIssues = issuesByType[type] || [];
        if (typeIssues.length > 0) {
          console.log(`${colors.magenta}${type} (showing first 3):${colors.reset}`);
          typeIssues.slice(0, 3).forEach(issue => {
            console.log(`  ${issue.file}:${issue.line}`);
            console.log(`    ${colors.gray}${issue.content}${colors.reset}`);
          });
          console.log('');
        }
      });

      console.log(`${colors.yellow}💡 To fix these issues automatically, run:${colors.reset}`);
      console.log(`${colors.green}   node scripts/comprehensive-cleanup.js --fix${colors.reset}\n`);
    }

  } catch (error) {
    console.error(`${colors.red}❌ Error:${colors.reset}`, error);
    process.exit(1);
  }
}

// Main execution
if (require.main === module) {
  const args = process.argv.slice(2);
  const fix = args.includes('--fix');
  main(fix);
}

module.exports = { main };