import 'package:flutter/material.dart';

class FilterModal extends StatefulWidget {
  const FilterModal({super.key});

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  RangeValues _ageRange = const RangeValues(20, 40);
  String _selectedCountry = 'All Countries';
  String _selectedMadhab = 'All';
  String _selectedReligiosity = 'All';
  String _selectedLanguage = 'All';

  final List<String> _countries = ['All Countries', 'Nigeria', 'Saudi Arabia', 'United Kingdom', 'United States', 'UAE', 'Egypt'];
  final List<String> _madhabs = ['All', 'Sunni / Salafi', 'Sunni / Maliki', 'Sunni / Hanafi', 'Sunni / Shafi\'i', 'Shia'];
  final List<String> _religiosityLevels = ['All', 'Very Practicing', 'Practicing Daily Prayers & Hijab', 'Moderately Practicing'];
  final List<String> _languages = ['All', 'English', 'Arabic', 'French', 'Hausa', 'Urdu', 'Indonesian', 'Turkish'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.between,
            children: [
              const Text(
                'Filter Halal Spouses',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0E6B50)),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: ListView(
              children: [
                const Text('Age Range', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                RangeSlider(
                  values: _ageRange,
                  min: 18,
                  max: 70,
                  divisions: 52,
                  labels: RangeLabels(
                    _ageRange.start.round().toString(),
                    _ageRange.end.round().toString(),
                  ),
                  activeColor: const Color(0xFF0E6B50),
                  onChanged: (values) {
                    setState(() {
                      _ageRange = values;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('Country / Region', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCountry,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setState(() => _selectedCountry = val!),
                ),
                const SizedBox(height: 16),
                const Text('Sect / Madhab', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedMadhab,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _madhabs.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                  onChanged: (val) => setState(() => _selectedMadhab = val!),
                ),
                const SizedBox(height: 16),
                const Text('Religiosity Level', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedReligiosity,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _religiosityLevels.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (val) => setState(() => _selectedReligiosity = val!),
                ),
                const SizedBox(height: 16),
                const Text('Spoken Language', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedLanguage,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _languages.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                  onChanged: (val) => setState(() => _selectedLanguage = val!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E6B50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                // Apply filters and fetch from backend /api/matches/discover
                Navigator.pop(context);
              },
              child: const Text('Apply Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}