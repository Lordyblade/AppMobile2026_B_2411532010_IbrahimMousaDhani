import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app_database.dart';
import 'transaction_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _transactions = [];
  int _balance = 0;
  bool _loading = true;
  final _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final _dateFormat = DateFormat('d MMMM yyyy', 'id_ID');

  int get _userId => widget.user['id'] as int;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final results = await Future.wait<dynamic>([
      AppDatabase.instance.getRecentTransactions(_userId),
      AppDatabase.instance.getBalance(_userId),
    ]);
    if (!mounted) return;
    setState(() {
      _transactions = results[0] as List<Map<String, dynamic>>;
      _balance = results[1] as int;
      _loading = false;
    });
  }

  String _formatDate(String value) {
    try {
      return _dateFormat.format(DateTime.parse(value));
    } catch (_) {
      return value;
    }
  }

  String _formatAmount(Map<String, dynamic> transaction) {
    final amount = _currency.format(transaction['amount'] as int);
    return transaction['type'] == 'income' ? '+ $amount' : '- $amount';
  }

  Future<void> _openAddTransaction() async {
    final saved = await Navigator.pushNamed<bool>(
      context,
      '/add',
      arguments: _userId,
    );
    if (saved == true) await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.user['name'] as String;
    final email = widget.user['email'] as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Keuangan'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
        onPressed: _openAddTransaction,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Halo, $name', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Email: $email', style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 20),
              _buildBalanceCard(),
              const SizedBox(height: 20),
              const Text('Transaksi Terakhir', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (_loading)
                const Center(child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ))
              else if (_transactions.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text('Belum ada transaksi. Tekan tombol + untuk menambahkan.')),
                  ),
                )
              else
                _buildTransactionList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    final isNegative = _balance < 0;
    return Card(
      elevation: 4,
      color: Colors.redAccent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Saldo Utama', style: TextStyle(fontSize: 16, color: Colors.white70)),
            const SizedBox(height: 8),
            Text(
              '${isNegative ? '-' : ''}${_currency.format(_balance.abs())}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    return Card(
      elevation: 2,
      child: Column(
        children: List.generate(_transactions.length, (index) {
          final transaction = _transactions[index];
          final isIncome = transaction['type'] == 'income';
          return Column(
            children: [
              if (index > 0) const Divider(height: 1),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: isIncome ? Colors.green : Colors.orange,
                  child: Icon(
                    isIncome ? Icons.attach_money : Icons.fastfood,
                    color: Colors.white,
                  ),
                ),
                title: Text(transaction['title'] as String),
                subtitle: Text(_formatDate(transaction['transaction_date'] as String)),
                trailing: Text(
                  _formatAmount(transaction),
                  style: TextStyle(fontWeight: FontWeight.bold, color: isIncome ? Colors.green : Colors.red),
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute<void>(
                    builder: (_) => TransactionDetailScreen(
                      title: transaction['title'] as String,
                      amount: _formatAmount(transaction),
                      category: transaction['category'] as String,
                      date: _formatDate(transaction['transaction_date'] as String),
                    ),
                  ));
                },
              ),
            ],
          );
        }),
      ),
    );
  }
}
