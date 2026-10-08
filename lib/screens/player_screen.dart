import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/sharingan_player.dart';
import 'equalizer_screen.dart';
import 'fullscreen_player_screen.dart';
import 'lyrics_screen.dart';
import 'queue_screen.dart';
import 'player_details_screen.dart';

/// LIVE IT — BY AZAM KHAN
/// Phase 5 & 6: Signature Now Playing Screen with Sharingan Centerpiece
class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  double _dragDx = 0;

  String _formatDuration(Duration duration) {
    if (duration <= Duration.zero) return '0:00';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:$seconds';
    }
    return '$minutes:$seconds';
  }

  void _showOptionsMenu(
    BuildContext context,
    Song song,
    AudioPlayerService audio,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.fullscreen,
                    color: AppColors.brightRed,
                  ),
                  title: const Text(
                    'Fullscreen Player',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Immersive cinematic visualizer experience',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FullscreenPlayerScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.info_outline,
                    color: AppColors.brightRed,
                  ),
                  title: const Text(
                    'Track Details',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    song.title,
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PlayerDetailsScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.graphic_eq,
                    color: AppColors.brightRed,
                  ),
                  title: const Text(
                    'Equalizer & DSP',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Adjust audio frequencies and bass boost',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const EqualizerScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(
                    audio.isSongFavorite(song.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: AppColors.brightRed,
                  ),
                  title: Text(
                    audio.isSongFavorite(song.id)
                        ? 'Remove from Favorites'
                        : 'Add to Favorites',
                    style: const TextStyle(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    audio.toggleFavorite(song);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.queue_music,
                    color: AppColors.brightRed,
                  ),
                  title: const Text(
                    'View Queue',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${audio.queue.length} tracks in active playlist',
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const QueueScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
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
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.primaryText,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: const Center(
              child: Text(
                'No track currently playing',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 16),
              ),
            ),
          );
        }

        final double progress = audio.duration.inMilliseconds > 0
            ? (audio.position.inMilliseconds / audio.duration.inMilliseconds)
                  .clamp(0.0, 1.0)
            : 0.0;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double maxH = constraints.maxHeight;
                final double maxW = constraints.maxWidth;

                // Responsive Sharingan Centerpiece Sizing
                final double sharinganSize = ((maxH - 310) * 0.72).clamp(
                  160.0,
                  (maxW * 0.70).clamp(160.0, 275.0),
                );

                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // --- 1. TOP BAR ---
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: AppColors.primaryText,
                              size: 24,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'NOW PLAYING',
                                style: TextStyle(
                                  color: AppColors.secondaryText,
                                  fontSize: 10,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                song.album.isNotEmpty
                                    ? song.album.toUpperCase()
                                    : 'AUDIUS STREAM',
                                style: const TextStyle(
                                  color: AppColors.primaryText,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.fullscreen,
                                  color: AppColors.primaryText,
                                  size: 24,
                                ),
                                tooltip: 'Fullscreen Mode',
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const FullscreenPlayerScreen(),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: AppColors.primaryText,
                                  size: 24,
                                ),
                                onPressed: () =>
                                    _showOptionsMenu(context, song, audio),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 1),

                    // --- 2. SHARINGAN CENTERPIECE & SONG INFO (SWIPE GESTURE AREA) ---
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragStart: (_) {
                        _dragDx = 0;
                      },
                      onHorizontalDragUpdate: (details) {
                        _dragDx += details.delta.dx;
                      },
                      onHorizontalDragEnd: (details) {
                        final velocity = details.primaryVelocity ?? 0;
                        final double dx = _dragDx;
                        _dragDx = 0;

                        if (dx < -40 || velocity < -150) {
                          // SWIPE LEFT (Finger moves right-to-left) -> Previous Track
                          audio.previousSong();
                        } else if (dx > 40 || velocity > 150) {
                          // SWIPE RIGHT (Finger moves left-to-right) -> Next Track
                          audio.nextSong();
                        }
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Large Centered Sharingan Video Animation
                          Center(
                            child: SharinganPlayer(
                              isPlaying: audio.isPlaying,
                              size: sharinganSize,
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Centered Song Title & Artist
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  song.title,
                                  style: const TextStyle(
                                    color: AppColors.primaryText,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  song.artist,
                                  style: const TextStyle(
                                    color: AppColors.secondaryText,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 1),

                    // --- 3. FUNCTIONAL PROGRESS SLIDER ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 3.5,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 14,
                              ),
                              activeTrackColor: AppColors.brightRed,
                              inactiveTrackColor: AppColors.divider.withValues(
                                alpha: 0.6,
                              ),
                              thumbColor: AppColors.brightRed,
                              overlayColor: AppColors.redGlow.withValues(
                                alpha: 0.2,
                              ),
                            ),
                            child: Slider(
                              value: progress,
                              onChanged: (val) {
                                final targetMs =
                                    (val * audio.duration.inMilliseconds)
                                        .toInt();
                                audio.seek(Duration(milliseconds: targetMs));
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(audio.position),
                                  style: const TextStyle(
                                    color: AppColors.secondaryText,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  _formatDuration(audio.duration),
                                  style: const TextStyle(
                                    color: AppColors.secondaryText,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // --- 4. PLAYBACK CONTROLS (Shuffle - Prev - Play/Pause - Next - Repeat) ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Shuffle Button
                          IconButton(
                            icon: Icon(
                              Icons.shuffle,
                              color: audio.isShuffle
                                  ? AppColors.brightRed
                                  : AppColors.secondaryText,
                              size: 24,
                            ),
                            onPressed: () {
                              LiveItHaptics.light();
                              audio.toggleShuffle();
                            },
                          ),

                          // Previous Button
                          IconButton(
                            icon: const Icon(
                              Icons.skip_previous_rounded,
                              color: AppColors.primaryText,
                              size: 38,
                            ),
                            onPressed: () {
                              LiveItHaptics.light();
                              audio.previousSong();
                            },
                          ),

                          // Master Red Play / Pause Button with Loading Indicator
                          GestureDetector(
                            onTap: () {
                              LiveItHaptics.light();
                              audio.togglePlayPause();
                            },
                            child: Container(
                              width: 68,
                              height: 68,
                              decoration: const BoxDecoration(
                                color: AppColors.brightRed,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.redGlow,
                                    blurRadius: 18,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: (audio.isLoading || audio.isBuffering)
                                  ? const Center(
                                      child: SizedBox(
                                        width: 26,
                                        height: 26,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.8,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      audio.isPlaying
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                            ),
                          ),

                          // Next Button
                          IconButton(
                            icon: const Icon(
                              Icons.skip_next_rounded,
                              color: AppColors.primaryText,
                              size: 38,
                            ),
                            onPressed: () {
                              LiveItHaptics.light();
                              audio.nextSong();
                            },
                          ),

                          // Repeat Button
                          IconButton(
                            icon: Icon(
                              audio.repeatState == RepeatState.one
                                  ? Icons.repeat_one
                                  : Icons.repeat,
                              color: audio.repeatState != RepeatState.off
                                  ? AppColors.brightRed
                                  : AppColors.secondaryText,
                              size: 24,
                            ),
                            onPressed: () {
                              LiveItHaptics.light();
                              audio.toggleRepeat();
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // --- 5. BOTTOM ACTIONS (Favorite - Lyrics - Queue) ---
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          // Favorite Button
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                LiveItHaptics.selection();
                                audio.toggleFavorite(song);
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    audio.isSongFavorite(song.id)
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: audio.isSongFavorite(song.id)
                                        ? AppColors.brightRed
                                        : AppColors.secondaryText,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Favorite',
                                    style: TextStyle(
                                      color: audio.isSongFavorite(song.id)
                                          ? AppColors.brightRed
                                          : AppColors.secondaryText,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Lyrics Button
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                LiveItHaptics.selection();
                                Navigator.of(context).push(
                                  LiveItPageRoute(child: const LyricsScreen()),
                                );
                              },
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.subtitles_outlined,
                                    color: AppColors.secondaryText,
                                    size: 24,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Lyrics',
                                    style: TextStyle(
                                      color: AppColors.secondaryText,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Queue Button
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                LiveItHaptics.selection();
                                Navigator.of(context).push(
                                  LiveItPageRoute(child: const QueueScreen()),
                                );
                              },
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.queue_music,
                                    color: AppColors.secondaryText,
                                    size: 24,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Queue',
                                    style: TextStyle(
                                      color: AppColors.secondaryText,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
