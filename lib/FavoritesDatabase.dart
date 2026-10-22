import 'package:sqflite/sqflite.dart';

import 'category_model.dart';
import 'product_model.dart';

/// sqflite storage for favourite products.
class FavoritesDatabase {
  FavoritesDatabase._();
  static final FavoritesDatabase instance = FavoritesDatabase._();

  static const _table = 'favorites';
  Database? _db;

  Future<Database> get _database async => _db ??= await _open();

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    return openDatabase(
      '$dir/favorites.db',
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE $_table (
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT,
          price REAL NOT NULL,
          stock INTEGER NOT NULL,
          image_url TEXT,
          category_id INTEGER,
          category_name TEXT,
          added_at INTEGER NOT NULL
        )
      '''),
    );
  }

  Future<List<ProductModel>> getAll() async {
    final db = await _database;
    final rows = await db.query(_table, orderBy: 'added_at DESC');
    return rows.map(_fromMap).toList();
  }

  Future<void> insert(ProductModel p) async {
    final db = await _database;
    await db.insert(
      _table,
      {
        'id': p.id,
        'name': p.name,
        'description': p.description,
        'price': p.price,
        'stock': p.stock,
        'image_url': p.imageUrl,
        'category_id': p.category?.id,
        'category_name': p.category?.name,
        'added_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> remove(int id) async {
    final db = await _database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  ProductModel _fromMap(Map<String, Object?> m) {
    final catName = m['category_name'] as String?;
    return ProductModel(
      id: m['id'] as int,
      name: m['name'] as String,
      description: m['description'] as String?,
      price: (m['price'] as num).toDouble(),
      stock: m['stock'] as int,
      imageUrl: m['image_url'] as String?,
      category: catName == null
          ? null
          : CategoryModel.fromJson({
        'id': m['category_id'],
        'name': catName,
      }),
    );
  }
}