import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Playback Settings Screen matching Section 22
class PlaybackSettingsScreen extends StatefulWidget {
  const PlaybackSettingsScreen({super.key});

  @override
  State<PlaybackSettingsScreen> createState() => _PlaybackSettingsScreenState();
}

class _PlaybackSettingsScreenState extends State<PlaybackSettingsScreen> {
  bool _crossfade = true;
  double _crossfadeDuration = 3.0;
  bool _gaplessPlayback = true;
  bool _normalizeVolume = true;
  bool _audioFocus = true;
  bool _resumePlayback = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Playback Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSwitchTile(
              title: 'Crossfade',
              subtitle: 'Allows songs to transition seamlessly',
              value: _crossfade,
              onChanged: (v) => setState(() => _crossfade = v),
            ),
            if (_crossfade) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Crossfade Duration', style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),
                    Text('${_crossfadeDuration.toInt()}s', style: const TextStyle(color: AppColors.brightRed, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Slider(
                min: 1,
                max: 12,
                value: _crossfadeDuration,
                activeColor: AppColors.brightRed,
                inactiveColor: AppColors.divider,
                onChanged: (v) => setState(() => _crossfadeDuration = v),
              ),
            ],

            const SizedBox(height: 12),
            _buildSwitchTile(
              title: 'Gapless Playback',
              subtitle: 'Eliminate silent gaps between songs',
              value: _gaplessPlayback,
              onChanged: (v) => setState(() => _gaplessPlayback = v),
            ),
            const SizedBox(height: 12),
            _buildSwitchTile(
              title: 'Normalize Volume',
              subtitle: 'Set same audio level for all tracks',
              value: _normalizeVolume,
              onChanged: (v) => setState(() => _normalizeVolume = v),
            ),
            const SizedBox(height: 12),
            _buildSwitchTile(
              title: 'Audio Focus',
              subtitle: 'Pause when other apps play audio',
              value: _audioFocus,
              onChanged: (v) => setState(() => _audioFocus = v),
            ),
            const SizedBox(height: 12),
            _buildSwitchTile(
              title: 'Resume Playback',
              subtitle: 'Automatically resume when headphones connect',
              value: _resumePlayback,
              onChanged: (v) => setState(() => _resumePlayback = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.secondaryText, fontSize: 12)),
        value: value,
        activeThumbColor: AppColors.brightRed,
        activeTrackColor: AppColors.darkRed,
        onChanged: onChanged,
      ),
    );
  }
}
