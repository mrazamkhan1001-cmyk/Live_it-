import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import 'about_screen.dart';
import 'animation_settings_screen.dart';
import 'audio_quality_screen.dart';
import 'edit_profile_screen.dart';
import 'equalizer_screen.dart';
import 'login_screen.dart';
import 'notification_settings_screen.dart';
import 'playback_settings_screen.dart';
import 'storage_screen.dart';
import 'theme_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _showLogoutDialog(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161616),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: AppColors.brightRed.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          title: const Text(
            'Log out?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out of your account?',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 14,
            ),
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brightRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                elevation: 0,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true && context.mounted) {
      try {
        final audioService =
            Provider.of<AudioPlayerService>(context, listen: false);
        await audioService.logout();

        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: $e'),
              backgroundColor: AppColors.brightRed,
            ),
          );
        }
      }
    }
  }

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
            const SizedBox(height: 10),
            // LOGOUT BUTTON TILE
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.brightRed.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.brightRed,
                    size: 22,
                  ),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      color: AppColors.brightRed,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Sign out of your LIVE IT account',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 11,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.brightRed,
                    size: 20,
                  ),
                  onTap: () => _showLogoutDialog(context),
                ),
              ),
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
