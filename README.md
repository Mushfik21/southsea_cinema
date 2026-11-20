# Southsea Cinema

A mobile-first Flutter app for the Southsea Cinema & Arts Centre. You can
browse the films that are showing, add tickets to a basket, check out and
see your past bookings. You can also save your profile details and switch
between light and dark mode.

This app was built for the M30235 Flutter coursework at the University of
Portsmouth, following the weekly worksheets.

## Features

- Browse the current films, loaded from a JSON asset file
  (`assets/data/movies.json`)
- Open a film to see its details, pick 1 to 5 tickets and add them to the
  basket
- View the basket, remove tickets one at a time and see the running total
- Check out to save a numbered booking (starting at 1001) in a local SQLite
  database
- See past bookings listed under the basket, newest first, with each film
  and quantity (saved in a separate `booking_items` table)
- Save a customer profile (name, email, phone and a news opt-in) with
  shared preferences
- Switch between light and dark mode in My Settings (the choice is saved)

## Platform

The app is designed to run on **Android**, because bookings are saved in a
SQLite file on the device using `sqflite`.

The app also opens in Chrome for quick checks, but `sqflite` does not work
on the web, so saving and listing bookings is not available there. The
basket, profile and theme settings still work in Chrome.

## Getting started

### Prerequisites

- Flutter SDK with the Android toolchain (check with `flutter doctor`)
- An Android emulator or an Android phone with USB debugging turned on
- Git

### Clone

```bash
git clone https://github.com/Mushfik21/southsea_cinema.git
cd southsea_cinema
```

### Install dependencies

```bash
flutter pub get
```

### Run

Start an emulator or connect your phone, then run:

```bash
flutter devices
flutter run
```

To try it in Chrome instead (without saved bookings):

```bash
flutter run -d chrome
```

## Tests

Run all the tests with:

```bash
flutter test
```

The tests do not need an emulator. Database tests use an in-memory SQLite
database (`sqflite_common_ffi`) and preference tests use in-memory shared
preferences, so nothing is written to your device.

To measure test coverage:

```bash
flutter test --coverage
```

The report is written to `coverage/lcov.info`. The `coverage/` folder is
ignored by Git.

Line coverage went from **92.9%** (421 of 453 lines) to **95.6%** (433 of
453 lines) after adding tests for the film page, the drawer, the home page
loading state, the movie cache and opening the real database file. The
lines still not covered are `main()` and the error messages shown when
loading or saving fails.

Before committing, the code is checked with:

```bash
dart format lib test
dart analyze
```

## Project structure

- `lib/main.dart`: the app, themes (light and dark) and named routes
- `lib/constants.dart`: shared colours, text styles and the app title
- `lib/models/`: `Movie`, `BasketItem`, `Booking`, `BookingItem` and
  `CustomerProfile`
- `lib/repositories/`: `MovieRepository` (loads the JSON) and
  `BasketRepository` (the in-memory basket)
- `lib/database/`: `CinemaDatabase`, which saves and reads bookings with
  SQLite (version 2 adds the `booking_items` table and keeps old bookings
  when it upgrades)
- `lib/views/`: the home, film listing, basket and settings pages
- `lib/widgets/`: reusable widgets (`MovieCard`, `NavDrawer`,
  `SquareButton`)
- `assets/`: film posters and `data/movies.json`
- `test/`: tests in folders that mirror `lib/`, plus `main_test.dart` for
  whole-app tests
