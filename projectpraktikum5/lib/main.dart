import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'add_transaction_screen.dart';
import 'login_screen.dart';
import 'main_screen.dart';
import 'register_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UangKu - Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        useMaterial3: false,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
          case '/login':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const LoginScreen(),
            );
          case '/register':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const RegisterScreen(),
            );
          case '/home':
            final user = Map<String, dynamic>.from(
              settings.arguments! as Map,
            );
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => MainScreen(user: user),
            );
          case '/add':
            final userId = settings.arguments! as int;
            return MaterialPageRoute<bool>(
              settings: settings,
              builder: (_) => AddTransactionScreen(userId: userId),
            );
          default:
            return MaterialPageRoute<void>(
              builder: (_) => const LoginScreen(),
            );
        }
      },
    );
  }
}
