import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/views/home_view.dart';

void main() {
  setUp(() {
    rootBundle.clear();
  });

  group('HomeView', () {
    testWidgets('shows a loading spinner before the films arrive',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeView()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
