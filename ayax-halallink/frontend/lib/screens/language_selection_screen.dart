import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class LanguageModel {
  final String code;
  final String name;
  final String nativeName;
  final bool isRtl;

  LanguageModel({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.isRtl,
  });
}

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedCode = 'en';
  String _searchQuery = '';

  final List<LanguageModel> _languages = [
    LanguageModel(code: 'en', name: 'English', nativeName: 'English', isRtl: false),
    LanguageModel(code: 'ar', name: 'Arabic', nativeName: 'العربية', isRtl: true),
    LanguageModel(code: 'fr', name: 'French', nativeName: 'Français', isRtl: false),
    LanguageModel(code: 'es', name: 'Spanish', nativeName: 'Español', isRtl: false),
    LanguageModel(code: 'ur', name: 'Urdu', nativeName: 'اردو', isRtl: true),
    LanguageModel(code: 'id', name: 'Indonesian', nativeName: 'Bahasa Indonesia', isRtl: false),
    LanguageModel(code: 'ms', name: 'Malay', nativeName: 'Bahasa Melayu', isRtl: false),
    LanguageModel(code: 'tr', name: 'Turkish', nativeName: 'Türkçe', isRtl: false),
    LanguageModel(code: 'bn', name: 'Bengali', nativeName: 'বাংলা', isRtl: false),
    LanguageModel(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी', isRtl: false),
    LanguageModel(code: 'fa', name: 'Persian', nativeName: 'فارسی', isRtl: true),
    LanguageModel(code: 'sw', name: 'Swahili', nativeName: 'Kiswahili', isRtl: false),
    LanguageModel(code: 'ru', name: 'Russian', nativeName: 'Русский', isRtl: false),
    LanguageModel(code: 'de', name: 'German', nativeName: 'Deutsch', isRtl: false),
    LanguageModel(code: 'pt', name: 'Portuguese', nativeName: 'Português', isRtl: false),
    LanguageModel(code: 'zh', name: 'Chinese', nativeName: '中文', isRtl: false),
  ];

  Future<void> _applyLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', code);

    setState(() {
      _selectedCode = code;
    });

    if (mounted) {
      AyaxHalalLinkApp.setLocale(context, Locale(code));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredLanguages = _languages.where((lang) {
      return lang.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          lang.nativeName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ayax HalalLink',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Your Preferred Language',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search language (e.g. Arabic, French, Urdu)...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: filteredLanguages.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final lang = filteredLanguages[index];
                  final isSelected = lang.code == _selectedCode;

                  return ListTile(
                    title: Text(
                      lang.nativeName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(lang.name),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Color(0xFF0E6B50))
                        : const Icon(Icons.circle_outlined, color: Colors.grey),
                    onTap: () => _applyLanguage(lang.code),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E6B50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // Navigate to Login / Registration Screen
                },
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}