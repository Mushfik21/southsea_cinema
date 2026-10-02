import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';

class MovieListing extends StatefulWidget {
  const MovieListing({super.key});

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
      drawer: const NavDrawer(),
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
            const Text(
              "MR. BEAN'S HOLIDAY",
              style: TextStyle(
                color: cinemaBrand,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Text('90 mins', style: TextStyle(color: cinemaFontMuted)),
                SizedBox(width: 16),
                Text('Rated U', style: TextStyle(color: cinemaFontMuted)),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "Mr. Bean wins a trip to the French Riviera and causes chaos all the way across France on his journey to the beach.",
              style: TextStyle(color: cinemaFontWhite),
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
