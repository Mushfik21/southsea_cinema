import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';

void main() {
  Future<void> pumpWithDrawer(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/': (context) => Scaffold(
                appBar: AppBar(),
                drawer: const NavDrawer(),
                body: const Text('Home page'),
              ),
          '/basket': (context) => const Scaffold(body: Text('Basket page')),
        },
      ),
    );
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
  }

  group('NavDrawer', () {
    testWidgets('shows the three pages', (WidgetTester tester) async {
      await pumpWithDrawer(tester);

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('My Basket'), findsOneWidget);
      expect(find.text('My Settings'), findsOneWidget);
    });

    testWidgets('close button shuts the drawer', (WidgetTester tester) async {
      await pumpWithDrawer(tester);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('My Basket'), findsNothing);
      expect(find.text('Home page'), findsOneWidget);
    });

    testWidgets('tapping a tile opens that page', (WidgetTester tester) async {
      await pumpWithDrawer(tester);

      await tester.tap(find.text('My Basket'));
      await tester.pumpAndSettle();

      expect(find.text('Basket page'), findsOneWidget);
    });
  });
}
