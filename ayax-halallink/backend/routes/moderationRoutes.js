const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const { reportUser, getAdminReports, toggleUserSuspension } = require('../controllers/moderationController');

router.post('/report', authMiddleware, reportUser);
router.get('/reports', authMiddleware, getAdminReports);
router.put('/suspend', authMiddleware, toggleUserSuspension);

module.exports = router;