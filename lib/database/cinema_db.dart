import 'package:path/path.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:southsea_cinema/models/booking_item.dart';
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
    return openDatabase(
      path,
      version: 2,
      onConfigure: configureDatabase,
      onCreate: createTablesAndSeed,
      onUpgrade: upgradeDatabase,
    );
  }

  // Runs every time the database opens. SQLite ignores foreign keys
  // unless we switch them on.
  Future<void> configureDatabase(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // Version 1 only had the bookings table. Version 2 adds booking_items.
  // Old bookings are kept and still show their summary.
  Future<void> upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await createBookingItemsTable(db);
    }
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
    await createBookingItemsTable(db);
  }

  Future<void> createBookingItemsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS booking_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        booking_id INTEGER NOT NULL,
        movie_title TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        ticket_price REAL NOT NULL,
        FOREIGN KEY (booking_id) REFERENCES bookings (id) ON DELETE CASCADE
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

  // Saves the booking and all its items together. If any insert fails,
  // the transaction rolls back and nothing is saved.
  Future<int> insertBookingWithItems(
    Booking booking,
    List<BookingItem> items,
  ) async {
    final Database db = await database;
    return db.transaction((Transaction txn) async {
      final int bookingId = await txn.insert('bookings', booking.toMap());
      for (final BookingItem item in items) {
        final Map<String, Object?> row = item.toMap();
        row['booking_id'] = bookingId;
        await txn.insert('booking_items', row);
      }
      return bookingId;
    });
  }

  Future<List<BookingItem>> getItemsForBooking(int bookingId) async {
    final Database db = await database;
    final List<Map<String, Object?>> rows = await db.query(
      'booking_items',
      where: 'booking_id = ?',
      whereArgs: [bookingId],
      orderBy: 'id',
    );
    return rows.map(BookingItem.fromMap).toList();
  }

  Future<List<Booking>> getAllBookings() async {
    final Database db = await database;
    final List<Map<String, Object?>> rows = await db.query(
      'bookings',
      orderBy: 'booking_number DESC',
    );
    final List<Booking> bookings = [];
    for (final Map<String, Object?> row in rows) {
      final List<BookingItem> items = await getItemsForBooking(row['id'] as int);
      bookings.add(Booking.fromMap(row, items: items));
    }
    return bookings;
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
