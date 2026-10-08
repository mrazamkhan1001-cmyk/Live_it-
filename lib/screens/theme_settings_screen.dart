import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  String _selectedTheme = 'Red Uchiha (Default)';

  final List<String> _themes = [
    'Red Uchiha (Default)',
    'Amaterasu Black',
    'Crimson Glow',
    'Tsukuyomi Dark',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Theme Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'SELECT APP THEME',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            ..._themes.map((t) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedTheme == t ? AppColors.brightRed : AppColors.divider,
                      width: _selectedTheme == t ? 1.5 : 1.0,
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      t,
                      style: TextStyle(
                        color: _selectedTheme == t ? AppColors.brightRed : AppColors.primaryText,
                        fontWeight: _selectedTheme == t ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: _selectedTheme == t ? const Icon(Icons.check_circle, color: AppColors.brightRed) : null,
                    onTap: () => setState(() => _selectedTheme = t),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
