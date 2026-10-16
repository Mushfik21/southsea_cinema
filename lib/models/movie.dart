class Movie {
  final String id;
  final String title;
  final String synopsis;
  final String ageRating;
  final int runtime;
  final String screeningTime;
  final double ticketPrice;
  final String posterPath;

  const Movie({
    required this.id,
    required this.title,
    required this.synopsis,
    required this.ageRating,
    required this.runtime,
    required this.screeningTime,
    required this.ticketPrice,
    required this.posterPath,
  });

  String get formattedPrice => '£${ticketPrice.toStringAsFixed(2)}';
}
