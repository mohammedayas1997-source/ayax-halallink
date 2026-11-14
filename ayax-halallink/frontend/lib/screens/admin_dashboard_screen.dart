import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  // Mock registered users fetched from /api/admin/users
  final List> _allUsers = [
    {
      'id': 1,
      'full_name': 'Fatima Al-Mansoor',
      'email': 'fatima@gmail.com',
      'gender': 'female',
      'points': 1450,
      'country': 'Saudi Arabia',
      'status': 'Active',
    },
    {
      'id': 2,
      'full_name': 'Ibrahim Al-Amin',
      'email': 'ibrahim@gmail.com',
      'gender': 'male',
      'points': 820,
      'country': 'Nigeria',
      'status': 'Active',
    },
    {
      'id': 3,
      'full_name': 'Tariq Suspended User',
      'email': 'tariq@gmail.com',
      'gender': 'male',
      'points': 50,
      'country': 'United Arab Emirates',
      'status': 'Suspended',
    },
  ];

  void _deleteUser(int id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete User: $name?'),
        content: const Text('This action is irreversible and will remove all user data, messages, and wallet points.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              setState(() {
                _allUsers.removeWhere((u) => u['id'] == id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User $name deleted.')));
            },
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }

  void _openGrantPointsDialog(Map<String, dynamic> user) {
    final TextEditingController pointsController = TextEditingController();
    final TextEditingController reasonController = TextEditingController(text: 'Admin Bonus Reward');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Grant Points to ${user['full_name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pointsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Points to Add (e.g. 500)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason / Description',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0E6B50), foregroundColor: Colors.white),
            onPressed: () {
              final int points = int.tryParse(pointsController.text) ?? 0;
              if (points > 0) {
                setState(() {
                  user['points'] += points;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Successfully granted $points points to ${user['full_name']}!')),
                );
              }
            },
            child: const Text('Grant Points'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    // Clear auth tokens and navigate back to login
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayax HalalLink • Master Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0E6B50),
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF0E6B50)),
              accountName: Text('Master Administrator', style: TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text('admin@ayaxhalallink.com'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.admin_panel_settings, color: Color(0xFF0E6B50), size: 36),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Color(0xFF0E6B50)),
              title: const Text('Manage All Users'),
              selected: _selectedIndex == 0,
              onTap: () {
                setState(() => _selectedIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.report, color: Color(0xFF0E6B50)),
              title: const Text('Moderation Reports'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to moderation screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.monetization_on, color: Color(0xFF0E6B50)),
              title: const Text('Withdrawal Requests'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to withdrawals screen
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                const Text(
                  'Registered Users Database',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0E6B50)),
                ),
                Chip(
                  backgroundColor: const Color(0xFF0E6B50).withOpacity(0.1),
                  label: Text('Total Users: ${_allUsers.length}', style: const TextStyle(color: Color(0xFF0E6B50), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _allUsers.length,
                itemBuilder: (context, index) {
                  final user = _allUsers[index];
                  final bool isSuspended = user['status'] == 'Suspended';

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF0E6B50).withOpacity(0.2),
                        child: Text(
                          user['full_name'][0],
                          style: const TextStyle(color: Color(0xFF0E6B50), fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        user['full_name'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Email: ${user['email']} • Country: ${user['country']}'),
                          Text('Points Balance: ${user['points']} Pts • Gender: ${user['gender']}'),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSuspended ? Colors.red[100] : Colors.green[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              user['status'],
                              style: TextStyle(
                                color: isSuspended ? Colors.red[800] : Colors.green[800],
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'delete') {
                            _deleteUser(user['id'], user['full_name']);
                          } else if (value == 'suspend') {
                            setState(() {
                              user['status'] = isSuspended ? 'Active' : 'Suspended';
                            });
                          } else if (value == 'grant_points') {
                            _openGrantPointsDialog(user);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'suspend',
                            child: Text(isSuspended ? 'Lift Suspension' : 'Suspend User'),
                          ),
                          const PopupMenuItem(
                            value: 'grant_points',
                            child: Text('Grant Bonus Points', style: TextStyle(color: Color(0xFF0E6B50))),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete User', style: TextStyle(color: Colors.red)),
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