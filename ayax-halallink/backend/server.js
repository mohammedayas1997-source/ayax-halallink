const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');
const path = require('path');
require('dotenv').config();
const pool = require('./config/db');
const { i18next, middleware } = require('./config/i18n');
const { translateMessage } = require('./services/translationService');

// Route Imports
const authRoutes = require('./routes/authRoutes');
const matchRoutes = require('./routes/matchRoutes');
const adminRoutes = require('./routes/adminRoutes');
const walletRoutes = require('./routes/walletRoutes');
const postRoutes = require('./routes/postRoutes');
const profileRoutes = require('./routes/profileRoutes');
const moderationRoutes = require('./routes/moderationRoutes');
const webhookRoutes = require('./routes/webhookRoutes');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: '*' }
});

app.use(cors());
app.use(express.json());
app.use(middleware.handle(i18next));
app.use(express.static(path.join(__dirname, 'public')));

// Mount Routes
app.use('/api/auth', authRoutes);
app.use('/api/wallet', walletRoutes);
app.use('/api/posts', postRoutes);
app.use('/api/profile', profileRoutes);
app.use('/api/moderation', moderationRoutes);
app.use('/api/webhooks', webhookRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/matches', matchRoutes);

// Real-Time Chat with Automatic Translation & Wali Monitoring Support
io.on('connection', (socket) => {
  console.log(`User connected: ${socket.id}`);

  // Join a private match room (e.g., match_104)
  socket.on('join_match_room', (roomId) => {
    socket.join(roomId);
  });

  // Handle incoming message
  socket.on('send_message', async (data) => {
    const { roomId, senderId, receiverLang, messageText } = data;

    // Translate message into receiver's preferred language
    const translatedText = await translateMessage(messageText, receiverLang);

    const messagePayload = {
      senderId,
      originalText: messageText,
      translatedText,
      targetLanguage: receiverLang,
      timestamp: new Date().toISOString()
    };

    // Broadcast to both users (and Wali if connected to the room)
    io.to(roomId).emit('receive_message', messagePayload);
  });

  socket.on('disconnect', () => {
    console.log(`User disconnected: ${socket.id}`);
  });
});

const PORT = process.env.PORT || 5000;
server.listen(PORT, () => {
  console.log(`Ayax HalalLink Server & Chat running on port: ${PORT}`);
});