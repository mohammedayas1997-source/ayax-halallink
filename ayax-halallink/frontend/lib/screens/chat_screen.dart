import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  final String roomId;
  final String currentUserId;
  final String partnerName;
  final String receiverLanguage; // e.g., 'ar', 'en', 'fr', 'ha'

  const ChatScreen({
    super.key,
    required this.roomId,
    required this.currentUserId,
    required this.partnerName,
    required this.receiverLanguage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late IO.Socket _socket;
  final TextEditingController _messageController = TextEditingController();
  final List> _messages = [];
  bool _isTranslating = false;

  @override
  void initState() {
    super.initState();
    _initSocketConnection();
  }

  void _initSocketConnection() {
    // Connect to your Node.js backend server (update IP/Port for production)
    _socket = IO.io('http://localhost:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket.connect();

    _socket.onConnect((_) {
      print('Connected to Ayax HalalLink Chat Server');
      // Join the private match room
      _socket.emit('join_match_room', widget.roomId);
    });

    // Listen for incoming translated messages
    _socket.on('receive_message', (data) {
      setState(() {
        _messages.add({
          'senderId': data['senderId'],
          'originalText': data['originalText'],
          'translatedText': data['translatedText'],
          'timestamp': data['timestamp'],
        });
      });
    });

    _socket.onDisconnect((_) => print('Disconnected from chat server'));
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Send payload to backend for real-time translation & broadcasting
    _socket.emit('send_message', {
      'roomId': widget.roomId,
      'senderId': widget.currentUserId,
      'receiverLang': widget.receiverLanguage,
      'messageText': text,
    });

    _messageController.clear();
  }

  @override
  void dispose() {
    _socket.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.partnerName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Halal Secure Chat • Auto-Translated',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0E6B50),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Chat Messages List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['senderId'].toString() == widget.currentUserId.toString();

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF0E6B50) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Original Text
                        Text(
                          msg['originalText'],
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                        // Translated Text (if different from original)
                        if (msg['originalText'] != msg['translatedText']) ...[
                          const Divider(color: Colors.white30, height: 10),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.translate,
                                size: 12,
                                color: isMe ? Colors.white70 : Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  msg['translatedText'],
                                  style: TextStyle(
                                    color: isMe ? Colors.white70 : Colors.grey[700],
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Message Input Field & Send Button
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a respectful Halal message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF0E6B50),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}