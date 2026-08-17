const config = require('../config/config');

/**
 * Send Firebase Cloud Messaging (FCM) push notification
 * Useful for dose reminders, refill alerts, and appointment notices
 */
async function sendPushNotification(fcmToken, { title, body, data = {} }) {
  if (!fcmToken) {
    return { success: false, error: 'No FCM token provided' };
  }

  // Development simulation if no server key
  if (config.app.env === 'development' && (!config.fcm.serverKey || config.fcm.serverKey === 'test_key')) {
    console.log(`\n🔔 [DEV PUSH NOTIFICATION]`);
    console.log(`   To Token: ${fcmToken.slice(0, 15)}...`);
    console.log(`   Title: ${title}`);
    console.log(`   Body: ${body}`);
    console.log(`   Data:`, data, '\n');
    return { success: true, mode: 'development' };
  }

  try {
    const response = await fetch('https://fcm.googleapis.com/fcm/send', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `key=${config.fcm.serverKey}`,
      },
      body: JSON.stringify({
        to: fcmToken,
        notification: {
          title,
          body,
          sound: 'default',
        },
        data: {
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
          ...data,
        },
      }),
    });

    const result = await response.json();
    return { success: result.success === 1, result };
  } catch (error) {
    console.error('FCM Send Error:', error.message);
    return { success: false, error: error.message };
  }
}

/**
 * Send Firebase Cloud Messaging (FCM) topic broadcast
 */
async function sendToTopic(topic, title, body, data = {}) {
  if (config.app.env === 'development' && (!config.fcm.serverKey || config.fcm.serverKey === 'test_key')) {
    console.log(`\n🔔 [DEV PUSH TOPIC BROADCAST]`);
    console.log(`   To Topic: /topics/${topic}`);
    console.log(`   Title: ${title}`);
    console.log(`   Body: ${body}`);
    console.log(`   Data:`, data, '\n');
    return { success: true, mode: 'development' };
  }

  try {
    const response = await fetch('https://fcm.googleapis.com/fcm/send', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `key=${config.fcm.serverKey}`,
      },
      body: JSON.stringify({
        to: `/topics/${topic}`,
        notification: {
          title,
          body,
          sound: 'default',
        },
        data: {
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
          ...data,
        },
      }),
    });

    const result = await response.json();
    return { success: result.success === 1, result };
  } catch (error) {
    console.error('FCM Topic Send Error:', error.message);
    return { success: false, error: error.message };
  }
}

module.exports = { sendPushNotification, sendToTopic };
