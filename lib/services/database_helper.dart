import 'package:ahorrify/models/transaction_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = "Ahorrify.db";
  static const _databaseVersion = 1;

  static const table = 'transactions';
  static const columnId = 'id';
  static const columnAmount = 'amount';
  static const columnTitle = 'title';
  static const columnType = 'type';
  static const columnCategory = 'category';
  static const columnDate = 'date';
  static const columnNote = 'note';

  // Singleton
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnAmount REAL NOT NULL,
        $columnTitle TEXT NOT NULL,
        $columnType TEXT NOT NULL,
        $columnCategory TEXT NOT NULL,
        $columnDate TEXT NOT NULL,
        $columnNote TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migración para agregar la columna note
      await db.execute('ALTER TABLE $table ADD COLUMN $columnNote TEXT');
    }
  }

  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.insert(table, transaction.toMap());
  }

  Future<List<TransactionModel>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      table,
      orderBy: '$columnDate DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<List<TransactionModel>> getTransactionsByDateRange(
      DateTime start, DateTime end) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      table,
      where: '$columnDate BETWEEN ? AND ?',
      whereArgs: [
        start.toIso8601String(),
        end.toIso8601String(),
      ],
      orderBy: '$columnDate DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.update(
      table,
      transaction.toMap(),
      where: '$columnId = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<List<String>> getCategoriesByType(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      table,
      where: '$columnType = ?',
      whereArgs: [type],
      distinct: true,
      columns: [columnCategory],
    );
    return maps.map((map) => map[columnCategory] as String).toList();
  }

  Future<void> clearAllTransactions() async {
    final db = await database;
    await db.delete(table);
  }

  Future<void> updateCategory(String oldName, String newName, String type) async {
    final db = await database;
    await db.update(
      table,
      {columnCategory: newName},
      where: '$columnCategory = ? AND $columnType = ?',
      whereArgs: [oldName, type],
    );
  }

  Future<void> insertCategory(String name, String type) async {
    // Las categorías se manejan implícitamente a través de las transacciones
    // No necesitamos una tabla separada para categorías
  }

  Future<void> deleteCategory(String name, String type) async {
    // No eliminamos las categorías ya que están vinculadas a transacciones
    // En su lugar, podríamos mostrar un mensaje al usuario
  }
}
