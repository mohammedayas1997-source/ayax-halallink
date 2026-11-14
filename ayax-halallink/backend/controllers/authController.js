const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const pool = require('../config/db');

// Generate JWT Token
const generateToken = (userId, email) => {
  return jwt.sign(
    { id: userId, email },
    process.env.JWT_SECRET || 'ayax_halallink_super_secret_key',
    { expiresIn: '30d' }
  );
};

// Register User
exports.registerUser = async (req, res) => {
  try {
    const { fullName, email, password, phoneNumber, gender, preferredLanguage } = req.body;

    const userExists = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    if (userExists.rows.length > 0) {
      return res.status(400).json({ error: req.t('user_exists') });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const newUser = await pool.query(
      `INSERT INTO users (full_name, email, password_hash, phone_number, gender, preferred_language) 
       VALUES ($1, $2, $3, $4, $5, $6) 
       RETURNING id, full_name, email, gender, preferred_language`,
      [fullName, email, hashedPassword, phoneNumber, gender, preferredLanguage || 'en']
    );

    const user = newUser.rows[0];
    const token = generateToken(user.id, user.email);

    res.status(201).json({
      message: req.t('register_success'),
      token,
      user
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: req.t('server_error') });
  }
};

// Login User
exports.loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;

    const userQuery = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    if (userQuery.rows.length === 0) {
      return res.status(401).json({ error: req.t('invalid_credentials') });
    }

    const user = userQuery.rows[0];
    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(401).json({ error: req.t('invalid_credentials') });
    }

    const token = generateToken(user.id, user.email);

    res.status(200).json({
      message: req.t('login_success'),
      token,
      user: {
        id: user.id,
        full_name: user.full_name,
        email: user.email,
        gender: user.gender,
        preferred_language: user.preferred_language,
        is_verified: user.is_verified
      }
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: req.t('server_error') });
  }
};