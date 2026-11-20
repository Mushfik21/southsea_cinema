import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:southsea_cinema/database/cinema_db.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  final CinemaDatabase cinemaDb = CinemaDatabase.instance;

  setUpAll(() {
    sqfliteFfiInit();
  });

  Future<void> openEmptyDatabase() async {
    final Database db = await databaseFactoryFfiNoIsolate.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: cinemaDb.createTables,
      ),
    );
    cinemaDb.setDatabase(db);
  }

  Future<void> openSeededDatabase() async {
    final Database db = await databaseFactoryFfiNoIsolate.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: cinemaDb.createTablesAndSeed,
      ),
    );
    cinemaDb.setDatabase(db);
  }

  tearDown(() async {
    await cinemaDb.close();
  });

  group('CinemaDatabase', () {
    test('a new database has no bookings', () async {
      await openEmptyDatabase();

      expect(await cinemaDb.getAllBookings(), isEmpty);
    });

    test('first booking number is 1001 when there are no bookings', () async {
      await openEmptyDatabase();

      expect(await cinemaDb.getNextBookingNumber(), 1001);
    });

    test('insertBooking saves a booking that can be read back', () async {
      await openEmptyDatabase();

      final int id = await cinemaDb.insertBooking(
        const Booking(
          bookingNumber: 1001,
          summary: '2 x Truth or Dare',
          total: 19.0,
          date: '19/11/2026 23:30',
        ),
      );
      final List<Booking> bookings = await cinemaDb.getAllBookings();

      expect(id, greaterThan(0));
      expect(bookings.length, 1);
      expect(bookings.first.id, id);
      expect(bookings.first.summary, '2 x Truth or Dare');
      expect(bookings.first.total, 19.0);
    });

    test('getAllBookings returns the highest booking number first', () async {
      await openEmptyDatabase();
      await cinemaDb.insertBooking(
        const Booking(bookingNumber: 1001, summary: 'A', total: 1, date: 'D'),
      );
      await cinemaDb.insertBooking(
        const Booking(bookingNumber: 1003, summary: 'C', total: 3, date: 'D'),
      );
      await cinemaDb.insertBooking(
        const Booking(bookingNumber: 1002, summary: 'B', total: 2, date: 'D'),
      );

      final List<Booking> bookings = await cinemaDb.getAllBookings();

      expect(
        bookings.map((booking) => booking.bookingNumber).toList(),
        [1003, 1002, 1001],
      );
    });

    test('next booking number is one more than the highest', () async {
      await openEmptyDatabase();
      await cinemaDb.insertBooking(
        const Booking(bookingNumber: 1007, summary: 'A', total: 1, date: 'D'),
      );

      expect(await cinemaDb.getNextBookingNumber(), 1008);
    });

    test('a newly created database is seeded with sample bookings', () async {
      await openSeededDatabase();

      final List<Booking> bookings = await cinemaDb.getAllBookings();

      expect(bookings.length, 3);
      expect(bookings.first.bookingNumber, 1003);
      expect(await cinemaDb.getNextBookingNumber(), 1004);
    });

    test('close lets a new database be supplied', () async {
      await openSeededDatabase();
      await cinemaDb.close();
      await openEmptyDatabase();

      expect(await cinemaDb.getAllBookings(), isEmpty);
    });
  });

  group('CinemaDatabase on a real file', () {
    test('opens the database file and seeds three bookings', () async {
      // Use the desktop SQLite engine instead of the Android one.
      databaseFactory = databaseFactoryFfiNoIsolate;
      final String path =
          join(await databaseFactory.getDatabasesPath(), 'cinema_data.db');
      await databaseFactory.deleteDatabase(path);
      cinemaDb.setDatabase(null);

      final List<Booking> bookings = await cinemaDb.getAllBookings();

      expect(bookings.length, 3);
      expect(bookings.first.bookingNumber, 1003);
      expect(await cinemaDb.getNextBookingNumber(), 1004);

      await cinemaDb.close();
      await databaseFactory.deleteDatabase(path);
    });
  });
}
