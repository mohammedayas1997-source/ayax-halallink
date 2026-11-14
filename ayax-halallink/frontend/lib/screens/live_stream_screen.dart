import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

class LiveStreamScreen extends StatefulWidget {
  final String liveId;
  final String userId;
  final String userName;
  final bool isHost;
  final bool isPkBattle;

  const LiveStreamScreen({
    super.key,
    required this.liveId,
    required this.userId,
    required this.userName,
    required this.isHost,
    this.isPkBattle = false,
  });

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> with SingleTickerProviderStateMixin {
  int _userPointsBalance = 1250;
  int _hostGiftScore = 8450; // Total points received during this live session
  int _challengerGiftScore = 7920; // Used if PK Battle mode is active

  // Gift catalog matching your pricing (100 points = $1 / ₦1,000)
  final List> _giftCatalog = [
    {'name': 'Rose', 'cost': 100, 'icon': '🌹'},
    {'name': 'Coffee', 'cost': 500, 'icon': '☕'},
    {'name': 'Ring', 'cost': 1000, 'icon': '💍'},
    {'name': 'Perfume', 'cost': 2000, 'icon': '🌸'},
    {'name': 'Car', 'cost': 10000, 'icon': '🚗'},
    {'name': 'House', 'cost': 50000, 'icon': '🏠'},
    {'name': 'Ayax Crown', 'cost': 100000, 'icon': '👑'},
  ];

  String? _activeAnimationGift;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnim = Tween<double>(begin: 0.0, end: 1.5).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _triggerGiftAnimation(String giftIcon) {
    setState(() {
      _activeAnimationGift = giftIcon;
    });
    _animController.forward(from: 0.0).then((_) {
      setState(() {
        _activeAnimationGift = null;
      });
    });
  }

  void _sendGift(Map<String, dynamic> gift) {
    final cost = gift['cost'] as int;

    if (_userPointsBalance < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient points! Please recharge your wallet.')),
      );
      return;
    }

    setState(() {
      _userPointsBalance -= cost;
      _hostGiftScore += cost;
    });

    Navigator.pop(context); // Close bottom sheet
    _triggerGiftAnimation(gift['icon']);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Successfully sent ${gift['name']} (${gift['cost']} Pts)!')),
    );
  }

  void _openGiftShop() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: 380,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                const Text(
                  'Send Halal Live Gift',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Balance: $_userPointsBalance Pts',
                  style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(color: Colors.white24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _giftCatalog.length,
                itemBuilder: (context, index) {
                  final gift = _giftCatalog[index];
                  return GestureDetector(
                    onTap: () => _sendGift(gift),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(gift['icon'], style: const TextStyle(fontSize: 32)),
                          const SizedBox(height: 4),
                          Text(gift['name'], style: const TextStyle(color: Colors.white, fontSize: 12)),
                          Text('${gift['cost']} Pts', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 10)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ZEGOCLOUD Live Streaming App Credentials
    const int appID = 123456789;
    const String appSign = "your_zego_app_sign_here";

    return Scaffold(
      body: Stack(
        children: [
          // 1. ZEGOCLOUD Video Streaming UIKit
          ZegoUIKitPrebuiltLiveStreaming(
            appID: appID,
            appSign: appSign,
            userID: widget.userId,
            userName: widget.userName,
            liveID: widget.liveId,
            config: widget.isHost
                ? ZegoUIKitPrebuiltLiveStreamingConfig.host()
                : ZegoUIKitPrebuiltLiveStreamingConfig.audience(),
          ),

          // 2. PK Battle Leaderboard Header (If PK mode is enabled)
          if (widget.isPkBattle)
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        const Text('Host 1', style: TextStyle(color: Colors.white, fontSize: 12)),
                        Text('$_hostGiftScore Pts', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Text('VS', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 20, fontWeight: FontWeight.bold)),
                    Column(
                      children: [
                        const Text('Challenger', style: TextStyle(color: Colors.white, fontSize: 12)),
                        Text('$_challengerGiftScore Pts', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // 3. Floating Gift Animation Layer
          if (_activeAnimationGift != null)
            Center(
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Text(
                  _activeAnimationGift!,
                  style: const TextStyle(fontSize: 100),
                ),
              ),
            ),

          // 4. Floating Gift Button at Bottom Right
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton.extended(
              backgroundColor: const Color(0xFF0E6B50),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.card_giftcard, color: Color(0xFFD4AF37)),
              label: const Text('Send Gift', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: _openGiftShop,
            ),
          ),
        ],
      ),
    );
  }
}