import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/main.dart';
import 'package:southsea_cinema/widgets/movie_card.dart';

void main() {
  testWidgets('Home page shows title, movie cards and booking buttons',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SouthseaCinemaApp());

    expect(find.text(appTitle), findsOneWidget);
    expect(find.byType(MovieCard), findsWidgets);
    expect(find.text("Mr. Bean's Holiday"), findsOneWidget);
    expect(find.text('Book tickets'), findsWidgets);
  });

  testWidgets('Booking opens the right film and Add to order shows feedback',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SouthseaCinemaApp());

    await tester.tap(find.text('Book tickets').first);
    await tester.pumpAndSettle();

    expect(find.text("MR. BEAN'S HOLIDAY"), findsOneWidget);
    expect(find.text('Rated U'), findsOneWidget);
    expect(find.text('£8.50'), findsOneWidget);

    await tester.tap(find.text('Add to order'));
    await tester.pump();

    expect(find.text('1 ticket(s) added to your order'), findsOneWidget);
  });
}
