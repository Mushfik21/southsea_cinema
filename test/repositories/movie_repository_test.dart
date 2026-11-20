import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/repositories/movie_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final repository = MovieRepository();

  test('getMovieById returns the movie when the id exists', () {
    final movie = repository.getMovieById('2');

    expect(movie, isNotNull);
    expect(movie!.title, 'Truth or Dare');
  });

  test('getMovieById returns null when the id does not exist', () {
    final movie = repository.getMovieById('999');

    expect(movie, isNull);
  });

  test('loadMoviesFromAsset reads every film from the JSON file', () async {
    final MovieRepository jsonRepository = MovieRepository();

    final movies = await jsonRepository.loadMoviesFromAsset();

    expect(movies.length, 2);
    expect(movies[0].title, "Mr. Bean's Holiday");
    expect(movies[1].title, 'Truth or Dare');
    expect(movies[1].ticketPrice, 9.50);
  });
}
