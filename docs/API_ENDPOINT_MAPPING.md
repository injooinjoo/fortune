# API Endpoint Mapping: Express.js to Edge Functions

## Overview
This document maps all Express.js API endpoints to their corresponding Supabase Edge Functions.

## Fortune Endpoints

### Basic Fortune Endpoints
| Express.js Endpoint | Edge Function | Status |
|-------------------|---------------|---------|
| POST /api/v1/fortune/daily | POST /functions/v1/fortune-daily | ✅ Created |
| POST /api/v1/fortune/today | POST /functions/v1/fortune-today | 🔄 Pending |
| POST /api/v1/fortune/tomorrow | POST /functions/v1/fortune-tomorrow | 🔄 Pending |
| POST /api/v1/fortune/weekly | POST /functions/v1/fortune-weekly | 🔄 Pending |
| POST /api/v1/fortune/monthly | POST /functions/v1/fortune-monthly | 🔄 Pending |
| POST /api/v1/fortune/yearly | POST /functions/v1/fortune-yearly | 🔄 Pending |
| POST /api/v1/fortune/hourly | POST /functions/v1/fortune-hourly | 🔄 Pending |

### Traditional Fortune Endpoints
| Express.js Endpoint | Edge Function | Status |
|-------------------|---------------|---------|
| POST /api/v1/fortune/saju | POST /functions/v1/fortune-saju | 🔄 Pending |
| POST /api/v1/fortune/traditional-saju | POST /functions/v1/fortune-traditional-saju | 🔄 Pending |
| POST /api/v1/fortune/saju-psychology | POST /functions/v1/fortune-saju-psychology | 🔄 Pending |
| POST /api/v1/fortune/tojeong | POST /functions/v1/fortune-tojeong | 🔄 Pending |
| POST /api/v1/fortune/salpuli | POST /functions/v1/fortune-salpuli | 🔄 Pending |
| POST /api/v1/fortune/palmistry | POST /functions/v1/fortune-palmistry | 🔄 Pending |
| POST /api/v1/fortune/physiognomy | POST /functions/v1/fortune-physiognomy | 🔄 Pending |

### Love & Relationship Fortune Endpoints
| Express.js Endpoint | Edge Function | Status |
|-------------------|---------------|---------|
| POST /api/v1/fortune/love | POST /functions/v1/fortune-love | 🔄 Pending |
| POST /api/v1/fortune/marriage | POST /functions/v1/fortune-marriage | 🔄 Pending |
| POST /api/v1/fortune/compatibility | POST /functions/v1/fortune-compatibility | 🔄 Pending |
| POST /api/v1/fortune/couple-match | POST /functions/v1/fortune-couple-match | 🔄 Pending |
| POST /api/v1/fortune/chemistry | POST /functions/v1/fortune-chemistry | 🔄 Pending |

### Lucky Item Fortune Endpoints
| Express.js Endpoint | Edge Function | Status |
|-------------------|---------------|---------|
| POST /api/v1/fortune/lucky-number | POST /functions/v1/fortune-lucky-number | 🔄 Pending |
| POST /api/v1/fortune/lucky-color | POST /functions/v1/fortune-lucky-color | 🔄 Pending |
| POST /api/v1/fortune/lucky-food | POST /functions/v1/fortune-lucky-food | 🔄 Pending |
| POST /api/v1/fortune/lucky-items | POST /functions/v1/fortune-lucky-items | 🔄 Pending |

## Token Management Endpoints

| Express.js Endpoint | Edge Function | Status |
|-------------------|---------------|---------|
| GET /api/v1/token/balance | GET /functions/v1/token-balance | ✅ Created |
| GET /api/v1/token/history | GET /functions/v1/token-history | 🔄 Pending |
| POST /api/v1/token/use | POST /functions/v1/token-use | 🔄 Pending |
| POST /api/v1/token/grant-daily | POST /functions/v1/token-daily-claim | 🔄 Pending |

## Payment Endpoints

| Express.js Endpoint | Edge Function | Status |
|-------------------|---------------|---------|
| POST /api/v1/payment/verify-purchase | POST /functions/v1/payment-verify-purchase | 🔄 Pending |
| POST /api/v1/payment/verify-subscription | POST /functions/v1/payment-verify-subscription | 🔄 Pending |
| POST /api/v1/payment/restore-purchases | POST /functions/v1/payment-restore-purchases | 🔄 Pending |

## User Management Endpoints

| Express.js Endpoint | Edge Function | Status |
|-------------------|---------------|---------|
| GET /api/v1/user/profile | GET /functions/v1/user-profile | 🔄 Pending |
| PUT /api/v1/user/profile | PUT /functions/v1/user-profile | 🔄 Pending |
| DELETE /api/v1/user/account | DELETE /functions/v1/user-account | 🔄 Pending |

## Admin Endpoints

| Express.js Endpoint | Edge Function | Status |
|-------------------|---------------|---------|
| GET /api/v1/admin/stats | GET /functions/v1/admin-stats | 🔄 Pending |
| GET /api/v1/admin/users | GET /functions/v1/admin-users | 🔄 Pending |
| POST /api/v1/admin/tokens/add | POST /functions/v1/admin-tokens-add | 🔄 Pending |

## Authentication Endpoints

| Express.js Endpoint | Edge Function | Status |
|-------------------|---------------|---------|
| POST /api/v1/auth/login | Handled by Supabase Auth | ✅ Built-in |
| POST /api/v1/auth/signup | Handled by Supabase Auth | ✅ Built-in |
| POST /api/v1/auth/logout | Handled by Supabase Auth | ✅ Built-in |
| POST /api/v1/auth/refresh | Handled by Supabase Auth | ✅ Built-in |

## Migration Priority

### High Priority (Week 1)
1. ✅ Token balance endpoint
2. 🔄 Daily claim endpoint
3. 🔄 Daily/Weekly/Monthly fortune endpoints
4. 🔄 Payment verification endpoints

### Medium Priority (Week 2-3)
1. 🔄 All fortune generation endpoints
2. 🔄 User profile management
3. 🔄 Token history

### Low Priority (Week 4)
1. 🔄 Admin endpoints
2. 🔄 Analytics endpoints
3. 🔄 Batch operations

## Flutter App Changes Required

### 1. Update Base URL
```dart
// Before
const String API_BASE_URL = 'https://fortune-api-server.run.app/api/v1';

// After
const String API_BASE_URL = 'https://[project-ref].supabase.co/functions/v1';
```

### 2. Update Headers
```dart
// Add Supabase headers
headers['apikey'] = SUPABASE_ANON_KEY;
headers['Authorization'] = 'Bearer $userToken';
```

### 3. Update Error Handling
```dart
// Handle Edge Function specific errors
if (response.statusCode == 402) {
  // Insufficient tokens
  throw InsufficientTokensException();
}
```

## Testing Checklist

- [ ] Test authentication flow
- [ ] Test token balance retrieval
- [ ] Test fortune generation
- [ ] Test token deduction
- [ ] Test caching mechanism
- [ ] Test error handling
- [ ] Test payment verification
- [ ] Load test Edge Functions
- [ ] Monitor cold start times
- [ ] Verify CORS handling