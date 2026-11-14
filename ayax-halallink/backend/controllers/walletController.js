const pool = require('../config/db');

// Ayax HalalLink Charge Configuration
const CHARGES = {
  chat_message: 2,       // 2 points per chat message
  photo_send: 5,         // 5 points per photo sent
  voice_call_per_min: 10,// 10 points per voice call minute
  video_call_per_min: 20 // 20 points per video call minute
};

// 1. Deduct Points (Chat, Photo, or Voice/Video Calls)
exports.deductPoints = async (req, res) => {
  try {
    const userId = req.user.id;
    const { actionType } = req.body; // 'chat_message', 'photo_send', 'voice_call_per_min', etc.

    const cost = CHARGES[actionType] || 1;

    // Check user points balance
    const userRes = await pool.query('SELECT points_balance FROM users WHERE id = $1', [userId]);
    if (userRes.rows.length === 0) return res.status(404).json({ error: 'User not found.' });

    const currentBalance = userRes.rows[0].points_balance;

    if (currentBalance < cost) {
      return res.status(402).json({ 
        error: 'Your points have run out. Please recharge starting from $1 / ₦1,000 (100 points).',
        balance: currentBalance,
        required: cost
      });
    }

    // Deduct points
    const newBalance = currentBalance - cost;
    await pool.query('UPDATE users SET points_balance = $1 WHERE id = $2', [newBalance, userId]);

    // Record in transaction ledger
    await pool.query(
      `INSERT INTO point_transactions (user_id, amount, transaction_type, description) VALUES ($1, $2, $3, $4)`,
      [userId, -cost, actionType, `Charge for ${actionType}`]
    );

    res.status(200).json({ success: true, remainingPoints: newBalance });
  } catch (err) {
    console.error('Deduct Points Error:', err.message);
    res.status(500).json({ error: 'Server error during points deduction.' });
  }
};

// 2. Send Gift (TikTok Style in Chat or Live Streams)
exports.sendGift = async (req, res) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const senderId = req.user.id;
    const { recipientId, giftId } = req.body;

    // Fetch gift details
    const giftRes = await client.query('SELECT * FROM gifts WHERE gift_id = $1', [giftId]);
    if (giftRes.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ error: 'Gift not found.' });
    }
    const gift = giftRes.rows[0];

    // Check sender's points balance
    const senderRes = await client.query('SELECT points_balance FROM users WHERE id = $1', [senderId]);
    const senderBalance = senderRes.rows[0].points_balance;

    if (senderBalance < gift.cost_in_points) {
      await client.query('ROLLBACK');
      return res.status(402).json({ error: 'Insufficient points to send this gift. Please recharge!' });
    }

    // 1. Deduct points from sender
    await client.query('UPDATE users SET points_balance = points_balance - $1 WHERE id = $2', [gift.cost_in_points, senderId]);

    // 2. Add points to recipient
    await client.query('UPDATE users SET points_balance = points_balance + $1 WHERE id = $2', [gift.cost_in_points, recipientId]);

    // Record transactions
    await client.query(
      `INSERT INTO point_transactions (user_id, amount, transaction_type, description) VALUES ($1, $2, 'gift_sent', $3)`,
      [senderId, -gift.cost_in_points, `Sent gift: ${gift.gift_name}`]
    );
    await client.query(
      `INSERT INTO point_transactions (user_id, amount, transaction_type, description) VALUES ($1, $2, 'gift_received', $3)`,
      [recipientId, gift.cost_in_points, `Received gift: ${gift.gift_name}`]
    );

    await client.query('COMMIT');
    res.status(200).json({ success: true, message: `Successfully sent ${gift.gift_name}!` });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Send Gift Error:', err.message);
    res.status(500).json({ error: 'Server error sending gift.' });
  } finally {
    client.release();
  }
};

// 3. Request Global Cash Out (60% to User, 40% to Ayax Platform)
exports.requestWithdrawal = async (req, res) => {
  try {
    const userId = req.user.id;
    const { pointsToRedeem, bankName, accountNumber, accountName } = req.body;

    // Minimum redemption threshold: 1,000 points
    if (pointsToRedeem < 1000) {
      return res.status(400).json({ error: 'Minimum points for withdrawal is 1,000 points.' });
    }

    const userRes = await pool.query('SELECT points_balance FROM users WHERE id = $1', [userId]);
    const currentBalance = userRes.rows[0].points_balance;

    if (currentBalance < pointsToRedeem) {
      return res.status(400).json({ error: 'You do not have enough points in your account.' });
    }

    // Calculation (100 points = $1 USD / ₦1,000)
    const totalValue = pointsToRedeem * 10;
    const userNetAmount = totalValue * 0.60;     // 60% user share
    const platformCommission = totalValue * 0.40; // 40% Ayax commission

    // Deduct points from user balance
    await pool.query('UPDATE users SET points_balance = points_balance - $1 WHERE id = $2', [pointsToRedeem, userId]);

    // Insert into withdrawals table
    const withdrawalRes = await pool.query(
      `INSERT INTO withdrawals (user_id, points_redeemed, naira_amount, user_net_amount, platform_commission, bank_name, account_number, account_name)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING withdrawal_id`,
      [userId, pointsToRedeem, totalValue, userNetAmount, platformCommission, bankName, accountNumber, accountName]
    );

    res.status(201).json({
      success: true,
      message: 'Withdrawal request submitted successfully. Payout will be processed within 24 hours.',
      withdrawalId: withdrawalRes.rows[0].withdrawal_id,
      netAmount: userNetAmount
    });
  } catch (err) {
    console.error('Withdrawal Error:', err.message);
    res.status(500).json({ error: 'Server error processing withdrawal.' });
  }
};