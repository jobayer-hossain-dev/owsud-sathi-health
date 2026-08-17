const { validationResult } = require('express-validator');
const { errorResponse } = require('../utils/helpers');

/**
 * Express-validator middleware wrapper
 * Runs after validation rules, returns 400 if errors found
 */
function validate(req, res, next) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    const messages = errors.array().map((e) => e.msg);
    return errorResponse(res, messages[0], 400, errors.array());
  }
  next();
}

module.exports = validate;
