class BookingItem {
  final int? id;
  final int? bookingId;
  final String movieTitle;
  final int quantity;
  final double ticketPrice;

  const BookingItem({
    this.id,
    this.bookingId,
    required this.movieTitle,
    required this.quantity,
    required this.ticketPrice,
  });

  Map<String, Object?> toMap() {
    final Map<String, Object?> map = {
      'movie_title': movieTitle,
      'quantity': quantity,
      'ticket_price': ticketPrice,
    };
    if (id != null) {
      map['id'] = id;
    }
    if (bookingId != null) {
      map['booking_id'] = bookingId;
    }
    return map;
  }

  factory BookingItem.fromMap(Map<String, Object?> map) {
    return BookingItem(
      id: map['id'] as int?,
      bookingId: map['booking_id'] as int?,
      movieTitle: map['movie_title'] as String,
      quantity: map['quantity'] as int,
      ticketPrice: (map['ticket_price'] as num).toDouble(),
    );
  }

  double get lineTotal => ticketPrice * quantity;

  String get formattedPrice => '£${ticketPrice.toStringAsFixed(2)}';
}
