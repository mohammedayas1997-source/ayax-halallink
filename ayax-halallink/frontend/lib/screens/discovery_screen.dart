import 'package:flutter/material.dart';
import 'dart:ui';
import 'filter_modal.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  // Mock data representing global Halal profiles fetched from /api/matches/discover
  final List> _profiles = [
    {
      'userId': 101,
      'full_name': 'Fatima Al-Mansoor',
      'age': 24,
      'country': 'Saudi Arabia',
      'city': 'Riyadh',
      'sect_or_madhab': 'Sunni / Salafi',
      'religiosity_level': 'Practicing Daily Prayers & Hijab',
      'marital_status': 'single',
      'marriage_timeline': 'Within 6 months',
      'profession': 'Software Engineer',
      'bio': 'Looking for a pious partner who values deen, family, and personal growth. Prefers someone supportive of tech career.',
      'photo_url': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80',
      'blur_photo': true, // Privacy feature for sisters
      'has_wali': true,
      'spoken_languages': ['English', 'Arabic']
    },
    {
      'userId': 102,
      'full_name': 'Amina Bello',
      'age': 22,
      'country': 'Nigeria',
      'city': 'Abuja',
      'sect_or_madhab': 'Sunni / Maliki',
      'religiosity_level': 'Very Practicing',
      'marital_status': 'single',
      'marriage_timeline': '1 year',
      'profession': 'Medical Student',
      'bio': 'Seeking a God-fearing husband who prioritizes prayer, kindness, and continuous learning.',
      'photo_url': 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?auto=format&fit=crop&w=800&q=80',
      'blur_photo': false,
      'has_wali': true,
      'spoken_languages': ['English', 'Hausa']
    }
  ];

  int _currentIndex = 0;

  void _handleSwipe(String action) {
    setState(() {
      if (_currentIndex < _profiles.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0; // Loop back for demo
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(action == 'liked' ? 'Interest sent successfully!' : 'Profile skipped.'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _openFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const FilterModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_profiles.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No more profiles available right now.')),
      );
    }

    final currentProfile = _profiles[_currentIndex];
    final bool shouldBlur = currentProfile['blur_photo'] ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ayax HalalLink',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0E6B50)),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF0E6B50)),
            onPressed: _openFilterModal,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Profile Image with Optional Blur
                    Image.network(
                      currentProfile['photo_url'],
                      fit: BoxFit.cover,
                    ),
                    if (shouldBlur)
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          color: Colors.black.withOpacity(0.3),
                          alignment: Alignment.center,
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock, color: Colors.white, size: 48),
                              SizedBox(height: 8),
                              Text(
                                'Photo Blurred for Privacy\nMatch to request photo access',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Gradient Overlay for Text Readability
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.85),
                          ],
                        ),
                      ),
                    ),

                    // Profile Details
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${currentProfile['full_name']}, ${currentProfile['age']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.verified, color: Colors.blueAccent, size: 22),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${currentProfile['profession']} • ${currentProfile['city']}, ${currentProfile['country']}',
                            style: const TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              _buildBadge(currentProfile['sect_or_madhab']),
                              _buildBadge(currentProfile['religiosity_level']),
                              _buildBadge('Timeline: ${currentProfile['marriage_timeline']}'),
                              if (currentProfile['has_wali'])
                                _buildBadge('Wali Mode Enabled', color: const Color(0xFFD4AF37)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            currentProfile['bio'],
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Action Buttons (Pass / Like)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: 'passBtn',
                  backgroundColor: Colors.white,
                  onPressed: () => _handleSwipe('passed'),
                  child: const Icon(Icons.close, color: Colors.red, size: 32),
                ),
                FloatingActionButton.large(
                  heroTag: 'likeBtn',
                  backgroundColor: const Color(0xFF0E6B50),
                  onPressed: () => _handleSwipe('liked'),
                  child: const Icon(Icons.favorite, color: Colors.white, size: 36),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, {Color color = const Color(0xFF0E6B50)}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}