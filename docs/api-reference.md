# Fortune API Reference

## Overview

The Fortune API provides endpoints for generating and retrieving personalized fortune-telling insights. All endpoints are built using Next.js API Routes and integrate with OpenAI for AI-powered fortune generation.

## Base URL

```
https://fortune-explorer.vercel.app/api
```

## Authentication

⚠️ **Current Status**: API endpoints are currently public. Authentication middleware is planned for implementation.

## Main Endpoints

### 1. Generate Fortune

Generates personalized fortunes based on user profile and request type.

**Endpoint**: `POST /api/fortune/generate`

**Request Body**:
```json
{
  "request_type": "onboarding_complete" | "daily_refresh" | "user_direct_request",
  "user_profile": {
    "name": "string",
    "birth_date": "YYYY-MM-DD",
    "birth_time": "string (optional)",
    "gender": "남성" | "여성" | "선택 안함",
    "mbti": "string (optional)"
  },
  "fortune_categories": ["saju", "daily", "love", ...] // optional for direct requests
}
```

**Response**:
```json
{
  "success": true,
  "data": {
    "fortune_type": "LIFE_PROFILE" | "DAILY_COMPREHENSIVE" | "DIRECT_REQUEST",
    "fortunes": {
      "saju": { ... },
      "daily": { ... },
      // ... other requested fortunes
    },
    "generated_at": "ISO 8601 timestamp",
    "expires_at": "ISO 8601 timestamp"
  }
}
```

### 2. User Profile

Manages user profile information for personalized fortune generation.

**Endpoint**: `GET /api/profile`

**Response**:
```json
{
  "name": "string",
  "birth_date": "YYYY-MM-DD",
  "birth_time": "string",
  "gender": "string",
  "mbti": "string",
  "created_at": "ISO 8601 timestamp"
}
```

**Endpoint**: `POST /api/profile`

**Request Body**:
```json
{
  "name": "string",
  "birth_date": "YYYY-MM-DD",
  "birth_time": "string (optional)",
  "gender": "남성" | "여성" | "선택 안함",
  "mbti": "string (optional)"
}
```

## Fortune Category Endpoints

Each fortune category has its own data structure. Here are the main categories:

### Daily Fortunes

#### Today's Fortune
- **Path**: `/fortune/daily`
- **Cache**: 24 hours
- **Data Structure**:
```json
{
  "user_info": { "name": "string", "birth_date": "string" },
  "fortune_scores": {
    "overall_luck": 0-100,
    "love_luck": 0-100,
    "career_luck": 0-100,
    "wealth_luck": 0-100,
    "health_luck": 0-100
  },
  "insights": {
    "today": "string",
    "advice": "string"
  },
  "lucky_items": {
    "color": "string",
    "number": 0-99,
    "direction": "string",
    "time": "string"
  }
}
```

### Traditional Fortunes (사주/Saju)

#### Basic Saju
- **Path**: `/fortune/saju`
- **Cache**: Lifetime (never expires)
- **Data Structure**:
```json
{
  "user_info": { "name": "string", "birth_date": "string" },
  "summary": "string",
  "manse": {
    "solar": "string",
    "lunar": "string",
    "ganji": "string"
  },
  "saju": {
    "heaven": ["string", "string", "string", "string"],
    "earth": ["string", "string", "string", "string"]
  },
  "elements": [
    { "subject": "木|火|土|金|水", "value": 0-100 }
  ],
  "life_cycles": {
    "youth": "string",
    "middle": "string",
    "old": "string"
  }
}
```

### Love & Relationships

#### Love Fortune
- **Path**: `/fortune/love`
- **Cache**: 24 hours
- **Data Structure**:
```json
{
  "user_info": { "name": "string", "birth_date": "string" },
  "love_status": {
    "current_energy": 0-100,
    "attraction_level": 0-100,
    "relationship_potential": 0-100
  },
  "predictions": {
    "this_week": "string",
    "this_month": "string",
    "key_dates": ["YYYY-MM-DD"]
  },
  "advice": {
    "single": "string",
    "relationship": "string"
  }
}
```

#### Compatibility
- **Path**: `/fortune/compatibility`
- **Cache**: 7 days (based on input hash)
- **Request**: Requires partner information
- **Data Structure**:
```json
{
  "compatibility_score": 0-100,
  "analysis": {
    "emotional": 0-100,
    "intellectual": 0-100,
    "physical": 0-100,
    "values": 0-100
  },
  "strengths": ["string"],
  "challenges": ["string"],
  "advice": "string"
}
```

### Career & Business

#### Career Fortune
- **Path**: `/fortune/career`
- **Cache**: 24 hours
- **Data Structure**:
```json
{
  "career_outlook": {
    "current_phase": "성장기|안정기|전환기",
    "opportunity_level": 0-100,
    "challenge_level": 0-100
  },
  "recommendations": {
    "best_fields": ["string"],
    "avoid_fields": ["string"],
    "timing": "string"
  },
  "monthly_forecast": {
    "promotion_chance": 0-100,
    "project_success": 0-100,
    "networking": 0-100
  }
}
```

### Lucky Items

#### Lucky Color
- **Path**: `/fortune/lucky-color`
- **Cache**: 24 hours
- **Data Structure**:
```json
{
  "primary_color": {
    "name": "string",
    "hex": "#RRGGBB",
    "meaning": "string"
  },
  "secondary_colors": [
    { "name": "string", "hex": "#RRGGBB" }
  ],
  "avoid_colors": ["string"],
  "fashion_tips": ["string"]
}
```

#### Lucky Numbers
- **Path**: `/fortune/lucky-number`
- **Cache**: 24 hours
- **Data Structure**:
```json
{
  "main_numbers": [1-45],
  "power_number": 1-99,
  "avoid_numbers": [1-99],
  "lottery_suggestion": {
    "numbers": [1-45],
    "best_time": "string"
  }
}
```

### Interactive Fortunes

#### Tarot Reading
- **Path**: `/interactive/tarot`
- **Cache**: None (real-time)
- **Request**: Requires question
- **Data Structure**:
```json
{
  "spread_type": "1장|3장|켈틱크로스",
  "question": "string",
  "cards": [
    {
      "position": "string",
      "card_name": "string",
      "card_number": 0-21,
      "is_reversed": boolean,
      "keywords": ["string"],
      "interpretation": "string"
    }
  ],
  "overall_message": "string"
}
```

## Error Responses

All endpoints return consistent error responses:

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": {} // Optional additional information
  }
}
```

### Common Error Codes

- `INVALID_REQUEST`: Missing or invalid parameters
- `PROFILE_NOT_FOUND`: User profile doesn't exist
- `GENERATION_FAILED`: AI generation error
- `RATE_LIMIT_EXCEEDED`: Too many requests (future implementation)
- `UNAUTHORIZED`: Authentication required (future implementation)

## Rate Limiting

⚠️ **Not yet implemented**. Planned limits:
- Free tier: 100 requests/day
- Premium tier: 1000 requests/day

## Caching Strategy

Fortune data is cached based on type:

1. **Lifetime Cache** (Group 1): Saju, personality, past life
   - Never expires
   - Generated once per user

2. **Daily Cache** (Group 2): Daily fortunes, lucky items
   - 24-hour cache
   - Refreshes at midnight KST

3. **Weekly Cache** (Group 3): Interactive fortunes with same input
   - 7-day cache
   - Based on input hash

4. **No Cache** (Group 4): Real-time interactive fortunes
   - Always fresh generation

## SDK Usage Example

```typescript
// Initialize client
const fortuneClient = new FortuneClient({
  apiKey: 'your-api-key' // Future implementation
});

// Get user profile
const profile = await fortuneClient.getProfile();

// Generate daily fortunes
const dailyFortunes = await fortuneClient.generateFortune({
  request_type: 'daily_refresh',
  user_profile: profile
});

// Get specific fortune
const loveFortune = await fortuneClient.getFortune('love');

// Interactive tarot reading
const tarotReading = await fortuneClient.tarot.read({
  question: '연애운이 어떻게 될까요?',
  spread: '3장'
});
```

## Webhook Events (Planned)

Future implementation for premium users:

- `fortune.generated`: New fortune created
- `fortune.viewed`: Fortune accessed
- `subscription.created`: Premium subscription started
- `subscription.cancelled`: Premium subscription ended

## Testing

Test API endpoints:
```bash
# Generate fortune
curl -X POST https://fortune-explorer.vercel.app/api/fortune/generate \
  -H "Content-Type: application/json" \
  -d '{
    "request_type": "daily_refresh",
    "user_profile": {
      "name": "테스트",
      "birth_date": "1990-01-01",
      "gender": "남성"
    }
  }'
```

---

*Last updated: 2025-07-06*
*Version: 1.0.0*