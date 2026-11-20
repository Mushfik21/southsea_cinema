class Booking {
  final int? id;
  final int bookingNumber;
  final String summary;
  final double total;
  final String date;

  const Booking({
    this.id,
    required this.bookingNumber,
    required this.summary,
    required this.total,
    required this.date,
  });

  Map<String, Object?> toMap() {
    final Map<String, Object?> map = {
      'booking_number': bookingNumber,
      'summary': summary,
      'total': total,
      'date': date,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Booking.fromMap(Map<String, Object?> map) {
    return Booking(
      id: map['id'] as int?,
      bookingNumber: map['booking_number'] as int,
      summary: map['summary'] as String,
      total: (map['total'] as num).toDouble(),
      date: map['date'] as String,
    );
  }

  String get formattedTotal => '£${total.toStringAsFixed(2)}';
}
