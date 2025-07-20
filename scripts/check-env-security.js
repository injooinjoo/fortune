#!/usr/bin/env node

/**
 * Environment Security Check Script
 * Validates that sensitive information is properly handled
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

// Patterns that indicate sensitive data
const SENSITIVE_PATTERNS = [
  { pattern: /^sk[-_]live[-_]/i, type: 'Stripe Live Key' },
  { pattern: /^pk[-_]live[-_]/i, type: 'Stripe Live Publishable Key' },
  { pattern: /^sk[-_]test[-_]/i, type: 'Stripe Test Key' },
  { pattern: /^AIza[0-9A-Za-z\-_]{35}/, type: 'Google API Key' },
  { pattern: /^[0-9a-f]{40}$/, type: 'GitHub Token' },
  { pattern: /^ghp_[0-9a-zA-Z]{36}$/, type: 'GitHub Personal Token' },
  { pattern: /^ghs_[0-9a-zA-Z]{36}$/, type: 'GitHub Secret' },
  { pattern: /AKIA[0-9A-Z]{16}/, type: 'AWS Access Key' },
  { pattern: /^eyJ[A-Za-z0-9\-_=]+\.[A-Za-z0-9\-_=]+\.?[A-Za-z0-9\-_.+/=]*$/, type: 'JWT Token' },
  { pattern: /^xox[baprs]-[0-9a-zA-Z\-]+/, type: 'Slack Token' },
  { pattern: /-----BEGIN RSA PRIVATE KEY-----/, type: 'RSA Private Key' },
  { pattern: /-----BEGIN PRIVATE KEY-----/, type: 'Private Key' },
  { pattern: /service_role.*[a-zA-Z0-9\-_]{20,}/, type: 'Service Role Key' },
];

// Files to check for sensitive data
const FILES_TO_CHECK = [
  'package.json',
  'package-lock.json',
  'README.md',
  '*.js',
  '*.ts',
  '*.dart',
  '*.swift',
  '*.kt',
  '*.java',
  '*.yml',
  '*.yaml',
  '*.json',
];

// Directories to skip
const SKIP_DIRS = [
  'node_modules',
  '.git',
  'build',
  'dist',
  '.next',
  'coverage',
  '.firebase',
];

class SecurityChecker {
  constructor(rootPath) {
    this.rootPath = rootPath;
    this.issues = [];
    this.checked = 0;
  }

  checkFile(filePath) {
    try {
      const content = fs.readFileSync(filePath, 'utf8');
      const relativePath = path.relative(this.rootPath, filePath);
      
      // Skip .env.example files
      if (filePath.includes('.example')) {
        return;
      }

      // Check each line
      const lines = content.split('\n');
      lines.forEach((line, index) => {
        SENSITIVE_PATTERNS.forEach(({ pattern, type }) => {
          if (pattern.test(line)) {
            // Check if it's a placeholder
            if (!line.includes('your-') && !line.includes('xxx') && !line.includes('placeholder')) {
              this.issues.push({
                file: relativePath,
                line: index + 1,
                type: type,
                preview: this.sanitizeLine(line),
              });
            }
          }
        });
      });

      this.checked++;
    } catch (error) {
      // File read error, skip
    }
  }

  sanitizeLine(line) {
    // Show only first and last few characters of sensitive data
    return line.replace(/([a-zA-Z0-9\-_]{8})[a-zA-Z0-9\-_]{8,}([a-zA-Z0-9\-_]{4})/g, '$1****$2');
  }

  shouldCheckFile(filePath) {
    const basename = path.basename(filePath);
    const ext = path.extname(filePath);
    
    return FILES_TO_CHECK.some(pattern => {
      if (pattern.startsWith('*')) {
        return filePath.endsWith(pattern.substring(1));
      }
      return basename === pattern;
    });
  }

  scanDirectory(dirPath) {
    const items = fs.readdirSync(dirPath);
    
    items.forEach(item => {
      const itemPath = path.join(dirPath, item);
      const stat = fs.statSync(itemPath);
      
      if (stat.isDirectory()) {
        if (!SKIP_DIRS.includes(item) && !item.startsWith('.')) {
          this.scanDirectory(itemPath);
        }
      } else if (stat.isFile() && this.shouldCheckFile(itemPath)) {
        this.checkFile(itemPath);
      }
    });
  }

  generateReport() {
    console.log('\n🔒 Security Scan Report\n');
    console.log(`Files checked: ${this.checked}`);
    console.log(`Issues found: ${this.issues.length}\n`);

    if (this.issues.length === 0) {
      console.log('✅ No sensitive data found in tracked files!\n');
      return 0;
    }

    console.log('⚠️  Potential sensitive data found:\n');
    
    // Group by file
    const byFile = {};
    this.issues.forEach(issue => {
      if (!byFile[issue.file]) {
        byFile[issue.file] = [];
      }
      byFile[issue.file].push(issue);
    });

    Object.entries(byFile).forEach(([file, issues]) => {
      console.log(`📄 ${file}`);
      issues.forEach(issue => {
        console.log(`   Line ${issue.line}: ${issue.type}`);
        console.log(`   Preview: ${issue.preview}`);
      });
      console.log('');
    });

    console.log('🔧 Recommended actions:');
    console.log('1. Move sensitive data to environment variables');
    console.log('2. Add files with secrets to .gitignore');
    console.log('3. Rotate any exposed keys immediately');
    console.log('4. Run git-secrets or similar tools in CI/CD\n');

    return 1;
  }

  checkGitHistory() {
    console.log('📜 Checking git history for secrets...\n');
    
    try {
      const { execSync } = require('child_process');
      
      // Check if git is available
      execSync('git --version', { stdio: 'ignore' });
      
      // Search for common secret patterns in git history
      const patterns = [
        'sk_live',
        'sk_test',
        'AKIA',
        'eyJ',
        'ghp_',
        'xox',
      ];

      let found = false;
      patterns.forEach(pattern => {
        try {
          const result = execSync(
            `git log -p -S"${pattern}" --all --full-history | grep -E "^\\+.*${pattern}" | head -5`,
            { encoding: 'utf8', stdio: 'pipe' }
          );
          
          if (result.trim()) {
            console.log(`⚠️  Found "${pattern}" in git history`);
            found = true;
          }
        } catch (e) {
          // Pattern not found
        }
      });

      if (found) {
        console.log('\n🚨 Secrets found in git history!');
        console.log('Consider using BFG Repo-Cleaner or git filter-branch to remove them.\n');
      } else {
        console.log('✅ No obvious secrets found in git history\n');
      }
    } catch (error) {
      console.log('⚠️  Could not check git history (git not available)\n');
    }
  }
}

// Main execution
const projectRoot = path.resolve(__dirname, '..');
const checker = new SecurityChecker(projectRoot);

console.log('🔍 Scanning for sensitive data...\n');
console.log(`Root: ${projectRoot}\n`);

// Scan files
checker.scanDirectory(projectRoot);

// Check git history
checker.checkGitHistory();

// Generate report
const exitCode = checker.generateReport();
process.exit(exitCode);