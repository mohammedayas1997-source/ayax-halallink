const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const {
  upsertProfile,
  discoverMatches,
  swipeProfile,
  getMyMatches
} = require('../controllers/matchController');

// All matchmaking routes require a valid JWT token
router.post('/profile', authMiddleware, upsertProfile);
router.get('/discover', authMiddleware, discoverMatches);
router.post('/swipe', authMiddleware, swipeProfile);
router.get('/my-matches', authMiddleware, getMyMatches);

module.exports = router;