const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const { createPost, getFeed, toggleLike } = require('../controllers/postController');

router.post('/', authMiddleware, createPost);
router.get('/feed', authMiddleware, getFeed);
router.post('/like', authMiddleware, toggleLike);

module.exports = router;