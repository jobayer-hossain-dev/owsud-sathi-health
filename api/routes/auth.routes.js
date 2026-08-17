const express = require('express');
const { body } = require('express-validator');
const validate = require('../middleware/validate');
const authController = require('../controllers/auth.controller');

const router = express.Router();

// POST /api/v1/auth/send-otp
router.post(
  '/send-otp',
  [
    body('phone')
      .notEmpty().withMessage('ফোন নম্বর দিন')
      .matches(/^01[3-9]\d{8}$/).withMessage('সঠিক বাংলাদেশি ফোন নম্বর দিন (01XXXXXXXXX)'),
  ],
  validate,
  authController.sendOTP
);

// POST /api/v1/auth/verify-otp
router.post(
  '/verify-otp',
  [
    body('phone')
      .notEmpty().withMessage('ফোন নম্বর দিন')
      .matches(/^01[3-9]\d{8}$/).withMessage('সঠিক ফোন নম্বর দিন'),
    body('code')
      .notEmpty().withMessage('OTP কোড দিন')
      .isLength({ min: 6, max: 6 }).withMessage('৬ সংখ্যার OTP কোড দিন'),
  ],
  validate,
  authController.verifyOTP
);

// POST /api/v1/auth/register
router.post(
  '/register',
  [
    body('name')
      .notEmpty().withMessage('নাম দিন')
      .isLength({ min: 2, max: 100 }).withMessage('নাম ২-১০০ অক্ষরের মধ্যে হতে হবে'),
    body('password')
      .notEmpty().withMessage('পাসওয়ার্ড দিন')
      .isLength({ min: 6 }).withMessage('পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে'),
  ],
  validate,
  authController.register
);

// POST /api/v1/auth/login
router.post(
  '/login',
  [
    body('phone')
      .notEmpty().withMessage('ফোন নম্বর দিন')
      .matches(/^01[3-9]\d{8}$/).withMessage('সঠিক ফোন নম্বর দিন'),
    body('password')
      .notEmpty().withMessage('পাসওয়ার্ড দিন'),
  ],
  validate,
  authController.login
);

module.exports = router;
