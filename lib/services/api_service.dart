import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction_item.dart';
import '../models/user_account.dart';
import '../models/app_notification.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

class ApiService {
  // 🔧 GANTI sesuai environment Anda
  // 10.0.2.2 = localhost untuk Emulator Android
  // Gunakan IP LAN (misal 192.168.1.x) jika pakai HP fisik
  static const String baseUrl = 'http://localhost:3000/api';

  String? _token;

  void setToken(String? token) => _token = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  dynamic _handle(http.Response res) {
    final body = res.body.isNotEmpty ? jsonDecode(res.body) : null;
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body;
    }
    final msg = (body is Map && body['message'] != null)
        ? body['message'].toString()
        : 'Terjadi kesalahan (${res.statusCode})';
    throw ApiException(msg, statusCode: res.statusCode);
  }

  // ============================================================
  // AUTH
  // ============================================================
  Future<UserAccount> login(String username, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({'username': username, 'password': password}),
    );
    final data = _handle(res) as Map<String, dynamic>;
    if (data['token'] != null) setToken(data['token'] as String);
    return UserAccount.fromJson(data['data']);
  }

  Future<UserAccount> register({
    required String username,
    required String password,
    required String fullName,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'username': username,
        'password': password,
        'fullName': fullName,
      }),
    );
    final data = _handle(res) as Map<String, dynamic>;
    return UserAccount.fromJson(data['data']);
  }

  // ============================================================
  // TRANSACTIONS
  // ============================================================
  Future<List<TransactionItem>> getTransactions() async {
    final res = await http.get(
      Uri.parse('$baseUrl/transactions'),
      headers: _headers,
    );
    final data = _handle(res) as Map<String, dynamic>;
    final list = data['data'] as List;
    return list.map((e) => TransactionItem.fromJson(e)).toList();
  }

  Future<TransactionItem> createTransaction(TransactionItem item) async {
    final res = await http.post(
      Uri.parse('$baseUrl/transactions'),
      headers: _headers,
      body: jsonEncode(item.toJson()),
    );
    final data = _handle(res) as Map<String, dynamic>;
    return TransactionItem.fromJson(data['data']);
  }

  Future<void> deleteTransaction(String id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/transactions/$id'),
      headers: _headers,
    );
    _handle(res);
  }

  // ============================================================
  // SUMMARY
  // ============================================================
  Future<Map<String, dynamic>> getSummary() async {
    final res = await http.get(
      Uri.parse('$baseUrl/summary'),
      headers: _headers,
    );
    final data = _handle(res) as Map<String, dynamic>;
    return data['data'] as Map<String, dynamic>;
  }

  // ============================================================
  // NOTIFICATIONS
  // ============================================================
  Future<List<AppNotification>> getNotifications() async {
    final res = await http.get(
      Uri.parse('$baseUrl/notifications'),
      headers: _headers,
    );
    final data = _handle(res) as Map<String, dynamic>;
    final list = data['data'] as List;
    return list.map((e) => AppNotification.fromJson(e)).toList();
  }

  Future<void> clearNotifications() async {
    final res = await http.delete(
      Uri.parse('$baseUrl/notifications'),
      headers: _headers,
    );
    _handle(res);
  }
}