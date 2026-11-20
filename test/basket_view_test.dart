import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/database/cinema_db.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/views/basket_view.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  const Movie bean = Movie(
    id: '1',
    title: "Mr. Bean's Holiday",
    synopsis: 'S',
    ageRating: 'U',
    runtime: 90,
    screeningTime: '18:00',
    ticketPrice: 8.50,
    posterPath: 'p',
  );

  final BasketRepository basket = BasketRepository.instance;

  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() async {
    basket.clear();
    final Database db = await databaseFactoryFfiNoIsolate.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: CinemaDatabase.instance.createTables,
      ),
    );
    CinemaDatabase.instance.setDatabase(db);
  });

  tearDown(() async {
    await CinemaDatabase.instance.close();
  });

  Future<void> pumpBasket(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: BasketView()));
    await tester.pumpAndSettle();
  }

  group('BasketView', () {
    testWidgets('shows a message when the basket is empty',
        (WidgetTester tester) async {
      await pumpBasket(tester);

      expect(find.text('Your basket is empty'), findsOneWidget);
    });

    testWidgets('shows tickets and the total', (WidgetTester tester) async {
      basket.addTickets(bean, 2);
      await pumpBasket(tester);

      expect(find.text("Mr. Bean's Holiday"), findsOneWidget);
      expect(find.text('2 x £8.50'), findsOneWidget);
      expect(find.text('Total (2 tickets)'), findsOneWidget);
      expect(find.text('£17.00'), findsWidgets);
    });

    testWidgets('remove button takes away one ticket',
        (WidgetTester tester) async {
      basket.addTickets(bean, 2);
      await pumpBasket(tester);

      await tester.tap(find.byTooltip('Remove one ticket'));
      await tester.pump();

      expect(find.text('1 x £8.50'), findsOneWidget);
      expect(basket.totalTickets, 1);
    });
  });

  group('BasketView checkout and past bookings', () {
    testWidgets('says when there are no past bookings',
        (WidgetTester tester) async {
      await pumpBasket(tester);

      expect(find.text('PAST BOOKINGS'), findsOneWidget);
      expect(find.text('No past bookings yet'), findsOneWidget);
    });

    testWidgets('lists past bookings from the database',
        (WidgetTester tester) async {
      await CinemaDatabase.instance.insertBooking(
        const Booking(
          bookingNumber: 1001,
          summary: '1 x Truth or Dare',
          total: 9.50,
          date: '02/10/2026 23:30',
        ),
      );

      await pumpBasket(tester);

      expect(find.text('Booking #1001'), findsOneWidget);
      expect(find.text('£9.50'), findsOneWidget);
    });

    testWidgets('checkout saves a numbered booking and empties the basket',
        (WidgetTester tester) async {
      basket.addTickets(bean, 2);
      await pumpBasket(tester);

      await tester.tap(find.text('Checkout'));
      await tester.pumpAndSettle();

      expect(basket.items, isEmpty);
      expect(find.text('Your basket is empty'), findsOneWidget);
      expect(
        find.text('Booking 1001 confirmed: 2 ticket(s). Enjoy the film!'),
        findsOneWidget,
      );
      expect(find.text('Booking #1001'), findsOneWidget);

      final List<Booking> saved =
          await CinemaDatabase.instance.getAllBookings();
      expect(saved.length, 1);
      expect(saved.first.summary, "2 x Mr. Bean's Holiday");
      expect(saved.first.total, 17.0);
    });
  });
}
