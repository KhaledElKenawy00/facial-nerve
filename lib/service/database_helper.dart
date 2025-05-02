import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('sensor_data.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
    CREATE TABLE sensor_data (
      id $idType,
      value REAL ,
      state $textType,
      date $textType,
      time $textType
    )
    ''');
  }

  Future<int> getTotalRecords() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM sensor_data');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Map<String, dynamic>>> getSensorDataPaged(
    int page,
    int pageSize,
  ) async {
    final db = await instance.database;
    final offset = (page - 1) * pageSize;

    return await db.query(
      'sensor_data',
      orderBy: 'date DESC, time DESC',
      limit: pageSize,
      offset: offset,
    );
  }

  Future<void> insertSensorData(Map<String, dynamic> data) async {
    final db = await instance.database;

    await db.insert(
      'sensor_data',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
