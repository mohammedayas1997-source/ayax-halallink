import 'package:flutter/material.dart';

class WaliDashboardScreen extends StatefulWidget {
  final String guardianName;
  final String wardName;

  const WaliDashboardScreen({
    super.key,
    required this.guardianName,
    required this.wardName,
  });

  @override
  State<WaliDashboardScreen> createState() => _WaliDashboardScreenState();
}

class _WaliDashboardScreenState extends State<WaliDashboardScreen> {
  // Mock active matched suitors monitored by the Wali
  final List> _monitoredMatches = [
    {
      'matchId': 201,
      'suitorName': 'Ibrahim Al-Amin',
      'suitorAge': 28,
      'suitorProfession': 'Civil Engineer',
      'suitorCountry': 'United Kingdom',
      'matchDate': 'Nov 10, 2026',
      'status': 'Active Chaperoned Discussion',
      'lastMessage': 'I would love to arrange a formal meeting with you and your family.',
      'safetyScore': '100% Halal Compliant',
    },
    {
      'matchId': 202,
      'suitorName': 'Tariq Mansoor',
      'suitorAge': 30,
      'suitorProfession': 'Data Architect',
      'suitorCountry': 'Saudi Arabia',
      'matchDate': 'Nov 05, 2026',
      'status': 'Pending Wali Approval',
      'lastMessage': 'Assalamu Alaikum uncle, I am writing to formally express my marriage intent.',
      'safetyScore': '100% Halal Compliant',
    },
  ];

  void _openConversationTranscript(Map<String, dynamic> match) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                Text(
                  'Transcript: ${widget.wardName} & ${match['suitorName']}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0E6B50)),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const Text(
              'Wali Chaperone Notice: All messages are scanned by AI for respectful dialogue.',
              style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _buildTranscriptBubble(widget.wardName, 'Wa Alaikum Assalam. Thank you for reaching out.', true),
                  _buildTranscriptBubble(match['suitorName'], match['lastMessage'], false),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.block),
                    label: const Text('Intervene / End Match'),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Match intervention recorded. Ward notified.')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0E6B50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Approve Suitor'),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Suitor officially approved by Wali.')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranscriptBubble(String sender, String text, bool isWard) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isWard ? const Color(0xFFE8F5E9) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(sender, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isWard ? const Color(0xFF0E6B50) : Colors.grey[700])),
          const SizedBox(height: 4),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ayax HalalLink • Wali Portal',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0E6B50),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0E6B50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF0E6B50).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.security, color: Color(0xFF0E6B50), size: 36),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Guardian: ${widget.guardianName}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Monitoring Ward: ${widget.wardName}',
                          style: const TextStyle(color: Colors.black8Text || Colors.black87, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Monitored Suitor Proposals',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0E6B50)),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _monitoredMatches.length,
                itemBuilder: (context, index) {
                  final match = _monitoredMatches[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.between,
                            children: [
                              Text(
                                match['suitorName'],
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD4AF37).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  match['status'],
                                  style: const TextStyle(color: Color(0xFF8C7323), fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${match['suitorProfession']} • ${match['suitorCountry']} (${match['suitorAge']} yrs)',
                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          const Divider(height: 16),
                          Text(
                            'Latest: "${match['lastMessage']}"',
                            style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0E6B50),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.visibility, size: 18),
                              label: const Text('Review Chaperoned Transcript'),
                              onPressed: () => _openConversationTranscript(match),
                            ),
                          ),
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
}