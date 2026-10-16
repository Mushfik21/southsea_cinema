import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/models/movie.dart';

class MovieListing extends StatefulWidget {
  final Movie movie;

  const MovieListing({super.key, required this.movie});

  @override
  State<MovieListing> createState() => _MovieListingState();
}

class _MovieListingState extends State<MovieListing> {
  int _ticketQuantity = 1;
  String _feedbackMessage = '';

  void _addToOrder() {
    setState(() {
      _feedbackMessage = '$_ticketQuantity ticket(s) added to your order';
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget ticketDropdown = DropdownMenu<int>(
      initialSelection: _ticketQuantity,
      label: const Text('Tickets'),
      onSelected: (int? value) {
        if (value != null) {
          setState(() {
            _ticketQuantity = value;
          });
        }
      },
      dropdownMenuEntries: const [
        DropdownMenuEntry(value: 1, label: '1'),
        DropdownMenuEntry(value: 2, label: '2'),
        DropdownMenuEntry(value: 3, label: '3'),
        DropdownMenuEntry(value: 4, label: '4'),
        DropdownMenuEntry(value: 5, label: '5'),
      ],
    );

    final Widget addButton = ElevatedButton(
      onPressed: _addToOrder,
      style: ElevatedButton.styleFrom(
        backgroundColor: cinemaBrand,
        foregroundColor: cinemaBackground,
      ),
      child: const Text('Add to order'),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(appTitle, style: cinemaHeaderStyle),
        backgroundColor: cinemaSurface,
        iconTheme: const IconThemeData(color: cinemaBrand),
        elevation: 0,
      ),
      body: Container(
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: cinemaSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.movie.title.toUpperCase(),
              style: const TextStyle(
                color: cinemaBrand,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${widget.movie.runtime} mins',
                  style: const TextStyle(color: cinemaFontMuted),
                ),
                const SizedBox(width: 16),
                Text(
                  'Rated ${widget.movie.ageRating}',
                  style: const TextStyle(color: cinemaFontMuted),
                ),
                const SizedBox(width: 16),
                Text(
                  widget.movie.formattedPrice,
                  style: const TextStyle(color: cinemaFontMuted),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.movie.synopsis,
              style: const TextStyle(color: cinemaFontWhite),
            ),
            const SizedBox(height: 16),
            const Text('BOOK TICKETS', style: cinemaHeaderStyle),
            const Divider(color: cinemaFontMuted),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return Row(
                    children: [
                      ticketDropdown,
                      const SizedBox(width: 16),
                      addButton,
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ticketDropdown,
                      const SizedBox(height: 16),
                      addButton,
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            Text(
              _feedbackMessage,
              style: const TextStyle(color: cinemaBrandLight),
            ),
          ],
        ),
      ),
    );
  }
}
