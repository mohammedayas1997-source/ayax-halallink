import 'package:flutter/material.dart';

class AdminModerationScreen extends StatefulWidget {
  const AdminModerationScreen({super.key});

  @override
  State<AdminModerationScreen> createState() => _AdminModerationScreenState();
}

class _AdminModerationScreenState extends State<AdminModerationScreen> {
  // Mock pending reports fetched from /api/moderation/reports
  final List> _reports = [
    {
      'reportId': 101,
      'reporterName': 'Amina Bello',
      'reportedUserId': 502,
      'reportedUserName': 'Tariq Mansoor',
      'reason': 'Inappropriate Behavior',
      'description': 'Sent disrespectful messages ignoring Halal boundaries.',
      'status': 'pending',
      'isSuspended': false,
      'date': 'Nov 13, 2026',
    },
    {
      'reportId': 102,
      'reporterName': 'Fatima Al-Mansoor',
      'reportedUserId': 503,
      'reportedUserName': 'Fake Profile Example',
      'reason': 'Fake Profile / Catfishing',
      'description': 'Using stolen celebrity photos.',
      'status': 'pending',
      'isSuspended': false,
      'date': 'Nov 12, 2026',
    },
  ];

  void _toggleSuspension(int index) {
    setState(() {
      final user = _reports[index];
      user['isSuspended'] = !user['isSuspended'];
      user['status'] = user['isSuspended'] ? 'Resolved (Suspended)' : 'Pending';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_reports[index]['isSuspended']
            ? 'User has been suspended.'
            : 'User suspension lifted.'),
      ),
    );
  }

  void _dismissReport(int index) {
    setState(() {
      _reports.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report dismissed and archived.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ayax HalalLink • Admin Moderation',
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
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.admin_panel_settings, color: Colors.red, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Moderation Control Center',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Pending Reports requiring review: ${_reports.length}',
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Community Reports Queue',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0E6B50)),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _reports.isEmpty
                  ? const Center(
                      child: Text(
                        'No pending reports. All clear, Alhamdulillah!',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _reports.length,
                      itemBuilder: (context, index) {
                        const Color(0xFF0E6B50);
                        final report = _reports[index];
                        final bool isSuspended = report['isSuspended'];

                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 16),
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
                                      'Reported: ${report['reportedUserName']}',
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isSuspended ? Colors.red[100] : Colors.orange[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        report['reason'],
                                        style: TextStyle(
                                          color: isSuspended ? Colors.red[800] : Colors.orange[800],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Reported by: ${report['reporterName']} on ${report['date']}',
                                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                                const Divider(height: 16),
                                Text(
                                  'Description: "${report['description']}"',
                                  style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.grey[700],
                                        side: BorderSide(color: Colors.grey[400]!),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onPressed: () => _dismissReport(index),
                                      child: const Text('Dismiss'),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isSuspended ? Colors.green : Colors.red,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onPressed: () => _toggleSuspension(index),
                                      child: Text(isSuspended ? 'Lift Suspension' : 'Suspend User'),
                                    ),
                                  ],
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