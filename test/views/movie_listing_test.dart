import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/views/movie_listing.dart';

void main() {
  const Movie dare = Movie(
    id: '2',
    title: 'Truth or Dare',
    synopsis: 'S',
    ageRating: '15',
    runtime: 100,
    screeningTime: '23:30',
    ticketPrice: 9.50,
    posterPath: 'p',
  );

  setUp(() {
    BasketRepository.instance.clear();
  });

  Future<void> pumpListing(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: MovieListing(movie: dare)));
  }

  group('MovieListing', () {
    testWidgets('shows the film details', (WidgetTester tester) async {
      await pumpListing(tester);

      expect(find.text('TRUTH OR DARE'), findsOneWidget);
      expect(find.text('100 mins'), findsOneWidget);
      expect(find.text('Rated 15'), findsOneWidget);
      expect(find.text('£9.50'), findsOneWidget);
    });

    testWidgets('choosing 3 tickets adds 3 to the basket',
        (WidgetTester tester) async {
      await pumpListing(tester);

      await tester.tap(find.byType(DropdownMenu<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('3').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add to order'));
      await tester.pump();

      expect(find.text('3 ticket(s) added to your order'), findsOneWidget);
      expect(BasketRepository.instance.totalTickets, 3);
    });
  });
}
