import 'package:flutter/material.dart';

void main() {
  runApp(const FinoteApp());
}

// ============================================================
// FINOTE APP
// ============================================================

class FinoteApp extends StatefulWidget {
  const FinoteApp({super.key});

  @override
  State<FinoteApp> createState() => _FinoteAppState();
}

class _FinoteAppState extends State<FinoteApp> {
  // State global tema
  bool _isDarkMode = false;

  void _setDarkMode(bool value) {
    setState(() => _isDarkMode = value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FINOTE',
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xffF5F7FB),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3F51B5),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: DashboardScreen(
        isDarkMode: _isDarkMode,
        onToggleDarkMode: _setDarkMode,
      ),
    );
  }
}

// ============================================================
// MODEL TRANSAKSI
// ============================================================

class TransactionItem {
  final String title;
  final int amount;
  final bool isIncome;
  final DateTime date;

  TransactionItem({
    required this.title,
    required this.amount,
    required this.isIncome,
    DateTime? date,
  }) : date = date ?? DateTime.now();
}

// ============================================================
// MODEL NOTIFIKASI
// ============================================================

class AppNotification {
  final String title;
  final String message;
  final bool isIncome;
  final DateTime time;

  AppNotification({
    required this.title,
    required this.message,
    required this.isIncome,
    DateTime? time,
  }) : time = time ?? DateTime.now();
}

// ============================================================
// USER MODEL
// ============================================================

class UserAccount {
  final String username;
  final String password;
  final String fullName;

  UserAccount({
    required this.username,
    required this.password,
    required this.fullName,
  });
}

// ============================================================
// DASHBOARD
// ============================================================

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
  // STATE LOGIN
  bool _isLoggedIn = false;
  UserAccount? _currentUser;

  // STATE PENGATURAN
  bool _hideBalance = false;
  bool _notifEnabled = true;

  final List<UserAccount> _registeredUsers = [
    UserAccount(
      username: 'admin',
      password: '123456',
      fullName: 'Admin FINOTE',
    ),
  ];

  int totalIncome = 4666000;
  int totalExpense = 4449209;

  final List<AppNotification> _notifications = [];

  List<TransactionItem> transactions = [
    TransactionItem(
      title: 'Dari workshop',
      amount: 50000,
      isIncome: true,
      date: DateTime(2026, 9, 3, 14, 37),
    ),
    TransactionItem(
      title: 'Print',
      amount: 1000,
      isIncome: false,
      date: DateTime(2026, 9, 3, 14, 38),
    ),
    TransactionItem(
      title: 'Kuota sebulan',
      amount: 105000,
      isIncome: false,
      date: DateTime(2026, 9, 3, 13, 45),
    ),
    TransactionItem(
      title: 'Bensin mas',
      amount: 20000,
      isIncome: false,
      date: DateTime(2026, 9, 3, 13, 44),
    ),
    TransactionItem(
      title: 'Bensin fulltank',
      amount: 33000,
      isIncome: false,
      date: DateTime(2026, 9, 3, 13, 43),
    ),
    TransactionItem(
      title: 'Stempel',
      amount: 85000,
      isIncome: false,
      date: DateTime(2026, 9, 3, 10, 0),
    ),
  ];

  int get balance => totalIncome - totalExpense;

  // ==========================================================
  // LOGIN / LOGOUT
  // ==========================================================
  void _handleLogin(UserAccount user) {
    setState(() {
      _isLoggedIn = true;
      _currentUser = user;
      _notifications.clear();
    });
    _showSnackBar(
      'Selamat datang, ${user.fullName}!',
      Colors.green,
      Icons.check_circle,
    );
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
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _isLoggedIn = false;
                _currentUser = null;
                _notifications.clear();
              });
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
      MaterialPageRoute(
        builder: (context) => LoginScreen(
          registeredUsers: _registeredUsers,
          onRegister: (newUser) {
            setState(() {
              _registeredUsers.add(newUser);
            });
          },
        ),
      ),
    );

    if (user != null) {
      _handleLogin(user);
    }
  }

  // ==========================================================
  // BUKA PENGATURAN
  // ==========================================================
  Future<void> _openPengaturan() async {
    if (!_isLoggedIn) {
      _showSnackBar(
        'Silakan login dulu untuk membuka pengaturan',
        Colors.orange,
        Icons.lock_outline,
      );
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

    // Terapkan hasil perubahan pengaturan
    if (result != null) {
      if (result['logout'] == true) {
        _handleLogout();
        return;
      }
      if (result['reset'] == true) {
        setState(() {
          transactions.clear();
          _notifications.clear();
          totalIncome = 0;
          totalExpense = 0;
        });
        _showSnackBar(
          'Semua data berhasil direset',
          Colors.blue,
          Icons.refresh,
        );
        return;
      }
      setState(() {
        _hideBalance = result['hideBalance'] ?? _hideBalance;
        _notifEnabled = result['notifEnabled'] ?? _notifEnabled;
      });
    }
  }

  // ==========================================================
  // NOTIFIKASI
  // ==========================================================
  void _pushNotification({
    required String title,
    required String message,
    required bool isIncome,
  }) {
    if (!_notifEnabled) return; // hormati setting notifikasi
    setState(() {
      _notifications.insert(
        0,
        AppNotification(
          title: title,
          message: message,
          isIncome: isIncome,
        ),
      );
    });
  }

  void addIncome(int amount, String description) {
    setState(() {
      totalIncome += amount;
      transactions.insert(
        0,
        TransactionItem(
          title: description,
          amount: amount,
          isIncome: true,
        ),
      );
    });

    _pushNotification(
      title: 'Pemasukan Baru',
      message: '$description — ${formatRupiah(amount)}',
      isIncome: true,
    );
    _showSnackBar(
      'Pemasukan "$description" berhasil dicatat',
      Colors.green,
      Icons.check_circle,
    );
  }

  void addExpense(int amount, String description) {
    setState(() {
      totalExpense += amount;
      transactions.insert(
        0,
        TransactionItem(
          title: description,
          amount: amount,
          isIncome: false,
        ),
      );
    });

    _pushNotification(
      title: 'Pengeluaran Baru',
      message: '$description — ${formatRupiah(amount)}',
      isIncome: false,
    );
    _showSnackBar(
      'Pengeluaran "$description" berhasil dicatat',
      Colors.red,
      Icons.check_circle,
    );
  }

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
      _showSnackBar(
        'Silakan login dulu untuk melihat notifikasi',
        Colors.orange,
        Icons.info_outline,
      );
      return;
    }
    if (!_notifEnabled) {
      _showSnackBar(
        'Notifikasi transaksi sedang dimatikan di Pengaturan',
        Colors.orange,
        Icons.notifications_off,
      );
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.notifications,
                            color: Color(0xFF1A237E)),
                        const SizedBox(width: 8),
                        const Text(
                          'Notifikasi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (_notifications.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              setState(() => _notifications.clear());
                              Navigator.pop(ctx);
                            },
                            child: const Text('Hapus semua'),
                          ),
                      ],
                    ),
                    const Divider(),
                    if (_notifications.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.notifications_off,
                                  size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                'Belum ada notifikasi',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _notifications.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final n = _notifications[i];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: n.isIncome
                                    ? Colors.green.withValues(alpha: 0.12)
                                    : Colors.red.withValues(alpha: 0.12),
                                child: Icon(
                                  n.isIncome
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  color: n.isIncome
                                      ? Colors.green[700]
                                      : Colors.red[700],
                                  size: 18,
                                ),
                              ),
                              title: Text(
                                n.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(n.message),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    formatTime(n.time),
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _notifications.removeAt(i);
                                      });
                                      Navigator.pop(ctx);
                                    },
                                    child: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
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
      },
    );
  }

  // ==========================================================
  // FORMAT
  // ==========================================================
  String formatRupiah(int number) {
    if (_hideBalance) return 'Rp••••••';
    final String value = number.toString();
    String result = '';
    int count = 0;
    for (int i = value.length - 1; i >= 0; i--) {
      result = value[i] + result;
      count++;
      if (count % 3 == 0 && i != 0) {
        result = '.$result';
      }
    }
    return 'Rp$result';
  }

  String formatDate(DateTime date) {
    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final dayName = days[date.weekday - 1];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year;
    return '$dayName, $day $month $year';
  }

  String formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // ==========================================================
  // BUILD
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final bgColor =
        isDark ? const Color(0xFF121212) : const Color(0xffF5F7FB);
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 30),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FINOTE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Catatan keuanganmu',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actions: [
          if (_isLoggedIn)
            Stack(
              children: [
                IconButton(
                  onPressed: _openNotificationPanel,
                  icon: const Icon(Icons.notifications_none,
                      color: Colors.white),
                ),
                if (_notifications.isNotEmpty && _notifEnabled)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        _notifications.length > 9
                            ? '9+'
                            : '${_notifications.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
      drawer: Drawer(
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
                  const Icon(Icons.account_balance_wallet,
                      color: Colors.white, size: 45),
                  const SizedBox(height: 10),
                  const Text(
                    'FINOTE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isLoggedIn
                        ? (_currentUser?.fullName ?? 'Pengguna')
                        : 'Belum login',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined,
                  color: Color(0xFF1A237E)),
              title: const Text('Dashboard',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.arrow_downward, color: Colors.green),
              title: const Text('Pemasukan',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Catat uang yang kamu terima'),
              onTap: () async {
                Navigator.pop(context);
                if (!_isLoggedIn) {
                  _showSnackBar('Silakan login dulu untuk mencatat pemasukan',
                      Colors.orange, Icons.lock_outline);
                  await _openLoginScreen();
                  return;
                }
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PemasukanScreen(onSave: addIncome),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_upward, color: Colors.red),
              title: const Text('Pengeluaran',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Catat uang yang kamu keluarkan'),
              onTap: () async {
                Navigator.pop(context);
                if (!_isLoggedIn) {
                  _showSnackBar(
                      'Silakan login dulu untuk mencatat pengeluaran',
                      Colors.orange, Icons.lock_outline);
                  await _openLoginScreen();
                  return;
                }
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PengeluaranScreen(onSave: addExpense),
                  ),
                );
              },
            ),
            const Divider(),
            if (!_isLoggedIn)
              ListTile(
                leading: const Icon(Icons.login, color: Colors.blue),
                title: const Text('Masuk',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () async {
                  Navigator.pop(context);
                  await _openLoginScreen();
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout',
                    style: TextStyle(fontWeight: FontWeight.w600)),
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
      ),
      body: _isLoggedIn
          ? _buildLoggedInBody(cardColor, textColor, isDark)
          : _buildGuestBody(cardColor, textColor),
    );
  }

  // ==========================================================
  // BODY GUEST
  // ==========================================================
  Widget _buildGuestBody(Color cardColor, Color textColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Halo! 👋',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Silakan login untuk melihat data keuanganmu',
            style: TextStyle(color: Colors.grey),
          ),
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
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline,
                      size: 50, color: Color(0xFF1A237E)),
                ),
                const SizedBox(height: 20),
                Text(
                  'Data Keuangan Terkunci',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Login dulu untuk melihat dan mencatat pemasukan serta pengeluaranmu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500], height: 1.5),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _openLoginScreen,
                    icon: const Icon(Icons.login),
                    label: const Text(
                      'Masuk ke Akun',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'Akun demo: admin / 123456',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildGuestPlaceholderCard('SALDO', 'Rp••••••', Colors.grey,
              Icons.account_balance_wallet, cardColor, textColor),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildGuestPlaceholderCard(
                  'Uang Masuk',
                  'Rp••••••',
                  Colors.green.withValues(alpha: 0.5),
                  Icons.arrow_downward,
                  cardColor,
                  textColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGuestPlaceholderCard(
                  'Uang Keluar',
                  'Rp••••••',
                  Colors.red.withValues(alpha: 0.5),
                  Icons.arrow_upward,
                  cardColor,
                  textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Text(
            'TRANSAKSI TERBARU',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 50, color: Colors.grey[400]),
                const SizedBox(height: 10),
                Text(
                  'Belum ada transaksi',
                  style: TextStyle(
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Login dulu untuk menampilkan data',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGuestPlaceholderCard(
    String title,
    String amount,
    Color color,
    IconData icon,
    Color cardColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 5),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BODY LOGGED IN
  // ==========================================================
  Widget _buildLoggedInBody(Color cardColor, Color textColor, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Halo, ${_currentUser?.fullName ?? 'Pengguna'}! 👋',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor),
          ),
          const SizedBox(height: 5),
          const Text(
            'Berikut ringkasan keuanganmu',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SALDO',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formatRupiah(balance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Saldo saat ini',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  title: 'Uang Masuk',
                  amount: formatRupiah(totalIncome),
                  icon: Icons.arrow_downward,
                  color: Colors.green,
                  cardColor: cardColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryCard(
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
          Text(
            'RINGKASAN KEUANGAN',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor),
          ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                _summaryRow(
                  'Masuk',
                  formatRupiah(totalIncome),
                  Colors.green,
                  textColor,
                ),
                const Divider(height: 25),
                _summaryRow(
                  'Keluar',
                  formatRupiah(totalExpense),
                  Colors.red,
                  textColor,
                ),
                const Divider(height: 25),
                _summaryRow(
                  'Saldo',
                  formatRupiah(balance),
                  const Color(0xFF1A237E),
                  textColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TRANSAKSI TERBARU',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length > 6 ? 6 : transactions.length,
            separatorBuilder: (context, index) {
              return const SizedBox(height: 12);
            },
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
                              Icon(Icons.calendar_today,
                                  size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 6),
                              Text(
                                formatDate(transaction.date),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.blue.withValues(alpha: 0.2)
                                  : Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Saldo ${formatRupiah(balance)}',
                              style: const TextStyle(
                                color: Color(0xFF7986CB),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            transaction.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                          Text(
                            formatTime(transaction.date),
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: transaction.isIncome
                              ? Colors.green.withValues(alpha: 0.08)
                              : Colors.red.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              transaction.isIncome
                                  ? 'Pemasukan'
                                  : 'Pengeluaran',
                              style: TextStyle(
                                color: transaction.isIncome
                                    ? Colors.green[700]
                                    : Colors.red[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${transaction.isIncome ? '+' : '-'} ${formatRupiah(transaction.amount)}',
                              style: TextStyle(
                                color: transaction.isIncome
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
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
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PemasukanScreen(onSave: addIncome),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Pemasukan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PengeluaranScreen(onSave: addExpense),
                      ),
                    );
                  },
                  icon: const Icon(Icons.remove),
                  label: const Text('Tambah Pengeluaran'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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

  Widget _summaryCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
    required Color cardColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 5),
          Text(
            amount,
            style: TextStyle(
                color: color,
                fontSize: 17,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
      String title, String amount, Color color, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w600, color: textColor)),
        Text(
          amount,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// ============================================================
// HALAMAN PENGATURAN (TAHAP 1)
// ============================================================

class PengaturanScreen extends StatefulWidget {
  final UserAccount user;
  final bool isDarkMode;
  final bool hideBalance;
  final bool notifEnabled;
  final ValueChanged<bool> onToggleDarkMode;

  const PengaturanScreen({
    super.key,
    required this.user,
    required this.isDarkMode,
    required this.hideBalance,
    required this.notifEnabled,
    required this.onToggleDarkMode,
  });

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  late bool _isDarkMode;
  late bool _hideBalance;
  late bool _notifEnabled;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    _hideBalance = widget.hideBalance;
    _notifEnabled = widget.notifEnabled;
  }

  void _back({bool logout = false, bool reset = false}) {
    Navigator.pop(context, {
      'isDarkMode': _isDarkMode,
      'hideBalance': _hideBalance,
      'notifEnabled': _notifEnabled,
      'logout': logout,
      'reset': reset,
    });
  }

  void _showTentangDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.account_balance_wallet,
                color: Color(0xFF1A237E)),
            const SizedBox(width: 8),
            const Text('Tentang FINOTE'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'FINOTE — Catatan Keuanganmu',
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 4),
            Text('Versi 1.0.0',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
            SizedBox(height: 12),
            Text(
              'Aplikasi sederhana untuk mencatat pemasukan dan pengeluaran sehari-hari dengan tampilan yang bersih dan mudah digunakan.',
              style: TextStyle(height: 1.5, fontSize: 13),
            ),
            SizedBox(height: 12),
            Text('Dibuat dengan Flutter 💙',
                style:
                    TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Logout'),
        content:
            const Text('Yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _back(logout: true);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Reset Data'),
        content: const Text(
          'Semua transaksi dan notifikasi akan dihapus permanen. Tindakan ini tidak bisa dibatalkan. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _back(reset: true);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _back();
      },
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF121212) : const Color(0xffF5F7FB),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A237E),
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text('Pengaturan'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _back(),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ==================================================
            // KARTU PROFIL
            // ==================================================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor:
                        const Color(0xFF1A237E).withValues(alpha: 0.15),
                    child: Text(
                      widget.user.fullName.isNotEmpty
                          ? widget.user.fullName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.fullName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${widget.user.username}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ==================================================
            // SECTION: TAMPILAN
            // ==================================================
            _sectionTitle('TAMPILAN', textColor),
            const SizedBox(height: 8),
            _card(
              cardColor: cardColor,
              textColor: textColor,
              children: [
                _switchTile(
                  icon: _isDarkMode
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  iconColor: _isDarkMode
                      ? Colors.amber
                      : const Color(0xFF1A237E),
                  title: 'Mode Gelap',
                  subtitle: _isDarkMode
                      ? 'Tema gelap aktif'
                      : 'Tema terang aktif',
                  value: _isDarkMode,
                  textColor: textColor,
                  onChanged: (v) {
                    setState(() => _isDarkMode = v);
                    widget.onToggleDarkMode(v); // langsung apply
                  },
                ),
                _divider(),
                _switchTile(
                  icon: Icons.visibility_off_outlined,
                  iconColor: Colors.purple,
                  title: 'Sembunyikan Saldo',
                  subtitle: 'Tampilkan saldo sebagai ••••••',
                  value: _hideBalance,
                  textColor: textColor,
                  onChanged: (v) {
                    setState(() => _hideBalance = v);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ==================================================
            // SECTION: NOTIFIKASI
            // ==================================================
            _sectionTitle('NOTIFIKASI', textColor),
            const SizedBox(height: 8),
            _card(
              cardColor: cardColor,
              textColor: textColor,
              children: [
                _switchTile(
                  icon: Icons.notifications_active,
                  iconColor: Colors.orange,
                  title: 'Notifikasi Transaksi',
                  subtitle: 'Tampilkan notifikasi saat input transaksi',
                  value: _notifEnabled,
                  textColor: textColor,
                  onChanged: (v) {
                    setState(() => _notifEnabled = v);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ==================================================
            // SECTION: LAINNYA
            // ==================================================
            _sectionTitle('LAINNYA', textColor),
            const SizedBox(height: 8),
            _card(
              cardColor: cardColor,
              textColor: textColor,
              children: [
                _tapTile(
                  icon: Icons.info_outline,
                  iconColor: Colors.blue,
                  title: 'Tentang Aplikasi',
                  subtitle: 'Versi 1.0.0',
                  textColor: textColor,
                  onTap: _showTentangDialog,
                ),
                _divider(),
                _tapTile(
                  icon: Icons.refresh,
                  iconColor: Colors.orange,
                  title: 'Reset Data',
                  subtitle: 'Hapus semua transaksi & notifikasi',
                  textColor: textColor,
                  onTap: _confirmReset,
                ),
                _divider(),
                _tapTile(
                  icon: Icons.logout,
                  iconColor: Colors.red,
                  title: 'Logout',
                  subtitle: 'Keluar dari akun ${widget.user.username}',
                  textColor: Colors.red,
                  onTap: _confirmLogout,
                ),
              ],
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                'FINOTE v1.0.0',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: Colors.grey[500],
        ),
      ),
    );
  }

  Widget _card({
    required Color cardColor,
    required Color textColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      indent: 56,
      color: Colors.grey.withValues(alpha: 0.15),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required Color textColor,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[500], fontSize: 12),
      ),
      trailing: Switch.adaptive(
        value: value,
        activeThumbColor: const Color(0xFF1A237E),
        onChanged: onChanged, 
      ),
    );
  }

  Widget _tapTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[500], fontSize: 12),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey[400],
        size: 20,
      ),
    );
  }
}

// ============================================================
// HALAMAN LOGIN / REGISTER
// ============================================================

class LoginScreen extends StatefulWidget {
  final List<UserAccount> registeredUsers;
  final Function(UserAccount) onRegister;

  const LoginScreen({
    super.key,
    required this.registeredUsers,
    required this.onRegister,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();

  bool _isLoginMode = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    super.dispose();
  }

  void _submit() {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final fullName = fullNameController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showError('Username dan password wajib diisi');
      return;
    }

    if (_isLoginMode) {
      final user = widget.registeredUsers.firstWhere(
        (u) => u.username == username && u.password == password,
        orElse: () =>
            UserAccount(username: '', password: '', fullName: ''),
      );
      if (user.username.isEmpty) {
        _showError('Username atau password salah');
        return;
      }
      Navigator.pop(context, user);
    } else {
      if (fullName.isEmpty) {
        _showError('Nama lengkap wajib diisi');
        return;
      }
      if (password.length < 6) {
        _showError('Password minimal 6 karakter');
        return;
      }
      final exists =
          widget.registeredUsers.any((u) => u.username == username);
      if (exists) {
        _showError('Username sudah dipakai');
        return;
      }
      final newUser = UserAccount(
        username: username,
        password: password,
        fullName: fullName,
      );
      widget.onRegister(newUser);
      Navigator.pop(context, newUser);
    }
  }

  void _showError(String message) {
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
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet,
                    size: 50, color: Color(0xFF1A237E)),
              ),
              const SizedBox(height: 20),
              Text(
                _isLoginMode ? 'Selamat Datang' : 'Buat Akun Baru',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
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
                      borderRadius: BorderRadius.circular(14),
                    ),
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
                    borderRadius: BorderRadius.circular(14),
                  ),
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
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isLoginMode ? 'Masuk' : 'Daftar',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLoginMode
                        ? 'Belum punya akun? '
                        : 'Sudah punya akun? ',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() => _isLoginMode = !_isLoginMode);
                    },
                    child: Text(
                      _isLoginMode ? 'Daftar' : 'Masuk',
                      style: const TextStyle(
                        color: Color(0xFF1A237E),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_isLoginMode)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: Color(0xFF1A237E), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Akun demo → username: admin, password: 123456',
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 12),
                        ),
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

// ============================================================
// HALAMAN PEMASUKAN
// ============================================================

class PemasukanScreen extends StatefulWidget {
  final Function(int amount, String description) onSave;

  const PemasukanScreen({super.key, required this.onSave});

  @override
  State<PemasukanScreen> createState() => _PemasukanScreenState();
}

class _PemasukanScreenState extends State<PemasukanScreen> {
  final TextEditingController nominalController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void dispose() {
    nominalController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void save() {
    final String nominalText =
        nominalController.text.replaceAll('.', '').replaceAll(',', '');
    final int? nominal = int.tryParse(nominalText);
    final String description = descriptionController.text.trim();

    if (nominal == null || nominal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nominal yang benar.')),
      );
      return;
    }
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan keterangan transaksi.')),
      );
      return;
    }
    widget.onSave(nominal, description);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Pemasukan'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tambah Pemasukan',
                style:
                    TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Masukkan uang yang kamu terima.',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 25),
            TextField(
              controller: nominalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Nominal',
                hintText: 'Contoh: 50000',
                prefixText: 'Rp ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Keterangan',
                hintText: 'Contoh: Gaji, bonus, jual barang',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: save,
                icon: const Icon(Icons.save),
                label: const Text('Simpan Pemasukan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HALAMAN PENGELUARAN
// ============================================================

class PengeluaranScreen extends StatefulWidget {
  final Function(int amount, String description) onSave;

  const PengeluaranScreen({super.key, required this.onSave});

  @override
  State<PengeluaranScreen> createState() => _PengeluaranScreenState();
}

class _PengeluaranScreenState extends State<PengeluaranScreen> {
  final TextEditingController nominalController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void dispose() {
    nominalController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void save() {
    final String nominalText =
        nominalController.text.replaceAll('.', '').replaceAll(',', '');
    final int? nominal = int.tryParse(nominalText);
    final String description = descriptionController.text.trim();

    if (nominal == null || nominal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nominal yang benar.')),
      );
      return;
    }
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan keterangan transaksi.')),
      );
      return;
    }
    widget.onSave(nominal, description);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Pengeluaran'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tambah Pengeluaran',
                style:
                    TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Masukkan uang yang kamu keluarkan.',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 25),
            TextField(
              controller: nominalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Nominal',
                hintText: 'Contoh: 50000',
                prefixText: 'Rp ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Keterangan',
                hintText: 'Contoh: bensin, makan, pulsa',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: save,
                icon: const Icon(Icons.save),
                label: const Text('Simpan Pengeluaran'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}