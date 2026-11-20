import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/movie.dart';

void main() {
  test('Movie stores its properties', () {
    const movie = Movie(
      id: '1',
      title: 'Test Film',
      synopsis: 'A test synopsis',
      ageRating: 'PG',
      runtime: 95,
      screeningTime: '19:00',
      ticketPrice: 8.0,
      posterPath: 'assets/images/test.jpg',
    );

    expect(movie.id, '1');
    expect(movie.title, 'Test Film');
    expect(movie.synopsis, 'A test synopsis');
    expect(movie.ageRating, 'PG');
    expect(movie.runtime, 95);
    expect(movie.screeningTime, '19:00');
    expect(movie.ticketPrice, 8.0);
    expect(movie.posterPath, 'assets/images/test.jpg');
  });

  test('formattedPrice shows whole pounds with .00', () {
    const movie = Movie(
      id: '1',
      title: 'T',
      synopsis: 'S',
      ageRating: 'U',
      runtime: 90,
      screeningTime: '18:00',
      ticketPrice: 8.0,
      posterPath: 'p',
    );

    expect(movie.formattedPrice, '£8.00');
  });

  test('formattedPrice shows pence correctly', () {
    const movie = Movie(
      id: '1',
      title: 'T',
      synopsis: 'S',
      ageRating: 'U',
      runtime: 90,
      screeningTime: '18:00',
      ticketPrice: 8.5,
      posterPath: 'p',
    );

    expect(movie.formattedPrice, '£8.50');
  });

  group('Movie JSON', () {
    test('fromJson reads every field', () {
      final Movie movie = Movie.fromJson({
        'id': '7',
        'title': 'Test Film',
        'synopsis': 'A test synopsis',
        'ageRating': '12A',
        'runtime': 120,
        'screeningTime': '20:15',
        'ticketPrice': 7.25,
        'posterPath': 'assets/images/test.jpg',
      });

      expect(movie.id, '7');
      expect(movie.title, 'Test Film');
      expect(movie.synopsis, 'A test synopsis');
      expect(movie.ageRating, '12A');
      expect(movie.runtime, 120);
      expect(movie.screeningTime, '20:15');
      expect(movie.ticketPrice, 7.25);
      expect(movie.posterPath, 'assets/images/test.jpg');
    });

    test('fromJson turns a whole-number price into a double', () {
      final Movie movie = Movie.fromJson({
        'id': '8',
        'title': 'T',
        'synopsis': 'S',
        'ageRating': 'U',
        'runtime': 90,
        'screeningTime': '18:00',
        'ticketPrice': 9,
        'posterPath': 'p',
      });

      expect(movie.ticketPrice, 9.0);
      expect(movie.formattedPrice, '£9.00');
    });

    test('toJson writes every field', () {
      const Movie movie = Movie(
        id: '1',
        title: 'T',
        synopsis: 'S',
        ageRating: 'U',
        runtime: 90,
        screeningTime: '18:00',
        ticketPrice: 8.5,
        posterPath: 'p',
      );

      expect(movie.toJson(), {
        'id': '1',
        'title': 'T',
        'synopsis': 'S',
        'ageRating': 'U',
        'runtime': 90,
        'screeningTime': '18:00',
        'ticketPrice': 8.5,
        'posterPath': 'p',
      });
    });
  });
}
