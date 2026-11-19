import 'package:flutter/material.dart';

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
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Keterangan',
                hintText: 'Contoh: bensin, makan, pulsa',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14)),
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
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}