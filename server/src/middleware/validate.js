import Joi from 'joi';

function makeValidator(schema, property = 'body') {
  return (req, res, next) => {
    const { error, value } = schema.validate(req[property], { abortEarly: false, stripUnknown: true });
    if (error) {
      return res.status(400).json({ error: 'Validation failed', details: error.details.map((d) => d.message) });
    }
    req[property] = value;
    next();
  };
}

export const validateBody = (schema) => makeValidator(schema, 'body');
export const validateParams = (schema) => makeValidator(schema, 'params');
export const validateQuery = (schema) => makeValidator(schema, 'query');

export const uuidParam = Joi.string().guid({ version: 'uuidv4' }).required();
