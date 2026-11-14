const pool = require('../config/db');
// Import SDKs for Paystack and Stripe
const https = require('https');

// Exchange rate mapping (Can also be fetched dynamically from an exchange rate API)
const EXCHANGE_RATES = {
  NGN: 10,       // 1 point = 10 NGN (100 points = 1,000 NGN)
  USD: 0.0065,   // 1 point = $0.0065 USD (100 points = $0.65, 1000 points = $6.50)
  EUR: 0.0060,
  GBP: 0.0052,
  KES: 0.85
};

exports.requestGlobalWithdrawal = async (req, res) => {
  try {
    const userId = req.user.id;
    const { 
      pointsToRedeem, 
      payoutCurrency, // 'NGN', 'USD', 'EUR', etc.
      bankCountry, 
      bankName, 
      accountNumber, 
      routingNumber, 
      swiftBic, 
      accountName 
    } = req.body;

    // Minimum redemption threshold: 1,000 points
    if (pointsToRedeem < 1000) {
      return res.status(400).json({ error: 'Minimum points for withdrawal is 1,000 points.' });
    }

    // Check user points balance
    const userRes = await pool.query('SELECT points_balance, email FROM users WHERE id = $1', [userId]);
    if (userRes.rows.length === 0) return res.status(404).json({ error: 'User not found.' });

    const currentBalance = userRes.rows[0].points_balance;
    const userEmail = userRes.rows[0].email;

    if (currentBalance < pointsToRedeem) {
      return res.status(400).json({ error: 'Insufficient points balance.' });
    }

    // Calculate total value based on currency rate
    const rate = EXCHANGE_RATES[payoutCurrency] || EXCHANGE_RATES['USD'];
    const totalLocalValue = pointsToRedeem * rate;
    
    const userNetAmount = totalLocalValue * 0.60;     // 60% user share
    const platformCommission = totalLocalValue * 0.40; // 40% Ayax commission

    // Determine gateway: Use Paystack for African currencies (NGN, GHS, KES, ZAR), Stripe for global USD/EUR/GBP
    const africanCurrencies = ['NGN', 'GHS', 'KES', 'ZAR'];
    const gatewayUsed = africanCurrencies.includes(payoutCurrency) ? 'paystack' : 'stripe_global';

    // Deduct points from user balance immediately
    await pool.query('UPDATE users SET points_balance = points_balance - $1 WHERE id = $2', [pointsToRedeem, userId]);

    // Record withdrawal request in database
    const withdrawalRes = await pool.query(
      `INSERT INTO global_withdrawals 
       (user_id, points_redeemed, payout_currency, local_amount, user_net_amount, platform_commission, gateway_used, bank_country, bank_name, account_number, routing_number, swift_bic, account_name)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13) RETURNING withdrawal_id`,
      [
        userId, pointsToRedeem, payoutCurrency, totalLocalValue, userNetAmount, platformCommission,
        gatewayUsed, bankCountry, bankName, accountNumber, routingNumber || null, swiftBic || null, accountName
      ]
    );

    // If gateway is Paystack (for Nigeria/Africa)
    if (gatewayUsed === 'paystack') {
      // Logic to trigger Paystack Transfer API goes here
      console.log(`Processing Paystack Transfer for ${userEmail}: ${userNetAmount} ${payoutCurrency}`);
    } else {
      // Logic to trigger Stripe Connect / International Payout API goes here
      console.log(`Processing Global Stripe Payout for ${userEmail}: ${userNetAmount} ${payoutCurrency}`);
    }

    res.status(201).json({
      success: true,
      message: `Withdrawal request of ${userNetAmount.toFixed(2)} ${payoutCurrency} submitted successfully via ${gatewayUsed.toUpperCase()}.`,
      withdrawalId: withdrawalRes.rows[0].withdrawal_id,
      netAmount: userNetAmount,
      currency: payoutCurrency
    });

  } catch (err) {
    console.error('Global Withdrawal Error:', err.message);
    res.status(500).json({ error: 'Internal server error processing global payout.' });
  }
};