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
}
