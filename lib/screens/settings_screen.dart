import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'edit_profile_screen.dart';
import 'playback_settings_screen.dart';
import 'audio_quality_screen.dart';
import 'equalizer_screen.dart';
import 'animation_settings_screen.dart';
import 'storage_screen.dart';
import 'notification_settings_screen.dart';
import 'theme_settings_screen.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            _buildSettingTile(
              context: context,
              icon: Icons.person_outline,
              title: 'Account Settings',
              subtitle: 'Edit Uchiha profile & credentials',
              targetScreen: const EditProfileScreen(),
            ),
            _buildSettingTile(
              context: context,
              icon: Icons.play_circle_outline,
              title: 'Playback Settings',
              subtitle: 'Crossfade, gapless, normalization',
              targetScreen: const PlaybackSettingsScreen(),
            ),
            _buildSettingTile(
              context: context,
              icon: Icons.high_quality_outlined,
              title: 'Audio Quality',
              subtitle: 'Streaming & download bitrate',
              targetScreen: const AudioQualityScreen(),
            ),
            _buildSettingTile(
              context: context,
              icon: Icons.graphic_eq,
              title: 'Equalizer',
              subtitle: '5-band red EQ & sound presets',
              targetScreen: const EqualizerScreen(),
            ),
            _buildSettingTile(
              context: context,
              icon: Icons.motion_photos_on_outlined,
              title: 'Sharingan Animation Controls',
              subtitle: 'Eye style, rotation speed, glow',
              targetScreen: const AnimationSettingsScreen(),
            ),
            _buildSettingTile(
              context: context,
              icon: Icons.storage_outlined,
              title: 'Storage & Cache',
              subtitle: 'Clear app cache and offline downloads',
              targetScreen: const StorageScreen(),
            ),
            _buildSettingTile(
              context: context,
              icon: Icons.notifications_none_outlined,
              title: 'Notifications',
              subtitle: 'Track releases & player alert settings',
              targetScreen: const NotificationSettingsScreen(),
            ),
            _buildSettingTile(
              context: context,
              icon: Icons.palette_outlined,
              title: 'Theme',
              subtitle: 'Red Uchiha (Default)',
              targetScreen: const ThemeSettingsScreen(),
            ),
            _buildSettingTile(
              context: context,
              icon: Icons.info_outline,
              title: 'About LIVE IT',
              subtitle: 'Version 2.0.0, credits, terms',
              targetScreen: const AboutScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget targetScreen,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: Icon(icon, color: AppColors.brightRed, size: 22),
          title: Text(
            title,
            style: const TextStyle(
              color: AppColors.primaryText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 11,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: AppColors.secondaryText,
            size: 14,
          ),
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => targetScreen));
          },
        ),
      ),
    );
  }
}
