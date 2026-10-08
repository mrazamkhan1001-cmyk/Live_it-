import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';

class LyricsScreen extends StatelessWidget {
  const LyricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (context, audio, child) {
        final song = audio.currentSong;
        final lyrics = song?.lyrics ?? [];

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Synchronized Lyrics'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: song == null || lyrics.isEmpty
              ? const Center(
                  child: Text(
                    'No lyrics available for this Uchiha track.',
                    style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
                  ),
                )
              : SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // Header song info
                      Text(
                        song.title,
                        style: const TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        song.artist,
                        style: const TextStyle(
                          color: AppColors.brightRed,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Lyrics list view
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                          itemCount: lyrics.length,
                          itemBuilder: (context, index) {
                            final line = lyrics[index];
                            final isHighlight = index == 3;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                line,
                                style: TextStyle(
                                  color: isHighlight
                                      ? AppColors.brightRed
                                      : AppColors.primaryText.withValues(alpha: 0.7),
                                  fontSize: isHighlight ? 22 : 18,
                                  fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
