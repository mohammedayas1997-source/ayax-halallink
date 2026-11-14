import 'package:flutter/material.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final TextEditingController _postController = TextEditingController();

  // Mock community posts
  final List> _posts = [
    {
      'postId': 1,
      'author': 'Ibrahim Al-Amin',
      'location': 'Abuja, Nigeria',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      'content': 'Alhamdulillah, attended the weekend Islamic seminar on marriage and family ethics. Highly recommended for everyone seeking knowledge!',
      'mediaUrl': 'https://images.unsplash.com/photo-1543269865-cbf427effbad?auto=format&fit=crop&w=800&q=80',
      'likes': 24,
      'comments': 5,
      'isLiked': false,
      'timeAgo': '2 hours ago',
    },
    {
      'postId': 2,
      'author': 'Fatima Al-Mansoor',
      'location': 'Riyadh, Saudi Arabia',
      'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      'content': 'May Allah bless our community with pious spouses, peace, and barakah. Remember to keep gratitude in your daily prayers.',
      'mediaUrl': null,
      'likes': 41,
      'comments': 8,
      'isLiked': true,
      'timeAgo': 'Yesterday',
    },
  ];

  void _createNewPost() {
    final text = _postController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _posts.insert(0, {
        'postId': DateTime.now().millisecondsSinceEpoch,
        'author': 'You (Ayax User)',
        'location': 'Nigeria',
        'avatar': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
        'content': text,
        'mediaUrl': null,
        'likes': 0,
        'comments': 0,
        'isLiked': false,
        'timeAgo': 'Just now',
      });
    });

    _postController.clear();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post published to Halal Community Feed!')),
    );
  }

  void _openCreatePostModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Halal Community Post',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0E6B50)),
            ),
            const Divider(),
            TextField(
              controller: _postController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Share your thoughts, reminders, or milestones...',
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image, color: Color(0xFF0E6B50)),
                  onPressed: () {
                    // Image picker integration
                  },
                ),
                const Text('Add Photo', style: TextStyle(color: Colors.grey)),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E6B50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _createNewPost,
                  child: const Text('Post'),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayax HalalFeed', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0E6B50),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author Header
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(post['avatar']),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post['author'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('${post['location']} • ${post['timeAgo']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Content Text
                  Text(post['content'], style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 12),
                  // Optional Media Image
                  if (post['mediaUrl'] != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(post['mediaUrl'], fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 12),
                  ],
                  const Divider(),
                  // Like & Comment Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton.icon(
                        icon: Icon(
                          post['isLiked'] ? Icons.favorite : Icons.favorite_border,
                          color: post['isLiked'] ? Colors.red : Colors.grey,
                        ),
                        label: Text('${post['likes']} Likes'),
                        onPressed: () {
                          setState(() {
                            post['isLiked'] = !post['isLiked'];
                            post['likes'] += post['isLiked'] ? 1 : -1;
                          });
                        },
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.chat_bubble_outline, color: Colors.grey),
                        label: Text('${post['comments']} Comments'),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0E6B50),
        foregroundColor: Colors.white,
        onPressed: _openCreatePostModal,
        child: const Icon(Icons.add_box),
      ),
    );
  }
}