import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';

class SquareButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const SquareButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: cinemaBrand,
        foregroundColor: cinemaBackground,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      child: Text(label),
    );
  }
}
