import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final databaseFactory = databaseFactoryFfi;
    final caminhoBanco = await databaseFactory.getDatabasesPath();
    final path = join(caminhoBanco, 'banco_pets.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS pets (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT,
            idade INTEGER
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS pets (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nome TEXT,
              idade INTEGER
            )
          ''');
        }
      },
    );
  }

  static Future<int> inserirPet(Map<String, dynamic> dados) async {
    final db = await database;
    return await db.insert('pets', dados);
  }

  static Future<List<Map<String, dynamic>>> listarPets() async {
    final db = await database;
    return await db.query('pets');
  }

  static Future<int> atualizarPet(int id, Map<String, dynamic> dados) async {
    final db = await database;
    return await db.update(
      'pets',
      dados,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> apagarPet(int id) async {
    final db = await database;
    return await db.delete(
      'pets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
