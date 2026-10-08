import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/sharingan_player.dart';
import 'equalizer_screen.dart';
import 'lyrics_screen.dart';
import 'queue_screen.dart';
import 'player_details_screen.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  double _dragDx = 0;

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (context, audio, child) {
        final song = audio.currentSong;
        if (song == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Text('No song selected', style: TextStyle(color: AppColors.primaryText)),
            ),
          );
        }

        final double progress = audio.duration.inMilliseconds > 0
            ? (audio.position.inMilliseconds / audio.duration.inMilliseconds).clamp(0.0, 1.0)
            : 0.0;
        final double sharinganSize = (MediaQuery.of(context).size.width * 0.70).clamp(280.0, 310.0);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: GestureDetector(
            behavior: HitTestBehavior.translucent,
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

              if (dx > 40 || velocity > 150) {
                // SWIPE RIGHT (Finger moves LEFT -> RIGHT): Next Song
                audio.nextSong();
              } else if (dx < -40 || velocity < -150) {
                // SWIPE LEFT (Finger moves RIGHT -> LEFT): Previous Song
                audio.previousSong();
              }
            },
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                // Top Header Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryText, size: 32),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Column(
                        children: [
                          const Text(
                            'PLAYING FROM',
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 10,
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            song.album.isNotEmpty ? song.album.toUpperCase() : 'UCHIHA VIBES',
                            style: const TextStyle(
                              color: AppColors.primaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: AppColors.primaryText, size: 24),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const PlayerDetailsScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Center Sharingan Video Visualizer (15-25% larger, responsive)
                SharinganPlayer(
                  isPlaying: audio.isPlaying,
                  size: sharinganSize,
                ),

                const Spacer(),

                // Song Title & Artist + Favorite Heart Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              style: const TextStyle(
                                color: AppColors.primaryText,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              song.artist,
                              style: const TextStyle(
                                color: AppColors.secondaryText,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          audio.isSongFavorite(song.id) ? Icons.favorite : Icons.favorite_border,
                          color: audio.isSongFavorite(song.id) ? AppColors.brightRed : AppColors.secondaryText,
                          size: 28,
                        ),
                        onPressed: () => audio.toggleFavorite(song),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Interactive Progress Slider Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                          activeTrackColor: AppColors.brightRed,
                          inactiveTrackColor: AppColors.divider,
                          thumbColor: AppColors.brightRed,
                          overlayColor: AppColors.redGlow,
                        ),
                        child: Slider(
                          value: progress,
                          onChanged: (val) {
                            final targetMs = (val * audio.duration.inMilliseconds).toInt();
                            audio.seek(Duration(milliseconds: targetMs));
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(audio.position),
                              style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
                            ),
                            Text(
                              _formatDuration(audio.duration),
                              style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Playback Control Buttons Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Shuffle Button
                      IconButton(
                        icon: Icon(
                          Icons.shuffle,
                          color: audio.isShuffle ? AppColors.brightRed : AppColors.secondaryText,
                          size: 22,
                        ),
                        onPressed: () => audio.toggleShuffle(),
                      ),

                      // Previous Button
                      IconButton(
                        icon: const Icon(
                          Icons.skip_previous_rounded,
                          color: AppColors.primaryText,
                          size: 38,
                        ),
                        onPressed: () => audio.previousSong(),
                      ),

                      // Red Play / Pause Master Button
                      GestureDetector(
                        onTap: () => audio.togglePlayPause(),
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: const BoxDecoration(
                            color: AppColors.brightRed,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.redGlow,
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            audio.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
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
                        onPressed: () => audio.nextSong(),
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
                          size: 22,
                        ),
                        onPressed: () => audio.toggleRepeat(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Bottom Action Tools Bar (Equalizer, Lyrics, Queue)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Equalizer Button
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const EqualizerScreen()),
                            );
                          },
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.graphic_eq, color: AppColors.secondaryText, size: 22),
                              SizedBox(height: 4),
                              Text('Equalizer', style: TextStyle(color: AppColors.secondaryText, fontSize: 11)),
                            ],
                          ),
                        ),
                      ),

                      // Lyrics Button
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const LyricsScreen()),
                            );
                          },
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.subtitles_outlined, color: AppColors.secondaryText, size: 22),
                              SizedBox(height: 4),
                              Text('Lyrics', style: TextStyle(color: AppColors.secondaryText, fontSize: 11)),
                            ],
                          ),
                        ),
                      ),

                      // Queue Button
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const QueueScreen()),
                            );
                          },
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.queue_music, color: AppColors.secondaryText, size: 22),
                              SizedBox(height: 4),
                              Text('Queue', style: TextStyle(color: AppColors.secondaryText, fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      },
    );
  }
}
