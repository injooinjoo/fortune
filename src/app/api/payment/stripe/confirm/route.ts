import { NextRequest } from 'next/server';
import { withAuth, AuthenticatedRequest } from '@/middleware/auth';
import { createSuccessResponse, createErrorResponse } from '@/lib/api-response-utils';
import { logger } from '@/lib/logger';
import { supabase } from '@/lib/supabase';
import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2024-12-18.acacia',
});

export async function POST(request: NextRequest) {
  return withAuth(request, async (req: AuthenticatedRequest) => {
    try {
      const body = await req.json();
      const { paymentIntentId, userId } = body;
      
      if (!paymentIntentId) {
        return createErrorResponse('Payment intent ID is required', undefined, undefined, 400);
      }
      
      // Retrieve the payment intent from Stripe
      const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);
      
      if (paymentIntent.status !== 'succeeded') {
        return createErrorResponse('Payment not completed', undefined, undefined, 400);
      }
      
      // Record successful payment
      const { error: insertError } = await supabase
        .from('payment_history')
        .insert({
          user_id: req.userId!,
          payment_intent_id: paymentIntentId,
          amount: paymentIntent.amount,
          currency: paymentIntent.currency,
          status: 'completed',
          metadata: paymentIntent.metadata,
          created_at: new Date().toISOString()
        });
      
      if (insertError) {
        logger.error('Failed to record payment', insertError);
      }
      
      logger.info('Payment confirmed', {
        userId: req.userId,
        paymentIntentId,
        amount: paymentIntent.amount
      });
      
      return createSuccessResponse({
        success: true,
        paymentIntentId,
        amount: paymentIntent.amount,
        status: paymentIntent.status
      });
      
    } catch (error) {
      logger.error('Failed to confirm payment', error);
      return createErrorResponse('Failed to confirm payment', undefined, undefined, 500);
    }
  });
}