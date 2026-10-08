import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _newReleases = true;
  bool _playlistUpdates = true;
  bool _recommendations = false;
  bool _lockScreenPlayer = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await StorageService.getNotificationSettings();
    if (mounted) {
      setState(() {
        _newReleases = settings.newReleases;
        _playlistUpdates = settings.playlistUpdates;
        _recommendations = settings.recommendations;
        _lockScreenPlayer = settings.lockScreenPlayer;
      });
    }
  }

  void _saveSettings() {
    StorageService.saveNotificationSettings(
      NotificationSettings(
        newReleases: _newReleases,
        playlistUpdates: _playlistUpdates,
        recommendations: _recommendations,
        lockScreenPlayer: _lockScreenPlayer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSwitchTile(
              'New Track Releases',
              'Get notified when your favorite artists drop new tracks',
              _newReleases,
              (v) {
                setState(() => _newReleases = v);
                _saveSettings();
              },
            ),
            _buildSwitchTile(
              'Playlist Updates',
              'Notifications when collaborative playlists are updated',
              _playlistUpdates,
              (v) {
                setState(() => _playlistUpdates = v);
                _saveSettings();
              },
            ),
            _buildSwitchTile(
              'Personalized Recommendations',
              'Daily Uchiha music recommendations',
              _recommendations,
              (v) {
                setState(() => _recommendations = v);
                _saveSettings();
              },
            ),
            _buildSwitchTile(
              'Lockscreen Media Player',
              'Show player notification controls on Android lockscreen',
              _lockScreenPlayer,
              (v) {
                setState(() => _lockScreenPlayer = v);
                _saveSettings();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
        ),
        value: value,
        activeThumbColor: Colors.white,
        activeTrackColor: AppColors.brightRed,
        onChanged: onChanged,
      ),
    );
  }
}
