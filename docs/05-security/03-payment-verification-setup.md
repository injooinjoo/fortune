# Payment Verification Setup Guide

This guide explains how to set up payment verification for Apple App Store and Google Play Store in-app purchases.

## Overview

The payment verification system validates all in-app purchases with Apple and Google servers to prevent fraud and ensure legitimate transactions.

## Apple App Store Setup

### 1. Generate Shared Secret

1. Log in to [App Store Connect](https://appstoreconnect.apple.com)
2. Go to **Apps** → Select your app
3. Navigate to **App Information** → **App-Specific Shared Secret**
4. Click **Generate** or **Regenerate**
5. Copy the shared secret

### 2. Configure Environment Variable

Add the shared secret to your environment:

```bash
# Production
APPLE_IAP_SHARED_SECRET=your-shared-secret-here
```

### 3. Test Receipt Validation

The system automatically handles both production and sandbox receipts:
- Production receipts: Verified against `https://buy.itunes.apple.com/verifyReceipt`
- Sandbox receipts: Automatically retried against `https://sandbox.itunes.apple.com/verifyReceipt`

## Google Play Store Setup

### 1. Create Service Account

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Select your project or create a new one
3. Navigate to **IAM & Admin** → **Service Accounts**
4. Click **Create Service Account**
5. Fill in:
   - Service account name: `fortune-iap-verifier`
   - Service account ID: (auto-generated)
   - Description: "Service account for IAP verification"
6. Click **Create and Continue**

### 2. Grant Permissions

1. In Google Play Console, go to **Settings** → **API access**
2. Link your Google Cloud project
3. Find your service account in the list
4. Click **Grant Access**
5. In the permissions dialog, grant:
   - **View financial data**
   - **Manage orders and subscriptions**

### 3. Generate Service Account Key

1. Back in Google Cloud Console
2. Go to your service account
3. Navigate to **Keys** tab
4. Click **Add Key** → **Create new key**
5. Choose **JSON** format
6. Download the key file

### 4. Configure Environment Variable

Add the service account JSON to your environment:

```bash
# Copy the entire JSON content
GOOGLE_SERVICE_ACCOUNT='{"type":"service_account","project_id":"your-project",...}'
```

**Important**: Store this as a single-line JSON string in your environment variables.

## Testing Payment Verification

### iOS Testing

1. Use sandbox test accounts
2. Make a test purchase in your app
3. Check the Edge Function logs for verification status
4. Verify the transaction appears in your database

### Android Testing

1. Use test accounts configured in Google Play Console
2. Make a test purchase in your app
3. Check the Edge Function logs for verification status
4. Verify the transaction appears in your database

## Security Best Practices

1. **Never expose secrets in client code**
   - All verification happens server-side
   - Client only sends purchase tokens/receipts

2. **Validate all fields**
   - Product ID must match expected values
   - Transaction ID must be unique
   - Purchase state must be valid

3. **Handle edge cases**
   - Network failures
   - Invalid receipts
   - Duplicate transactions
   - Refunds and cancellations

## Monitoring

Monitor these metrics:
- Verification success/failure rates
- Response times from Apple/Google servers
- Duplicate transaction attempts
- Failed acknowledgements (Android)

## Troubleshooting

### Apple Verification Errors

| Status Code | Meaning | Action |
|------------|---------|--------|
| 0 | Valid receipt | Process normally |
| 21000 | Bad JSON | Check receipt format |
| 21002 | Malformed receipt | Client issue |
| 21003 | Authentication failed | Check shared secret |
| 21007 | Sandbox receipt | Auto-retry handled |
| 21008 | Production receipt | Check environment |

### Google Verification Errors

| Error | Meaning | Action |
|-------|---------|--------|
| 401 | Authentication failed | Check service account |
| 403 | Permission denied | Grant proper permissions |
| 404 | Purchase not found | May be consumed/expired |
| 410 | Purchase expired | Normal for old purchases |

## Database Schema

Transactions are stored in the `payment_transactions` table:

```sql
CREATE TABLE payment_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  transaction_id TEXT UNIQUE NOT NULL,
  platform TEXT NOT NULL,
  product_id TEXT NOT NULL,
  amount INTEGER NOT NULL,
  tokens_purchased INTEGER NOT NULL,
  status TEXT NOT NULL,
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

## Next Steps

1. Set up monitoring alerts for failed verifications
2. Implement webhook handlers for subscription status changes
3. Add admin dashboard for transaction management
4. Set up automated refund processing