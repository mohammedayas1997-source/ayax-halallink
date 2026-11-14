import 'package:flutter/material.dart';
Image.asset('assets/images/logo.png', height: 100);

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Form Controllers
  String _gender = 'male';
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _hobbiesController = TextEditingController();
  final TextEditingController _photoUrlController = TextEditingController();
  
  // Spouse Preferences Controllers
  final TextEditingController _spouseMinAgeController = TextEditingController(text: '18');
  final TextEditingController _spouseMaxAgeController = TextEditingController(text: '35');
  String _spouseReligiosity = 'Practicing Daily Prayers';
  String _spouseMadhab = 'Any / Sunni';

  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Submit onboarding data to backend
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile setup completed successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setup Profile (Step ${_currentStep + 1} of 3)', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0E6B50),
        foregroundColor: Colors.white,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentStep = index),
        children: [
          // Step 1: Personal Details & Photo
          _buildStep1(),
          // Step 2: Bio & Hobbies
          _buildStep2(),
          // Step 3: Spouse Preferences (Wife/Husband Criteria)
          _buildStep3(),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ListView(
        children: [
          const Text('Personal Information', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0E6B50))),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _gender,
            decoration: InputDecoration(labelText: 'Gender', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            items: const [
              DropdownMenuItem(value: 'male', child: Text('Male')),
              DropdownMenuItem(value: 'female', child: Text('Female')),
            ],
            onChanged: (val) => setState(() => _gender = val!),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Age', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _countryController,
            decoration: InputDecoration(labelText: 'Country', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _cityController,
            decoration: InputDecoration(labelText: 'City / State', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _photoUrlController,
            decoration: InputDecoration(labelText: 'Profile Photo URL', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0E6B50), foregroundColor: Colors.white, padding: const EdgeInsets.all(14)),
            onPressed: _nextStep,
            child: const Text('Next: Bio & Hobbies', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ListView(
        children: [
          const Text('About You & Hobbies', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0E6B50))),
          const SizedBox(height: 16),
          TextField(
            controller: _bioController,
            maxLines: 4,
            decoration: InputDecoration(labelText: 'Short Bio (Tell potential spouses about your deen & goals)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _hobbiesController,
            decoration: InputDecoration(labelText: 'Hobbies (e.g., Reading, Traveling, Quran Study)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0E6B50), foregroundColor: Colors.white, padding: const EdgeInsets.all(14)),
            onPressed: _nextStep,
            child: const Text('Next: Spouse Criteria', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ListView(
        children: [
          const Text('Spouse Preferences', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0E6B50))),
          const Text('Define the qualities you are looking for in a partner.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _spouseMinAgeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Min Age', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _spouseMaxAgeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Max Age', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _spouseReligiosity,
            decoration: InputDecoration(labelText: 'Preferred Religiosity Level', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            items: const [
              DropdownMenuItem(value: 'Very Practicing', child: Text('Very Practicing')),
              DropdownMenuItem(value: 'Practicing Daily Prayers', child: Text('Practicing Daily Prayers')),
              DropdownMenuItem(value: 'Moderate', child: Text('Moderate')),
            ],
            onChanged: (val) => setState(() => _spouseReligiosity = val!),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0E6B50), foregroundColor: Colors.white, padding: const EdgeInsets.all(14)),
            onPressed: _nextStep,
            child: const Text('Complete Profile Setup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}