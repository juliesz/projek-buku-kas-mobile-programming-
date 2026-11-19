import 'package:flutter/material.dart';
import '../models/transaction_item.dart';
import '../services/api_service.dart';
import '../widgets/common_widgets.dart';
import 'transaction_detail_screen.dart';

class TransactionListScreen extends StatefulWidget {
  final bool isHideBalance;
  const TransactionListScreen({super.key, required this.isHideBalance});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final ApiService _api = ApiService();
  
  // State untuk menangani API
  bool _isLoading = true;
  String? _errorMessage;
  List<TransactionItem> _transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _api.getTransactions();
      setState(() {
        _transactions = data;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper Format
  String formatRupiah(int number) {
    if (widget.isHideBalance) return 'Rp••••••';
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
    return '${days[date.weekday - 1]}, ${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Transaksi'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchTransactions, // Tombol untuk mencoba lagi
          )
        ],
      ),
      body: _buildBody(cardColor, textColor),
    );
  }

  Widget _buildBody(Color cardColor, Color textColor) {
    // 1. LOADING STATE
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF1A237E)),
            SizedBox(height: 16),
            Text('Memuat data dari server...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    // 2. ERROR STATE
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Gagal Memuat Data',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchTransactions,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 3. EMPTY STATE
    if (_transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Transaksi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 8),
            const Text('Semua transaksi Anda akan muncul di sini.'),
          ],
        ),
      );
    }

    // 4. LIST STATE (Data Berhasil Dimuat)
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final trx = _transactions[index];
        return InkWell(
          onTap: () {
            // Navigasi ke Halaman Detail
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransactionDetailScreen(
                  transaction: trx,
                  isHideBalance: widget.isHideBalance,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: trx.isIncome ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                  child: Icon(
                    trx.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                    color: trx.isIncome ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trx.title,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                      ),
                      const SizedBox(height: 4),
                      Text(formatDate(trx.date), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                ),
                Text(
                  '${trx.isIncome ? '+' : '-'} ${formatRupiah(trx.amount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: trx.isIncome ? Colors.green : Colors.red,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }
}