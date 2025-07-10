#!/usr/bin/env node

/**
 * Production code cleanup script
 * Focuses on removing console.log and alert() from production code only
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

// Production directories to scan
const productionDirs = [
  'src',
  'middleware.ts',
  'sentry.client.config.ts',
  'sentry.server.config.ts',
  'sentry.edge.config.ts',
];

// Files to exclude from modifications
const excludeFiles = [
  'logger.ts', // Logger service legitimately uses console
  'db-health-check.ts', // Uses console.group for formatting
];

async function findProductionFiles() {
  const files = [];
  
  for (const dir of productionDirs) {
    if (dir.endsWith('.ts') || dir.endsWith('.tsx')) {
      // It's a file, not a directory
      files.push(dir);
    } else {
      // It's a directory, find all files in it
      try {
        const command = `find ${dir} -type f \\( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \\) -print`;
        const { stdout } = await execAsync(command);
        const dirFiles = stdout.trim().split('\n').filter(f => f);
        files.push(...dirFiles);
      } catch (error) {
        console.error(`Error scanning ${dir}:`, error.message);
      }
    }
  }
  
  return files.filter(file => {
    const basename = path.basename(file);
    return !excludeFiles.includes(basename);
  });
}

async function processFile(filePath, fix = false) {
  try {
    const content = await fs.readFile(filePath, 'utf-8');
    const lines = content.split('\n');
    const issues = [];
    let modifiedLines = [...lines];
    let hasChanges = false;

    lines.forEach((line, index) => {
      const lineNumber = index + 1;
      
      // Check for console statements
      const consoleMatch = line.match(/console\.(log|error|warn|info|debug)\(/);
      if (consoleMatch) {
        issues.push({
          type: 'console',
          method: consoleMatch[1],
          file: filePath,
          line: lineNumber,
          content: line.trim(),
        });
        
        if (fix) {
          // Import logger if not already imported
          const hasLoggerImport = lines.some(l => l.includes("from '@/lib/logger'") || l.includes('from "@/lib/logger"'));
          
          if (!hasLoggerImport && !hasChanges) {
            // Add logger import at the top after other imports
            const lastImportIndex = lines.findIndex((l, i) => {
              return l.includes('import') && !lines[i + 1]?.includes('import');
            });
            if (lastImportIndex !== -1) {
              modifiedLines.splice(lastImportIndex + 1, 0, "import { logger } from '@/lib/logger';");
            }
          }
          
          // Replace console with logger
          modifiedLines[index] = line.replace(
            /console\.(log|error|warn|info|debug)/g,
            (match, method) => {
              const loggerMethod = method === 'log' ? 'info' : method;
              return `logger.${loggerMethod}`;
            }
          );
          hasChanges = true;
        }
      }
      
      // Check for alert statements
      if (line.includes('alert(')) {
        issues.push({
          type: 'alert',
          file: filePath,
          line: lineNumber,
          content: line.trim(),
        });
        
        if (fix) {
          // Comment out alert and add TODO
          modifiedLines[index] = line.replace(
            /alert\s*\((.*?)\)/g,
            '// TODO: Replace with toast notification - $1'
          );
          hasChanges = true;
        }
      }
      
      // Check for TODO comments
      const todoMatch = line.match(/\/\/\s*TODO[:\s](.+)|\/\*\s*TODO[:\s](.+?)\*\//i);
      if (todoMatch) {
        issues.push({
          type: 'TODO',
          file: filePath,
          line: lineNumber,
          content: line.trim(),
          message: todoMatch[1] || todoMatch[2],
        });
      }
    });

    if (fix && hasChanges) {
      await fs.writeFile(filePath, modifiedLines.join('\n'), 'utf-8');
    }

    return { issues, modified: hasChanges };
  } catch (error) {
    console.error(`Error processing ${filePath}:`, error);
    return { issues: [], modified: false };
  }
}

async function main(fix = false) {
  console.log(`${colors.cyan}🔍 Production Code Cleanup${colors.reset}`);
  console.log(`${colors.cyan}Mode: ${fix ? 'FIX' : 'SCAN'}${colors.reset}\n`);

  try {
    const files = await findProductionFiles();
    console.log(`${colors.blue}📂 Production files to scan: ${files.length}${colors.reset}\n`);

    const allIssues = [];
    let modifiedFiles = 0;

    for (const file of files) {
      const { issues, modified } = await processFile(file, fix);
      if (issues.length > 0) {
        allIssues.push(...issues);
      }
      if (modified) {
        modifiedFiles++;
        console.log(`${colors.green}✅ Fixed: ${file}${colors.reset}`);
      }
    }

    // Group issues by type
    const issuesByType = {
      console: [],
      alert: [],
      TODO: [],
    };
    
    allIssues.forEach(issue => {
      issuesByType[issue.type].push(issue);
    });

    // Display summary
    console.log(`\n${colors.cyan}📊 Summary:${colors.reset}`);
    console.log('─'.repeat(50));
    
    if (issuesByType.console.length > 0) {
      console.log(`${colors.yellow}Console statements: ${issuesByType.console.length}${colors.reset}`);
      // Group by method
      const byMethod = {};
      issuesByType.console.forEach(issue => {
        byMethod[issue.method] = (byMethod[issue.method] || 0) + 1;
      });
      Object.entries(byMethod).forEach(([method, count]) => {
        console.log(`  - console.${method}: ${count}`);
      });
    }
    
    if (issuesByType.alert.length > 0) {
      console.log(`${colors.red}Alert statements: ${issuesByType.alert.length}${colors.reset}`);
    }
    
    if (issuesByType.TODO.length > 0) {
      console.log(`${colors.blue}TODO comments: ${issuesByType.TODO.length}${colors.reset}`);
    }
    
    console.log('─'.repeat(50));
    console.log(`Total issues: ${allIssues.length}\n`);

    if (fix) {
      console.log(`${colors.green}✅ Modified ${modifiedFiles} files${colors.reset}\n`);
    } else if (allIssues.length > 0) {
      // Show details when not fixing
      console.log(`${colors.cyan}📋 Details:${colors.reset}\n`);
      
      // Show console statements
      if (issuesByType.console.length > 0) {
        console.log(`${colors.yellow}Console Statements:${colors.reset}`);
        issuesByType.console.forEach(issue => {
          console.log(`  ${issue.file}:${issue.line}`);
          console.log(`    ${colors.cyan}${issue.content}${colors.reset}`);
        });
        console.log('');
      }
      
      // Show alerts
      if (issuesByType.alert.length > 0) {
        console.log(`${colors.red}Alert Statements:${colors.reset}`);
        issuesByType.alert.forEach(issue => {
          console.log(`  ${issue.file}:${issue.line}`);
          console.log(`    ${colors.cyan}${issue.content}${colors.reset}`);
        });
        console.log('');
      }
      
      // Show TODOs
      if (issuesByType.TODO.length > 0) {
        console.log(`${colors.blue}TODO Comments:${colors.reset}`);
        issuesByType.TODO.forEach(issue => {
          console.log(`  ${issue.file}:${issue.line}`);
          console.log(`    ${colors.cyan}${issue.message}${colors.reset}`);
        });
        console.log('');
      }
      
      console.log(`${colors.yellow}💡 To fix console/alert issues automatically, run:${colors.reset}`);
      console.log(`${colors.green}   node scripts/production-cleanup.js --fix${colors.reset}\n`);
    } else {
      console.log(`${colors.green}🎉 No issues found in production code!${colors.reset}`);
    }

    // Save report
    const report = {
      scanDate: new Date().toISOString(),
      mode: fix ? 'fix' : 'scan',
      filesScanned: files.length,
      filesModified: modifiedFiles,
      issues: {
        console: issuesByType.console.length,
        alert: issuesByType.alert.length,
        TODO: issuesByType.TODO.length,
        total: allIssues.length,
      },
      details: allIssues,
    };

    await fs.writeFile(
      'production-cleanup-report.json',
      JSON.stringify(report, null, 2)
    );

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