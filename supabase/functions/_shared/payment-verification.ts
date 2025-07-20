// Payment verification utilities for Apple and Google IAP

interface AppleVerifyReceiptResponse {
  status: number;
  receipt: {
    bundle_id: string;
    in_app: Array<{
      product_id: string;
      transaction_id: string;
      original_transaction_id: string;
      purchase_date_ms: string;
      expires_date_ms?: string;
    }>;
  };
  latest_receipt_info?: Array<{
    product_id: string;
    transaction_id: string;
    original_transaction_id: string;
    purchase_date_ms: string;
    expires_date_ms?: string;
  }>;
}

interface GooglePurchaseData {
  orderId: string;
  packageName: string;
  productId: string;
  purchaseTime: number;
  purchaseState: number;
  purchaseToken: string;
  acknowledged?: boolean;
}

interface GoogleVerifyResponse {
  kind: string;
  purchaseTimeMillis: string;
  purchaseState: number;
  consumptionState: number;
  developerPayload?: string;
  orderId: string;
  acknowledgementState: number;
}

// Apple StoreKit verification
export async function verifyAppleReceipt(
  receipt: string,
  isProduction: boolean = true
): Promise<{ valid: boolean; data?: any; error?: string }> {
  const verifyUrl = isProduction
    ? 'https://buy.itunes.apple.com/verifyReceipt'
    : 'https://sandbox.itunes.apple.com/verifyReceipt';

  try {
    const response = await fetch(verifyUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        'receipt-data': receipt,
        password: Deno.env.get('APPLE_IAP_SHARED_SECRET'),
        'exclude-old-transactions': true,
      }),
    });

    const data: AppleVerifyReceiptResponse = await response.json();

    // Status codes:
    // 0 - Valid
    // 21007 - Receipt is from sandbox (retry with sandbox URL)
    // 21008 - Receipt is from production (when sent to sandbox)
    if (data.status === 21007 && isProduction) {
      // Retry with sandbox URL
      return verifyAppleReceipt(receipt, false);
    }

    if (data.status !== 0) {
      return {
        valid: false,
        error: `Apple verification failed with status: ${data.status}`,
      };
    }

    // Get the latest receipt info
    const latestReceipt = data.latest_receipt_info?.[0] || data.receipt.in_app[0];
    
    if (!latestReceipt) {
      return {
        valid: false,
        error: 'No valid purchase found in receipt',
      };
    }

    return {
      valid: true,
      data: {
        productId: latestReceipt.product_id,
        transactionId: latestReceipt.transaction_id,
        originalTransactionId: latestReceipt.original_transaction_id,
        purchaseDate: new Date(parseInt(latestReceipt.purchase_date_ms)),
        expiresDate: latestReceipt.expires_date_ms
          ? new Date(parseInt(latestReceipt.expires_date_ms))
          : null,
      },
    };
  } catch (error) {
    console.error('Apple receipt verification error:', error);
    return {
      valid: false,
      error: error instanceof Error ? error.message : 'Unknown error',
    };
  }
}

// Google Play verification
export async function verifyGooglePurchase(
  packageName: string,
  productId: string,
  purchaseToken: string
): Promise<{ valid: boolean; data?: any; error?: string }> {
  try {
    // Get access token for Google Play API
    const accessToken = await getGoogleAccessToken();
    
    if (!accessToken) {
      return {
        valid: false,
        error: 'Failed to get Google access token',
      };
    }

    // Verify the purchase
    const verifyUrl = `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${packageName}/purchases/products/${productId}/tokens/${purchaseToken}`;

    const response = await fetch(verifyUrl, {
      method: 'GET',
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
    });

    if (!response.ok) {
      const errorText = await response.text();
      return {
        valid: false,
        error: `Google verification failed: ${response.status} - ${errorText}`,
      };
    }

    const data: GoogleVerifyResponse = await response.json();

    // Check purchase state (0 = purchased, 1 = canceled)
    if (data.purchaseState !== 0) {
      return {
        valid: false,
        error: 'Purchase is not in valid state',
      };
    }

    // Check acknowledgement state
    if (data.acknowledgementState !== 1) {
      // Acknowledge the purchase
      await acknowledgeGooglePurchase(packageName, productId, purchaseToken, accessToken);
    }

    return {
      valid: true,
      data: {
        orderId: data.orderId,
        purchaseTime: new Date(parseInt(data.purchaseTimeMillis)),
        acknowledged: data.acknowledgementState === 1,
      },
    };
  } catch (error) {
    console.error('Google purchase verification error:', error);
    return {
      valid: false,
      error: error instanceof Error ? error.message : 'Unknown error',
    };
  }
}

// Get Google access token using service account
async function getGoogleAccessToken(): Promise<string | null> {
  try {
    const serviceAccount = JSON.parse(
      Deno.env.get('GOOGLE_SERVICE_ACCOUNT') || '{}'
    );

    if (!serviceAccount.client_email || !serviceAccount.private_key) {
      console.error('Invalid Google service account configuration');
      return null;
    }

    // Create JWT for Google OAuth2
    const now = Math.floor(Date.now() / 1000);
    const payload = {
      iss: serviceAccount.client_email,
      scope: 'https://www.googleapis.com/auth/androidpublisher',
      aud: 'https://oauth2.googleapis.com/token',
      exp: now + 3600,
      iat: now,
    };

    // Sign JWT (simplified - in production use proper JWT library)
    const jwt = await createJWT(payload, serviceAccount.private_key);

    // Exchange JWT for access token
    const tokenResponse = await fetch('https://oauth2.googleapis.com/token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams({
        grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        assertion: jwt,
      }),
    });

    const tokenData = await tokenResponse.json();
    return tokenData.access_token;
  } catch (error) {
    console.error('Failed to get Google access token:', error);
    return null;
  }
}

// Acknowledge Google purchase
async function acknowledgeGooglePurchase(
  packageName: string,
  productId: string,
  purchaseToken: string,
  accessToken: string
): Promise<boolean> {
  try {
    const acknowledgeUrl = `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${packageName}/purchases/products/${productId}/tokens/${purchaseToken}:acknowledge`;

    const response = await fetch(acknowledgeUrl, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({}),
    });

    return response.ok;
  } catch (error) {
    console.error('Failed to acknowledge Google purchase:', error);
    return false;
  }
}

// Create JWT using jose library
async function createJWT(payload: any, privateKey: string): Promise<string> {
  // Import jose for JWT creation
  const { SignJWT, importPKCS8 } = await import('https://deno.land/x/jose@v4.14.4/index.ts');
  
  try {
    // Import the private key
    const key = await importPKCS8(privateKey, 'RS256');
    
    // Create and sign the JWT
    const jwt = await new SignJWT(payload)
      .setProtectedHeader({ alg: 'RS256', typ: 'JWT' })
      .sign(key);
    
    return jwt;
  } catch (error) {
    console.error('Failed to create JWT:', error);
    throw new Error('JWT creation failed');
  }
}

// Verify purchase based on platform
export async function verifyPurchase(
  platform: 'ios' | 'android',
  data: {
    productId: string;
    purchaseToken?: string;
    transactionReceipt?: string;
    packageName?: string;
  }
): Promise<{ valid: boolean; data?: any; error?: string }> {
  if (platform === 'ios') {
    if (!data.transactionReceipt) {
      return {
        valid: false,
        error: 'Transaction receipt is required for iOS',
      };
    }
    return verifyAppleReceipt(data.transactionReceipt);
  } else if (platform === 'android') {
    if (!data.purchaseToken || !data.packageName) {
      return {
        valid: false,
        error: 'Purchase token and package name are required for Android',
      };
    }
    return verifyGooglePurchase(
      data.packageName,
      data.productId,
      data.purchaseToken
    );
  }

  return {
    valid: false,
    error: 'Invalid platform',
  };
}