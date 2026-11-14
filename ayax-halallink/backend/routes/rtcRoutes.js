const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const { generateZegoToken } = require('../services/rtcService');

router.get('/call-token/:roomId', authMiddleware, (req, res) => {
  try {
    const { roomId } = req.params;
    const userId = req.user.id;
    const tokenData = generateZegoToken(userId, roomId);
    res.status(200).json(tokenData);
  } catch (err) {
    res.status(500).json({ error: 'Failed to generate call token.' });
  }
});

module.exports = router;