const pool = require('../config/db');
const crypto = require('crypto');

// 1. Paystack Webhook Handler (For NGN, GHS, KES, ZAR transfers)
exports.handlePaystackWebhook = async (req, res) => {
  try {
    // Verify Paystack signature for security
    const paystackSecretKey = process.env.PAYSTACK_SECRET_KEY || 'your_paystack_secret_key';
    const hash = crypto
      .createHmac('sha512', paystackSecretKey)
      .update(JSON.stringify(req.body))
      .digest('hex');

    if (hash !== req.headers['x-paystack-signature']) {
      return res.status(400).json({ error: 'Invalid Paystack signature.' });
    }

    const event = req.body;

    // Handle transfer success or failure events
    if (event.event === 'transfer.success') {
      const transferData = event.data;
      const reference = transferData.reference; // Or match by transfer code / recipient

      await pool.query(
        `UPDATE global_withdrawals SET status = 'paid' WHERE account_number = $1 AND status = 'pending'`,
        [transferData.recipient.details.account_number]
      );
      console.log(`Paystack Transfer Successful for reference: ${reference}`);
    } else if (event.event === 'transfer.failed' || event.event === 'transfer.reversed') {
      const transferData = event.data;
      await pool.query(
        `UPDATE global_withdrawals SET status = 'failed' WHERE account_number = $1 AND status = 'pending'`,
        [transferData.recipient.details.account_number]
      );
      console.log(`Paystack Transfer Failed/Reversed.`);
    }

    res.status(200).json({ received: true });
  } catch (err) {
    console.error('Paystack Webhook Error:', err.message);
    res.status(500).json({ error: 'Webhook processing error.' });
  }
};

// 2. Stripe Webhook Handler (For Global USD/EUR/GBP Payouts via Stripe Connect)
exports.handleStripeWebhook = async (req, res) => {
  const event = req.body;

  try {
    // Handle Stripe payout events
    if (event.type === 'payout.paid') {
      const payout = event.data.object;
      console.log(`Stripe Payout Paid: ${payout.id}`);

      await pool.query(
        `UPDATE global_withdrawals SET status = 'paid' WHERE gateway_used = 'stripe_global' AND status = 'pending'`
      );
    } else if (event.type === 'payout.failed') {
      const payout = event.data.object;
      console.log(`Stripe Payout Failed: ${payout.id}`);

      await pool.query(
        `UPDATE global_withdrawals SET status = 'failed' WHERE gateway_used = 'stripe_global' AND status = 'pending'`
      );
    }

    res.status(200).json({ received: true });
  } catch (err) {
    console.error('Stripe Webhook Error:', err.message);
    res.status(500).json({ error: 'Webhook processing error.' });
  }
};