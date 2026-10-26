import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app_database.dart';

class AddTransactionScreen extends StatefulWidget {
  final int userId;
  const AddTransactionScreen({super.key, required this.userId});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _categoryController = TextEditingController();
  DateTime? _selectedDate;
  String _type = 'expense';
  bool _saving = false;

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) return;
    final amount = int.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (amount == null || amount <= 0) return;

    setState(() => _saving = true);
    try {
      await AppDatabase.instance.addTransaction(
        userId: widget.userId,
        title: _titleController.text,
        amount: amount,
        type: _type,
        category: _categoryController.text,
        dateIso: DateFormat('yyyy-MM-dd').format(_selectedDate!),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil disimpan.'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi gagal disimpan. Silakan coba lagi.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catat Transaksi'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul Transaksi'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Judul wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Nominal (Rupiah)'),
                validator: (value) {
                  final amount = int.tryParse((value ?? '').replaceAll(RegExp(r'[^0-9]'), ''));
                  if (amount == null || amount <= 0) return 'Masukkan nominal yang valid';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Jenis Transaksi'),
                items: const [
                  DropdownMenuItem(value: 'expense', child: Text('Pengeluaran')),
                  DropdownMenuItem(value: 'income', child: Text('Pemasukan')),
                ],
                onChanged: (value) => setState(() => _type = value ?? 'expense'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Kategori (contoh: Makanan, Transportasi)'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Kategori wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Transaksi', suffixIcon: Icon(Icons.calendar_today)),
                onTap: () => _selectDate(context),
                validator: (value) => value == null || value.isEmpty ? 'Tanggal wajib diisi' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Simpan', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
