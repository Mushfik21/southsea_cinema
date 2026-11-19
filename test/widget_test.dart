import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/main.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/widgets/movie_card.dart';

void main() {
  setUp(() {
    BasketRepository.instance.clear();
    rootBundle.clear();
  });

  testWidgets('Home page shows title, movie cards and booking buttons',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SouthseaCinemaApp());
    await tester.pumpAndSettle();

    expect(find.text(appTitle), findsOneWidget);
    expect(find.byType(MovieCard), findsWidgets);
    expect(find.text("Mr. Bean's Holiday"), findsOneWidget);
    expect(find.text('Book tickets'), findsWidgets);
  });

  testWidgets('Booking opens the right film and Add to order shows feedback',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SouthseaCinemaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Book tickets').first);
    await tester.pumpAndSettle();

    expect(find.text("MR. BEAN'S HOLIDAY"), findsOneWidget);
    expect(find.text('Rated U'), findsOneWidget);
    expect(find.text('£8.50'), findsOneWidget);

    await tester.tap(find.text('Add to order'));
    await tester.pump();

    expect(find.text('1 ticket(s) added to your order'), findsOneWidget);
    expect(BasketRepository.instance.totalTickets, 1);
  });

  testWidgets('Home page shows both films from the JSON file',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SouthseaCinemaApp());
    await tester.pumpAndSettle();

    expect(find.text("Mr. Bean's Holiday"), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Truth or Dare'), 300);

    expect(find.text('Truth or Dare'), findsOneWidget);
  });

  testWidgets('Full booking flow: add, remove one, then checkout',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SouthseaCinemaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Book tickets').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add to order'));
    await tester.pump();
    await tester.tap(find.text('Add to order'));
    await tester.pump();

    await tester.tap(find.text('View basket'));
    await tester.pumpAndSettle();

    expect(find.text("Mr. Bean's Holiday"), findsOneWidget);
    expect(find.text('2 x £8.50'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove one ticket'));
    await tester.pump();

    expect(find.text('1 x £8.50'), findsOneWidget);

    await tester.tap(find.text('Checkout'));
    await tester.pump();

    expect(find.text('Your basket is empty'), findsOneWidget);
    expect(BasketRepository.instance.items, isEmpty);
  });
}
