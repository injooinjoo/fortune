import winston from 'winston';

const levels = {
  error: 0,
  warn: 1,
  info: 2,
  http: 3,
  debug: 4,
};

const level = () => {
  const isDevelopment = process.env.NODE_ENV === 'development';
  return isDevelopment ? 'debug' : 'info';
};

const colors = {
  error: 'red',
  warn: 'yellow',
  info: 'green',
  http: 'magenta',
  debug: 'white',
};

winston.addColors(colors);

const format = winston.format.combine(
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss:ms' }),
  winston.format.colorize({ all: true }),
  winston.format.printf(
    (info) => `${info.timestamp} ${info.level}: ${info.message}`,
  ),
);

const jsonFormat = winston.format.combine(
  winston.format.timestamp(),
  winston.format.errors({ stack: true }),
  winston.format.splat(),
  winston.format.json(),
);

const transports: winston.transport[] = [
  new winston.transports.Console({
    format: process.env.LOG_FORMAT === 'json' ? jsonFormat : format,
  }),
];

// Add file transport in production (disabled for Cloud Run)
// Cloud Run logs to stdout/stderr automatically
if (process.env.NODE_ENV === 'production' && process.env.ENABLE_FILE_LOGS === 'true') {
  transports.push(
    new winston.transports.File({
      filename: 'logs/error.log',
      level: 'error',
      format: jsonFormat,
    }) as winston.transport,
    new winston.transports.File({
      filename: 'logs/combined.log',
      format: jsonFormat,
    }) as winston.transport,
  );
}

const logger = winston.createLogger({
  level: level(),
  levels,
  transports,
});

export default logger;