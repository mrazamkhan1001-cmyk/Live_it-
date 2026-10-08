import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../theme/app_theme.dart';

/// Audio Quality Settings Screen matching Section 23
class AudioQualityScreen extends StatefulWidget {
  const AudioQualityScreen({super.key});

  @override
  State<AudioQualityScreen> createState() => _AudioQualityScreenState();
}

class _AudioQualityScreenState extends State<AudioQualityScreen> {
  String _streamQuality = 'High';
  String _downloadQuality = 'Very High';

  final List<String> _qualities = ['Low', 'Normal', 'High', 'Very High'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await StorageService.getAudioQualitySettings();
    if (mounted) {
      setState(() {
        _streamQuality = settings.streamQuality;
        _downloadQuality = settings.downloadQuality;
      });
    }
  }

  void _updateSettings({String? stream, String? download}) {
    setState(() {
      if (stream != null) _streamQuality = stream;
      if (download != null) _downloadQuality = download;
    });
    StorageService.saveAudioQualitySettings(
      AudioQualitySettings(
        streamQuality: _streamQuality,
        downloadQuality: _downloadQuality,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Audio Quality'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'STREAMING QUALITY',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            ..._qualities.map(
              (q) => _buildRadioTile(
                title: q,
                subtitle: q == 'Very High'
                    ? '320 kbps MP3 / Lossless Audio'
                    : '${q == 'High' ? '256' : '128'} kbps MP3',
                selected: _streamQuality == q,
                onSelect: () => _updateSettings(stream: q),
              ),
            ),

            const SizedBox(height: 28),
            const Text(
              'DOWNLOAD QUALITY',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            ..._qualities.map(
              (q) => _buildRadioTile(
                title: q,
                subtitle: q == 'Very High'
                    ? '320 kbps High Fidelity'
                    : '${q == 'High' ? '256' : '128'} kbps Standard',
                selected: _downloadQuality == q,
                onSelect: () => _updateSettings(download: q),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioTile({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onSelect,
  }) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.brightRed : AppColors.divider,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: selected
                        ? AppColors.brightRed
                        : AppColors.primaryText,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? AppColors.brightRed : AppColors.secondaryText,
            ),
          ],
        ),
      ),
    );
  }
}
