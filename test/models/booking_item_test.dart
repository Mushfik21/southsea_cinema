import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/booking_item.dart';

void main() {
  group('BookingItem', () {
    const BookingItem item = BookingItem(
      bookingId: 4,
      movieTitle: "Mr. Bean's Holiday",
      quantity: 2,
      ticketPrice: 8.50,
    );

    test('lineTotal multiplies price by quantity', () {
      expect(item.lineTotal, 17.0);
    });

    test('formattedPrice shows pounds and pence', () {
      expect(item.formattedPrice, '£8.50');
    });

    test('toMap uses the database column names', () {
      final Map<String, Object?> map = item.toMap();

      expect(map['booking_id'], 4);
      expect(map['movie_title'], "Mr. Bean's Holiday");
      expect(map['quantity'], 2);
      expect(map['ticket_price'], 8.50);
      expect(map.containsKey('id'), false);
    });

    test('fromMap reads a database row', () {
      final BookingItem fromRow = BookingItem.fromMap({
        'id': 1,
        'booking_id': 4,
        'movie_title': 'Truth or Dare',
        'quantity': 3,
        'ticket_price': 9,
      });

      expect(fromRow.id, 1);
      expect(fromRow.bookingId, 4);
      expect(fromRow.movieTitle, 'Truth or Dare');
      expect(fromRow.quantity, 3);
      expect(fromRow.ticketPrice, 9.0);
    });
  });
}
