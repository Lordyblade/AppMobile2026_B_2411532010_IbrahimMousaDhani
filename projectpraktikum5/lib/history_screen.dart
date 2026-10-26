import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app_database.dart';
import 'transaction_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  final int userId;
  const HistoryScreen({super.key, required this.userId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _transactions = [];
  bool _loading = true;
  final _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final _dateFormat = DateFormat('d MMMM yyyy', 'id_ID');

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _loading = true);
    final rows = await AppDatabase.instance.getTransactions(widget.userId);
    if (!mounted) return;
    setState(() {
      _transactions = rows;
      _loading = false;
    });
  }

  String _amount(Map<String, dynamic> transaction) {
    final formatted = _currency.format(transaction['amount'] as int);
    return transaction['type'] == 'income' ? '+ $formatted' : '- $formatted';
  }

  String _date(String value) {
    try {
      return _dateFormat.format(DateTime.parse(value));
    } catch (_) {
      return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
              ? const Center(child: Text('Belum ada transaksi.'))
              : RefreshIndicator(
                  onRefresh: _loadTransactions,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _transactions[index];
                      final isIncome = transaction['type'] == 'income';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isIncome ? Colors.green.shade100 : Colors.red.shade100,
                            child: Icon(
                              isIncome ? Icons.trending_up : Icons.trending_down,
                              color: isIncome ? Colors.green : Colors.red,
                            ),
                          ),
                          title: Text(transaction['title'] as String),
                          subtitle: Text('${transaction['category']} · ${_date(transaction['transaction_date'] as String)}'),
                          trailing: Text(
                            _amount(transaction),
                            style: TextStyle(fontWeight: FontWeight.bold, color: isIncome ? Colors.green : Colors.red),
                          ),
                          onTap: () => Navigator.push(context, MaterialPageRoute<void>(
                            builder: (_) => TransactionDetailScreen(
                              title: transaction['title'] as String,
                              amount: _amount(transaction),
                              category: transaction['category'] as String,
                              date: _date(transaction['transaction_date'] as String),
                            ),
                          )),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
