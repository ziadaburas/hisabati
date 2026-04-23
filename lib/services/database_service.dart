import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import '../models/entry_model.dart';

class DatabaseService {
  static Database? _database;
  static const String _tableName = 'entries';

  static void initForWeb() {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ownaccounts.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            amount REAL NOT NULL,
            isCredit INTEGER NOT NULL,
            date TEXT NOT NULL,
            note TEXT DEFAULT '',
            customerName TEXT DEFAULT '',
            createdAt TEXT NOT NULL,
            syncStatus INTEGER DEFAULT 1,
            userId TEXT NOT NULL
          )
        ''');
        await db.execute(
            'CREATE INDEX idx_userId ON $_tableName (userId)');
        await db.execute(
            'CREATE INDEX idx_syncStatus ON $_tableName (syncStatus)');
      },
    );
  }

  // Insert entry
  Future<void> insertEntry(String userId, EntryModel entry) async {
    final db = await database;
    await db.insert(
      _tableName,
      {...entry.toMap(), 'userId': userId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all entries for user
  Future<List<EntryModel>> getEntries(String userId) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'userId = ? AND syncStatus != ?',
      whereArgs: [userId, 2],
      orderBy: 'date DESC',
    );
    return maps.map((m) => EntryModel.fromMap(m)).toList();
  }

  // Update entry
  Future<void> updateEntry(String userId, EntryModel entry) async {
    final db = await database;
    await db.update(
      _tableName,
      {...entry.toMap(), 'userId': userId},
      where: 'id = ? AND userId = ?',
      whereArgs: [entry.id, userId],
    );
  }

  // Soft delete (mark as deleted for sync)
  Future<void> softDeleteEntry(String userId, String entryId) async {
    final db = await database;
    await db.update(
      _tableName,
      {'syncStatus': 2},
      where: 'id = ? AND userId = ?',
      whereArgs: [entryId, userId],
    );
  }

  // Hard delete
  Future<void> hardDeleteEntry(String userId, String entryId) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'id = ? AND userId = ?',
      whereArgs: [entryId, userId],
    );
  }

  // Get pending entries (not synced)
  Future<List<EntryModel>> getPendingEntries(String userId) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'userId = ? AND syncStatus = ?',
      whereArgs: [userId, 1],
    );
    return maps.map((m) => EntryModel.fromMap(m)).toList();
  }

  // Get deleted entries (pending deletion from cloud)
  Future<List<EntryModel>> getDeletedEntries(String userId) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'userId = ? AND syncStatus = ?',
      whereArgs: [userId, 2],
    );
    return maps.map((m) => EntryModel.fromMap(m)).toList();
  }

  // Mark entry as synced
  Future<void> markAsSynced(String userId, String entryId) async {
    final db = await database;
    await db.update(
      _tableName,
      {'syncStatus': 0},
      where: 'id = ? AND userId = ?',
      whereArgs: [entryId, userId],
    );
  }

  // Replace all entries (after full sync from cloud)
  Future<void> replaceAllEntries(
      String userId, List<EntryModel> entries) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        _tableName,
        where: 'userId = ? AND syncStatus = ?',
        whereArgs: [userId, 0],
      );
      for (final entry in entries) {
        await txn.insert(
          _tableName,
          {...entry.copyWith(syncStatus: 0).toMap(), 'userId': userId},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  // Count pending changes
  Future<int> countPendingChanges(String userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName WHERE userId = ? AND syncStatus != 0',
      [userId],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  // Clear user data
  Future<void> clearUserData(String userId) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }
}
