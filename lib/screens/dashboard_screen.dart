import 'package:flutter/material.dart';
import '../models/transaction_item.dart';
import '../models/user_account.dart';
import '../models/app_notification.dart';
import '../services/api_service.dart';
import '../widgets/common_widgets.dart';
import 'login_screen.dart';
import 'pengaturan_screen.dart';
import 'pemasukan_screen.dart';
import 'pengeluaran_screen.dart';
import 'transaction_list_screen.dart'; // <-- Import halaman list baru

class DashboardScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onToggleDarkMode;

  const DashboardScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleDarkMode,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _api = ApiService();

  // State login
  bool _isLoggedIn = false;
  UserAccount? _currentUser;

  // State data API
  bool _isLoading = false;
  List<TransactionItem> transactions = [];
  List<AppNotification> _notifications = [];
  int totalIncome = 0;
  int totalExpense = 0;

  // State pengaturan
  bool _hideBalance = false;
  bool _notifEnabled = true;

  int get balance => totalIncome - totalExpense;

  // ================= FETCH DATA =================
  Future<void> _fetchData() async {
    if (!_isLoggedIn) return;
    setState(() => _isLoading = true);
    try {
      final trx = await _api.getTransactions();
      final summary = await _api.getSummary();
      final notifs = await _api.getNotifications();

      setState(() {
        transactions = trx;
        totalIncome = summary['totalIncome'] ?? 0;
        totalExpense = summary['totalExpense'] ?? 0;
        _notifications = notifs;
      });
    } catch (e) {
      if (mounted) {
        _showSnackBar('Gagal mengambil data dari server', Colors.red, Icons.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ================= LOGIN / LOGOUT =================
  Future<void> _handleLogin(UserAccount user) async {
    setState(() {
      _isLoggedIn = true;
      _currentUser = user;
    });
    _showSnackBar('Selamat datang, ${user.fullName}!', Colors.green, Icons.check_circle);
    await _fetchData();
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _isLoggedIn = false;
                _currentUser = null;
                _notifications.clear();
                transactions.clear();
                totalIncome = 0;
                totalExpense = 0;
              });
              _api.setToken(null); // Hapus token
              _showSnackBar('Kamu telah logout', Colors.grey, Icons.logout);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _openLoginScreen() async {
    final user = await Navigator.push<UserAccount>(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
    if (user != null) await _handleLogin(user);
  }

  // ================= PENGATURAN =================
  Future<void> _openPengaturan() async {
    if (!_isLoggedIn) {
      _showSnackBar('Silakan login dulu untuk membuka pengaturan', Colors.orange, Icons.lock_outline);
      return;
    }
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => PengaturanScreen(
          user: _currentUser!,
          isDarkMode: widget.isDarkMode,
          hideBalance: _hideBalance,
          notifEnabled: _notifEnabled,
          onToggleDarkMode: widget.onToggleDarkMode,
        ),
      ),
    );
    if (result != null) {
      if (result['logout'] == true) {
        _handleLogout();
        return;
      }
      if (result['reset'] == true) {
        _showSnackBar('Fitur Reset belum diimplementasi di API', Colors.orange, Icons.info);
        return;
      }
      setState(() {
        _hideBalance = result['hideBalance'] ?? _hideBalance;
        _notifEnabled = result['notifEnabled'] ?? _notifEnabled;
      });
    }
  }

  // ================= NOTIFIKASI =================
  void _showSnackBar(String text, Color color, IconData icon) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }

  void _openNotificationPanel() {
    if (!_isLoggedIn) {
      _showSnackBar('Silakan login dulu', Colors.orange, Icons.info_outline);
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.notifications, color: Color(0xFF1A237E)),
                    const SizedBox(width: 8),
                    const Text('Notifikasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    if (_notifications.isNotEmpty)
                   TextButton(
                    onPressed: () async {
                      await _api.clearNotifications();
                      if (mounted) {
                        setState(() => _notifications.clear());
                        if (ctx.mounted) { // <-- Tambahkan pengecekan pada ctx
                          Navigator.pop(ctx);
                        }
                      }
                    },
                    child: const Text('Hapus semua'),
                  ),
                  ],
                ),
                const Divider(),
                if (_notifications.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: Text('Belum ada notifikasi')),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _notifications.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final n = _notifications[i];
                        return ListTile(
                          leading: Icon(
                            n.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                            color: n.isIncome ? Colors.green : Colors.red,
                          ),
                          title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(n.message),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= FORMAT =================
  String formatRupiah(int number) {
    if (_hideBalance) return 'Rp••••••';
    final String value = number.toString();
    String result = '';
    int count = 0;
    for (int i = value.length - 1; i >= 0; i--) {
      result = value[i] + result;
      count++;
      if (count % 3 == 0 && i != 0) result = '.$result';
    }
    return 'Rp$result';
  }

  String formatDate(DateTime date) {
    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${days[date.weekday - 1]}, ${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  String formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xffF5F7FB);
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 30),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FINOTE', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            Text('Catatan keuanganmu', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        actions: [
          if (_isLoggedIn)
            Stack(
              children: [
                IconButton(
                  onPressed: _openNotificationPanel,
                  icon: const Icon(Icons.notifications_none, color: Colors.white),
                ),
                if (_notifications.isNotEmpty && _notifEnabled)
                  Positioned(
                    right: 6, top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        _notifications.length > 9 ? '9+' : '${_notifications.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isLoggedIn
              ? _buildLoggedInBody(cardColor, textColor, isDark)
              : _buildGuestBody(cardColor, textColor),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 180,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: Color(0xFF1A237E)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.account_balance_wallet, color: Colors.white, size: 45),
                const SizedBox(height: 10),
                const Text('FINOTE', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(
                  _isLoggedIn ? (_currentUser?.fullName ?? 'Pengguna') : 'Belum login',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined, color: Color(0xFF1A237E)),
            title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.arrow_downward, color: Colors.green),
            title: const Text('Pemasukan', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Catat uang yang kamu terima'),
            onTap: () async {
              Navigator.pop(context);
              if (!_isLoggedIn) {
                _showSnackBar('Silakan login dulu', Colors.orange, Icons.lock_outline);
                await _openLoginScreen();
                return;
              }
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (context) => PemasukanScreen(onSave: (amount, desc) async {
                  await _api.createTransaction(TransactionItem(title: desc, amount: amount, isIncome: true));
                  await _fetchData();
                  return true;
                })),
              );
              if (result == true && mounted) _showSnackBar('Pemasukan dicatat', Colors.green, Icons.check_circle);
            },
          ),
          ListTile(
            leading: const Icon(Icons.arrow_upward, color: Colors.red),
            title: const Text('Pengeluaran', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Catat uang yang kamu keluarkan'),
            onTap: () async {
              Navigator.pop(context);
              if (!_isLoggedIn) {
                _showSnackBar('Silakan login dulu', Colors.orange, Icons.lock_outline);
                await _openLoginScreen();
                return;
              }
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (context) => PengeluaranScreen(onSave: (amount, desc) async {
                  await _api.createTransaction(TransactionItem(title: desc, amount: amount, isIncome: false));
                  await _fetchData();
                  return true;
                })),
              );
              if (result == true && mounted) _showSnackBar('Pengeluaran dicatat', Colors.red, Icons.check_circle);
            },
          ),
          const Divider(),
          if (!_isLoggedIn)
            ListTile(
              leading: const Icon(Icons.login, color: Colors.blue),
              title: const Text('Masuk', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () async {
                Navigator.pop(context);
                await _openLoginScreen();
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(_currentUser?.username ?? ''),
              onTap: () {
                Navigator.pop(context);
                _handleLogout();
              },
            ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Pengaturan'),
            onTap: () {
              Navigator.pop(context);
              _openPengaturan();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGuestBody(Color cardColor, Color textColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Halo! 👋', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 5),
          const Text('Silakan login untuk melihat data keuanganmu', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.lock_outline, size: 50, color: Color(0xFF1A237E)),
                ),
                const SizedBox(height: 20),
                Text('Data Keuangan Terkunci', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('Login dulu untuk melihat dan mencatat pemasukan serta pengeluaranmu.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500], height: 1.5)),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _openLoginScreen,
                    icon: const Icon(Icons.login),
                    label: const Text('Masuk ke Akun', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text('Akun demo: admin / 123456', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedInBody(Color cardColor, Color textColor, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Halo, ${_currentUser?.fullName ?? 'Pengguna'}! 👋', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 5),
          const Text('Berikut ringkasan keuanganmu', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(color: const Color(0xFF1A237E), borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SALDO', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(formatRupiah(balance), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                const Text('Saldo saat ini', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: 'Uang Masuk',
                  amount: formatRupiah(totalIncome),
                  icon: Icons.arrow_downward,
                  color: Colors.green,
                  cardColor: cardColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SummaryCard(
                  title: 'Uang Keluar',
                  amount: formatRupiah(totalExpense),
                  icon: Icons.arrow_upward,
                  color: Colors.red,
                  cardColor: cardColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TRANSAKSI TERBARU', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransactionListScreen(
                        isHideBalance: _hideBalance,
                      ),
                    ),
                  );
                },
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (transactions.isEmpty)
            Center(child: Text('Belum ada transaksi', style: TextStyle(color: Colors.grey[500])))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length > 6 ? 6 : transactions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final trx = transactions[index];
                return Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2))],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 6),
                                Text(formatDate(trx.date), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey[600])),
                              ],
                            ),
                            Text(formatTime(trx.date), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(trx.title, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: textColor)),
                            Text(
                              '${trx.isIncome ? '+' : '-'} ${formatRupiah(trx.amount)}',
                              style: TextStyle(color: trx.isIncome ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(builder: (context) => PemasukanScreen(onSave: (amount, desc) async {
                        await _api.createTransaction(TransactionItem(title: desc, amount: amount, isIncome: true));
                        await _fetchData();
                        return true;
                      })),
                    );
                    if (result == true && mounted) _showSnackBar('Pemasukan dicatat', Colors.green, Icons.check_circle);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Pemasukan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(builder: (context) => PengeluaranScreen(onSave: (amount, desc) async {
                        await _api.createTransaction(TransactionItem(title: desc, amount: amount, isIncome: false));
                        await _fetchData();
                        return true;
                      })),
                    );
                    if (result == true && mounted) _showSnackBar('Pengeluaran dicatat', Colors.red, Icons.check_circle);
                  },
                  icon: const Icon(Icons.remove),
                  label: const Text('Tambah Pengeluaran'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}