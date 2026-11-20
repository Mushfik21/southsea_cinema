import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/views/movie_listing.dart';
import 'package:southsea_cinema/widgets/square_button.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(movie.posterPath, height: 200),
            const SizedBox(height: 8),
            Text(
              movie.title,
              style: const TextStyle(
                color: cinemaBrand,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Rated ${movie.ageRating} · ${movie.screeningTime}',
              style: const TextStyle(color: cinemaFontMuted),
            ),
            const SizedBox(height: 8),
            Text(movie.synopsis),
            const SizedBox(height: 12),
            SquareButton(
              label: 'Book tickets',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MovieListing(movie: movie),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
