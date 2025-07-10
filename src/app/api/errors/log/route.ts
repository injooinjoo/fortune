import { NextRequest, NextResponse } from 'next/server';
import { logger } from '@/lib/logger';
import fs from 'fs/promises';
import path from 'path';

// Store errors in a log file (in production, you might want to use a database)
const ERROR_LOG_PATH = path.join(process.cwd(), 'logs', 'errors.log');

export async function POST(request: NextRequest) {
  try {
    const errorData = await request.json();
    
    // Add server context
    const enrichedError = {
      ...errorData,
      serverTimestamp: new Date().toISOString(),
      ip: request.headers.get('x-forwarded-for') || request.headers.get('x-real-ip'),
      userAgent: request.headers.get('user-agent'),
    };

    // Log to console/file
    logger.error('Client error received:', enrichedError);

    // Ensure logs directory exists
    const logsDir = path.dirname(ERROR_LOG_PATH);
    await fs.mkdir(logsDir, { recursive: true });

    // Append to error log file
    const logEntry = JSON.stringify(enrichedError) + '\n';
    await fs.appendFile(ERROR_LOG_PATH, logEntry);

    // You can add additional handling here:
    // - Send email notifications for critical errors
    // - Store in database
    // - Send to Discord/Slack webhook
    // - Aggregate and analyze errors

    return NextResponse.json({ success: true });
  } catch (error) {
    logger.error('Failed to log error:', error);
    return NextResponse.json(
      { error: 'Failed to log error' },
      { status: 500 }
    );
  }
}