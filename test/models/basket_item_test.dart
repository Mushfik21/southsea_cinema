import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/basket_item.dart';
import 'package:southsea_cinema/models/movie.dart';

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

  group('BasketItem', () {
    test('stores the film and quantity', () {
      const BasketItem item = BasketItem(movie: bean, quantity: 2);

      expect(item.movie.id, '1');
      expect(item.quantity, 2);
    });

    test('lineTotal is price times quantity', () {
      const BasketItem item = BasketItem(movie: bean, quantity: 3);

      expect(item.lineTotal, 25.50);
    });
  });
}
