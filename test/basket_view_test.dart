import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/views/basket_view.dart';

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

  setUp(() {
    basket.clear();
  });

  Future<void> pumpBasket(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: BasketView()));
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

    testWidgets('checkout empties the basket and confirms',
        (WidgetTester tester) async {
      basket.addTickets(bean, 1);
      await pumpBasket(tester);

      await tester.tap(find.text('Checkout'));
      await tester.pump();

      expect(basket.items, isEmpty);
      expect(find.text('Your basket is empty'), findsOneWidget);
      expect(
        find.text('Booking confirmed: 1 ticket(s). Enjoy the film!'),
        findsOneWidget,
      );
    });
  });
}
