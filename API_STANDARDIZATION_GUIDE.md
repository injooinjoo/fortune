
# API Response Standardization Guide

## Before:
```typescript
return NextResponse.json({ error: 'Something went wrong' }, { status: 500 });
return NextResponse.json({ success: true, data: { ... } });
```

## After:
```typescript
import { createSuccessResponse, createErrorResponse } from '@/lib/api-response-utils';

return createErrorResponse('Something went wrong', 'ERROR_CODE', null, 500);
return createSuccessResponse({ ... });
```

## Standard Response Format:

### Success:
```json
{
  "success": true,
  "data": { ... },
  "message": "Optional success message",
  "metadata": {
    "timestamp": "2025-01-09T10:00:00Z",
    "fortune_type": "love",
    "user_id": "123"
  }
}
```

### Error:
```json
{
  "success": false,
  "error": {
    "message": "Error description",
    "code": "ERROR_CODE",
    "details": { ... }
  },
  "metadata": {
    "timestamp": "2025-01-09T10:00:00Z"
  }
}
```
