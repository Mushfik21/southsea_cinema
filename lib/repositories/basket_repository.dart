import 'package:southsea_cinema/models/basket_item.dart';
import 'package:southsea_cinema/models/movie.dart';

class BasketRepository {
  BasketRepository._internal();

  static final BasketRepository instance = BasketRepository._internal();

  final List<BasketItem> _items = [];

  List<BasketItem> get items => List.unmodifiable(_items);

  void addTickets(Movie movie, int quantity) {
    if (quantity <= 0) {
      return;
    }
    final int index = _items.indexWhere((item) => item.movie.id == movie.id);
    if (index == -1) {
      _items.add(BasketItem(movie: movie, quantity: quantity));
    } else {
      final BasketItem existing = _items[index];
      _items[index] = BasketItem(
        movie: movie,
        quantity: existing.quantity + quantity,
      );
    }
  }

  void removeTicket(String movieId) {
    final int index = _items.indexWhere((item) => item.movie.id == movieId);
    if (index == -1) {
      return;
    }
    final BasketItem existing = _items[index];
    if (existing.quantity <= 1) {
      _items.removeAt(index);
    } else {
      _items[index] = BasketItem(
        movie: existing.movie,
        quantity: existing.quantity - 1,
      );
    }
  }

  void clear() {
    _items.clear();
  }

  int get totalTickets {
    int count = 0;
    for (final BasketItem item in _items) {
      count += item.quantity;
    }
    return count;
  }

  double get total {
    double sum = 0;
    for (final BasketItem item in _items) {
      sum += item.lineTotal;
    }
    return sum;
  }

  String get formattedTotal => '£${total.toStringAsFixed(2)}';
}
