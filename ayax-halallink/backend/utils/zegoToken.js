const crypto = require('crypto');

// Generate Zego Token04 for secure server-side room/live authentication
function generateZegoToken(appId, userId, secret, effectiveTimeInSeconds = 3600) {
  if (!appId || !userId || !secret) {
    throw new Error('App ID, User ID, and Secret are required to generate Zego token.');
  }

  const expireTime = Math.floor(Date.now() / 1000) + effectiveTimeInSeconds;
  const payload = {
    user_id: userId,
    nonce: Math.floor(Math.random() * 2147483647),
    expire: expireTime,
    payload: ''
  };

  const plainText = JSON.stringify(payload);
  const iv = crypto.randomBytes(16);
  const key = crypto.createHash('md5').update(secret).digest();

  const cipher = crypto.createCipheriv('aes-128-cbc', key, iv);
  let encrypted = cipher.update(plainText, 'utf8');
  encrypted = Buffer.concat([encrypted, cipher.final()]);

  const binLen = Buffer.alloc(2);
  binLen.writeUInt16BE(iv.length, 0);

  const tokenInfo = {
    app_id: parseInt(appId),
    token_version: 4,
    expire_time: expireTime,
    hash: Buffer.concat([binLen, iv, encrypted]).toString('base64')
  };

  return '04' + Buffer.from(JSON.stringify(tokenInfo)).toString('base64');
}

exports.generateZegoToken = generateZegoToken;