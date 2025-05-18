import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/transaction_model.dart';
import '../services/database_helper.dart';

class TransactionProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  TransactionProvider() {
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await _dbHelper.getTransactions();
    } catch (e) {
      debugPrint('Error al cargar transacciones: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTransactions() async {
    await _loadTransactions();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      final id = await _dbHelper.insertTransaction(transaction);
      final newTx = transaction.copyWith(id: id);
      _transactions.add(newTx);
      notifyListeners();
    } catch (e) {
      debugPrint('Error al agregar transacción: $e');
      rethrow;
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await _dbHelper.updateTransaction(transaction);
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error al actualizar transacción: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _dbHelper.deleteTransaction(id);
      _transactions.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error al eliminar transacción: $e');
      rethrow;
    }
  }

  Future<List<TransactionModel>> getTransactionsByDateRange(
      DateTime start, DateTime end) async {
    try {
      return await _dbHelper.getTransactionsByDateRange(start, end);
    } catch (e) {
      debugPrint('Error al obtener por rango de fechas: $e');
      return [];
    }
  }

  // ------------------------------
  // Métodos de respaldo/restauración
  // ------------------------------

  Future<String> createBackup() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/backup.json';
      final file = File(path);

      final data = _transactions.map((tx) => tx.toMap()).toList();
      await file.writeAsString(jsonEncode(data));

      return path;
    } catch (e) {
      debugPrint('Error al crear respaldo: $e');
      rethrow;
    }
  }

  Future<void> restoreFromBackup() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/backup.json';
      final file = File(path);

      if (!await file.exists()) {
        throw Exception('El archivo de respaldo no existe');
      }

      final content = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(content);

      final restoredTransactions = jsonList
          .map((json) => TransactionModel.fromMap(json as Map<String, dynamic>))
          .toList();

      await _dbHelper.clearAllTransactions();
      for (var tx in restoredTransactions) {
        await _dbHelper.insertTransaction(tx);
      }

      _transactions = restoredTransactions;
      notifyListeners();
    } catch (e) {
      debugPrint('Error al restaurar respaldo: $e');
      rethrow;
    }
  }
}
