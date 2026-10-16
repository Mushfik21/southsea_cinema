import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/repositories/movie_repository.dart';

void main() {
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
}
