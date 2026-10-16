import 'package:southsea_cinema/models/movie.dart';

class MovieRepository {
  List<Movie> getMovies() {
    return const [
      Movie(
        id: '1',
        title: "Mr. Bean's Holiday",
        synopsis:
            'Mr. Bean wins a trip to the French Riviera and causes chaos all the way across France on his journey to the beach.',
        ageRating: 'U',
        runtime: 90,
        screeningTime: '18:00',
        ticketPrice: 8.50,
        posterPath: 'assets/images/Mr_bean.jpg',
      ),
      Movie(
        id: '2',
        title: 'Truth or Dare',
        synopsis:
            'A group of college students become trapped in a deadly, demonic game where choosing a lie or failing a dare results in gruesome death.',
        ageRating: '15',
        runtime: 100,
        screeningTime: '23:30',
        ticketPrice: 9.50,
        posterPath: 'assets/images/Truth_or_dare.jpg',
      ),
    ];
  }

  Movie? getMovieById(String id) {
    for (final movie in getMovies()) {
      if (movie.id == id) {
        return movie;
      }
    }
    return null;
  }
}
