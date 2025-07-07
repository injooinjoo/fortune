import { 
  DeterministicRandom, 
  createDeterministicRandom,
  getTodayDateString,
  getSeededRandom,
  getRandomScore,
  shuffleArray
} from '@/lib/deterministic-random';

describe('DeterministicRandom', () => {
  const userId = 'test-user-123';
  const date = '2025-01-07';
  const fortuneType = 'daily';
  
  describe('Deterministic behavior', () => {
    it('should generate same values for same inputs', () => {
      const rng1 = new DeterministicRandom(userId, date, fortuneType);
      const rng2 = new DeterministicRandom(userId, date, fortuneType);
      
      // Generate values from first instance
      const values1 = [
        rng1.random(),
        rng1.randomInt(1, 100),
        rng1.randomScore(),
        rng1.randomBoolean(0.7)
      ];
      
      // Generate values from second instance
      const values2 = [
        rng2.random(),
        rng2.randomInt(1, 100),
        rng2.randomScore(),
        rng2.randomBoolean(0.7)
      ];
      
      expect(values1).toEqual(values2);
    });
    
    it('should generate different values for different users', () => {
      const rng1 = new DeterministicRandom('user1', date, fortuneType);
      const rng2 = new DeterministicRandom('user2', date, fortuneType);
      
      const value1 = rng1.random();
      const value2 = rng2.random();
      
      expect(value1).not.toEqual(value2);
    });
    
    it('should generate different values for different dates', () => {
      const rng1 = new DeterministicRandom(userId, '2025-01-07', fortuneType);
      const rng2 = new DeterministicRandom(userId, '2025-01-08', fortuneType);
      
      const value1 = rng1.random();
      const value2 = rng2.random();
      
      expect(value1).not.toEqual(value2);
    });
    
    it('should generate different values for different fortune types', () => {
      const rng1 = new DeterministicRandom(userId, date, 'daily');
      const rng2 = new DeterministicRandom(userId, date, 'love');
      
      const value1 = rng1.random();
      const value2 = rng2.random();
      
      expect(value1).not.toEqual(value2);
    });
  });
  
  describe('Random methods', () => {
    let rng: DeterministicRandom;
    
    beforeEach(() => {
      rng = new DeterministicRandom(userId, date, fortuneType);
    });
    
    it('should generate random numbers between 0 and 1', () => {
      for (let i = 0; i < 100; i++) {
        const value = rng.random();
        expect(value).toBeGreaterThanOrEqual(0);
        expect(value).toBeLessThan(1);
      }
    });
    
    it('should generate random integers within range', () => {
      const min = 10;
      const max = 20;
      
      for (let i = 0; i < 100; i++) {
        const value = rng.randomInt(min, max);
        expect(value).toBeGreaterThanOrEqual(min);
        expect(value).toBeLessThanOrEqual(max);
        expect(Number.isInteger(value)).toBe(true);
      }
    });
    
    it('should generate random scores', () => {
      const score1 = rng.randomScore();
      expect(score1).toBeGreaterThanOrEqual(0);
      expect(score1).toBeLessThanOrEqual(100);
      
      const score2 = rng.randomScore(50, 80);
      expect(score2).toBeGreaterThanOrEqual(50);
      expect(score2).toBeLessThanOrEqual(80);
    });
    
    it('should pick random element from array', () => {
      const array = ['a', 'b', 'c', 'd', 'e'];
      const element = rng.randomElement(array);
      
      expect(array).toContain(element);
    });
    
    it('should throw error for empty array', () => {
      expect(() => rng.randomElement([])).toThrow('Cannot pick from empty array');
    });
    
    it('should shuffle array deterministically', () => {
      const original = [1, 2, 3, 4, 5];
      const shuffled1 = rng.shuffle(original);
      
      // Reset RNG with same seed
      rng = new DeterministicRandom(userId, date, fortuneType);
      const shuffled2 = rng.shuffle(original);
      
      expect(shuffled1).toEqual(shuffled2);
      expect(shuffled1).not.toBe(original); // Should be a new array
      expect(shuffled1.sort()).toEqual(original.sort()); // Should contain same elements
    });
    
    it('should generate multiple random scores', () => {
      const scores = rng.randomScores(5, 60, 90);
      
      expect(scores).toHaveLength(5);
      scores.forEach(score => {
        expect(score).toBeGreaterThanOrEqual(60);
        expect(score).toBeLessThanOrEqual(90);
      });
    });
    
    it('should pick multiple unique elements', () => {
      const array = ['a', 'b', 'c', 'd', 'e'];
      const elements = rng.randomElements(array, 3);
      
      expect(elements).toHaveLength(3);
      expect(new Set(elements).size).toBe(3); // All unique
      elements.forEach(el => expect(array).toContain(el));
    });
    
    it('should throw error when picking too many elements', () => {
      const array = ['a', 'b', 'c'];
      expect(() => rng.randomElements(array, 5)).toThrow('Cannot pick more elements than array length');
    });
    
    it('should generate random boolean with probability', () => {
      let trueCount = 0;
      const iterations = 1000;
      
      for (let i = 0; i < iterations; i++) {
        // Reset RNG to get different values
        rng = new DeterministicRandom(userId, date, `${fortuneType}-${i}`);
        if (rng.randomBoolean(0.7)) {
          trueCount++;
        }
      }
      
      // Should be roughly 70% true
      const ratio = trueCount / iterations;
      expect(ratio).toBeGreaterThan(0.6);
      expect(ratio).toBeLessThan(0.8);
    });
    
    it('should generate random date within range', () => {
      const start = new Date('2025-01-01');
      const end = new Date('2025-12-31');
      
      const randomDate = rng.randomDate(start, end);
      
      expect(randomDate.getTime()).toBeGreaterThanOrEqual(start.getTime());
      expect(randomDate.getTime()).toBeLessThanOrEqual(end.getTime());
    });
  });
  
  describe('Factory and utility functions', () => {
    it('should create deterministic random with factory function', () => {
      const rng1 = createDeterministicRandom(userId, date, fortuneType);
      const rng2 = createDeterministicRandom(userId, new Date(date), fortuneType);
      
      expect(rng1.random()).toEqual(rng2.random());
    });
    
    it('should get today date string', () => {
      const dateString = getTodayDateString();
      const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
      
      expect(dateString).toMatch(dateRegex);
    });
  });
  
  describe('Legacy compatibility functions', () => {
    it('should work with getSeededRandom', () => {
      const random = getSeededRandom(userId, date, fortuneType);
      const value1 = random();
      const value2 = random();
      
      expect(value1).toBeGreaterThanOrEqual(0);
      expect(value1).toBeLessThan(1);
      expect(value2).not.toEqual(value1); // Different values on each call
    });
    
    it('should work with getRandomScore', () => {
      const score1 = getRandomScore(userId, date, fortuneType);
      const score2 = getRandomScore(userId, date, fortuneType);
      
      expect(score1).toEqual(score2); // Same inputs = same output
      expect(score1).toBeGreaterThanOrEqual(0);
      expect(score1).toBeLessThanOrEqual(100);
    });
    
    it('should work with shuffleArray', () => {
      const array = [1, 2, 3, 4, 5];
      const shuffled1 = shuffleArray(array, userId, date, fortuneType);
      const shuffled2 = shuffleArray(array, userId, date, fortuneType);
      
      expect(shuffled1).toEqual(shuffled2); // Deterministic
      expect(shuffled1.sort()).toEqual(array.sort());
    });
  });
});