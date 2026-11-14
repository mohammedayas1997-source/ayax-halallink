const pool = require('../config/db');

// 1. Create a New Post
exports.createPost = async (req, res) => {
  try {
    const userId = req.user.id;
    const { content, mediaUrl } = req.body;

    const newPost = await pool.query(
      `INSERT INTO posts (user_id, content, media_url) 
       VALUES ($1, $2, $3) RETURNING *`,
      [userId, content, mediaUrl]
    );

    res.status(201).json({
      success: true,
      message: 'Post published successfully!',
      post: newPost.rows[0]
    });
  } catch (err) {
    console.error('Create Post Error:', err.message);
    res.status(500).json({ error: 'Server error creating post.' });
  }
};

// 2. Fetch Community Feed
exports.getFeed = async (req, res) => {
  try {
    const feed = await pool.query(
      `SELECT 
        p.post_id,
        p.content,
        p.media_url,
        p.likes_count,
        p.comments_count,
        p.created_at,
        u.id AS user_id,
        u.full_name,
        pr.photo_url AS profile_photo,
        pr.country,
        pr.city
      FROM posts p
      JOIN users u ON p.user_id = u.id
      LEFT JOIN profiles pr ON u.id = pr.user_id
      ORDER BY p.created_at DESC
      LIMIT 50`
    );

    res.status(200).json({ success: true, posts: feed.rows });
  } catch (err) {
    console.error('Get Feed Error:', err.message);
    res.status(500).json({ error: 'Server error fetching feed.' });
  }
};

// 3. Like / Unlike Post
exports.toggleLike = async (req, res) => {
  try {
    const userId = req.user.id;
    const { postId } = req.body;

    const existingLike = await pool.query(
      'SELECT * FROM post_likes WHERE post_id = $1 AND user_id = $2',
      [postId, userId]
    );

    if (existingLike.rows.length > 0) {
      // Unlike
      await pool.query('DELETE FROM post_likes WHERE post_id = $1 AND user_id = $2', [postId, userId]);
      await pool.query('UPDATE posts SET likes_count = likes_count - 1 WHERE post_id = $1', [postId]);
      return res.status(200).json({ success: true, liked: false });
    } else {
      // Like
      await pool.query('INSERT INTO post_likes (post_id, user_id) VALUES ($1, $2)', [postId, userId]);
      await pool.query('UPDATE posts SET likes_count = likes_count + 1 WHERE post_id = $1', [postId]);
      return res.status(200).json({ success: true, liked: true });
    }
  } catch (err) {
    console.error('Toggle Like Error:', err.message);
    res.status(500).json({ error: 'Server error toggling like.' });
  }
};