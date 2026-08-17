const config = require('../config/config');

function generateOTP() {
  const digits = config.otp.length;
  const min = Math.pow(10, digits - 1);
  const max = Math.pow(10, digits) - 1;
  return Math.floor(min + Math.random() * (max - min + 1)).toString();
}

function getOTPExpiry() {
  const now = new Date();
  now.setMinutes(now.getMinutes() + config.otp.expiryMinutes);
  return now;
}

module.exports = { generateOTP, getOTPExpiry };
