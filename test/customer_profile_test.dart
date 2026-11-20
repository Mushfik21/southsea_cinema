import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/customer_profile.dart';

void main() {
  group('CustomerProfile', () {
    test('starts with empty values and no email news', () {
      const CustomerProfile profile = CustomerProfile();

      expect(profile.name, '');
      expect(profile.email, '');
      expect(profile.phone, '');
      expect(profile.emailNews, false);
    });

    test('stores the values it is given', () {
      const CustomerProfile profile = CustomerProfile(
        name: 'Sam Smith',
        email: 'sam@example.com',
        phone: '07123456789',
        emailNews: true,
      );

      expect(profile.name, 'Sam Smith');
      expect(profile.email, 'sam@example.com');
      expect(profile.phone, '07123456789');
      expect(profile.emailNews, true);
    });

    test('is valid with a name and a proper email', () {
      const CustomerProfile profile =
          CustomerProfile(name: 'Sam', email: 'sam@example.com');

      expect(profile.isValid, true);
    });

    test('is not valid without a name or with a bad email', () {
      const CustomerProfile noName = CustomerProfile(email: 'sam@example.com');
      const CustomerProfile badEmail = CustomerProfile(name: 'Sam', email: 'sam');

      expect(noName.isValid, false);
      expect(badEmail.isValid, false);
    });
  });
}
