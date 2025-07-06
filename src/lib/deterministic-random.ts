import seedrandom from 'seedrandom';

/**
 * Deterministic random number generator for consistent fortune results
 * Uses user ID, date, and fortune type to generate reproducible random values
 */
export class DeterministicRandom {
  private rng: seedrandom.PRNG;
  
  constructor(userId: string, date: string, fortuneType: string) {
    // Create a deterministic seed from user data
    const seed = `${userId}-${date}-${fortuneType}`;
    this.rng = seedrandom(seed);
  }
  
  /**
   * Generate a random number between 0 and 1
   */
  random(): number {
    return this.rng();
  }
  
  /**
   * Generate a random integer between min and max (inclusive)
   */
  randomInt(min: number, max: number): number {
    return Math.floor(this.random() * (max - min + 1)) + min;
  }
  
  /**
   * Generate a random score between min and max
   */
  randomScore(min: number = 0, max: number = 100): number {
    return this.randomInt(min, max);
  }
  
  /**
   * Pick a random element from an array
   */
  randomElement<T>(array: T[]): T {
    if (array.length === 0) {
      throw new Error('Cannot pick from empty array');
    }
    const index = this.randomInt(0, array.length - 1);
    return array[index];
  }
  
  /**
   * Shuffle an array deterministically
   */
  shuffle<T>(array: T[]): T[] {
    const shuffled = [...array];
    for (let i = shuffled.length - 1; i > 0; i--) {
      const j = this.randomInt(0, i);
      [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }
    return shuffled;
  }
  
  /**
   * Generate multiple random scores
   */
  randomScores(count: number, min: number = 0, max: number = 100): number[] {
    return Array.from({ length: count }, () => this.randomScore(min, max));
  }
  
  /**
   * Pick multiple unique random elements from an array
   */
  randomElements<T>(array: T[], count: number): T[] {
    if (count > array.length) {
      throw new Error('Cannot pick more elements than array length');
    }
    
    const shuffled = this.shuffle(array);
    return shuffled.slice(0, count);
  }
  
  /**
   * Generate a random boolean with given probability
   */
  randomBoolean(probability: number = 0.5): boolean {
    return this.random() < probability;
  }
  
  /**
   * Generate a random date within a range
   */
  randomDate(start: Date, end: Date): Date {
    const startTime = start.getTime();
    const endTime = end.getTime();
    const randomTime = startTime + this.random() * (endTime - startTime);
    return new Date(randomTime);
  }
}

/**
 * Factory function to create a deterministic random generator
 */
export function createDeterministicRandom(
  userId: string,
  date: string | Date,
  fortuneType: string
): DeterministicRandom {
  const dateString = typeof date === 'string' ? date : date.toISOString().split('T')[0];
  return new DeterministicRandom(userId, dateString, fortuneType);
}

/**
 * Get today's date string in YYYY-MM-DD format
 */
export function getTodayDateString(): string {
  return new Date().toISOString().split('T')[0];
}

/**
 * Legacy compatibility functions for gradual migration
 */
export function getSeededRandom(userId: string, date: string, type: string): () => number {
  const rng = new DeterministicRandom(userId, date, type);
  return () => rng.random();
}

export function getRandomScore(
  userId: string,
  date: string,
  type: string,
  min: number = 0,
  max: number = 100
): number {
  const rng = new DeterministicRandom(userId, date, type);
  return rng.randomScore(min, max);
}

export function shuffleArray<T>(
  array: T[],
  userId: string,
  date: string,
  type: string
): T[] {
  const rng = new DeterministicRandom(userId, date, type);
  return rng.shuffle(array);
}