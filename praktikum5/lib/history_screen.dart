import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = [
      {
        'title': 'Makan Siang',
        'amount': '- Rp 50.000',
        'category': 'Makanan',
        'date': '13 September 2026',
        'type': 'expense',
      },
      {
        'title': 'Gaji Bulanan',
        'amount': '+ Rp 5.000.000',
        'category': 'Pemasukan',
        'date': '1 September 2026',
        'type': 'income',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          final isIncome = transaction['type'] == 'income';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isIncome
                    ? Colors.green.shade100
                    : Colors.red.shade100,
                child: Icon(
                  isIncome ? Icons.trending_up : Icons.trending_down,
                  color: isIncome ? Colors.green : Colors.red,
                ),
              ),
              title: Text(transaction['title']!),
              subtitle: Text(
                '${transaction['category']} - ${transaction['date']}',
              ),
              trailing: Text(
                transaction['amount']!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isIncome ? Colors.green : Colors.red,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}