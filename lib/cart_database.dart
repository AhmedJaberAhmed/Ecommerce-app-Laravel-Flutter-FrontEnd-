import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'cart_item.dart';

class CartDatabase {
  CartDatabase._();
  static final CartDatabase instance = CartDatabase._();

  static const _table = 'cart_items';
  Database? _db;

  Future<Database> get _database async {
    if (_db != null) return _db!;
    // New file name so it doesn't clash with the earlier schema.
    final path = p.join(await getDatabasesPath(), 'cart_v2.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE $_table (
          product_id   INTEGER PRIMARY KEY,
          qty          INTEGER NOT NULL,
          product_json TEXT    NOT NULL
        )
      '''),
    );
    return _db!;
  }

  Future<List<CartItem>> getItems() async {
    final db = await _database;
    final rows = await db.query(_table);
    return rows.map(CartItem.fromMap).toList();
  }

  Future<void> upsert(CartItem item) async {
    final db = await _database;
    await db.insert(_table, item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> delete(int productId) async {
    final db = await _database;
    await db.delete(_table, where: 'product_id = ?', whereArgs: [productId]);
  }

  Future<void> clear() async {
    final db = await _database;
    await db.delete(_table);
  }
}