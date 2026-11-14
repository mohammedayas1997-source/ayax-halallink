const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const { 
  getAllUsers, 
  deleteUser, 
  adminOverrideUser, 
  grantPointsToUser 
} = require('../controllers/adminController');

router.get('/users', authMiddleware, getAllUsers);
router.delete('/users/:userId', authMiddleware, deleteUser);
router.put('/users/override', authMiddleware, adminOverrideUser);
router.post('/grant-points', authMiddleware, grantPointsToUser);

module.exports = router;