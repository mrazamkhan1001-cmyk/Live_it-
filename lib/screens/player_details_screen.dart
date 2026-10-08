import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';

class PlayerDetailsScreen extends StatelessWidget {
  const PlayerDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (context, audio, child) {
        final song = audio.currentSong;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Track Details'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: song == null
              ? const Center(child: Text('No song details available', style: TextStyle(color: AppColors.primaryText)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Large Artwork
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.brightRed, width: 1.5),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            song.artworkUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.card,
                              child: const Icon(Icons.music_note, color: AppColors.brightRed, size: 60),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        song.title,
                        style: const TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        song.artist,
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Technical Metadata Cards
                      _buildDetailRow(Icons.album, 'Album', song.album),
                      _buildDetailRow(Icons.high_quality, 'Quality', 'Lossless 320 kbps MP3'),
                      _buildDetailRow(Icons.music_note, 'Source', 'Audius Streaming API'),
                      _buildDetailRow(Icons.speed, 'Sample Rate', '44.1 kHz / 16-bit'),
                      _buildDetailRow(Icons.speaker_group, 'Audio Engine', 'LIVE IT High-Fidelity DSP'),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.brightRed, size: 22),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(color: AppColors.primaryText, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
