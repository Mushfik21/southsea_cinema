class CustomerProfile {
  final String name;
  final String email;
  final String phone;
  final bool emailNews;

  const CustomerProfile({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.emailNews = false,
  });

  bool get hasValidEmail => email.contains('@') && email.contains('.');

  bool get isValid => name.trim().isNotEmpty && hasValidEmail;
}
