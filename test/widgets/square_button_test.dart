import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/widgets/square_button.dart';

void main() {
  group('SquareButton', () {
    testWidgets('shows its label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SquareButton(label: 'Book tickets', onPressed: () {}),
          ),
        ),
      );

      expect(find.text('Book tickets'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      int taps = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SquareButton(label: 'Tap me', onPressed: () => taps++),
          ),
        ),
      );

      await tester.tap(find.text('Tap me'));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('has square corners', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SquareButton(label: 'Square', onPressed: () {}),
          ),
        ),
      );

      final ElevatedButton button =
          tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final OutlinedBorder? shape = button.style?.shape?.resolve({});

      expect(shape, isA<RoundedRectangleBorder>());
      expect(
          (shape! as RoundedRectangleBorder).borderRadius, BorderRadius.zero);
    });
  });
}
