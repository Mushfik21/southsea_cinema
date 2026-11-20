import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/database/cinema_db.dart';
import 'package:southsea_cinema/main.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/views/settings_view.dart';
import 'package:southsea_cinema/widgets/movie_card.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() async {
    BasketRepository.instance.clear();
    rootBundle.clear();
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    final Database db = await databaseFactoryFfiNoIsolate.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: CinemaDatabase.instance.createTables,
      ),
    );
    CinemaDatabase.instance.setDatabase(db);
  });

  tearDown(() async {
    await CinemaDatabase.instance.close();
  });

  testWidgets('Home page shows title, movie cards and booking buttons',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SouthseaCinemaApp());
    await tester.pumpAndSettle();

    expect(find.text(appTitle), findsOneWidget);
    expect(find.byType(MovieCard), findsWidgets);
    expect(find.text("Mr. Bean's Holiday"), findsOneWidget);
    expect(find.text('Book tickets'), findsWidgets);
  });

  testWidgets('Booking opens the right film and Add to order shows feedback',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SouthseaCinemaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Book tickets').first);
    await tester.pumpAndSettle();

    expect(find.text("MR. BEAN'S HOLIDAY"), findsOneWidget);
    expect(find.text('Rated U'), findsOneWidget);
    expect(find.text('£8.50'), findsOneWidget);

    await tester.tap(find.text('Add to order'));
    await tester.pump();

    expect(find.text('1 ticket(s) added to your order'), findsOneWidget);
    expect(BasketRepository.instance.totalTickets, 1);
  });

  testWidgets('Home page shows both films from the JSON file',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SouthseaCinemaApp());
    await tester.pumpAndSettle();

    expect(find.text("Mr. Bean's Holiday"), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Truth or Dare'), 300);

    expect(find.text('Truth or Dare'), findsOneWidget);
  });

  testWidgets('Full booking flow: add, remove one, then checkout',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SouthseaCinemaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Book tickets').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add to order'));
    await tester.pump();
    await tester.tap(find.text('Add to order'));
    await tester.pump();

    await tester.tap(find.text('View basket'));
    await tester.pumpAndSettle();

    expect(find.text("Mr. Bean's Holiday"), findsOneWidget);
    expect(find.text('2 x £8.50'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove one ticket'));
    await tester.pump();

    expect(find.text('1 x £8.50'), findsOneWidget);

    await tester.tap(find.text('Checkout'));
    await tester.pumpAndSettle();

    expect(find.text('Your basket is empty'), findsOneWidget);
    expect(BasketRepository.instance.items, isEmpty);
    expect(find.text('Booking #1001'), findsOneWidget);
  });

  group('Light and dark mode', () {
    ThemeMode currentThemeMode(WidgetTester tester) {
      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      return app.themeMode!;
    }

    testWidgets('starts in dark mode by default', (WidgetTester tester) async {
      await tester.pumpWidget(const SouthseaCinemaApp());
      await tester.pumpAndSettle();

      expect(currentThemeMode(tester), ThemeMode.dark);
    });

    testWidgets('loads light mode from saved preferences',
        (WidgetTester tester) async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData({prefDarkMode: false});

      await tester.pumpWidget(const SouthseaCinemaApp());
      await tester.pumpAndSettle();

      expect(currentThemeMode(tester), ThemeMode.light);
    });

    testWidgets('dark mode switch in settings changes and saves the theme',
        (WidgetTester tester) async {
      await tester.pumpWidget(const SouthseaCinemaApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('My Settings'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('darkModeSwitch')));
      await tester.pumpAndSettle();

      expect(currentThemeMode(tester), ThemeMode.light);
      expect(await SharedPreferencesAsync().getBool(prefDarkMode), false);
    });
  });
}
