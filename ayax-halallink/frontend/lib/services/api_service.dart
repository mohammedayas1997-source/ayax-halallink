import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  // Helper don samun Token din mai amfani
  static Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  // 1. Aika Request na Withdrawal zuwa Backend
  static Future> requestWithdrawal(int points, String currency, String bankName, String accountNumber, String accountName) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/wallet/withdraw'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'pointsToRedeem': points,
        'payoutCurrency': currency,
        'bankName': bankName,
        'accountNumber': accountNumber,
        'accountName': accountName,
      }),
    );
    return jsonDecode(response.body);
  }

  // 2. Aika Post zuwa Community Feed
  static Future> createPost(String content) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'content': content}),
    );
    return jsonDecode(response.body);
  }

  // 3. Ƙarar Points ta Hanyar Admin
  static Future> adminGrantPoints(int userId, int points, String reason) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/admin/grant-points'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'userId': userId,
        'pointsToAdd': points,
        'reason': reason,
      }),
    );
    return jsonDecode(response.body);
  }
}