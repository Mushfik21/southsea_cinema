import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/views/settings_view.dart';

void main() {
  Future<void> pumpSettings(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsView()));
  }

  group('SettingsView', () {
    testWidgets('shows the profile form', (WidgetTester tester) async {
      await pumpSettings(tester);

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Phone (optional)'), findsOneWidget);
      expect(find.text('Email me news about new films'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('asks for a name when it is missing',
        (WidgetTester tester) async {
      await pumpSettings(tester);

      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.text('Please enter your name'), findsOneWidget);
    });

    testWidgets('rejects a bad email', (WidgetTester tester) async {
      await pumpSettings(tester);

      await tester.enterText(find.byKey(const Key('nameField')), 'Sam');
      await tester.enterText(find.byKey(const Key('emailField')), 'sam');
      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('saves a valid profile', (WidgetTester tester) async {
      await pumpSettings(tester);

      await tester.enterText(find.byKey(const Key('nameField')), 'Sam');
      await tester.enterText(
        find.byKey(const Key('emailField')),
        'sam@example.com',
      );
      await tester.tap(find.byType(Switch));
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.text('Profile saved'), findsOneWidget);
      final Switch toggle = tester.widget<Switch>(find.byType(Switch));
      expect(toggle.value, true);
    });
  });
}
