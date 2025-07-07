#!/usr/bin/env node

const crypto = require('crypto');

// Test webhook endpoint locally
async function testWebhook() {
  const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET || 'whsec_test_secret';
  
  // Sample webhook event
  const event = {
    id: 'evt_test_' + Date.now(),
    object: 'event',
    api_version: '2024-11-20.acacia',
    created: Math.floor(Date.now() / 1000),
    data: {
      object: {
        id: 'cs_test_' + Date.now(),
        object: 'checkout.session',
        amount_total: 9900,
        currency: 'krw',
        customer: 'cus_test_123',
        mode: 'subscription',
        payment_status: 'paid',
        subscription: 'sub_test_123',
        metadata: {
          userId: 'test_user_123',
          productId: 'premium_monthly'
        }
      }
    },
    type: 'checkout.session.completed'
  };

  const payload = JSON.stringify(event);
  
  // Generate Stripe signature
  const timestamp = Math.floor(Date.now() / 1000);
  const signedPayload = `${timestamp}.${payload}`;
  const expectedSignature = crypto
    .createHmac('sha256', webhookSecret)
    .update(signedPayload)
    .digest('hex');
  
  const signature = `t=${timestamp},v1=${expectedSignature}`;

  try {
    const response = await fetch('http://localhost:9002/api/payment/webhook/stripe', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'stripe-signature': signature
      },
      body: payload
    });

    const result = await response.json();
    console.log('Response status:', response.status);
    console.log('Response body:', result);
    
    if (response.ok) {
      console.log('✅ Webhook test successful!');
    } else {
      console.log('❌ Webhook test failed');
    }
  } catch (error) {
    console.error('Error testing webhook:', error);
  }
}

// Run test
console.log('🧪 Testing payment webhook...\n');
testWebhook();