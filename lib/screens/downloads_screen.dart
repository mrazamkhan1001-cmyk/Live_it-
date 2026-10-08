import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../services/audio_service.dart';
import '../services/download_service.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state_view.dart';
import 'lyrics_screen.dart';
import 'playlist_screen.dart';

/// Phase 10: Downloads & Offline Playback Screen
/// Displays verified local audio tracks with storage metrics, active download progress,
/// cancellation, deletion, and seamless local file playback via shared AudioPlayerService.
class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  int _storageBytes = 0;
  bool _isLoadingStorage = true;

  @override
  void initState() {
    super.initState();
    _refreshStorageUsage();
  }

  Future<void> _refreshStorageUsage() async {
    final bytes = await DownloadService.getTotalDownloadSizeBytes();
    if (mounted) {
      setState(() {
        _storageBytes = bytes;
        _isLoadingStorage = false;
      });
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _confirmClearAllDownloads(AudioPlayerService audio) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.divider),
        ),
        title: const Text(
          'Clear All Downloads?',
          style: TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'This will permanently delete all offline audio files from your device.',
          style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
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
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await audio.clearAllDownloads();
              await _refreshStorageUsage();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All downloaded tracks cleared'),
                    backgroundColor: AppColors.brightRed,
                  ),
                );
              }
            },
            child: const Text('CLEAR ALL'),
          ),
        ],
      ),
    );
  }

  void _showTrackOptions(Song song, AudioPlayerService audio) {
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
                    Icons.play_circle_fill,
                    color: AppColors.brightRed,
                  ),
                  title: const Text(
                    'Play Offline',
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
                    audio.playSong(song, queueList: audio.downloadedSongs);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.playlist_add,
                    color: AppColors.brightRed,
                  ),
                  title: const Text(
                    'Add to Playlist',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PlaylistScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.subtitles_outlined,
                    color: AppColors.brightRed,
                  ),
                  title: const Text(
                    'View Lyrics',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LyricsScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  title: const Text(
                    'Remove Download',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Delete local file from device',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await audio.deleteDownload(song.id);
                    await _refreshStorageUsage();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Removed "${song.title}" from downloads',
                          ),
                          backgroundColor: AppColors.card,
                        ),
                      );
                    }
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
        final downloadedSongs = audio.downloadedSongs;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Downloads',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!_isLoadingStorage)
                  Text(
                    '${downloadedSongs.length} ${downloadedSongs.length == 1 ? "track" : "tracks"} • ${_formatBytes(_storageBytes)} stored',
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            actions: [
              if (downloadedSongs.isNotEmpty)
                IconButton(
                  icon: const Icon(
                    Icons.delete_sweep_outlined,
                    color: AppColors.secondaryText,
                  ),
                  tooltip: 'Clear All Downloads',
                  onPressed: () => _confirmClearAllDownloads(audio),
                ),
            ],
          ),
          body: SafeArea(
            child: downloadedSongs.isEmpty
                ? _buildEmptyState(context)
                : RefreshIndicator(
                    color: AppColors.brightRed,
                    backgroundColor: AppColors.card,
                    onRefresh: () async {
                      await DownloadService.init();
                      await _refreshStorageUsage();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 100),
                      itemCount: downloadedSongs.length,
                      itemBuilder: (context, index) {
                        final song = downloadedSongs[index];
                        final isCurrent = audio.currentSong?.id == song.id;
                        final isPlaying = isCurrent && audio.isPlaying;
                        final status = audio.getDownloadStatus(song.id);
                        final progress = audio.getDownloadProgress(song.id);

                        return _buildSongTile(
                          context: context,
                          song: song,
                          index: index + 1,
                          isCurrent: isCurrent,
                          isPlaying: isPlaying,
                          status: status,
                          progress: progress,
                          audio: audio,
                          onTap: () => audio.playSong(
                            song,
                            queueList: downloadedSongs,
                            index: index,
                          ),
                          onOptionsTap: () => _showTrackOptions(song, audio),
                        );
                      },
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return EmptyStateView(
      icon: Icons.download_done_rounded,
      title: 'No Downloaded Tracks',
      description: 'Download tracks that permit offline listening to enjoy your music without an internet connection.',
      actionLabel: 'EXPLORE MUSIC',
      actionIcon: Icons.explore_outlined,
      onAction: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildSongTile({
    required BuildContext context,
    required Song song,
    required int index,
    required bool isCurrent,
    required bool isPlaying,
    required DownloadStatus status,
    required double progress,
    required AudioPlayerService audio,
    required VoidCallback onTap,
    required VoidCallback onOptionsTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.darkRed.withValues(alpha: 0.25)
            : AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent
              ? AppColors.brightRed.withValues(alpha: 0.5)
              : AppColors.divider.withValues(alpha: 0.5),
          width: isCurrent ? 1.2 : 0.8,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              child: Text(
                '$index',
                style: TextStyle(
                  color: isCurrent
                      ? AppColors.brightRed
                      : AppColors.secondaryText,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 10),
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    song.artworkUrl,
                    width: 46,
                    height: 46,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 46,
                      height: 46,
                      color: AppColors.background,
                      child: const Icon(
                        Icons.music_note,
                        color: AppColors.brightRed,
                      ),
                    ),
                  ),
                ),
                if (isCurrent)
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isPlaying ? Icons.equalizer : Icons.play_arrow,
                      color: AppColors.brightRed,
                      size: 26,
                    ),
                  ),
              ],
            ),
          ],
        ),
        title: Text(
          song.title,
          style: TextStyle(
            color: isCurrent ? AppColors.brightRed : AppColors.primaryText,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
            fontSize: 15,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: AppColors.darkRed.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: AppColors.brightRed.withValues(alpha: 0.4),
                  width: 0.5,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.offline_pin, color: AppColors.brightRed, size: 10),
                  SizedBox(width: 3),
                  Text(
                    'OFFLINE',
                    style: TextStyle(
                      color: AppColors.brightRed,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                song.artist,
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                audio.isSongFavorite(song.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: audio.isSongFavorite(song.id)
                    ? AppColors.brightRed
                    : AppColors.secondaryText,
                size: 20,
              ),
              onPressed: () => audio.toggleFavorite(song),
            ),
            IconButton(
              icon: const Icon(
                Icons.more_vert,
                color: AppColors.secondaryText,
                size: 20,
              ),
              onPressed: onOptionsTap,
            ),
          ],
        ),
      ),
    );
  }
}
