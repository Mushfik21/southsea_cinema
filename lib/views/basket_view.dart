import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/database/cinema_db.dart';
import 'package:southsea_cinema/models/basket_item.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:southsea_cinema/models/booking_item.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';
import 'package:southsea_cinema/widgets/square_button.dart';

class BasketView extends StatefulWidget {
  const BasketView({super.key});

  @override
  State<BasketView> createState() => _BasketViewState();
}

class _BasketViewState extends State<BasketView> {
  final BasketRepository _basket = BasketRepository.instance;
  List<Booking> _pastBookings = [];
  bool _loadingBookings = true;
  String? _bookingsError;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      final List<Booking> bookings =
          await CinemaDatabase.instance.getAllBookings();
      if (!mounted) {
        return;
      }
      setState(() {
        _pastBookings = bookings;
        _bookingsError = null;
        _loadingBookings = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _bookingsError = 'Could not load past bookings: $error';
        _loadingBookings = false;
      });
    }
  }

  void _removeTicket(String movieId) {
    setState(() {
      _basket.removeTicket(movieId);
    });
  }

  String _buildSummary(List<BasketItem> items) {
    return items
        .map((item) => '${item.quantity} x ${item.movie.title}')
        .join(', ');
  }

  String _formatDate(DateTime now) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(now.day)}/${twoDigits(now.month)}/${now.year} '
        '${twoDigits(now.hour)}:${twoDigits(now.minute)}';
  }

  Future<void> _checkout() async {
    final List<BasketItem> items = _basket.items;
    final int tickets = _basket.totalTickets;
    try {
      final CinemaDatabase db = CinemaDatabase.instance;
      final int bookingNumber = await db.getNextBookingNumber();
      await db.insertBookingWithItems(
        Booking(
          bookingNumber: bookingNumber,
          summary: _buildSummary(items),
          total: _basket.total,
          date: _formatDate(DateTime.now()),
        ),
        [
          for (final BasketItem item in items)
            BookingItem(
              movieTitle: item.movie.title,
              quantity: item.quantity,
              ticketPrice: item.movie.ticketPrice,
            ),
        ],
      );
      _basket.clear();
      await _loadBookings();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Booking $bookingNumber confirmed: $tickets ticket(s). '
            'Enjoy the film!',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save your booking: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Basket')),
      drawer: const NavDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ..._buildBasketSection(),
          const SizedBox(height: 32),
          const Text('PAST BOOKINGS', style: cinemaSectionStyle),
          const Divider(color: cinemaFontMuted),
          ..._buildPastBookings(),
        ],
      ),
    );
  }

  List<Widget> _buildBasketSection() {
    if (_basket.items.isEmpty) {
      return [_buildEmptyState()];
    }
    return [
      for (final BasketItem item in _basket.items) _buildLineItem(item),
      const SizedBox(height: 8),
      const Divider(color: cinemaFontMuted),
      _buildTotalRow(),
      const SizedBox(height: 16),
      SquareButton(label: 'Checkout', onPressed: _checkout),
    ];
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          'Your basket is empty',
          style: TextStyle(color: cinemaFontMuted),
        ),
      ),
    );
  }

  Widget _buildLineItem(BasketItem item) {
    return Card(
      child: ListTile(
        title: Text(
          item.movie.title,
        ),
        subtitle: Text(
          '${item.quantity} x ${item.movie.formattedPrice}',
          style: const TextStyle(color: cinemaFontMuted),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('£${item.lineTotal.toStringAsFixed(2)}'),
            IconButton(
              key: Key('remove_${item.movie.id}'),
              tooltip: 'Remove one ticket',
              icon: const Icon(Icons.remove_circle_outline, color: cinemaBrand),
              onPressed: () => _removeTicket(item.movie.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total (${_basket.totalTickets} tickets)',
          style: cinemaSectionStyle,
        ),
        Text(_basket.formattedTotal, style: cinemaSectionStyle),
      ],
    );
  }

  List<Widget> _buildPastBookings() {
    if (_loadingBookings) {
      return [const Center(child: CircularProgressIndicator())];
    }
    if (_bookingsError != null) {
      return [
        Text(_bookingsError!, style: const TextStyle(color: cinemaFontMuted)),
      ];
    }
    if (_pastBookings.isEmpty) {
      return [
        const Text(
          'No past bookings yet',
          style: TextStyle(color: cinemaFontMuted),
        ),
      ];
    }
    return [
      for (final Booking booking in _pastBookings) _buildBookingCard(booking),
    ];
  }

  // New bookings list each film. Old bookings (saved before the
  // booking_items table existed) have no items, so show their summary.
  String _describeBooking(Booking booking) {
    if (booking.items.isEmpty) {
      return booking.summary;
    }
    return booking.items
        .map((item) =>
            '${item.quantity} x ${item.movieTitle} @ ${item.formattedPrice}')
        .join('\n');
  }

  Widget _buildBookingCard(Booking booking) {
    return Card(
      child: ListTile(
        title: Text(
          'Booking #${booking.bookingNumber}',
        ),
        subtitle: Text(
          '${_describeBooking(booking)}\n${booking.date}',
          style: const TextStyle(color: cinemaFontMuted),
        ),
        trailing: Text(
          booking.formattedTotal,
          style: const TextStyle(color: cinemaBrand),
        ),
      ),
    );
  }
}
