import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/booking.dart';

void main() {
  group('Booking', () {
    test('stores the values it is given', () {
      const Booking booking = Booking(
        id: 5,
        bookingNumber: 1004,
        summary: "2 x Mr. Bean's Holiday",
        total: 17.0,
        date: '19/11/2026 21:30',
      );

      expect(booking.id, 5);
      expect(booking.bookingNumber, 1004);
      expect(booking.summary, "2 x Mr. Bean's Holiday");
      expect(booking.total, 17.0);
      expect(booking.date, '19/11/2026 21:30');
    });

    test('id is optional before the booking is saved', () {
      const Booking booking = Booking(
        bookingNumber: 1001,
        summary: '1 x Truth or Dare',
        total: 9.5,
        date: '01/01/2026 10:00',
      );

      expect(booking.id, isNull);
    });

    test('toMap uses the database column names and leaves out a null id', () {
      const Booking booking = Booking(
        bookingNumber: 1001,
        summary: '1 x Truth or Dare',
        total: 9.5,
        date: '01/01/2026 10:00',
      );

      expect(booking.toMap(), {
        'booking_number': 1001,
        'summary': '1 x Truth or Dare',
        'total': 9.5,
        'date': '01/01/2026 10:00',
      });
    });

    test('toMap includes the id when it has one', () {
      const Booking booking = Booking(
        id: 3,
        bookingNumber: 1003,
        summary: 'S',
        total: 1.0,
        date: 'D',
      );

      expect(booking.toMap()['id'], 3);
    });

    test('fromMap reads every column', () {
      final Booking booking = Booking.fromMap({
        'id': 7,
        'booking_number': 1007,
        'summary': '3 x Truth or Dare',
        'total': 28.5,
        'date': '20/11/2026 18:00',
      });

      expect(booking.id, 7);
      expect(booking.bookingNumber, 1007);
      expect(booking.summary, '3 x Truth or Dare');
      expect(booking.total, 28.5);
      expect(booking.date, '20/11/2026 18:00');
    });

    test('fromMap turns a whole-number total into a double', () {
      final Booking booking = Booking.fromMap({
        'id': 1,
        'booking_number': 1001,
        'summary': 'S',
        'total': 17,
        'date': 'D',
      });

      expect(booking.total, 17.0);
    });

    test('a booking survives a round trip through toMap and fromMap', () {
      const Booking original = Booking(
        id: 2,
        bookingNumber: 1002,
        summary: '1 x Truth or Dare',
        total: 9.5,
        date: '02/03/2026 18:10',
      );

      final Booking copy = Booking.fromMap(original.toMap());

      expect(copy.id, original.id);
      expect(copy.bookingNumber, original.bookingNumber);
      expect(copy.summary, original.summary);
      expect(copy.total, original.total);
      expect(copy.date, original.date);
    });

    test('formattedTotal shows pounds and pence', () {
      const Booking booking = Booking(
        bookingNumber: 1001,
        summary: 'S',
        total: 17,
        date: 'D',
      );

      expect(booking.formattedTotal, '£17.00');
    });
  
    test('a booking has no items unless they are given', () {
      const Booking booking = Booking(
        bookingNumber: 1001,
        summary: '1 x Truth or Dare',
        total: 9.50,
        date: '02/10/2026 23:30',
      );

      expect(booking.items, isEmpty);
    });
});
}
