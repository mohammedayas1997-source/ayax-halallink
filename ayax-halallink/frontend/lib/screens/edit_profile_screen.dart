import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _bioController = TextEditingController(text: 'Seeking a righteous spouse for a blessed Halal marriage.');
  final TextEditingController _cityController = TextEditingController(text: 'Abuja');
  final TextEditingController _countryController = TextEditingController(text: 'Nigeria');
  final TextEditingController _hobbiesController = TextEditingController(text: 'Reading, Quran, Traveling');
  bool _isLoading = false;

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await http.put(
        Uri.parse('http://localhost:5000/api/profile/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'city': _cityController.text,
          'country': _countryController.text,
          'bio': _bioController.text,
          'hobbies': _hobbiesController.text,
        }),
      );

      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile.')),
          );
        }
      }
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $err')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAccount() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account Permanently?'),
        content: const Text('This will erase all your profile data, points, and chat history. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(context);
              // Call API to delete account
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            child: const Text('Delete My Account'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile & Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0E6B50),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          const Text('Update Your Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0E6B50))),
          const SizedBox(height: 16),
          TextField(
            controller: _bioController,
            maxLines: 3,
            decoration: InputDecoration(labelText: 'Bio', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _cityController,
            decoration: InputDecoration(labelText: 'City', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _countryController,
            decoration: InputDecoration(labelText: 'Country', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _hobbiesController,
            decoration: InputDecoration(labelText: 'Hobbies', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0E6B50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _isLoading ? null : _updateProfile,
            child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 40),
          const Text('Danger Zone', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.delete_forever),
            label: const Text('Delete Account Permanently', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            onPressed: _deleteAccount,
          ),
        ],
      ),
    );
  }
}