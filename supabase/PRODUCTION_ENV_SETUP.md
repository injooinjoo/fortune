# Supabase Edge Functions Production Environment Variables

This document lists all environment variables that need to be configured in Supabase Dashboard for production deployment.

## Setting Environment Variables in Supabase

1. Go to your Supabase Dashboard
2. Navigate to **Edge Functions** → **Secrets**
3. Add the following environment variables:

## Required Environment Variables

### Core Configuration

- `OPENAI_API_KEY` - Your OpenAI API key for fortune generation
  - Get from: https://platform.openai.com/api-keys
  - Required for: All fortune generation functions

- `SUPABASE_URL` - Your Supabase project URL
  - Already set by Supabase
  
- `SUPABASE_ANON_KEY` - Your Supabase anonymous key
  - Already set by Supabase
  
- `SUPABASE_SERVICE_ROLE_KEY` - Your Supabase service role key
  - Already set by Supabase

### Payment Configuration

- `STRIPE_SECRET_KEY` - Your Stripe secret key
  - Get from: https://dashboard.stripe.com/apikeys
  - Required for: Payment processing
  
- `STRIPE_WEBHOOK_SECRET` - Your Stripe webhook endpoint secret
  - Get from: Stripe Dashboard → Webhooks
  - Required for: Payment webhook verification

- `TOSS_SECRET_KEY` - Your Toss Payments secret key
  - Get from: Toss Payments Dashboard
  - Required for: Korean payment processing

### Feature Flags

These should match your Flutter app configuration:

- `ENABLE_ANALYTICS` - Enable/disable analytics (true/false)
- `ENABLE_CRASH_REPORTING` - Enable/disable crash reporting (true/false)
- `ENABLE_ADS` - Enable/disable ads (true/false)
- `ENABLE_PAYMENT` - Enable/disable payment features (true/false)
- `USE_EDGE_FUNCTIONS` - Should always be true for Edge Functions

### API Configuration

- `API_VERSION` - API version (default: v1)

### Rate Limiting (Optional)

- `RATE_LIMIT_PER_MINUTE` - Global rate limit (default: 100)
- `RATE_LIMIT_PER_USER_PER_MINUTE` - Per-user rate limit (default: 20)

### Token Configuration (Optional)

- `DAILY_TOKEN_GRANT` - Daily free tokens for users (default: 3)
- `DEFAULT_TOKEN_COST` - Default token cost per fortune (default: 1)

### Cache Configuration (Optional)

- `CACHE_TTL_SECONDS` - Cache time-to-live in seconds (default: 86400)
- `FORTUNE_CACHE_ENABLED` - Enable/disable fortune caching (default: true)

### Environment

- `ENVIRONMENT` - Set to "production" for production deployment

## Important Notes

1. **Security**: Never commit actual API keys or secrets to version control
2. **Consistency**: Ensure feature flags match between Flutter app and Edge Functions
3. **Testing**: Test with development keys before using production keys
4. **Monitoring**: Monitor API usage and costs, especially for OpenAI

## Deployment Checklist

- [ ] Set all required environment variables in Supabase Dashboard
- [ ] Verify OpenAI API key has sufficient credits
- [ ] Configure Stripe webhook endpoints
- [ ] Test payment flows with test keys first
- [ ] Enable appropriate feature flags
- [ ] Set ENVIRONMENT to "production"