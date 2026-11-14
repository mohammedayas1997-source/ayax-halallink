const pool = require('../config/db');

// 1. Create or Update User Matchmaking Profile
exports.upsertProfile = async (req, res) => {
  try {
    const userId = req.user.id;
    const {
      age,
      country,
      city,
      sectOrMadhab,
      religiosityLevel,
      maritalStatus,
      marriageTimeline,
      educationLevel,
      profession,
      bio,
      waliEmail,
      photoUrl,
      blurPhoto,
      spokenLanguages
    } = req.body;

    const existing = await pool.query('SELECT * FROM profiles WHERE user_id = $1', [userId]);

    if (existing.rows.length > 0) {
      const updated = await pool.query(
        `UPDATE profiles SET
          age = $1, country = $2, city = $3, sect_or_madhab = $4,
          religiosity_level = $5, marital_status = $6, marriage_timeline = $7,
          education_level = $8, profession = $9, bio = $10, wali_email = $11,
          photo_url = $12, blur_photo = $13, spoken_languages = $14,
          updated_at = CURRENT_TIMESTAMP
         WHERE user_id = $15 RETURNING *`,
        [
          age, country, city, sectOrMadhab, religiosityLevel, maritalStatus,
          marriageTimeline, educationLevel, profession, bio, waliEmail,
          photoUrl, blurPhoto ?? false, spokenLanguages || ['English'], userId
        ]
      );
      return res.status(200).json({ message: req.t('profile_updated'), profile: updated.rows[0] });
    }

    const created = await pool.query(
      `INSERT INTO profiles (
        user_id, age, country, city, sect_or_madhab, religiosity_level,
        marital_status, marriage_timeline, education_level, profession,
        bio, wali_email, photo_url, blur_photo, spoken_languages
      ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15) RETURNING *`,
      [
        userId, age, country, city, sectOrMadhab, religiosityLevel,
        maritalStatus, marriageTimeline, educationLevel, profession,
        bio, waliEmail, photoUrl, blurPhoto ?? false, spokenLanguages || ['English']
      ]
    );

    res.status(201).json({ message: req.t('profile_updated'), profile: created.rows[0] });
  } catch (err) {
    console.error('Profile Upsert Error:', err.message);
    res.status(500).json({ error: req.t('server_error') });
  }
};

// 2. Discover & Filter Potential Spouses
exports.discoverMatches = async (req, res) => {
  try {
    const currentUserId = req.user.id;

    // Get current user's gender so we only show the opposite gender
    const userRes = await pool.query('SELECT gender FROM users WHERE id = $1', [currentUserId]);
    if (userRes.rows.length === 0) {
      return res.status(404).json({ error: req.t('unauthorized') });
    }
    const targetGender = userRes.rows[0].gender === 'male' ? 'female' : 'male';

    // Extract optional query filters
    const {
      minAge = 18,
      maxAge = 70,
      country,
      sectOrMadhab,
      religiosityLevel,
      maritalStatus,
      language
    } = req.query;

    const queryParams = [currentUserId, targetGender, parseInt(minAge), parseInt(maxAge)];
    let paramIndex = 5;

    let sql = `
      SELECT 
        u.id AS user_id,
        u.full_name,
        u.gender,
        u.is_verified,
        u.preferred_language,
        p.age,
        p.country,
        p.city,
        p.sect_or_madhab,
        p.religiosity_level,
        p.marital_status,
        p.marriage_timeline,
        p.education_level,
        p.profession,
        p.bio,
        p.photo_url,
        p.blur_photo,
        p.spoken_languages,
        CASE WHEN p.wali_email IS NOT NULL AND p.wali_email <> '' THEN TRUE ELSE FALSE END AS has_wali
      FROM users u
      INNER JOIN profiles p ON u.id = p.user_id
      WHERE u.id <> $1
        AND u.gender = $2
        AND p.age BETWEEN $3 AND $4
        AND u.id NOT IN (
          SELECT liked_id FROM likes WHERE liker_id = $1
        )
    `;

    if (country) {
      sql += ` AND LOWER(p.country) = LOWER($${paramIndex++})`;
      queryParams.push(country);
    }

    if (sectOrMadhab) {
      sql += ` AND LOWER(p.sect_or_madhab) = LOWER($${paramIndex++})`;
      queryParams.push(sectOrMadhab);
    }

    if (religiosityLevel) {
      sql += ` AND LOWER(p.religiosity_level) = LOWER($${paramIndex++})`;
      queryParams.push(religiosityLevel);
    }

    if (maritalStatus) {
      sql += ` AND p.marital_status = $${paramIndex++}`;
      queryParams.push(maritalStatus);
    }

    if (language) {
      sql += ` AND $${paramIndex++} = ANY(p.spoken_languages)`;
      queryParams.push(language);
    }

    sql += ` ORDER BY u.is_verified DESC, p.updated_at DESC LIMIT 30`;

    const results = await pool.query(sql, queryParams);

    res.status(200).json({
      count: results.rows.length,
      profiles: results.rows
    });
  } catch (err) {
    console.error('Discover Matches Error:', err.message);
    res.status(500).json({ error: req.t('server_error') });
  }
};

// 3. Like or Pass a Profile (Creates Mutual Match on Reciprocal Like)
exports.swipeProfile = async (req, res) => {
  try {
    const likerId = req.user.id;
    const { targetUserId, action } = req.body; // action: 'liked' or 'passed'

    if (!['liked', 'passed'].includes(action)) {
      return res.status(400).json({ error: 'Invalid swipe action.' });
    }

    // Record swipe
    await pool.query(
      `INSERT INTO likes (liker_id, liked_id, status)
       VALUES ($1, $2, $3)
       ON CONFLICT (liker_id, liked_id) DO UPDATE SET status = $3`,
      [likerId, targetUserId, action]
    );

    if (action === 'passed') {
      return res.status(200).json({ matched: false, message: req.t('pass_recorded') });
    }

    // Check if targetUserId already liked likerId
    const mutualCheck = await pool.query(
      `SELECT * FROM likes WHERE liker_id = $1 AND liked_id = $2 AND status = 'liked'`,
      [targetUserId, likerId]
    );

    if (mutualCheck.rows.length > 0) {
      const user1 = Math.min(likerId, targetUserId);
      const user2 = Math.max(likerId, targetUserId);

      const matchRes = await pool.query(
        `INSERT INTO matches (user1_id, user2_id)
         VALUES ($1, $2)
         ON CONFLICT (user1_id, user2_id) DO UPDATE SET user1_id = EXCLUDED.user1_id
         RETURNING match_id`,
        [user1, user2]
      );

      return res.status(201).json({
        matched: true,
        matchId: matchRes.rows[0].match_id,
        roomId: `match_${matchRes.rows[0].match_id}`,
        message: req.t('its_a_match')
      });
    }

    res.status(200).json({ matched: false, message: req.t('like_recorded') });
  } catch (err) {
    console.error('Swipe Profile Error:', err.message);
    res.status(500).json({ error: req.t('server_error') });
  }
};

// 4. Fetch User's Active Matches
exports.getMyMatches = async (req, res) => {
  try {
    const userId = req.user.id;

    const matches = await pool.query(
      `SELECT 
        m.match_id,
        CONCAT('match_', m.match_id) AS room_id,
        m.created_at AS matched_at,
        u.id AS partner_id,
        u.full_name,
        u.is_verified,
        u.preferred_language,
        p.age,
        p.country,
        p.city,
        p.photo_url,
        p.blur_photo,
        p.wali_email
      FROM matches m
      JOIN users u ON (u.id = CASE WHEN m.user1_id = $1 THEN m.user2_id ELSE m.user1_id END)
      LEFT JOIN profiles p ON p.user_id = u.id
      WHERE m.user1_id = $1 OR m.user2_id = $1
      ORDER BY m.created_at DESC`,
      [userId]
    );

    res.status(200).json({ matches: matches.rows });
  } catch (err) {
    console.error('Get Matches Error:', err.message);
    res.status(500).json({ error: req.t('server_error') });
  }
};