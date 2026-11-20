import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:southsea_cinema/database/cinema_db.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:southsea_cinema/models/booking_item.dart';
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

  group('CinemaDatabase booking items (version 2)', () {
    const Booking booking = Booking(
      bookingNumber: 1004,
      summary: "2 x Mr. Bean's Holiday, 1 x Truth or Dare",
      total: 26.50,
      date: '20/11/2026 18:00',
    );
    const List<BookingItem> items = [
      BookingItem(
        movieTitle: "Mr. Bean's Holiday",
        quantity: 2,
        ticketPrice: 8.50,
      ),
      BookingItem(movieTitle: 'Truth or Dare', quantity: 1, ticketPrice: 9.50),
    ];

    test('saves a booking and its items together', () async {
      await openEmptyDatabase();

      final int bookingId = await cinemaDb.insertBookingWithItems(
        booking,
        items,
      );

      final List<BookingItem> saved =
          await cinemaDb.getItemsForBooking(bookingId);
      expect(saved.length, 2);
      expect(saved[0].movieTitle, "Mr. Bean's Holiday");
      expect(saved[0].quantity, 2);
      expect(saved[1].movieTitle, 'Truth or Dare');

      final List<Booking> bookings = await cinemaDb.getAllBookings();
      expect(bookings.first.bookingNumber, 1004);
      expect(bookings.first.items.length, 2);
    });

    test('old bookings without items still load', () async {
      await openSeededDatabase();

      final List<Booking> bookings = await cinemaDb.getAllBookings();

      expect(bookings.length, 3);
      expect(bookings.first.items, isEmpty);
      expect(bookings.first.summary, "2 x Mr. Bean's Holiday");
    });

    test('foreign keys stop items for a booking that does not exist',
        () async {
      final Database db = await databaseFactoryFfiNoIsolate.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 2,
          onConfigure: cinemaDb.configureDatabase,
          onCreate: cinemaDb.createTables,
        ),
      );
      cinemaDb.setDatabase(db);

      await expectLater(
        db.insert('booking_items', {
          'booking_id': 999,
          'movie_title': 'Truth or Dare',
          'quantity': 1,
          'ticket_price': 9.50,
        }),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('upgrading from version 1 keeps the old bookings', () async {
      final String path = join(
        await databaseFactoryFfiNoIsolate.getDatabasesPath(),
        'upgrade_test.db',
      );
      await databaseFactoryFfiNoIsolate.deleteDatabase(path);

      // Make a version 1 database: only the bookings table.
      final Database oldDb = await databaseFactoryFfiNoIsolate.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (Database db, int version) async {
            await db.execute('''
              CREATE TABLE bookings (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                booking_number INTEGER NOT NULL,
                summary TEXT NOT NULL,
                total REAL NOT NULL,
                date TEXT NOT NULL
              )
            ''');
          },
        ),
      );
      await oldDb.insert(
        'bookings',
        const Booking(
          bookingNumber: 1001,
          summary: '1 x Truth or Dare',
          total: 9.50,
          date: '02/10/2026 23:30',
        ).toMap(),
      );
      await oldDb.close();

      // Open it again as version 2, which runs onUpgrade.
      final Database newDb = await databaseFactoryFfiNoIsolate.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 2,
          onConfigure: cinemaDb.configureDatabase,
          onCreate: cinemaDb.createTablesAndSeed,
          onUpgrade: cinemaDb.upgradeDatabase,
        ),
      );
      cinemaDb.setDatabase(newDb);

      final List<Booking> bookings = await cinemaDb.getAllBookings();
      expect(bookings.length, 1);
      expect(bookings.first.summary, '1 x Truth or Dare');
      expect(bookings.first.items, isEmpty);

      await cinemaDb.insertBookingWithItems(booking, items);
      final List<Booking> after = await cinemaDb.getAllBookings();
      expect(after.first.bookingNumber, 1004);
      expect(after.first.items.length, 2);

      await cinemaDb.close();
      await databaseFactoryFfiNoIsolate.deleteDatabase(path);
    });
  });
}
