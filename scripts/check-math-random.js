const fs = require('fs');
const path = require('path');

// Files to exclude from checks
const EXCLUDE_FILES = [
  'deterministic-random.ts', // The implementation itself
  'supabase.ts', // Guest ID generation should remain random
];

// Patterns to search for
const MATH_RANDOM_PATTERNS = [
  /Math\.random\(\)/g,
  /Math\.floor\s*\(\s*Math\.random/g,
  /Math\.ceil\s*\(\s*Math\.random/g,
  /Math\.round\s*\(\s*Math\.random/g,
];

function checkFile(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const lines = content.split('\n');
  const findings = [];
  
  lines.forEach((line, index) => {
    MATH_RANDOM_PATTERNS.forEach(pattern => {
      if (pattern.test(line)) {
        // Check if it's already marked with TODO
        const hasTodo = line.includes('TODO') || lines[index - 1]?.includes('TODO');
        findings.push({
          line: index + 1,
          content: line.trim(),
          hasTodo
        });
      }
    });
  });
  
  return findings;
}

function walkDir(dir, callback) {
  fs.readdirSync(dir).forEach(file => {
    const fullPath = path.join(dir, file);
    if (fs.statSync(fullPath).isDirectory()) {
      if (!fullPath.includes('node_modules') && !fullPath.includes('.next')) {
        walkDir(fullPath, callback);
      }
    } else if (fullPath.endsWith('.ts') || fullPath.endsWith('.tsx')) {
      callback(fullPath);
    }
  });
}

console.log('🔍 Checking for Math.random() usage...\n');

const results = [];
const srcDir = path.join(process.cwd(), 'src');

walkDir(srcDir, (filePath) => {
  const fileName = path.basename(filePath);
  if (!EXCLUDE_FILES.includes(fileName)) {
    const findings = checkFile(filePath);
    if (findings.length > 0) {
      results.push({
        file: filePath.replace(process.cwd() + '/', ''),
        findings
      });
    }
  }
});

// Group by whether they have TODO comments
const withTodo = results.filter(r => r.findings.some(f => f.hasTodo));
const withoutTodo = results.filter(r => r.findings.every(f => !f.hasTodo));

console.log(`📊 Summary:`);
console.log(`   Total files with Math.random(): ${results.length}`);
console.log(`   Files with TODO comments: ${withTodo.length}`);
console.log(`   Files needing attention: ${withoutTodo.length}\n`);

if (withoutTodo.length > 0) {
  console.log('❌ Files needing Math.random() replacement:\n');
  withoutTodo.forEach(result => {
    console.log(`📄 ${result.file}`);
    result.findings.forEach(finding => {
      console.log(`   Line ${finding.line}: ${finding.content}`);
    });
    console.log('');
  });
}

if (withTodo.length > 0) {
  console.log('⚠️  Files with TODO comments (already marked):\n');
  withTodo.forEach(result => {
    console.log(`📄 ${result.file}`);
    console.log(`   ${result.findings.length} occurrences marked with TODO`);
  });
}

console.log('\n💡 To fix these, import and use deterministic-random functions:');
console.log('   import { getRandom, getRandomInt, getRandomFromArray } from "@/lib/deterministic-random";');
console.log('   // Then use getRandom(userId, fortuneType) instead of Math.random()');