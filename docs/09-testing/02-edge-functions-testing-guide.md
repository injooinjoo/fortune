# Supabase Edge Functions Testing Guide

## 🚀 Quick Start

### 1. Local Testing Setup

```bash
# Start Supabase locally
cd /Users/jacobmac/Desktop/Dev/fortune
supabase start

# Serve Edge Functions locally
supabase functions serve --env-file ./supabase/.env.local
```

### 2. Test Individual Functions

#### Test Daily Fortune
```bash
# Get your local Supabase anon key
supabase status

# Test daily fortune endpoint
curl -X POST http://localhost:54321/functions/v1/fortune-daily \
  -H "Authorization: Bearer YOUR_LOCAL_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "테스트",
    "birthDate": "1990-01-01"
  }'
```

#### Test Token Balance
```bash
curl -X GET http://localhost:54321/functions/v1/token-balance \
  -H "Authorization: Bearer YOUR_LOCAL_ANON_KEY"
```

#### Test Daily Token Claim
```bash
curl -X POST http://localhost:54321/functions/v1/token-daily-claim \
  -H "Authorization: Bearer YOUR_LOCAL_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{}'
```

## 📱 Flutter App Testing

### 1. Enable Edge Functions for Testing

```dart
// In your app initialization
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize feature flags
  final userId = await getCurrentUserId();
  FeatureFlags().initialize(userId: userId);
  
  // Force enable Edge Functions for testing
  FeatureFlags().enableEdgeFunctions();
  
  runApp(MyApp());
}
```

### 2. Update API Service Provider

```dart
// In providers.dart
final fortuneApiServiceProvider = Provider<FortuneApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  // Use the Edge Functions version
  return FortuneApiServiceWithEdgeFunctions(apiClient);
});
```

### 3. Test Scenarios

#### Scenario 1: Daily Fortune Generation
1. Open the app
2. Navigate to Daily Fortune
3. Generate a fortune
4. Verify token deduction
5. Check if result is cached

#### Scenario 2: Token Management
1. Check token balance
2. Claim daily tokens
3. Verify balance update
4. Try claiming again (should fail)

#### Scenario 3: Payment Flow
1. Navigate to token purchase
2. Complete in-app purchase
3. Verify tokens added
4. Check transaction history

## 🔍 Debugging

### View Function Logs
```bash
# Real-time logs
supabase functions logs fortune-daily --tail

# Check specific errors
supabase functions logs token-balance --limit 50
```

### Common Issues

1. **CORS Error**
   - Check if OPTIONS handling is correct
   - Verify headers in Edge Function

2. **Authentication Error**
   - Ensure JWT token is valid
   - Check if user exists in Supabase Auth

3. **Token Balance Issues**
   - Verify user_profiles table has entry
   - Check RLS policies

## 🚀 Production Deployment

### 1. Deploy to Production

```bash
# Link to production project
supabase link --project-ref hayjukwfcsdmppairazc

# Set production secrets
supabase secrets set OPENAI_API_KEY="your-production-key"

# Deploy all functions
./scripts/deploy-edge-functions.sh
```

### 2. Gradual Rollout

```dart
// Set rollout percentage (e.g., 10% of users)
FeatureFlags().setEdgeFunctionsRolloutPercentage(10);

// Add specific test users
FeatureFlags().addEdgeFunctionsTestUser('user-id-1');
FeatureFlags().addEdgeFunctionsTestUser('user-id-2');
```

### 3. Monitor Performance

```sql
-- Check function invocations
SELECT 
  function_name,
  COUNT(*) as invocations,
  AVG(response_time_ms) as avg_response_time,
  MAX(response_time_ms) as max_response_time
FROM edge_function_logs
WHERE created_at > NOW() - INTERVAL '1 hour'
GROUP BY function_name;
```

## 📊 Performance Benchmarks

### Expected Response Times
- Token Balance: < 100ms
- Daily Fortune (cached): < 200ms
- Daily Fortune (generated): < 2000ms
- Payment Verification: < 500ms

### Load Testing
```bash
# Install Apache Bench
apt-get install apache2-utils

# Test token balance endpoint
ab -n 100 -c 10 \
  -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:54321/functions/v1/token-balance
```

## ✅ Pre-Deployment Checklist

- [ ] All Edge Functions created and tested locally
- [ ] Environment variables configured
- [ ] Database migrations applied
- [ ] Flutter app updated with Edge Functions support
- [ ] Feature flags configured for gradual rollout
- [ ] Error handling tested
- [ ] Performance benchmarks met
- [ ] Monitoring setup complete
- [ ] Rollback plan documented

## 🔄 Rollback Plan

If issues arise:

1. **Immediate Rollback**
   ```dart
   // Disable Edge Functions globally
   FeatureFlags().disableEdgeFunctions();
   ```

2. **Partial Rollback**
   ```dart
   // Reduce rollout percentage
   FeatureFlags().setEdgeFunctionsRolloutPercentage(0);
   ```

3. **Monitor and Fix**
   - Check error logs
   - Fix issues
   - Re-deploy
   - Gradually increase rollout

## 📞 Support

For issues or questions:
1. Check Supabase Dashboard logs
2. Review Edge Functions documentation
3. Check Flutter app error logs
4. Monitor user feedback