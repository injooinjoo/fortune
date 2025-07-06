#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Function to update a lucky page file
function updateLuckyPage(filePath) {
  const fullPath = path.join(process.cwd(), filePath);
  
  if (!fs.existsSync(fullPath)) {
    console.log(`❌ File not found: ${filePath}`);
    return false;
  }
  
  let content = fs.readFileSync(fullPath, 'utf8');
  const originalContent = content;
  
  // Check if already updated
  if (content.includes('deterministic-random')) {
    console.log(`✅ Already updated: ${filePath}`);
    return true;
  }
  
  // Add import if not present
  if (!content.includes('import { createDeterministicRandom')) {
    // Find the last import statement
    const importMatch = content.match(/(import[\s\S]*?from\s+["'][^"']+["'];?\s*\n)+/);
    if (importMatch) {
      const lastImportEnd = importMatch.index + importMatch[0].length;
      content = content.slice(0, lastImportEnd) + 
        'import { createDeterministicRandom, getTodayDateString } from "@/lib/deterministic-random";\n' +
        content.slice(lastImportEnd);
    }
  }
  
  // Find the analyze function (common patterns)
  const analyzePatterns = [
    /const analyze\w+Fortune = async \(\):/,
    /const generate\w+Fortune = async \(\):/,
    /const calculate\w+Fortune = async \(\):/
  ];
  
  let functionFound = false;
  for (const pattern of analyzePatterns) {
    if (pattern.test(content)) {
      functionFound = true;
      
      // Add RNG initialization after function declaration
      content = content.replace(pattern, (match) => {
        return match + `\n    // Create deterministic random generator based on user and date
    const userId = formData.name || 'guest';
    const dateString = selectedDate ? selectedDate.toISOString().split('T')[0] : getTodayDateString();
    const rng = createDeterministicRandom(userId, dateString, '${path.basename(filePath, '.tsx')}');
    `;
      });
      break;
    }
  }
  
  if (!functionFound) {
    console.log(`⚠️  Could not find analyze function in: ${filePath}`);
  }
  
  // Replace common Math.random patterns
  const replacements = [
    // Math.floor(Math.random() * n) -> rng.randomInt(0, n-1)
    {
      pattern: /Math\.floor\(Math\.random\(\)\s*\*\s*(\d+)\)/g,
      replacement: (match, n) => `rng.randomInt(0, ${parseInt(n) - 1})`
    },
    // Math.floor(Math.random() * n) + m -> rng.randomInt(m, n+m-1)
    {
      pattern: /Math\.floor\(Math\.random\(\)\s*\*\s*(\d+)\)\s*\+\s*(\d+)/g,
      replacement: (match, n, m) => `rng.randomInt(${m}, ${parseInt(n) + parseInt(m) - 1})`
    },
    // array[Math.floor(Math.random() * array.length)] -> rng.randomElement(array)
    {
      pattern: /(\w+)\[Math\.floor\(Math\.random\(\)\s*\*\s*\1\.length\)\]/g,
      replacement: (match, arrayName) => `rng.randomElement(${arrayName})`
    },
    // .sort(() => 0.5 - Math.random()) -> rng.shuffle()
    {
      pattern: /\.slice\(\)\.sort\(\(\)\s*=>\s*0\.5\s*-\s*Math\.random\(\)\)/g,
      replacement: '.slice() /* Use rng.shuffle() instead */'
    },
    // Math.random() * n -> rng.random() * n
    {
      pattern: /Math\.random\(\)/g,
      replacement: 'rng.random()'
    }
  ];
  
  // Apply replacements
  replacements.forEach(({ pattern, replacement }) => {
    content = content.replace(pattern, replacement);
  });
  
  // Save if changed
  if (content !== originalContent) {
    fs.writeFileSync(fullPath, content);
    console.log(`✅ Updated: ${filePath}`);
    return true;
  }
  
  return false;
}

// Update all lucky pages
const luckyFiles = [
  'src/app/fortune/lucky-outfit/page.tsx',
  'src/app/fortune/lucky-items/page.tsx',
  'src/app/fortune/lucky-investment/page.tsx',
  'src/app/fortune/lucky-job/page.tsx',
  'src/app/fortune/lucky-sidejob/page.tsx',
  'src/app/fortune/lucky-realestate/page.tsx',
  'src/app/fortune/lucky-exam/page.tsx',
  'src/app/fortune/lucky-fishing/page.tsx',
  'src/app/fortune/lucky-cycling/page.tsx',
  'src/app/fortune/lucky-running/page.tsx',
  'src/app/fortune/lucky-swim/page.tsx'
];

console.log('🔄 Auto-replacing Math.random() in lucky pages...\n');

let updatedCount = 0;
luckyFiles.forEach(file => {
  if (updateLuckyPage(file)) {
    updatedCount++;
  }
});

console.log(`\n✅ Updated ${updatedCount} files`);
console.log('\n⚠️  Please review the changes and fix any issues manually');
console.log('Common issues to check:');
console.log('- Ensure formData.name is available in the scope');
console.log('- Ensure selectedDate is available in the scope');
console.log('- Replace .slice().sort() patterns with rng.shuffle()');
console.log('- Check array shuffling and element picking');