import 'package:flutter/material.dart';
import '../models/user_account.dart';

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.account_balance_wallet, color: Color(0xFF1A237E)),
            const SizedBox(width: 8),
            const Text('Tentang FINOTE'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FINOTE — Catatan Keuanganmu',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
        ],
      ),
    );
  }

  void _confirmLogout() {
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Reset Data'),
        content: const Text(
            'Semua transaksi dan notifikasi akan dihapus permanen. Tindakan ini tidak bisa dibatalkan. Lanjutkan?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
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
              icon: const Icon(Icons.arrow_back), onPressed: () => _back()),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
                          color: Color(0xFF1A237E)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.user.fullName,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor)),
                        const SizedBox(height: 4),
                        Text('@${widget.user.username}',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _sectionTitle('TAMPILAN'),
            const SizedBox(height: 8),
            _card(cardColor: cardColor, children: [
              _switchTile(
                icon: _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                iconColor:
                    _isDarkMode ? Colors.amber : const Color(0xFF1A237E),
                title: 'Mode Gelap',
                subtitle:
                    _isDarkMode ? 'Tema gelap aktif' : 'Tema terang aktif',
                value: _isDarkMode,
                textColor: textColor,
                onChanged: (v) {
                  setState(() => _isDarkMode = v);
                  widget.onToggleDarkMode(v);
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
                onChanged: (v) => setState(() => _hideBalance = v),
              ),
            ]),
            const SizedBox(height: 20),
            _sectionTitle('NOTIFIKASI'),
            const SizedBox(height: 8),
            _card(cardColor: cardColor, children: [
              _switchTile(
                icon: Icons.notifications_active,
                iconColor: Colors.orange,
                title: 'Notifikasi Transaksi',
                subtitle: 'Tampilkan notifikasi saat input transaksi',
                value: _notifEnabled,
                textColor: textColor,
                onChanged: (v) => setState(() => _notifEnabled = v),
              ),
            ]),
            const SizedBox(height: 20),
            _sectionTitle('LAINNYA'),
            const SizedBox(height: 8),
            _card(cardColor: cardColor, children: [
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
            ]),
            const SizedBox(height: 30),
            Center(
              child: Text('FINOTE v1.0.0',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(title,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: Colors.grey[500])),
    );
  }

  Widget _card({required Color cardColor, required List<Widget> children}) {
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
        height: 1, indent: 56, color: Colors.grey.withValues(alpha: 0.15));
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title,
          style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14, color: textColor)),
      subtitle: Text(subtitle,
          style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      trailing: Switch.adaptive(
          value: value,
          activeThumbColor: const Color(0xFF1A237E),
          onChanged: onChanged),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title,
          style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14, color: textColor)),
      subtitle: Text(subtitle,
          style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      trailing:
          Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
    );
  }
}