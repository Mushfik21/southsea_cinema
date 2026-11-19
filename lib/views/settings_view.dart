import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/models/customer_profile.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';
import 'package:southsea_cinema/widgets/square_button.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _emailNews = false;
  String _message = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final CustomerProfile profile = CustomerProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      emailNews: _emailNews,
    );
    setState(() {
      if (profile.name.isEmpty) {
        _message = 'Please enter your name';
      } else if (!profile.hasValidEmail) {
        _message = 'Please enter a valid email address';
      } else {
        _message = 'Profile saved';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Settings')),
      drawer: const NavDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('MY PROFILE', style: cinemaHeaderStyle),
            const SizedBox(height: 16),
            TextField(
              key: const Key('nameField'),
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('emailField'),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('phoneField'),
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Email me news about new films',
                style: TextStyle(color: cinemaFontWhite),
              ),
              value: _emailNews,
              onChanged: (bool value) {
                setState(() {
                  _emailNews = value;
                });
              },
            ),
            const SizedBox(height: 16),
            SquareButton(label: 'Save', onPressed: _saveSettings),
            const SizedBox(height: 12),
            Text(
              _message,
              style: const TextStyle(color: cinemaBrandLight),
            ),
          ],
        ),
      ),
    );
  }
}
