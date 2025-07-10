import { NextRequest } from 'next/server';
import { withAuth, AuthenticatedRequest } from '@/middleware/auth';
import { createSuccessResponse, createErrorResponse } from '@/lib/api-response-utils';
import { createOrUpdateCustomer, createPaymentIntent } from '@/lib/payment/stripe-client';
import { logger } from '@/lib/logger';
import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2024-12-18.acacia',
});

export async function POST(request: NextRequest) {
  return withAuth(request, async (req: AuthenticatedRequest) => {
    try {
      const body = await req.json();
      const { amount, currency = 'krw', userId } = body;
      
      if (!amount || amount <= 0) {
        return createErrorResponse('Invalid amount', undefined, undefined, 400);
      }
      
      // Create or update Stripe customer
      const customer = await createOrUpdateCustomer(req.userEmail!, req.userId!);
      
      // Create ephemeral key for mobile SDK
      const ephemeralKey = await stripe.ephemeralKeys.create(
        { customer: customer.id },
        { apiVersion: '2024-12-18.acacia' }
      );
      
      // Create payment intent
      const paymentIntent = await createPaymentIntent(
        amount,
        customer.id,
        {
          userId: req.userId!,
          timestamp: new Date().toISOString()
        }
      );
      
      logger.info('Created payment intent for Flutter app', {
        userId: req.userId,
        amount,
        paymentIntentId: paymentIntent.id
      });
      
      return createSuccessResponse({
        payment_intent_id: paymentIntent.id,
        client_secret: paymentIntent.client_secret,
        customer: customer.id,
        ephemeral_key: ephemeralKey.secret,
        publishable_key: process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY
      });
      
    } catch (error) {
      logger.error('Failed to create payment intent', error);
      return createErrorResponse('Failed to create payment intent', undefined, undefined, 500);
    }
  });
}