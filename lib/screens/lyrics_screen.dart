import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lyric_line.dart';
import '../services/audio_service.dart';
import '../services/lyrics_service.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state_view.dart';

/// Phase 9: Real-time Synchronized Lyrics Screen
/// Uses the actual playback position from AudioPlayerService to dynamically highlight and auto-scroll lyrics.
class LyricsScreen extends StatefulWidget {
  const LyricsScreen({super.key});

  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen> {
  final ScrollController _scrollController = ScrollController();
  int _lastActiveIndex = -1;
  String? _currentSongId;
  List<LyricLine> _lyrics = [];

  // Approximate height per lyric row for auto-scrolling
  static const double _rowHeight = 58.0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToActiveIndex(int index) {
    if (!_scrollController.hasClients || index < 0) return;

    final targetOffset = (index * _rowHeight) - 160.0;
    final clampedOffset = targetOffset.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (context, audio, child) {
        final song = audio.currentSong;

        if (song == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('Lyrics'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: const Center(
              child: Text(
                'No active song playing.',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
              ),
            ),
          );
        }

        // Reload lyrics if active track changed
        if (_currentSongId != song.id) {
          _currentSongId = song.id;
          _lyrics = LyricsService.getLyricsForSong(song);
          _lastActiveIndex = -1;
        }

        final isSyncAvailable = _lyrics.any((l) => l.isSynchronized);
        final activeIndex = isSyncAvailable
            ? LyricLine.findActiveIndex(_lyrics, audio.position)
            : -1;

        // Auto-scroll only when active line changes
        if (activeIndex != _lastActiveIndex && activeIndex >= 0) {
          _lastActiveIndex = activeIndex;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToActiveIndex(activeIndex);
          });
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Column(
              children: [
                const Text(
                  'LYRICS',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  isSyncAvailable ? 'Real-Time Synchronized' : 'Plain Lyrics',
                  style: const TextStyle(
                    color: AppColors.brightRed,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Header: Song & Artist Info Banner
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          song.artworkUrl,
                          width: 54,
                          height: 54,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 54,
                            height: 54,
                            color: AppColors.card,
                            child: const Icon(
                              Icons.music_note,
                              color: AppColors.brightRed,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              style: const TextStyle(
                                color: AppColors.primaryText,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              song.artist,
                              style: const TextStyle(
                                color: AppColors.brightRed,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.divider, height: 1),

                // Lyrics Content Viewport
                Expanded(
                  child: _lyrics.isEmpty
                      ? const EmptyStateView(
                          icon: Icons.lyrics_outlined,
                          title: "Synchronized lyrics aren't available for this track.",
                          description: 'Streaming audio directly from Audius decentralized nodes.',
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 24,
                          ),
                          itemCount: _lyrics.length,
                          itemBuilder: (context, index) {
                            final line = _lyrics[index];
                            final isHighlight =
                                isSyncAvailable && index == activeIndex;

                            return GestureDetector(
                              onTap: () {
                                if (line.isSynchronized) {
                                  LiveItHaptics.selection();
                                  audio.seek(line.startTime);
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 12,
                                ),
                                margin: const EdgeInsets.only(bottom: 6),
                                decoration: BoxDecoration(
                                  color: isHighlight
                                      ? AppColors.brightRed.withValues(
                                          alpha: 0.15,
                                        )
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: isHighlight
                                      ? Border.all(
                                          color: AppColors.brightRed.withValues(
                                            alpha: 0.6,
                                          ),
                                          width: 1,
                                        )
                                      : null,
                                ),
                                child: Text(
                                  line.text,
                                  style: TextStyle(
                                    color: isHighlight
                                        ? Colors.white
                                        : isSyncAvailable
                                        ? AppColors.secondaryText.withValues(
                                            alpha: 0.6,
                                          )
                                        : AppColors.primaryText,
                                    fontSize: isHighlight ? 20 : 16,
                                    fontWeight: isHighlight
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    letterSpacing: isHighlight ? 0.3 : 0,
                                    height: 1.4,
                                    shadows: isHighlight
                                        ? const [
                                            Shadow(
                                              color: AppColors.redGlow,
                                              blurRadius: 12,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // Bottom Quick Playback Controls
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.card,
                    border: Border(top: BorderSide(color: AppColors.divider)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.skip_previous_rounded,
                          color: AppColors.primaryText,
                          size: 28,
                        ),
                        onPressed: () {
                          LiveItHaptics.light();
                          audio.previousSong();
                        },
                      ),
                      Container(
                        width: 46,
                        height: 46,
                        decoration: const BoxDecoration(
                          color: AppColors.brightRed,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.redGlow,
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            audio.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {
                            LiveItHaptics.light();
                            audio.togglePlayPause();
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.skip_next_rounded,
                          color: AppColors.primaryText,
                          size: 28,
                        ),
                        onPressed: () {
                          LiveItHaptics.light();
                          audio.nextSong();
                        },
                      ),
                    ],
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
