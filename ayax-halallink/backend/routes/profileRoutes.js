const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const { 
  completeOnboarding, 
  updateProfile, 
  deleteMyAccount 
} = require('../controllers/profileController');

router.post('/onboarding', authMiddleware, completeOnboarding);
router.put('/update', authMiddleware, updateProfile); // Ko '/profile' dangane da yadda ka sanya shi
router.delete('/delete-account', authMiddleware, deleteMyAccount);

module.exports = router;