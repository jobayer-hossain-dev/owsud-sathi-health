const config = require('../config/config');

/**
 * Send OTP via BulkSMSBD API
 * In development mode, just logs to console
 * 
 * BulkSMSBD API Docs: https://bulksmsbd.net/developer/api
 */
async function sendOTP(phone, otp) {
  const message = `আপনার OshudhSathi যাচাইকরণ কোড: ${otp}\nকোডটি ${config.otp.expiryMinutes} মিনিট কার্যকর থাকবে।`;

  // Development mode — just log to console
  if (config.app.env === 'development') {
    console.log(`\n📱 [DEV MODE] OTP for ${phone}: ${otp}`);
    console.log(`   Message: ${message}\n`);
    return { success: true, mode: 'development' };
  }

  // Production — send via BulkSMSBD API
  try {
    const response = await fetch('https://bulksmsbd.net/api/smsapi', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        api_key: config.sms.apiKey,
        senderid: config.sms.senderId,
        number: phone,
        message: message,
        type: 'text',
      }),
    });

    const data = await response.json();

    if (data.response_code === 202) {
      return { success: true, messageId: data.message_id };
    } else {
      console.error('SMS send failed:', data);
      return { success: false, error: data.error_message || 'SMS পাঠানো যায়নি' };
    }
  } catch (error) {
    console.error('SMS service error:', error.message);
    return { success: false, error: 'SMS সার্ভিসে সমস্যা হয়েছে' };
  }
}

module.exports = { sendOTP };
