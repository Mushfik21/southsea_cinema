import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/models/basket_item.dart';
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

  void _removeTicket(String movieId) {
    setState(() {
      _basket.removeTicket(movieId);
    });
  }

  void _checkout() {
    final int tickets = _basket.totalTickets;
    setState(() {
      _basket.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking confirmed: $tickets ticket(s). Enjoy the film!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Basket')),
      drawer: const NavDrawer(),
      body: _basket.items.isEmpty ? _buildEmptyState() : _buildBasket(),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'Your basket is empty',
        style: TextStyle(color: cinemaFontMuted),
      ),
    );
  }

  Widget _buildBasket() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final BasketItem item in _basket.items) _buildLineItem(item),
        const SizedBox(height: 8),
        const Divider(color: cinemaFontMuted),
        _buildTotalRow(),
        const SizedBox(height: 16),
        SquareButton(label: 'Checkout', onPressed: _checkout),
      ],
    );
  }

  Widget _buildLineItem(BasketItem item) {
    return Card(
      color: cinemaSurface,
      child: ListTile(
        title: Text(
          item.movie.title,
          style: const TextStyle(color: cinemaFontWhite),
        ),
        subtitle: Text(
          '${item.quantity} x ${item.movie.formattedPrice}',
          style: const TextStyle(color: cinemaFontMuted),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '£${item.lineTotal.toStringAsFixed(2)}',
              style: const TextStyle(color: cinemaFontWhite),
            ),
            IconButton(
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
          style: cinemaHeaderStyle,
        ),
        Text(_basket.formattedTotal, style: cinemaHeaderStyle),
      ],
    );
  }
}
