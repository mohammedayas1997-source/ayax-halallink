const pool = require('../config/db');

exports.completeOnboarding = async (req, res) => {
  try {
    const userId = req.user.id;
    const {
      gender,
      age,
      country,
      city,
      bio,
      hobbies,
      photoUrl,
      blurPhoto,
      spouseAgeMin,
      spouseAgeMax,
      spouseReligiosity,
      spouseMadhab,
      spouseCountry
    } = req.body;

    // 1. Update user gender
    await pool.query('UPDATE users SET gender = $1 WHERE id = $2', [gender, userId]);

    // 2. Upsert profile with bio, hobbies, and spouse preferences
    const existing = await pool.query('SELECT * FROM profiles WHERE user_id = $1', [userId]);

    if (existing.rows.length > 0) {
      await pool.query(
        `UPDATE profiles SET
          age = $1, country = $2, city = $3, bio = $4, hobbies = $5,
          photo_url = $6, blur_photo = $7, spouse_age_min = $8, spouse_age_max = $9,
          spouse_religiosity = $10, spouse_madhab = $11, spouse_country = $12,
          updated_at = CURRENT_TIMESTAMP
         WHERE user_id = $13`,
        [
          age, country, city, bio, hobbies, photoUrl, blurPhoto ?? false,
          spouseAgeMin, spouseAgeMax, spouseReligiosity, spouseMadhab, spouseCountry, userId
        ]
      );
    } else {
      await pool.query(
        `INSERT INTO profiles (
          user_id, age, country, city, bio, hobbies, photo_url, blur_photo,
          spouse_age_min, spouse_age_max, spouse_religiosity, spouse_madhab, spouse_country
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)`,
        [
          userId, age, country, city, bio, hobbies, photoUrl, blurPhoto ?? false,
          spouseAgeMin, spouseAgeMax, spouseReligiosity, spouseMadhab, spouseCountry
        ]
      );
    }

    res.status(200).json({ success: true, message: 'Onboarding completed successfully!' });
  } catch (err) {
    console.error('Onboarding Error:', err.message);
    res.status(500).json({ error: 'Server error saving profile setup.' });
  }
};



// 1. Update Existing Profile Information
exports.updateProfile = async (req, res) => {
  try {
    const userId = req.user.id;
    const {
      age,
      country,
      city,
      bio,
      hobbies,
      photoUrl,
      blurPhoto,
      spouseAgeMin,
      spouseAgeMax,
      spouseReligiosity,
      spouseMadhab,
      spouseCountry
    } = req.body;

    await pool.query(
      `UPDATE profiles SET
        age = COALESCE($1, age),
        country = COALESCE($2, country),
        city = COALESCE($3, city),
        bio = COALESCE($4, bio),
        hobbies = COALESCE($5, hobbies),
        photo_url = COALESCE($6, photo_url),
        blur_photo = COALESCE($7, blur_photo),
        spouse_age_min = COALESCE($8, spouse_age_min),
        spouse_age_max = COALESCE($9, spouse_age_max),
        spouse_religiosity = COALESCE($10, spouse_religiosity),
        spouse_madhab = COALESCE($11, spouse_madhab),
        spouse_country = COALESCE($12, spouse_country),
        updated_at = CURRENT_TIMESTAMP
       WHERE user_id = $13`,
      [
        age, country, city, bio, hobbies, photoUrl, blurPhoto,
        spouseAgeMin, spouseAgeMax, spouseReligiosity, spouseMadhab, spouseCountry, userId
      ]
    );

    res.status(200).json({ success: true, message: 'Profile updated successfully!' });
  } catch (err) {
    console.error('Update Profile Error:', err.message);
    res.status(500).json({ error: 'Server error updating profile.' });
  }
};

// 2. Delete Account Permanently (GDPR / User Choice)
exports.deleteMyAccount = async (req, res) => {
  try {
    const userId = req.user.id;

    // Delete user from database (CASCADE will automatically clean up profiles, posts, wallet transactions, etc.)
    await pool.query('DELETE FROM users WHERE id = $1', [userId]);

    res.status(200).json({ success: true, message: 'Account and all associated data deleted permanently.' });
  } catch (err) {
    console.error('Delete Account Error:', err.message);
    res.status(500).json({ error: 'Server error deleting account.' });
  }
};