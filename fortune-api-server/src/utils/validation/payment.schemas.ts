import Joi from 'joi';

export const paymentSchemas = {
  createCheckout: Joi.object({
    priceId: Joi.string().required(),
    successUrl: Joi.string().uri().required(),
    cancelUrl: Joi.string().uri().required(),
    metadata: Joi.object().optional(),
  }),

  createPaymentIntent: Joi.object({
    amount: Joi.number().positive().required(),
    currency: Joi.string().default('usd'),
    metadata: Joi.object().optional(),
  }),

  createSubscription: Joi.object({
    priceId: Joi.string().required(),
    paymentMethodId: Joi.string().required(),
    metadata: Joi.object().optional(),
  }),

  verifyPurchase: Joi.object({
    platform: Joi.string().valid('ios', 'android').required(),
    receiptData: Joi.string().required(),
    productId: Joi.string().required(),
  }),

  confirmSubscription: Joi.object({
    subscriptionId: Joi.string().required(),
  }),

  cancelSubscription: Joi.object({
    subscriptionId: Joi.string().required(),
    reason: Joi.string().optional(),
  }),
};