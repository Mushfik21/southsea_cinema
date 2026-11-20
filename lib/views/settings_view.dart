import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/models/customer_profile.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';
import 'package:southsea_cinema/widgets/square_button.dart';

const String prefName = 'user_name';
const String prefEmail = 'user_email';
const String prefPhone = 'user_phone';
const String prefEmailNews = 'user_email_news';
const String prefDarkMode = 'dark_mode';

class SettingsView extends StatefulWidget {
  final bool darkMode;
  final ValueChanged<bool>? onDarkModeChanged;

  const SettingsView({
    super.key,
    this.darkMode = true,
    this.onDarkModeChanged,
  });

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  bool _emailNews = false;
  bool _darkMode = true;
  bool _isLoading = true;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _darkMode = widget.darkMode;
    _loadSettings();
  }

  @override
  void didUpdateWidget(SettingsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.darkMode != widget.darkMode) {
      _darkMode = widget.darkMode;
    }
  }

  void _changeDarkMode(bool value) {
    setState(() {
      _darkMode = value;
    });
    final ValueChanged<bool>? onChanged = widget.onDarkModeChanged;
    if (onChanged != null) {
      onChanged(value);
    }
  }

  Future<void> _loadSettings() async {
    final String? name = await _prefs.getString(prefName);
    final String? email = await _prefs.getString(prefEmail);
    final String? phone = await _prefs.getString(prefPhone);
    final bool? emailNews = await _prefs.getBool(prefEmailNews);
    if (!mounted) {
      return;
    }
    setState(() {
      _nameController.text = name ?? '';
      _emailController.text = email ?? '';
      _phoneController.text = phone ?? '';
      _emailNews = emailNews ?? false;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final CustomerProfile profile = CustomerProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      emailNews: _emailNews,
    );
    if (profile.name.isEmpty) {
      setState(() {
        _message = 'Please enter your name';
      });
      return;
    }
    if (!profile.hasValidEmail) {
      setState(() {
        _message = 'Please enter a valid email address';
      });
      return;
    }
    await _prefs.setString(prefName, profile.name);
    await _prefs.setString(prefEmail, profile.email);
    await _prefs.setString(prefPhone, profile.phone);
    await _prefs.setBool(prefEmailNews, profile.emailNews);
    if (!mounted) {
      return;
    }
    setState(() {
      _message = 'Profile saved';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Settings')),
      drawer: const NavDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('APPEARANCE', style: cinemaSectionStyle),
          SwitchListTile(
            key: const Key('darkModeSwitch'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Dark mode'),
            value: _darkMode,
            onChanged: _changeDarkMode,
          ),
          const SizedBox(height: 16),
          const Text('MY PROFILE', style: cinemaSectionStyle),
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
            key: const Key('emailNewsSwitch'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Email me news about new films'),
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
    );
  }
}
