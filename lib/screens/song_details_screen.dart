import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import 'artist_screen.dart';
import 'album_screen.dart';
import 'lyrics_screen.dart';
import 'playlist_screen.dart';

/// Song Details Screen matching Section 9 & Mockup #7
class SongDetailsScreen extends StatelessWidget {
  final Song song;

  const SongDetailsScreen({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (context, audio, child) {
        final isFav = audio.isSongFavorite(song.id);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                children: [
                  // Large Artwork Box matching Mockup #7
                  Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.brightRed,
                        width: 1.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.redGlow,
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.network(
                        song.artworkUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.card,
                          child: const Icon(
                            Icons.music_note,
                            color: AppColors.brightRed,
                            size: 80,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Song Title & Artist
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
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Primary Action Buttons Row (Play, Shuffle, Like) matching Mockup #7
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Play Button
                      ElevatedButton.icon(
                        onPressed: () {
                          audio.playSong(song);
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Play',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brightRed,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Shuffle Button
                      OutlinedButton.icon(
                        onPressed: () {
                          audio.toggleShuffle();
                          audio.playSong(song);
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(
                          Icons.shuffle,
                          color: AppColors.primaryText,
                          size: 18,
                        ),
                        label: const Text(
                          'Shuffle',
                          style: TextStyle(color: AppColors.primaryText),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.card,
                          side: const BorderSide(color: AppColors.divider),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Heart Button
                      IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav
                              ? AppColors.brightRed
                              : AppColors.secondaryText,
                          size: 26,
                        ),
                        onPressed: () => audio.toggleFavorite(song),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Options Menu Items matching Section 9
                  _buildOptionTile(
                    icon: Icons.playlist_add,
                    title: 'Add to Playlist',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PlaylistScreen(),
                        ),
                      );
                    },
                  ),
                  _buildOptionTile(
                    icon: audio.isSongDownloaded(song.id)
                        ? Icons.download_done_rounded
                        : Icons.download_outlined,
                    title: audio.isSongDownloaded(song.id)
                        ? 'Downloaded (Offline Available)'
                        : 'Download Track',
                    onTap: () async {
                      if (audio.isSongDownloaded(song.id)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Track is already downloaded and available offline.',
                            ),
                            backgroundColor: AppColors.card,
                          ),
                        );
                        return;
                      }

                      if (!song.isDownloadable) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Track cannot be downloaded (provider permission restricted).',
                            ),
                            backgroundColor: AppColors.darkRed,
                          ),
                        );
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Downloading "${song.title}"...'),
                          backgroundColor: AppColors.card,
                        ),
                      );

                      final file = await audio.downloadSong(song);
                      if (file != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Downloaded "${song.title}" for offline playback!',
                            ),
                            backgroundColor: AppColors.brightRed,
                          ),
                        );
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Download failed or cancelled.'),
                            backgroundColor: AppColors.darkRed,
                          ),
                        );
                      }
                    },
                  ),
                  _buildOptionTile(
                    icon: Icons.subtitles_outlined,
                    title: 'View Lyrics',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LyricsScreen()),
                      );
                    },
                  ),
                  _buildOptionTile(
                    icon: Icons.person_outline,
                    title: 'Go to Artist',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ArtistScreen(artistName: song.artist),
                        ),
                      );
                    },
                  ),
                  _buildOptionTile(
                    icon: Icons.album_outlined,
                    title: 'Go to Album',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AlbumScreen(
                            albumTitle: song.album,
                            artistName: song.artist,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildOptionTile(
                    icon: Icons.share_outlined,
                    title: 'Share Track',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.brightRed, size: 22),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.primaryText,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: AppColors.secondaryText,
          size: 14,
        ),
        onTap: onTap,
      ),
    );
  }
}
