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

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as String,
      title: json['title'] as String,
      synopsis: json['synopsis'] as String,
      ageRating: json['ageRating'] as String,
      runtime: json['runtime'] as int,
      screeningTime: json['screeningTime'] as String,
      ticketPrice: (json['ticketPrice'] as num).toDouble(),
      posterPath: json['posterPath'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'synopsis': synopsis,
      'ageRating': ageRating,
      'runtime': runtime,
      'screeningTime': screeningTime,
      'ticketPrice': ticketPrice,
      'posterPath': posterPath,
    };
  }

  String get formattedPrice => '£${ticketPrice.toStringAsFixed(2)}';
}
