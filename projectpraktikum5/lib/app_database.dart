import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// SQLite lokal untuk akun pengguna dan transaksi UangKu - Expense Tracker.
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  static const _databaseName = 'expense_tracker.db';
  static const _databaseVersion = 1;
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dbPath, _databaseName),
      version: _databaseVersion,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _createTables,
    );
    return _db!;
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        password_salt TEXT NOT NULL,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        amount INTEGER NOT NULL CHECK(amount > 0),
        type TEXT NOT NULL CHECK(type IN ('income', 'expense')),
        category TEXT NOT NULL,
        transaction_date TEXT NOT NULL,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_transactions_user_date ON transactions(user_id, transaction_date DESC)',
    );
  }

  String _createSalt() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(24, (_) => chars[random.nextInt(chars.length)]).join();
  }

  String _hashPassword(String salt, String password) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();

  /// Membuat akun lokal. Mengembalikan data pengguna tanpa hash password.
  /// Dua transaksi contoh disimpan di SQLite agar halaman awal tetap berisi data.
  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final db = await database;
    final normalizedEmail = email.trim().toLowerCase();
    final salt = _createSalt();
    final hash = _hashPassword(salt, password);

    return db.transaction((txn) async {
      final id = await txn.insert('users', {
        'name': name.trim(),
        'email': normalizedEmail,
        'password_hash': hash,
        'password_salt': salt,
      });
      // Data awal ini tersimpan di database, bukan dibuat ulang setiap build.
      await txn.insert('transactions', {
        'user_id': id,
        'title': 'Makan Siang',
        'amount': 50000,
        'type': 'expense',
        'category': 'Makanan',
        'transaction_date': '2026-09-13',
      });
      await txn.insert('transactions', {
        'user_id': id,
        'title': 'Gaji Bulanan',
        'amount': 5000000,
        'type': 'income',
        'category': 'Pemasukan',
        'transaction_date': '2026-09-01',
      });
      return {'id': id, 'name': name.trim(), 'email': normalizedEmail};
    });
  }

  Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
  }) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );
    if (rows.isEmpty) return null;

    final stored = rows.first;
    final salt = stored['password_salt'] as String;
    final expectedHash = stored['password_hash'] as String;
    if (_hashPassword(salt, password) != expectedHash) return null;

    return {
      'id': stored['id'] as int,
      'name': stored['name'] as String,
      'email': stored['email'] as String,
    };
  }

  Future<List<Map<String, dynamic>>> getTransactions(int userId) async {
    final db = await database;
    return db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'transaction_date DESC, id DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getRecentTransactions(int userId,
      {int limit = 3}) async {
    final db = await database;
    return db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'transaction_date DESC, id DESC',
      limit: limit,
    );
  }

  Future<int> getBalance(int userId) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT COALESCE(SUM(
        CASE WHEN type = 'income' THEN amount ELSE -amount END
      ), 0) AS balance
      FROM transactions WHERE user_id = ?
    ''', [userId]);
    return (rows.first['balance'] as num).toInt();
  }

  Future<void> addTransaction({
    required int userId,
    required String title,
    required int amount,
    required String type,
    required String category,
    required String dateIso,
  }) async {
    final db = await database;
    await db.insert('transactions', {
      'user_id': userId,
      'title': title.trim(),
      'amount': amount,
      'type': type,
      'category': category.trim().isEmpty ? 'Lainnya' : category.trim(),
      'transaction_date': dateIso,
    });
  }
}
