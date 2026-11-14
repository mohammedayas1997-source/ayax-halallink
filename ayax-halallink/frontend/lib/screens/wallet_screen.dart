import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final TextEditingController _pointsController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _routingNumberController = TextEditingController();

  String _selectedCurrency = 'NGN';
  int _currentPointsBalance = 1250; // Mock initial balance including 100 signup bonus
  bool _isLoading = false;

  final List<String> _currencies = ['NGN', 'USD', 'EUR', 'GBP', 'KES', 'GHS', 'CAD'];

  // Calculate estimated net payout (60% to user, 40% platform commission)
  double get _estimatedPayout {
    int points = int.tryParse(_pointsController.text) ?? 0;
    double grossValue = points * 10; // 1 point = 10 units in local currency/USD rate
    return grossValue * 0.60;
  }

  Future<void> _requestWithdrawal() async {
    final points = int.tryParse(_pointsController.text) ?? 0;

    if (points < 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimum points for cash out is 1,000 points.')),
      );
      return;
    }

    if (points > _currentPointsBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient points balance.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await http.post(
        Uri.parse('http://localhost:5000/api/wallet/withdraw'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'pointsToRedeem': points,
          'payoutCurrency': _selectedCurrency,
          'bankName': _bankNameController.text,
          'accountNumber': _accountNumberController.text,
          'accountName': _accountNameController.text,
          'routingNumber': _routingNumberController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        setState(() {
          _currentPointsBalance -= points;
        });
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Cash-Out Requested'),
              content: Text(data['message'] ?? 'Your payout request has been successfully submitted.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['error'] ?? 'Failed to process withdrawal.')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ayax HalalLink • Wallet & Cash Out',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0E6B50),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Points Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0E6B50), Color(0xFF138564)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Available Points Balance',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      Text(
                        '$_currentPointsBalance Pts',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '100 Pts = $1 / ₦1,000',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Cash-Out Form
            const Text(
              'Request Global Payout (60% You / 40% Platform)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0E6B50)),
            ),
            const SizedBox(height: 16),

            // Points to Redeem Input
            TextField(
              controller: _pointsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Points to Redeem (Min. 1,000)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.monetization_on, color: Color(0xFF0E6B50)),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Currency Selector
            DropdownButtonFormField<String>(
              value: _selectedCurrency,
              decoration: InputDecoration(
                labelText: 'Payout Currency',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.currency_exchange, color: Color(0xFF0E6B50)),
              ),
              items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _selectedCurrency = val!),
            ),
            const SizedBox(height: 16),

            // Estimated Net Payout Display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.between,
                children: [
                  const Text('Estimated Net Payout (60%):', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    '${_estimatedPayout.toStringAsFixed(2)} $_selectedCurrency',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0E6B50)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Bank Details Inputs
            TextField(
              controller: _bankNameController,
              decoration: InputDecoration(
                labelText: 'Bank Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.account_balance, color: Color(0xFF0E6B50)),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _accountNumberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Account Number / IBAN',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.numbers, color: Color(0xFF0E6B50)),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _accountNameController,
              decoration: InputDecoration(
                labelText: 'Account Holder Full Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.person, color: Color(0xFF0E6B50)),
              ),
            ),
            const SizedBox(height: 16),

            if (_selectedCurrency != 'NGN')
              TextField(
                controller: _routingNumberController,
                decoration: InputDecoration(
                  labelText: 'Routing Number / SWIFT BIC (International)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.security, color: Color(0xFF0E6B50)),
                ),
              ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E6B50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _requestWithdrawal,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Request Cash-Out',
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