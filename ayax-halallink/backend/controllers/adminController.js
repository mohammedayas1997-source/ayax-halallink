const pool = require('../config/db');

// 1. Fetch All Registered Users for Admin Dashboard
exports.getAllUsers = async (req, res) => {
  try {
    const users = await pool.query(
      `SELECT 
        u.id,
        u.full_name,
        u.email,
        u.gender,
        u.points_balance,
        u.is_verified,
        u.is_suspended,
        u.created_at,
        p.country,
        p.city,
        p.age
       FROM users u
       LEFT JOIN profiles p ON u.id = p.user_id
       ORDER BY u.created_at DESC`
    );

    res.status(200).json({ success: true, count: users.rows.length, users: users.rows });
  } catch (err) {
    console.error('Admin Get Users Error:', err.message);
    res.status(500).json({ error: 'Server error fetching users list.' });
  }
};

// 2. Admin: Delete a User
exports.deleteUser = async (req, res) => {
  try {
    const { userId } = req.params;

    const result = await pool.query('DELETE FROM users WHERE id = $1 RETURNING id', [userId]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found.' });
    }

    res.status(200).json({ success: true, message: 'User deleted successfully by Admin.' });
  } catch (err) {
    console.error('Admin Delete User Error:', err.message);
    res.status(500).json({ error: 'Server error deleting user.' });
  }
};

// 3. Admin: Override / Update User Points Balance or Status
exports.adminOverrideUser = async (req, res) => {
  try {
    const { userId, pointsBalance, isSuspended } = req.body;

    await pool.query(
      `UPDATE users SET points_balance = COALESCE($1, points_balance), is_suspended = COALESCE($2, is_suspended) WHERE id = $3`,
      [pointsBalance, isSuspended, userId]
    );

    res.status(200).json({ success: true, message: 'User record updated successfully via Admin override.' });
  } catch (err) {
    console.error('Admin Override Error:', err.message);
    res.status(500).json({ error: 'Server error performing admin override.' });
  }
};

// Admin: Grant Bonus Points to a User
exports.grantPointsToUser = async (req, res) => {
  try {
    const { userId, pointsToAdd, reason } = req.body;

    if (!pointsToAdd || pointsToAdd <= 0) {
      return res.status(400).json({ error: 'Please specify a valid positive point amount.' });
    }

    // 1. Update user points balance
    const updatedUser = await pool.query(
      `UPDATE users SET points_balance = points_balance + $1 WHERE id = $2 RETURNING id, full_name, points_balance`,
      [pointsToAdd, userId]
    );

    if (updatedUser.rows.length === 0) {
      return res.status(404).json({ error: 'User not found.' });
    }

    // 2. Record transaction in ledger
    await pool.query(
      `INSERT INTO point_transactions (user_id, amount, transaction_type, description) VALUES ($1, $2, 'admin_grant', $3)`,
      [userId, pointsToAdd, reason || 'Admin bonus grant']
    );

    res.status(200).json({
      success: true,
      message: `Successfully granted ${pointsToAdd} points to ${updatedUser.rows[0].full_name}.`,
      newBalance: updatedUser.rows[0].points_balance
    });
  } catch (err) {
    console.error('Admin Grant Points Error:', err.message);
    res.status(500).json({ error: 'Server error granting points.' });
  }
};