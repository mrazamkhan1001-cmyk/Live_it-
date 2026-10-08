import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import 'artist_screen.dart';

/// Phase 9: Playback Queue Screen
/// Provides real-time queue management with drag-and-drop reordering, track removal,
/// immediate selection playback, clear upcoming queue, and shared single-player engine synchronization.
class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  void _confirmClearUpcoming(BuildContext context, AudioPlayerService audio) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Clear Upcoming Queue',
            style: TextStyle(
              color: AppColors.primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to clear all upcoming songs? The currently playing track will continue uninterrupted.',
            style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.secondaryText),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brightRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                LiveItHaptics.medium();
                audio.clearUpcoming();
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cleared upcoming queue.'),
                    backgroundColor: AppColors.card,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text(
                'Clear',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showQueueTrackMenu(
    BuildContext context,
    Song song,
    int queueIndex,
    AudioPlayerService audio,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final isFav = audio.isSongFavorite(song.id);
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        song.artworkUrl,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 48,
                          height: 48,
                          color: AppColors.background,
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
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            song.artist,
                            style: const TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.divider, height: 1),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.brightRed,
                  ),
                  title: const Text(
                    'Play Now',
                    style: TextStyle(color: AppColors.primaryText),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    audio.playSong(song, index: queueIndex);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.playlist_remove_rounded,
                    color: AppColors.brightRed,
                  ),
                  title: const Text(
                    'Remove from Queue',
                    style: TextStyle(color: AppColors.primaryText),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    audio.removeFromQueue(queueIndex);
                  },
                ),
                ListTile(
                  leading: Icon(
                    isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: AppColors.brightRed,
                  ),
                  title: Text(
                    isFav ? 'Remove from Liked Songs' : 'Add to Liked Songs',
                    style: const TextStyle(color: AppColors.primaryText),
                  ),
                  onTap: () {
                    audio.toggleFavorite(song);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.brightRed,
                  ),
                  title: Text(
                    'View Artist (${song.artist})',
                    style: const TextStyle(color: AppColors.primaryText),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ArtistScreen(artistName: song.artist),
                      ),
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
        final queue = audio.queue;
        final currentIndex = audio.currentIndex;
        final currentSong = audio.currentSong;

        // Upcoming tracks start after currentIndex
        final upcomingSongs =
            (currentIndex >= 0 && currentIndex < queue.length - 1)
            ? queue.sublist(currentIndex + 1)
            : <Song>[];

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Playback Queue',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              if (upcomingSongs.isNotEmpty)
                TextButton.icon(
                  onPressed: () => _confirmClearUpcoming(context, audio),
                  icon: const Icon(
                    Icons.delete_sweep_rounded,
                    color: AppColors.brightRed,
                    size: 18,
                  ),
                  label: const Text(
                    'Clear',
                    style: TextStyle(
                      color: AppColors.brightRed,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: 90,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. NOW PLAYING SECTION
                  const Text(
                    'NOW PLAYING',
                    style: TextStyle(
                      color: AppColors.brightRed,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (currentSong == null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: const Center(
                        child: Text(
                          'No active song currently playing.',
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.brightRed.withValues(alpha: 0.7),
                          width: 1.2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.redGlow,
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  currentSong.artworkUrl,
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 52,
                                    height: 52,
                                    color: AppColors.background,
                                    child: const Icon(
                                      Icons.music_note,
                                      color: AppColors.brightRed,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  audio.isPlaying
                                      ? Icons.equalizer
                                      : Icons.pause_rounded,
                                  color: AppColors.brightRed,
                                  size: 26,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentSong.title,
                                  style: const TextStyle(
                                    color: AppColors.primaryText,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  currentSong.artist,
                                  style: const TextStyle(
                                    color: AppColors.secondaryText,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              audio.isPlaying
                                  ? Icons.pause_circle_filled_rounded
                                  : Icons.play_circle_fill_rounded,
                              color: AppColors.brightRed,
                              size: 32,
                            ),
                            onPressed: () => audio.togglePlayPause(),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // 2. UP NEXT SECTION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'UP NEXT',
                            style: TextStyle(
                              color: AppColors.primaryText,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: Text(
                              '${upcomingSongs.length}',
                              style: const TextStyle(
                                color: AppColors.brightRed,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (upcomingSongs.isNotEmpty)
                        const Text(
                          'Drag to Reorder',
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (upcomingSongs.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 36,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.queue_music_rounded,
                            color: AppColors.secondaryText,
                            size: 42,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No upcoming tracks in queue',
                            style: TextStyle(
                              color: AppColors.primaryText,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Search tracks or add songs from Home to expand your queue.',
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: upcomingSongs.length,
                      onReorderItem: (oldIdx, newIdx) {
                        final absoluteOld = currentIndex + 1 + oldIdx;
                        final absoluteNew = currentIndex + 1 + newIdx;
                        audio.reorderQueue(absoluteOld, absoluteNew);
                      },
                      itemBuilder: (context, index) {
                        final song = upcomingSongs[index];
                        final absoluteIndex = currentIndex + 1 + index;

                        return Container(
                          key: ValueKey('queue_${song.id}_$absoluteIndex'),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.divider,
                              width: 1,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 2,
                              ),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  song.artworkUrl,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 44,
                                    height: 44,
                                    color: AppColors.background,
                                    child: const Icon(
                                      Icons.music_note,
                                      color: AppColors.brightRed,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                song.title,
                                style: const TextStyle(
                                  color: AppColors.primaryText,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                song.artist,
                                style: const TextStyle(
                                  color: AppColors.secondaryText,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.play_circle_outline_rounded,
                                      color: AppColors.brightRed,
                                      size: 24,
                                    ),
                                    onPressed: () => audio.playSong(
                                      song,
                                      index: absoluteIndex,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.more_vert_rounded,
                                      color: AppColors.secondaryText,
                                      size: 18,
                                    ),
                                    onPressed: () => _showQueueTrackMenu(
                                      context,
                                      song,
                                      absoluteIndex,
                                      audio,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.drag_handle_rounded,
                                    color: AppColors.secondaryText,
                                    size: 20,
                                  ),
                                ],
                              ),
                              onTap: () =>
                                  audio.playSong(song, index: absoluteIndex),
                            ),
                          ),
                        );
                      },
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
