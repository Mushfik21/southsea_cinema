import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:southsea_cinema/views/settings_view.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  Future<void> pumpSettings(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsView()));
    await tester.pumpAndSettle();
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
      await tester.pumpAndSettle();

      expect(find.text('Please enter your name'), findsOneWidget);
    });

    testWidgets('rejects a bad email', (WidgetTester tester) async {
      await pumpSettings(tester);

      await tester.enterText(find.byKey(const Key('nameField')), 'Sam');
      await tester.enterText(find.byKey(const Key('emailField')), 'sam');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();

      expect(find.text('Profile saved'), findsOneWidget);
      final Switch toggle = tester.widget<Switch>(find.byType(Switch));
      expect(toggle.value, true);
    });
  });

  group('SettingsView saved preferences', () {
    testWidgets('loads saved values when the page opens',
        (WidgetTester tester) async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData({
        prefName: 'Alex Test',
        prefEmail: 'alex@example.com',
        prefPhone: '07000000000',
        prefEmailNews: true,
      });

      await pumpSettings(tester);

      expect(find.text('Alex Test'), findsOneWidget);
      expect(find.text('alex@example.com'), findsOneWidget);
      expect(find.text('07000000000'), findsOneWidget);
      final Switch toggle = tester.widget<Switch>(find.byType(Switch));
      expect(toggle.value, true);
    });

    testWidgets('saving writes the values to preferences',
        (WidgetTester tester) async {
      await pumpSettings(tester);

      await tester.enterText(find.byKey(const Key('nameField')), 'Sam');
      await tester.enterText(
        find.byKey(const Key('emailField')),
        'sam@example.com',
      );
      await tester.tap(find.byType(Switch));
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final SharedPreferencesAsync prefs = SharedPreferencesAsync();
      expect(await prefs.getString(prefName), 'Sam');
      expect(await prefs.getString(prefEmail), 'sam@example.com');
      expect(await prefs.getBool(prefEmailNews), true);
    });

    testWidgets('reopening the page shows the saved values',
        (WidgetTester tester) async {
      await pumpSettings(tester);

      await tester.enterText(find.byKey(const Key('nameField')), 'Sam');
      await tester.enterText(
        find.byKey(const Key('emailField')),
        'sam@example.com',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      await tester.pumpWidget(const SizedBox());
      await pumpSettings(tester);

      expect(find.text('Sam'), findsOneWidget);
      expect(find.text('sam@example.com'), findsOneWidget);
    });
  });
}
