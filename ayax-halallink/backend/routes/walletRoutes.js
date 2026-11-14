const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const { deductPoints, sendGift, requestWithdrawal } = require('../controllers/walletController');

router.post('/deduct', authMiddleware, deductPoints);
router.post('/gift', authMiddleware, sendGift);
router.post('/withdraw', authMiddleware, requestWithdrawal);

module.exports = router;