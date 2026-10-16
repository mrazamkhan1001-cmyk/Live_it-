import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/live_it_shimmer.dart';
import '../widgets/empty_state_view.dart';
import 'recently_played_screen.dart';
import 'queue_screen.dart';

/// Redesigned Home Screen for LIVE IT — BY AZAM
/// Matches the cinematic dark reference aesthetic with:
/// 1. Cinematic Itachi blood-moon anime hero artwork with LIVE IT branding.
/// 2. Horizontally scrollable Recently Played section.
/// 3. Vertically scrollable Trending Songs chart with ranking, artwork, favorite, and overflow menu.
/// Clean, single scrollable layout blending into #050505 black background.
class HomeScreen extends StatefulWidget {
  final void Function(int)? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (context, audio, child) {
        final trendingSongs = audio.queue;
        final recentSongs = audio.recentlyPlayed;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: RefreshIndicator(
            onRefresh: () async {
              await audio.refreshTrending(forceRefresh: true);
            },
            color: AppColors.brightRed,
            backgroundColor: AppColors.card,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. HERO ARTWORK WITH LIVE IT BRANDING
                  _buildHeroHeader(context),

                  const SizedBox(height: 14),

                  // 2. RECENTLY PLAYED SECTION
                  _buildSectionHeader(
                    title: 'Recently Played',
                    onSeeAll: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RecentlyPlayedScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildRecentlyPlayedList(context, audio, recentSongs),

                  const SizedBox(height: 24),

                  // 3. TRENDING SONGS SECTION
                  _buildSectionHeader(
                    title: 'Trending Songs',
                    onSeeAll: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const QueueScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTrendingSongsList(context, audio, trendingSongs),

                  // Clearance for persistent MiniPlayer and Bottom Navigation
                  const SizedBox(height: 110),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Cinematic Itachi blood-moon hero header with LIVE IT branding
  Widget _buildHeroHeader(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;
    final heroHeight = (screenHeight * 0.38).clamp(320.0, 390.0);

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Cinematic Itachi Blood Moon Artwork
          Image.asset(
            'assets/images/itachi_library_bg.png',
            fit: BoxFit.cover,
            alignment: const Alignment(0.12, -0.60),
            filterQuality: FilterQuality.high,
            errorBuilder: (_, __, ___) => Image.asset(
              'assets/images/itachi_face_bg.png',
              fit: BoxFit.cover,
              alignment: const Alignment(0.12, -0.60),
            ),
          ),

          // 2. Smooth Gradient Overlay blending into #050505 black
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.18),
                  Colors.transparent,
                  Colors.transparent,
                  const Color(0xFF050505).withValues(alpha: 0.45),
                  const Color(0xFF050505).withValues(alpha: 0.85),
                  const Color(0xFF050505),
                ],
                stops: const [0.0, 0.18, 0.55, 0.78, 0.92, 1.0],
              ),
            ),
          ),

          // 3. LIVE IT Branding in Upper-Left Corner
          Positioned(
            top: topPadding + 10,
            left: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/live_it_logo.png',
                  width: 175,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, __, ___) => const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'LIVE ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                      Text(
                        'IT',
                        style: TextStyle(
                          color: AppColors.brightRed,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text(
                    'BY AZAM KHAN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Section Header with White Title and Red "See All >" Action
  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primaryText,
              fontSize: 19,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
          InkWell(
            onTap: onSeeAll,
            borderRadius: BorderRadius.circular(6),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'See All',
                    style: TextStyle(
                      color: AppColors.brightRed,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.brightRed,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Horizontally scrollable Recently Played Cards
  Widget _buildRecentlyPlayedList(
    BuildContext context,
    AudioPlayerService audio,
    List<Song> recentSongs,
  ) {
    if (recentSongs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppRadii.r12,
            border: Border.all(color: AppColors.divider, width: 1),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history_rounded,
                color: AppColors.secondaryText,
                size: 20,
              ),
              SizedBox(width: 10),
              Text(
                'No recently played tracks yet',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 185,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: recentSongs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final song = recentSongs[index];

          return GestureDetector(
            onTap: () {
              LiveItHaptics.light();
              audio.playSong(
                song,
                queueList: recentSongs,
                index: index,
              );
            },
            child: SizedBox(
              width: 125,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      song.artworkUrl,
                      width: 125,
                      height: 125,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 125,
                        height: 125,
                        color: AppColors.card,
                        child: const Icon(
                          Icons.music_note,
                          color: AppColors.brightRed,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    song.title,
                    style: const TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.artist,
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 11.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Vertically list Trending Songs with Rank, Artwork, Title, Artist, Favorite, and 3-dots
  Widget _buildTrendingSongsList(
    BuildContext context,
    AudioPlayerService audio,
    List<Song> trendingSongs,
  ) {
    if (audio.isLoading && trendingSongs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            SongTileSkeleton(showLeadingNumber: true),
            SongTileSkeleton(showLeadingNumber: true),
            SongTileSkeleton(showLeadingNumber: true),
            SongTileSkeleton(showLeadingNumber: true),
            SongTileSkeleton(showLeadingNumber: true),
          ],
        ),
      );
    }

    if (trendingSongs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: EmptyStateView(
          icon: Icons.music_off_rounded,
          title: 'No Trending Songs Loaded',
          description:
              'Unable to connect to Audius discovery nodes. Please check your network.',
          actionLabel: 'REFRESH',
          actionIcon: Icons.refresh_rounded,
          onAction: () => audio.refreshTrending(forceRefresh: true),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: trendingSongs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 6),
        itemBuilder: (context, index) {
          final song = trendingSongs[index];
          final isCurrent = audio.currentSong?.id == song.id;
          final isPlaying = isCurrent && audio.isPlaying;
          final isFav = audio.isSongFavorite(song.id);

          return _buildTrendingTrackRow(
            context: context,
            audio: audio,
            song: song,
            rank: index + 1,
            isCurrent: isCurrent,
            isPlaying: isPlaying,
            isFav: isFav,
            trendingSongs: trendingSongs,
            index: index,
          );
        },
      ),
    );
  }

  /// Individual Trending Song Row matching the reference layout
  Widget _buildTrendingTrackRow({
    required BuildContext context,
    required AudioPlayerService audio,
    required Song song,
    required int rank,
    required bool isCurrent,
    required bool isPlaying,
    required bool isFav,
    required List<Song> trendingSongs,
    required int index,
  }) {
    return InkWell(
      onTap: () {
        LiveItHaptics.light();
        audio.playSong(
          song,
          queueList: trendingSongs,
          index: index,
        );
      },
      borderRadius: AppRadii.r8,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            // 1. Track Ranking Number
            SizedBox(
              width: 24,
              child: Text(
                '$rank',
                style: TextStyle(
                  color: isCurrent
                      ? AppColors.brightRed
                      : AppColors.primaryText,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 12),

            // 2. Small Square Album Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(
                    song.artworkUrl,
                    width: 46,
                    height: 46,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 46,
                      height: 46,
                      color: AppColors.card,
                      child: const Icon(
                        Icons.music_note,
                        color: AppColors.brightRed,
                        size: 22,
                      ),
                    ),
                  ),
                  if (isCurrent)
                    Container(
                      width: 46,
                      height: 46,
                      color: Colors.black54,
                      child: Icon(
                        isPlaying ? Icons.equalizer : Icons.play_arrow,
                        color: AppColors.brightRed,
                        size: 22,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // 3. Song Title & Artist
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    song.title,
                    style: TextStyle(
                      color: isCurrent
                          ? AppColors.brightRed
                          : AppColors.primaryText,
                      fontSize: 14.5,
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    song.artist,
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

            // 4. Favorite Heart Button
            IconButton(
              icon: Icon(
                isFav
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: isFav ? AppColors.brightRed : AppColors.secondaryText,
                size: 20,
              ),
              onPressed: () {
                LiveItHaptics.selection();
                audio.toggleFavorite(song);
              },
            ),

            // 5. Three-dot Overflow Menu
            IconButton(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: AppColors.secondaryText,
                size: 20,
              ),
              onPressed: () {
                LiveItHaptics.selection();
                _showSongOptionsModal(context, audio, song, trendingSongs);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Song Options Overflow Bottom Sheet Modal
  void _showSongOptionsModal(
    BuildContext context,
    AudioPlayerService audio,
    Song song,
    List<Song> currentQueue,
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
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),

                // Song Header Preview
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        song.artworkUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 50,
                          height: 50,
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

                // Play Now
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
                    audio.playSong(song, queueList: currentQueue);
                  },
                ),

                // Liked Songs Toggle
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

                // Add to Queue
                ListTile(
                  leading: const Icon(
                    Icons.queue_music_rounded,
                    color: AppColors.brightRed,
                  ),
                  title: const Text(
                    'Add to Queue',
                    style: TextStyle(color: AppColors.primaryText),
                  ),
                  onTap: () {
                    audio.addToQueue(song);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added "${song.title}" to queue'),
                        backgroundColor: AppColors.card,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),

                // Add to Playlist
                ListTile(
                  leading: const Icon(
                    Icons.playlist_add_rounded,
                    color: AppColors.brightRed,
                  ),
                  title: const Text(
                    'Add to Playlist',
                    style: TextStyle(color: AppColors.primaryText),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showAddToPlaylistSheet(context, audio, song);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Playlist Selector Bottom Sheet
  void _showAddToPlaylistSheet(
    BuildContext context,
    AudioPlayerService audio,
    Song song,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final playlists = audio.playlists;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Add to Playlist',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (playlists.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'No custom playlists found in Library.',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                else
                  ...playlists.map((playlist) {
                    return ListTile(
                      leading: const Icon(
                        Icons.queue_music,
                        color: AppColors.brightRed,
                      ),
                      title: Text(
                        playlist.title,
                        style: const TextStyle(color: AppColors.primaryText),
                      ),
                      subtitle: Text(
                        '${playlist.songs.length} tracks',
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                      onTap: () {
                        audio.addSongToPlaylist(playlist.id, song);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Added to "${playlist.title}"',
                            ),
                            backgroundColor: AppColors.card,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }
}
