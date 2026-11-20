import 'package:path/path.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:sqflite/sqflite.dart';

class CinemaDatabase {
  CinemaDatabase._internal();

  static final CinemaDatabase instance = CinemaDatabase._internal();

  static Database? _database;

  static const List<Booking> _seedBookings = [
    Booking(
      bookingNumber: 1003,
      summary: "2 x Mr. Bean's Holiday",
      total: 17.00,
      date: '18/10/2026 18:00',
    ),
    Booking(
      bookingNumber: 1002,
      summary: '1 x Truth or Dare',
      total: 9.50,
      date: '02/10/2026 23:30',
    ),
    Booking(
      bookingNumber: 1001,
      summary: "3 x Mr. Bean's Holiday",
      total: 25.50,
      date: '20/09/2026 18:00',
    ),
  ];

  void setDatabase(Database? db) {
    _database = db;
  }

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDB('cinema_data.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, fileName);
    return openDatabase(path, version: 1, onCreate: createTablesAndSeed);
  }

  Future<void> createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        booking_number INTEGER NOT NULL,
        summary TEXT NOT NULL,
        total REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<void> createTablesAndSeed(Database db, int version) async {
    await createTables(db, version);
    for (final Booking booking in _seedBookings) {
      await db.insert('bookings', booking.toMap());
    }
  }

  Future<int> insertBooking(Booking booking) async {
    final Database db = await database;
    return db.insert('bookings', booking.toMap());
  }

  Future<List<Booking>> getAllBookings() async {
    final Database db = await database;
    final List<Map<String, Object?>> rows = await db.query(
      'bookings',
      orderBy: 'booking_number DESC',
    );
    return rows.map(Booking.fromMap).toList();
  }

  Future<int> getNextBookingNumber() async {
    final Database db = await database;
    final List<Map<String, Object?>> result = await db.rawQuery(
      'SELECT MAX(booking_number) as max_num FROM bookings',
    );
    final Object? maxNumber = result.first['max_num'];
    if (maxNumber == null) {
      return 1001;
    }
    return (maxNumber as int) + 1;
  }

  Future<void> close() async {
    final Database? db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
