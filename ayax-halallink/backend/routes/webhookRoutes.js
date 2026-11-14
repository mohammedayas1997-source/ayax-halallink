const express = require('express');
const router = express.Router();
const { handlePaystackWebhook, handleStripeWebhook } = require('../controllers/webhookController');

// Note: Webhook routes require raw body parsing for signature verification in production
router.post('/paystack', handlePaystackWebhook);
router.post('/stripe', handleStripeWebhook);

module.exports = router;