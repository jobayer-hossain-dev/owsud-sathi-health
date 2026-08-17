const { verifyToken } = require('../utils/jwt');
const { errorResponse } = require('../utils/helpers');

/**
 * JWT Authentication Middleware
 * Extracts Bearer token from Authorization header, verifies it,
 * and attaches user info to req.user
 */
function auth(req, res, next) {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return errorResponse(res, 'অনুগ্রহ করে লগইন করুন', 401);
    }

    const token = authHeader.split(' ')[1];
    const decoded = verifyToken(token);

    req.user = {
      id: decoded.id,
      phone: decoded.phone,
      name: decoded.name,
    };

    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return errorResponse(res, 'সেশন মেয়াদ শেষ হয়েছে, পুনরায় লগইন করুন', 401);
    }
    return errorResponse(res, 'অবৈধ টোকেন', 401);
  }
}

module.exports = auth;
