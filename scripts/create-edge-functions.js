#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// List of all fortune types from the Express.js API
const fortuneTypes = [
  'daily', 'today', 'tomorrow', 'weekly', 'monthly', 'yearly', 'hourly',
  'saju', 'traditional-saju', 'saju-psychology', 'tojeong', 'salpuli',
  'palmistry', 'physiognomy', 'mbti', 'personality', 'blood-type',
  'love', 'marriage', 'compatibility', 'traditional-compatibility',
  'couple-match', 'blind-date', 'ex-lover', 'celebrity-match', 'chemistry',
  'career', 'employment', 'business', 'startup', 'lucky-job',
  'wealth', 'health', 'destiny', 'past-life', 'talent',
  'network-report', 'timeline', 'biorhythm', 'birth-season',
  'birthdate', 'birthstone', 'zodiac-animal', 'zodiac',
  'five-blessings', 'wish', 'avoid-people', 'lucky-number',
  'lucky-color', 'lucky-items', 'lucky-food', 'lucky-place',
  'lucky-outfit', 'lucky-series', 'lucky-lottery', 'lucky-stock',
  'lucky-crypto', 'lucky-investment', 'lucky-realestate', 'lucky-sidejob',
  'lucky-baseball', 'lucky-golf', 'lucky-tennis', 'lucky-cycling',
  'lucky-running', 'lucky-hiking', 'lucky-fishing', 'lucky-swim',
  'lucky-fitness', 'lucky-yoga', 'lucky-exam', 'moving',
  'moving-date', 'new-year', 'face-reading', 'celebrity', 'talisman'
];

const functionsDir = path.join(__dirname, '..', 'supabase', 'functions');
const templatePath = path.join(functionsDir, 'fortune-daily', 'index.ts');

// Read template
const template = fs.readFileSync(templatePath, 'utf8');

// Create functions for each fortune type
fortuneTypes.forEach(type => {
  if (type === 'daily') return; // Skip daily as it's our template
  
  const functionName = `fortune-${type}`;
  const functionDir = path.join(functionsDir, functionName);
  
  // Create directory
  if (!fs.existsSync(functionDir)) {
    fs.mkdirSync(functionDir, { recursive: true });
  }
  
  // Modify template for this fortune type
  let functionCode = template
    .replace(/FORTUNE_TYPE = 'daily'/g, `FORTUNE_TYPE = '${type}'`)
    .replace(/Daily fortune generation/g, `${type.charAt(0).toUpperCase() + type.slice(1)} fortune generation`);
  
  // Write function
  fs.writeFileSync(path.join(functionDir, 'index.ts'), functionCode);
  
  console.log(`✅ Created function: ${functionName}`);
});

// Create deployment script
const deployScript = `#!/bin/bash
# Deploy all fortune Edge Functions

echo "🚀 Deploying Supabase Edge Functions..."

# Deploy shared functions first
echo "📦 Deploying shared utilities..."

# Deploy all fortune functions
${fortuneTypes.map(type => `
echo "🔮 Deploying fortune-${type}..."
supabase functions deploy fortune-${type}`).join('')}

echo "✅ All functions deployed successfully!"
`;

fs.writeFileSync(path.join(__dirname, 'deploy-edge-functions.sh'), deployScript);
fs.chmodSync(path.join(__dirname, 'deploy-edge-functions.sh'), '755');

console.log('\\n✅ Created all Edge Functions!');
console.log('📝 Created deployment script: scripts/deploy-edge-functions.sh');
console.log('\\nNext steps:');
console.log('1. Review generated functions in supabase/functions/');
console.log('2. Run: supabase functions serve --env-file ./supabase/.env.local');
console.log('3. Deploy: ./scripts/deploy-edge-functions.sh');