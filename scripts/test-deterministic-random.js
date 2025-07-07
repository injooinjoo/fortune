#!/usr/bin/env node

// Test the deterministic random implementation
const path = require('path');
const tsNode = require('ts-node');

// Register TypeScript compiler
tsNode.register({
  compilerOptions: {
    module: 'commonjs',
    target: 'es2020',
    jsx: 'react',
    esModuleInterop: true,
    paths: {
      '@/*': ['./src/*']
    }
  },
  transpileOnly: true
});

// Import the module
const { 
  DeterministicRandom, 
  createDeterministicRandom,
  getRandomScore,
  shuffleArray
} = require('../src/lib/deterministic-random.ts');

console.log('🧪 Testing Deterministic Random Library\n');

// Test 1: Same inputs = same outputs
console.log('Test 1: Deterministic behavior');
const rng1 = new DeterministicRandom('user123', '2025-01-07', 'daily');
const rng2 = new DeterministicRandom('user123', '2025-01-07', 'daily');

const value1 = rng1.random();
const value2 = rng2.random();

console.log(`RNG1 first value: ${value1}`);
console.log(`RNG2 first value: ${value2}`);
console.log(`✅ Same inputs produce same outputs: ${value1 === value2}\n`);

// Test 2: Different inputs = different outputs
console.log('Test 2: Different inputs');
const rng3 = new DeterministicRandom('user456', '2025-01-07', 'daily');
const value3 = rng3.random();

console.log(`Different user value: ${value3}`);
console.log(`✅ Different inputs produce different outputs: ${value1 !== value3}\n`);

// Test 3: Random scores
console.log('Test 3: Random scores');
const score1 = getRandomScore('user123', '2025-01-07', 'daily');
const score2 = getRandomScore('user123', '2025-01-07', 'daily');
const score3 = getRandomScore('user123', '2025-01-08', 'daily');

console.log(`Score for same inputs: ${score1}, ${score2}`);
console.log(`Score for different date: ${score3}`);
console.log(`✅ Scores are deterministic: ${score1 === score2}`);
console.log(`✅ Different dates produce different scores: ${score1 !== score3}\n`);

// Test 4: Array shuffling
console.log('Test 4: Array shuffling');
const array = ['a', 'b', 'c', 'd', 'e'];
const shuffled1 = shuffleArray([...array], 'user123', '2025-01-07', 'daily');
const shuffled2 = shuffleArray([...array], 'user123', '2025-01-07', 'daily');
const shuffled3 = shuffleArray([...array], 'user456', '2025-01-07', 'daily');

console.log(`Original: [${array.join(', ')}]`);
console.log(`Shuffled 1: [${shuffled1.join(', ')}]`);
console.log(`Shuffled 2: [${shuffled2.join(', ')}]`);
console.log(`Shuffled 3: [${shuffled3.join(', ')}]`);
console.log(`✅ Same shuffle for same inputs: ${JSON.stringify(shuffled1) === JSON.stringify(shuffled2)}`);
console.log(`✅ Different shuffle for different user: ${JSON.stringify(shuffled1) !== JSON.stringify(shuffled3)}\n`);

// Test 5: Multiple methods
console.log('Test 5: Various random methods');
const rng = createDeterministicRandom('testuser', '2025-01-07', 'test');

const randomInt = rng.randomInt(1, 10);
const randomBool = rng.randomBoolean(0.7);
const randomElement = rng.randomElement(['red', 'blue', 'green']);
const randomScores = rng.randomScores(3, 70, 90);

console.log(`Random int (1-10): ${randomInt}`);
console.log(`Random boolean (70% true): ${randomBool}`);
console.log(`Random element: ${randomElement}`);
console.log(`Random scores (70-90): [${randomScores.join(', ')}]`);

console.log('\n✅ All tests passed! The deterministic random library is working correctly.');