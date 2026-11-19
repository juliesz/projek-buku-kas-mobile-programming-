import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final ApiService _api = ApiService();

  bool _isLoginMode = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final fullName = fullNameController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showError('Username dan password wajib diisi');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLoginMode) {
        final user = await _api.login(username, password);
        if (mounted) Navigator.pop(context, user);
      } else {
        if (fullName.isEmpty) throw ApiException('Nama lengkap wajib diisi');
        if (password.length < 6) throw ApiException('Password minimal 6 karakter');
        
        final user = await _api.register(
          username: username,
          password: password,
          fullName: fullName,
        );
        if (mounted) Navigator.pop(context, user);
      }
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Gagal terhubung ke server. Pastikan backend menyala.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoginMode ? 'Masuk' : 'Daftar'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    shape: BoxShape.circle),
                child: const Icon(Icons.account_balance_wallet,
                    size: 50, color: Color(0xFF1A237E)),
              ),
              const SizedBox(height: 20),
              Text(_isLoginMode ? 'Selamat Datang' : 'Buat Akun Baru',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor)),
              const SizedBox(height: 8),
              Text(
                _isLoginMode
                    ? 'Masuk untuk mengakses catatan keuanganmu'
                    : 'Daftar untuk mulai mencatat keuangan',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500]),
              ),
              const SizedBox(height: 30),
              if (!_isLoginMode) ...[
                TextField(
                  controller: fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    hintText: 'Contoh: Budi Santoso',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Masukkan username',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Masukkan password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(_isLoginMode ? 'Masuk' : 'Daftar',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLoginMode ? 'Belum punya akun? ' : 'Sudah punya akun? ',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _isLoginMode = !_isLoginMode),
                    child: Text(_isLoginMode ? 'Daftar' : 'Masuk',
                        style: const TextStyle(
                            color: Color(0xFF1A237E),
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_isLoginMode)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: Color(0xFF1A237E), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                            'Akun demo → username: admin, password: 123456',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}