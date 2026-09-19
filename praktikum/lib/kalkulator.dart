import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final TextEditingController angka1 = TextEditingController();
  final TextEditingController angka2 = TextEditingController();

  double hasil = 0;

  void tambah() {
    setState(() {
      hasil = double.parse(angka1.text) + double.parse(angka2.text);
    });
  }

  void kurang() {
    setState(() {
      hasil = double.parse(angka1.text) - double.parse(angka2.text);
    });
  }

  void kali() {
    setState(() {
      hasil = double.parse(angka1.text) * double.parse(angka2.text);
    });
  }

  void bagi() {
    setState(() {
      hasil = double.parse(angka1.text) / double.parse(angka2.text);
    });
  }

  @override
  void dispose() {
    angka1.dispose();
    angka2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kalkulator KABATAKU"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: angka1,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Angka Pertama",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: angka2,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Angka Kedua",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: tambah,
                    child: const Text("+")),
                ElevatedButton(
                    onPressed: kurang,
                    child: const Text("-")),
                ElevatedButton(
                    onPressed: kali,
                    child: const Text("×")),
                ElevatedButton(
                    onPressed: bagi,
                    child: const Text("÷")),
              ],
            ),

            const SizedBox(height: 30),

            Text(
              "Hasil : $hasil",
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}