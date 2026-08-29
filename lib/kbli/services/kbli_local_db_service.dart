import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:archive/archive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Dalem/kbli/models/kbli_item.dart';
import 'package:Dalem/kbli/models/kbli_submission.dart';

class KbliLocalDbService {
  static Database? _database;
  static const String _dbFileName = 'kbli_offline.db';
  static const String _prefVersionKey = 'kbli_offline_db_version';
  static const String _prefSyncDateKey = 'kbli_offline_db_sync_date';

  /// Returns the singleton database instance.
  static Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  /// Path to the local SQLite database file.
  static Future<String> get _databasePath async {
    final docsDir = await getApplicationDocumentsDirectory();
    return p.join(docsDir.path, _dbFileName);
  }

  /// Initialize SQLite database and check asset / local copy.
  static Future<Database> _initDatabase() async {
    final path = await _databasePath;
    final file = File(path);

    // If file doesn't exist, try loading from assets bundle if available
    if (!await file.exists()) {
      try {
        final byteData =
            await rootBundle.load('assets/database/kbli_offline.db');
        final bytes = byteData.buffer
            .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
        await file.writeAsBytes(bytes, flush: true);
      } catch (_) {
        // Asset not packaged yet, create empty container schema
      }
    }

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createLocalTables(db);
      },
      onOpen: (db) async {
        await _createLocalTables(db);
      },
    );

    return db;
  }

  /// Ensure local management tables exist (submissions queue, etc.).
  static Future<void> _createLocalTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS local_submissions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        kode TEXT NOT NULL,
        content TEXT NOT NULL,
        submitter_name TEXT,
        device_id TEXT,
        local_created_at TEXT NOT NULL,
        status TEXT DEFAULT 'pending',
        is_synced INTEGER DEFAULT 0
      )
    ''');
  }

  /// Checks if the master KBLI tables and FTS virtual tables exist.
  static Future<bool> isDatabaseReady() async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('kbli2025', 'kbli_fts')",
      );
      return result.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Returns metadata info about local offline database version.
  static Future<Map<String, dynamic>> getLocalDbInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final version = prefs.getString(_prefVersionKey) ?? 'Belum ada data';
    final syncDate = prefs.getString(_prefSyncDateKey) ?? '-';

    int kbliCount = 0;
    int kbjiCount = 0;

    try {
      final db = await database;
      final kbliRes = await db.rawQuery(
        "SELECT COUNT(*) as count FROM sqlite_master WHERE type='table' AND name='kbli2025'",
      );
      if (kbliRes.isNotEmpty && (kbliRes.first['count'] as int? ?? 0) > 0) {
        final c = await db.rawQuery('SELECT COUNT(*) as total FROM kbli2025');
        kbliCount = (c.first['total'] as int?) ?? 0;
      }

      final kbjiRes = await db.rawQuery(
        "SELECT COUNT(*) as count FROM sqlite_master WHERE type='table' AND name='kbji2014'",
      );
      if (kbjiRes.isNotEmpty && (kbjiRes.first['count'] as int? ?? 0) > 0) {
        final c = await db.rawQuery('SELECT COUNT(*) as total FROM kbji2014');
        kbjiCount = (c.first['total'] as int?) ?? 0;
      }
    } catch (_) {}

    return {
      'version': version,
      'sync_date': syncDate,
      'kbli_count': kbliCount,
      'kbji_count': kbjiCount,
      'is_ready': kbliCount > 0,
    };
  }

  /// Perform offline full-text search using SQLite FTS5 index.
  static Future<List<KbliItem>> searchFts(
    String query, {
    String? type,
    int limit = 20,
  }) async {
    final cleanQuery = query.replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), ' ').trim();
    if (cleanQuery.isEmpty) return [];

    final isReady = await isDatabaseReady();
    if (!isReady) return [];

    final db = await database;
    final terms = cleanQuery
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .map((t) => '$t*')
        .join(' ');

    if (terms.isEmpty) return [];

    final results = <KbliItem>[];

    // 1. Search KBLI 2025 if type is null or 'KBLI'
    if (type == null || type == 'KBLI' || type == 'ALL') {
      try {
        final rows = await db.rawQuery('''
          SELECT k.kode, k.judul, k.deskripsi, k.contoh_lapangan, 'KBLI 2025' as type,
                 bm25(kbli_fts) as rank
          FROM kbli_fts f
          JOIN kbli2025 k ON f.rowid = k.id
          WHERE kbli_fts MATCH ?
          ORDER BY rank ASC
          LIMIT ?
        ''', [terms, limit]);

        for (var row in rows) {
          results.add(KbliItem.fromSqlite(row));
        }
      } catch (e) {
        debugPrint('KBLI FTS query error: $e');
      }
    }

    // 2. Search KBJI 2014 if type is null or 'KBJI'
    if (type == null || type == 'KBJI' || type == 'ALL') {
      try {
        final rows = await db.rawQuery('''
          SELECT k.kode, k.judul, k.deskripsi, k.contoh_lapangan, 'KBJI 2014' as type,
                 bm25(kbji_fts) as rank
          FROM kbji_fts f
          JOIN kbji2014 k ON f.rowid = k.id
          WHERE kbji_fts MATCH ?
          ORDER BY rank ASC
          LIMIT ?
        ''', [terms, limit]);

        for (var row in rows) {
          results.add(KbliItem.fromSqlite(row));
        }
      } catch (e) {
        debugPrint('KBJI FTS query error: $e');
      }
    }

    return results;
  }

  /// Replace current SQLite DB with newly downloaded bundle.
  static Future<bool> installBundle({
    required String downloadedFilePath,
    required String version,
  }) async {
    try {
      // Close open database first
      if (_database != null && _database!.isOpen) {
        await _database!.close();
        _database = null;
      }

      final downloadedFile = File(downloadedFilePath);
      final destPath = await _databasePath;
      final destFile = File(destPath);

      // Check if file is gzipped (.db.gz) or plain sqlite
      final bytes = await downloadedFile.readAsBytes();
      Uint8List dbBytes;

      if (bytes.length > 2 && bytes[0] == 0x1f && bytes[1] == 0x8b) {
        // GZip compressed
        final decompressed = GZipDecoder().decodeBytes(bytes);
        dbBytes = Uint8List.fromList(decompressed);
      } else {
        dbBytes = bytes;
      }

      await destFile.writeAsBytes(dbBytes, flush: true);

      // Clean up temp downloaded file
      if (await downloadedFile.exists()) {
        await downloadedFile.delete();
      }

      // Re-open and create local management tables
      final db = await database;
      await _createLocalTables(db);

      // Save version metadata
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefVersionKey, version);
      await prefs.setString(_prefSyncDateKey, DateTime.now().toIso8601String());

      return true;
    } catch (e) {
      debugPrint('Error installing KBLI bundle: $e');
      return false;
    }
  }

  // ==========================================
  // OFFLINE SUBMISSIONS QUEUE
  // ==========================================

  /// Save submission draft locally in offline queue.
  static Future<int> saveLocalSubmission(KbliSubmission submission) async {
    final db = await database;
    return await db.insert(
      'local_submissions',
      submission.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieve pending submissions waiting to be synced online.
  static Future<List<KbliSubmission>> getPendingSubmissions() async {
    final db = await database;
    final rows = await db.query(
      'local_submissions',
      where: 'is_synced = 0',
      orderBy: 'id ASC',
    );
    return rows.map((r) => KbliSubmission.fromJson(r)).toList();
  }

  /// Get all local submissions for history viewing.
  static Future<List<KbliSubmission>> getAllLocalSubmissions() async {
    final db = await database;
    final rows = await db.query(
      'local_submissions',
      orderBy: 'id DESC',
    );
    return rows.map((r) => KbliSubmission.fromJson(r)).toList();
  }

  /// Mark submissions as synced.
  static Future<void> markSubmissionsSynced(List<int> ids) async {
    if (ids.isEmpty) return;
    final db = await database;
    final idList = ids.join(',');
    await db.rawUpdate(
      "UPDATE local_submissions SET is_synced = 1, status = 'synced' WHERE id IN ($idList)",
    );
  }
}
