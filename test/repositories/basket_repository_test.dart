import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/basket_item.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';

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

  final BasketRepository basket = BasketRepository.instance;

  setUp(() {
    basket.clear();
  });

  group('BasketRepository', () {
    test('starts empty', () {
      expect(basket.items, isEmpty);
      expect(basket.totalTickets, 0);
      expect(basket.total, 0);
    });

    test('addTickets adds a film with its quantity', () {
      basket.addTickets(bean, 2);

      expect(basket.items.length, 1);
      expect(basket.items.first.movie.id, '1');
      expect(basket.items.first.quantity, 2);
    });

    test('adding the same film again increases its quantity', () {
      basket.addTickets(bean, 2);
      basket.addTickets(bean, 1);

      expect(basket.items.length, 1);
      expect(basket.items.first.quantity, 3);
    });

    test('addTickets ignores zero or negative quantities', () {
      basket.addTickets(bean, 0);

      expect(basket.items, isEmpty);
    });

    test('removeTicket takes away one ticket', () {
      basket.addTickets(bean, 2);
      basket.removeTicket('1');

      expect(basket.items.first.quantity, 1);
    });

    test('removeTicket removes the film when its last ticket goes', () {
      basket.addTickets(bean, 1);
      basket.removeTicket('1');

      expect(basket.items, isEmpty);
    });

    test('clear empties the basket', () {
      basket.addTickets(bean, 2);
      basket.addTickets(dare, 1);
      basket.clear();

      expect(basket.items, isEmpty);
    });

    test('totals add up across films', () {
      basket.addTickets(bean, 2);
      basket.addTickets(dare, 1);

      expect(basket.totalTickets, 3);
      expect(basket.total, 26.50);
      expect(basket.formattedTotal, '£26.50');
    });

    test('items cannot be changed from outside', () {
      basket.addTickets(bean, 1);

      expect(
        () => basket.items.add(const BasketItem(movie: dare, quantity: 1)),
        throwsUnsupportedError,
      );
    });
  });
}
