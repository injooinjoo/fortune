# Supabase Edge Functions Deployment Guide

## Prerequisites

1. **Supabase CLI** installed and updated
```bash
brew upgrade supabase
```

2. **Environment Variables** configured
```bash
# Create .env.local for local development
cp .env.example supabase/.env.local
```

## Local Development

### 1. Start Supabase locally
```bash
supabase start
```

### 2. Serve Edge Functions locally
```bash
# Serve single function
supabase functions serve fortune-daily --env-file ./supabase/.env.local

# Serve all functions
supabase functions serve --env-file ./supabase/.env.local
```

### 3. Test locally
```bash
# Test daily fortune
curl -i --location --request POST \
  'http://localhost:54321/functions/v1/fortune-daily' \
  --header 'Authorization: Bearer YOUR_ANON_KEY' \
  --header 'Content-Type: application/json' \
  --data '{"name":"홍길동","birthDate":"1990-01-01"}'
```

## Production Deployment

### 1. Link to Supabase project
```bash
supabase link --project-ref your-project-ref
```

### 2. Set production secrets
```bash
# Set environment variables
supabase secrets set OPENAI_API_KEY=sk-xxx
supabase secrets set STRIPE_SECRET_KEY=sk-xxx
supabase secrets set TOSS_SECRET_KEY=xxx
```

### 3. Deploy functions
```bash
# Deploy single function
supabase functions deploy fortune-daily

# Deploy all functions
supabase functions deploy
```

### 4. Verify deployment
```bash
# List deployed functions
supabase functions list

# Check function logs
supabase functions logs fortune-daily
```

## Creating New Fortune Functions

### 1. Copy template
```bash
# Create new fortune function
cp -r supabase/functions/fortune-daily supabase/functions/fortune-zodiac

# Update the fortune type in index.ts
sed -i '' "s/FORTUNE_TYPE = 'daily'/FORTUNE_TYPE = 'zodiac'/g" supabase/functions/fortune-zodiac/index.ts
```

### 2. Customize the function
- Update system prompts in `getSystemPrompt()`
- Add specific validation if needed
- Adjust caching strategy

### 3. Deploy
```bash
supabase functions deploy fortune-zodiac
```

## Monitoring & Debugging

### 1. View logs
```bash
# Real-time logs
supabase functions logs fortune-daily --tail

# Last 100 logs
supabase functions logs fortune-daily --limit 100
```

### 2. Monitor metrics
- Check Supabase Dashboard > Edge Functions
- View invocation count, errors, latency

### 3. Debug errors
```typescript
// Add detailed logging
console.log(JSON.stringify({
  function: 'fortune-daily',
  userId: user.id,
  timestamp: new Date().toISOString(),
  error: error.message
}))
```

## Flutter App Integration

### 1. Update API endpoints
```dart
// lib/core/constants/api_endpoints.dart
class ApiEndpoints {
  static const String baseUrl = 'https://[your-project-ref].supabase.co/functions/v1';
  
  static String getDailyFortune() => '$baseUrl/fortune-daily';
  static String getZodiacFortune() => '$baseUrl/fortune-zodiac';
  // ... other endpoints
}
```

### 2. Update service calls
```dart
// lib/data/services/fortune_api_service.dart
Future<FortuneResult> getDailyFortune(Map<String, dynamic> data) async {
  final response = await _client.post(
    ApiEndpoints.getDailyFortune(),
    data: data,
  );
  
  return FortuneResult.fromJson(response.data);
}
```

## Migration Checklist

- [ ] Set up Supabase project
- [ ] Configure environment variables
- [ ] Deploy shared utilities
- [ ] Deploy fortune functions (one by one)
- [ ] Test each function thoroughly
- [ ] Update Flutter app endpoints
- [ ] Monitor performance
- [ ] Gradual traffic migration
- [ ] Decommission old services

## Rollback Procedure

1. **Quick rollback** - Update Flutter app to use old endpoints
2. **Function rollback** - Deploy previous version
```bash
supabase functions deploy fortune-daily --version previous
```

## Performance Optimization

1. **Enable caching**
- Use fortune_cache table
- Set appropriate TTL

2. **Optimize cold starts**
- Keep functions small
- Minimize dependencies

3. **Monitor latency**
- Track p95 response times
- Optimize slow functions

## Cost Management

1. **Monitor usage**
- Check invocation counts
- Track compute time

2. **Optimize token usage**
- Cache OpenAI responses
- Batch similar requests

3. **Set alerts**
- Configure usage alerts
- Monitor billing dashboard