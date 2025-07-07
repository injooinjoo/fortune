#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// List of files to update
const files = [
  'src/app/fortune/blind-date/page.tsx',
  'src/app/fortune/chemistry/page.tsx',
  'src/app/fortune/compatibility/page.tsx',
  'src/app/fortune/couple-match/page.tsx',
  'src/app/fortune/ex-lover/page.tsx',
  'src/app/fortune/personality/page.tsx',
  'src/app/fortune/saju/page.tsx',
  'src/app/fortune/startup/page.tsx',
  'src/app/fortune/timeline/page.tsx',
  'src/app/fortune/traditional-compatibility/page.tsx',
  'src/app/fortune/wish/page.tsx'
];

function updateFile(filePath) {
  const fullPath = path.join(process.cwd(), filePath);
  let content = fs.readFileSync(fullPath, 'utf8');
  
  // Check if file already imports useAuth
  const hasUseAuthImport = content.includes('useAuth');
  
  // Add useAuth import if not present
  if (!hasUseAuthImport) {
    // Find the imports section and add useAuth import
    const importRegex = /import\s+{[^}]*}\s+from\s+["']@\/hooks\/use-user-profile["'];/;
    content = content.replace(importRegex, (match) => {
      return match + '\nimport { useAuth } from "@/contexts/auth-context";';
    });
  }
  
  // Replace the demo-user line with actual user ID
  const oldLine = "const userId = 'demo-user'; // TODO: Get actual user ID from context";
  const newLines = `// Get actual user ID from auth context
  const { user } = useAuth();
  const userId = user?.id || 'guest-user';`;
  
  content = content.replace(oldLine, newLines);
  
  fs.writeFileSync(fullPath, content, 'utf8');
  console.log(`✅ Updated: ${filePath}`);
}

// Update all files
console.log('🔧 Updating user ID context in fortune pages...\n');

files.forEach(file => {
  try {
    updateFile(file);
  } catch (error) {
    console.error(`❌ Error updating ${file}:`, error.message);
  }
});

console.log('\n✅ All files updated successfully!');