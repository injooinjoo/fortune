import Joi from 'joi';

export const tokenSchemas = {
  consume: Joi.object({
    amount: Joi.number().positive().integer().required(),
    type: Joi.string().required(),
    metadata: Joi.object().optional(),
  }),
};