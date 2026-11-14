const { generateToken04 } = require('zego-server-assistant');

// Replace with your credentials from ZEGOCLOUD Admin Console (https://console.zegocloud.com)
const APP_ID = parseInt(process.env.ZEGO_APP_ID || '123456789');
const SERVER_SECRET = process.env.ZEGO_SERVER_SECRET || 'your_server_secret_32_chars_min';

exports.generateZegoToken = (userId, roomId) => {
  const effectiveTimeInSeconds = 3600; // Token valid for 1 hour
  const payload = '';
  
  const token = generateToken04(
    APP_ID,
    userId.toString(),
    SERVER_SECRET,
    effectiveTimeInSeconds,
    payload
  );

  return {
    appId: APP_ID,
    roomId: roomId,
    userId: userId.toString(),
    token: token
  };
};