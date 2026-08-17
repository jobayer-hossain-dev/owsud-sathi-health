const { verifyToken } = require('../utils/jwt');
const { pool } = require('../config/database');
const { errorResponse } = require('../utils/helpers');

/**
 * Admin Authentication Middleware
 * Verifies JWT and checks if user is an admin
 */
async function adminAuth(req, res, next) {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return errorResponse(res, 'Admin authentication required', 401);
    }

    const token = authHeader.split(' ')[1];
    const decoded = verifyToken(token);

    // Check if this is an admin token
    if (!decoded.isAdmin) {
      return errorResponse(res, 'Access denied — admin only', 403);
    }

    // Verify admin still exists and is active
    const [rows] = await pool.execute(
      'SELECT id, email, name, role FROM admins WHERE id = ? AND is_active = 1',
      [decoded.id]
    );

    if (rows.length === 0) {
      return errorResponse(res, 'Admin account not found or disabled', 403);
    }

    req.admin = rows[0];
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return errorResponse(res, 'Session expired, please login again', 401);
    }
    return errorResponse(res, 'Invalid admin token', 401);
  }
}

module.exports = adminAuth;
