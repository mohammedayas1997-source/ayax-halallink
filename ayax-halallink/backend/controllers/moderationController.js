const pool = require('../config/db');

// 1. Submit a Report against a User
exports.reportUser = async (req, res) => {
  try {
    const reporterId = req.user.id;
    const { reportedUserId, reason, description } = req.body;

    if (reporterId === parseInt(reportedUserId)) {
      return res.status(400).json({ error: 'You cannot report yourself.' });
    }

    await pool.query(
      `INSERT INTO reports (reporter_id, reported_user_id, reason, description)
       VALUES ($1, $2, $3, $4)`,
      [reporterId, reportedUserId, reason, description || '']
    );

    res.status(201).json({ success: true, message: 'Report submitted successfully. Our moderation team will review it.' });
  } catch (err) {
    console.error('Report User Error:', err.message);
    res.status(500).json({ error: 'Server error submitting report.' });
  }
};

// 2. Admin: Get All Pending Reports
exports.getAdminReports = async (req, res) => {
  try {
    // Add admin check middleware in production
    const reports = await pool.query(
      `SELECT 
        r.report_id,
        r.reason,
        r.description,
        r.status,
        r.created_at,
        reporter.id AS reporter_id,
        reporter.full_name AS reporter_name,
        reported.id AS reported_user_id,
        reported.full_name AS reported_user_name,
        reported.is_suspended
       FROM reports r
       JOIN users reporter ON r.reporter_id = reporter.id
       JOIN users reported ON r.reported_user_id = reported.id
       ORDER BY r.created_at DESC`
    );

    res.status(200).json({ success: true, reports: reports.rows });
  } catch (err) {
    console.error('Get Admin Reports Error:', err.message);
    res.status(500).json({ error: 'Server error fetching reports.' });
  }
};

// 3. Admin: Suspend or Unsuspend a User
exports.toggleUserSuspension = async (req, res) => {
  try {
    const { userId, suspend, reason } = req.body; // suspend: true/false

    await pool.query(
      `UPDATE users SET is_suspended = $1, suspension_reason = $2 WHERE id = $3`,
      [suspend, suspend ? (reason || 'Community guidelines violation') : null, userId]
    );

    res.status(200).json({
      success: true,
      message: suspend ? 'User successfully suspended.' : 'User suspension lifted.'
    });
  } catch (err) {
    console.error('Toggle Suspension Error:', err.message);
    res.status(500).json({ error: 'Server error updating user suspension status.' });
  }
};