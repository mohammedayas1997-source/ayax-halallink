import 'package:flutter/material.dart';

class ReportDialog extends StatefulWidget {
  final int reportedUserId;

  const ReportDialog({super.key, required this.reportedUserId});

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String _selectedReason = 'Inappropriate Behavior';
  final TextEditingController _detailsController = TextEditingController();

  final List<String> _reasons = [
    'Inappropriate Behavior',
    'Fake Profile / Catfishing',
    'Harassment or Disrespect',
    'Not Halal Compliant',
    'Spam or Scam'
  ];

  void _submitReport() {
    // Send report to backend POST /api/moderation/report
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report submitted. Thank you for keeping Ayax HalalLink safe.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Report User', style: TextStyle(color: Color(0xFF0E6B50), fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select a reason for reporting this user:'),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedReason,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            items: _reasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (val) => setState(() => _selectedReason = val!),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _detailsController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Additional Details (Optional)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          onPressed: _submitReport,
          child: const Text('Submit Report'),
        ),
      ],
    );
  }
}