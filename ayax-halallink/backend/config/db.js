const { Pool } = require('pg');
require('dotenv').config();

// Haɗa database ta amfani da connection string daga .env
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false
  }
});

pool.on('connect', () => {
  console.log('An yi nasarar haɗa database na Ayax HalalLink da Neon PostgreSQL!');
});

module.exports = pool;