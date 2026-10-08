import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class AnimationSettingsScreen extends StatefulWidget {
  const AnimationSettingsScreen({super.key});

  @override
  State<AnimationSettingsScreen> createState() =>
      _AnimationSettingsScreenState();
}

class _AnimationSettingsScreenState extends State<AnimationSettingsScreen> {
  String _selectedStyle = 'Sharingan (Default)';
  String _rotationSpeed = 'Medium';
  String _glowIntensity = 'High';
  bool _autoPatternChange = true;

  final List<String> _styles = [
    'Sharingan (Default)',
    'Rinnegan',
    'Mangekyou',
    'Off',
  ];
  final List<String> _speeds = ['Slow', 'Medium', 'Fast'];
  final List<String> _glows = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await StorageService.getAnimationSettings();
    if (mounted) {
      setState(() {
        _selectedStyle = settings.selectedStyle;
        _rotationSpeed = settings.rotationSpeed;
        _glowIntensity = settings.glowIntensity;
        _autoPatternChange = settings.autoPatternChange;
      });
    }
  }

  void _saveSettings() {
    StorageService.saveAnimationSettings(
      AnimationSettings(
        selectedStyle: _selectedStyle,
        rotationSpeed: _rotationSpeed,
        glowIntensity: _glowIntensity,
        autoPatternChange: _autoPatternChange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sharingan Animation Controls'),
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
              'ANIMATION STYLE',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            ..._styles.map(
              (style) => _buildOptionTile(
                title: style,
                isSelected: _selectedStyle == style,
                onTap: () {
                  setState(() => _selectedStyle = style);
                  _saveSettings();
                },
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'ROTATION SPEED',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            ..._speeds.map(
              (speed) => _buildOptionTile(
                title: speed,
                isSelected: _rotationSpeed == speed,
                onTap: () {
                  setState(() => _rotationSpeed = speed);
                  _saveSettings();
                },
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'GLOW INTENSITY',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            ..._glows.map(
              (glow) => _buildOptionTile(
                title: glow,
                isSelected: _glowIntensity == glow,
                onTap: () {
                  setState(() => _glowIntensity = glow);
                  _saveSettings();
                },
              ),
            ),
            const SizedBox(height: 24),

            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider, width: 1),
              ),
              child: SwitchListTile(
                title: const Text(
                  'Automatic Pattern Change',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Morph between eyes during song playback',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
                value: _autoPatternChange,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.brightRed,
                onChanged: (val) {
                  setState(() => _autoPatternChange = val);
                  _saveSettings();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.brightRed : AppColors.divider,
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.brightRed : AppColors.primaryText,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: AppColors.brightRed)
            : null,
        onTap: onTap,
      ),
    );
  }
}
