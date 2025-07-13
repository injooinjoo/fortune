import { Request, Response, NextFunction } from 'express';
import Joi from 'joi';
import { ValidationError } from '../utils/errors';

export function validateRequest(schema: Joi.ObjectSchema) {
  return (req: Request, res: Response, next: NextFunction): void => {
    const { error } = schema.validate(req.body, {
      abortEarly: false,
      stripUnknown: true,
    });

    if (error) {
      const details = error.details.map((detail) => ({
        field: detail.path.join('.'),
        message: detail.message,
      }));
      
      return next(new ValidationError('Validation failed', details));
    }

    next();
  };
}

export function validateQuery(schema: Joi.ObjectSchema) {
  return (req: Request, res: Response, next: NextFunction): void => {
    const { error } = schema.validate(req.query, {
      abortEarly: false,
      stripUnknown: true,
    });

    if (error) {
      const details = error.details.map((detail) => ({
        field: detail.path.join('.'),
        message: detail.message,
      }));
      
      return next(new ValidationError('Query validation failed', details));
    }

    next();
  };
}

export function validateParams(schema: Joi.ObjectSchema) {
  return (req: Request, res: Response, next: NextFunction): void => {
    const { error } = schema.validate(req.params, {
      abortEarly: false,
      stripUnknown: true,
    });

    if (error) {
      const details = error.details.map((detail) => ({
        field: detail.path.join('.'),
        message: detail.message,
      }));
      
      return next(new ValidationError('Parameter validation failed', details));
    }

    next();
  };
}