// 로그 레벨 제어 유틸리티

export enum LogLevel {
  ERROR = 0,
  WARN = 1,
  INFO = 2,
  DEBUG = 3,
}

class Logger {
  private static instance: Logger;
  private level: LogLevel;

  private constructor() {
    // 개발 환경에서는 DEBUG, 프로덕션에서는 WARN
    this.level = process.env.NODE_ENV === 'development' ? LogLevel.DEBUG : LogLevel.WARN;
  }

  static getInstance(): Logger {
    if (!Logger.instance) {
      Logger.instance = new Logger();
    }
    return Logger.instance;
  }

  setLevel(level: LogLevel): void {
    this.level = level;
  }

  error(message: string, ...args: any[]): void {
    if (this.level >= LogLevel.ERROR) {
      console.error(message, ...args);
    }
  }

  warn(message: string, ...args: any[]): void {
    if (this.level >= LogLevel.WARN) {
      console.warn(message, ...args);
    }
  }

  info(message: string, ...args: any[]): void {
    if (this.level >= LogLevel.INFO) {
      console.info(message, ...args);
    }
  }

  debug(message: string, ...args: any[]): void {
    if (this.level >= LogLevel.DEBUG) {
      console.log(message, ...args);
    }
  }

  // 조건부 로깅 - 특정 조건에서만 로그 출력
  debugOnce(key: string, message: string, ...args: any[]): void {
    if (typeof window === 'undefined') return;
    
    const loggedKey = `_logged_${key}`;
    if (!window[loggedKey as any]) {
      window[loggedKey as any] = true;
      this.debug(message, ...args);
    }
  }

  // 스로틀링된 로깅 - 지정된 시간 간격으로만 로그 출력
  private throttleTimers: Map<string, number> = new Map();
  
  debugThrottled(key: string, intervalMs: number, message: string, ...args: any[]): void {
    const now = Date.now();
    const lastLogged = this.throttleTimers.get(key) || 0;
    
    if (now - lastLogged >= intervalMs) {
      this.throttleTimers.set(key, now);
      this.debug(message, ...args);
    }
  }
}

export const logger = Logger.getInstance();