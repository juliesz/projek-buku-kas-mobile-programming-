import 'package:flutter/material.dart';
import '../models/transaction_item.dart';

class TransactionDetailScreen extends StatelessWidget {
  final TransactionItem transaction;
  final bool isHideBalance;

  const TransactionDetailScreen({
    super.key,
    required this.transaction,
    required this.isHideBalance,
  });

  String formatRupiah(int number) {
    if (isHideBalance) return 'Rp••••••';
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

  String formatFullDate(DateTime date) {
    final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}\nPukul ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} WIB';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final isIncome = transaction.isIncome;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Ikon Status
            CircleAvatar(
              radius: 40,
              backgroundColor: isIncome ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                size: 40,
                color: isIncome ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isIncome ? 'Pemasukan' : 'Pengeluaran',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isIncome ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formatRupiah(transaction.amount),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 30),

            // Kartu Detail
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Judul', transaction.title, textColor),
                  const Divider(height: 24),
                  _buildDetailRow('ID Transaksi', transaction.id ?? '-', textColor),
                  const Divider(height: 24),
                  _buildDetailRow('Waktu', formatFullDate(transaction.date), textColor),
                  const Divider(height: 24),
                  _buildDetailRow('Tipe', isIncome ? 'Uang Masuk' : 'Uang Keluar', textColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color textColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}