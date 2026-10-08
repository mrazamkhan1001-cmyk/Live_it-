import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/mini_player.dart';
import '../widgets/song_card.dart';
import '../models/playlist.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';
import 'playlist_screen.dart';
import 'album_screen.dart';
import 'artist_screen.dart';
import 'recently_played_screen.dart';
import 'queue_screen.dart';

/// Fully Expanded Music Discovery Dashboard (HomeScreen)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  String _selectedCategory = 'For You';

  final List<String> _categories = [
    'For You',
    'Anime',
    'Chill',
    'Rap',
    'Lo-fi',
    'Trending',
    'Bollywood',
    'Hollywood'
  ];

  final List<Map<String, String>> _popularArtists = [
    {
      'name': 'Audius Lo-Fi',
      'image': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500',
    },
    {
      'name': 'Naruto Beats',
      'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500',
    },
    {
      'name': 'Sharingan Ninja',
      'image': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500',
    },
    {
      'name': 'Konoha Vibes',
      'image': 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=500',
    },
    {
      'name': 'Glass Animals',
      'image': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=500',
    },
    {
      'name': 'The Living Tombstone',
      'image': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=500',
    },
  ];

  final List<Map<String, String>> _trendingAlbums = [
    {
      'title': 'Arcane Soundtrack',
      'artist': 'Various Artists',
      'image': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500',
    },
    {
      'title': 'Sharingan Beats',
      'artist': 'Uchiha Clan',
      'image': 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=500',
    },
    {
      'title': 'Lo-Fi Chill Hop',
      'artist': 'Konoha Records',
      'image': 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500',
    },
    {
      'title': 'Uchiha Chronicles',
      'artist': 'Azam Khan',
      'image': 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500',
    },
  ];

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    if (_currentNavIndex == 1) return const SearchScreen();
    if (_currentNavIndex == 2) return const LibraryScreen();
    if (_currentNavIndex == 3) return const ProfileScreen();

    return Consumer<AudioPlayerService>(
      builder: (context, audio, child) {
        final trendingSongs = audio.queue;
        final recentSongs = audio.recentlyPlayed;
        final userName = audio.uchihaUserName;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. TOP HEADER (Menu left, LIVE IT logo center, Bell right)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.menu_rounded, color: AppColors.primaryText, size: 24),
                              onPressed: () {},
                            ),
                            Column(
                              children: const [
                                Text(
                                  'LIVE IT',
                                  style: TextStyle(
                                    color: AppColors.primaryText,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                  ),
                                ),
                                SizedBox(height: 1),
                                Text(
                                  'BY AZAM KHAN',
                                  style: TextStyle(
                                    color: AppColors.brightRed,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            Stack(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.notifications_none_rounded, color: AppColors.primaryText, size: 24),
                                  onPressed: () {},
                                ),
                                Positioned(
                                  right: 12,
                                  top: 12,
                                  child: Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: AppColors.brightRed,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // GREETING TEXT
                        Text(
                          '${_getGreeting()}, $userName',
                          style: const TextStyle(
                            color: AppColors.primaryText,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // 2. SEARCH BAR INPUT
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentNavIndex = 1;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.divider, width: 1),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.search_rounded, color: AppColors.secondaryText, size: 20),
                                SizedBox(width: 10),
                                Text(
                                  'Search songs, artists, albums...',
                                  style: TextStyle(
                                    color: AppColors.secondaryText,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 3. CATEGORIES HORIZONTALLY SCROLLABLE CHIPS
                        SizedBox(
                          height: 36,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final cat = _categories[index];
                              final isSelected = cat == _selectedCategory;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedCategory = cat),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.brightRed : AppColors.card,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: isSelected ? AppColors.brightRed : AppColors.divider,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    cat,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 4. FEATURED HERO CARD
                        GestureDetector(
                          onTap: () {
                            final playlist = Playlist(
                              id: 'featured_uchiha',
                              title: 'Uchiha Vibes',
                              description: 'Songs for the ones who understand...',
                              coverUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=500',
                              songs: trendingSongs,
                            );
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => PlaylistScreen(playlist: playlist)),
                            );
                          },
                          child: Container(
                            height: 160,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.brightRed.withValues(alpha: 0.5), width: 1),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.redGlow,
                                  blurRadius: 16,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.asset(
                                      'assets/images/live_it_loading.png',
                                      fit: BoxFit.cover,
                                      filterQuality: FilterQuality.high,
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.black.withValues(alpha: 0.2),
                                            Colors.black.withValues(alpha: 0.85),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 16,
                                    left: 16,
                                    right: 16,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: const [
                                            Text(
                                              'Uchiha Vibes',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Music for the ones who understand...',
                                              style: TextStyle(
                                                color: AppColors.secondaryText,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: const BoxDecoration(
                                            color: AppColors.brightRed,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.redGlow,
                                                blurRadius: 12,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.play_arrow_rounded,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // 5. RECENTLY PLAYED
                        _buildSectionHeader(
                          title: 'Recently Played',
                          onSeeAll: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RecentlyPlayedScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        recentSongs.isEmpty
                            ? Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.divider, width: 1),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.history_rounded, color: AppColors.secondaryText, size: 20),
                                    SizedBox(width: 12),
                                    Text(
                                      'No recently played songs yet',
                                      style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
                                    ),
                                  ],
                                ),
                              )
                            : SizedBox(
                                height: 155,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: recentSongs.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                                  itemBuilder: (context, index) {
                                    final song = recentSongs[index];
                                    return GestureDetector(
                                      onTap: () => audio.playSong(song, queueList: recentSongs, index: index),
                                      child: SizedBox(
                                        width: 110,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: Image.network(
                                                song.artworkUrl,
                                                width: 110,
                                                height: 110,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => Container(
                                                  width: 110,
                                                  height: 110,
                                                  color: AppColors.card,
                                                  child: const Icon(Icons.music_note, color: AppColors.brightRed),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              song.title,
                                              style: const TextStyle(
                                                color: AppColors.primaryText,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              song.artist,
                                              style: const TextStyle(
                                                color: AppColors.secondaryText,
                                                fontSize: 11,
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
                              ),
                        const SizedBox(height: 22),

                        // 6. TRENDING SONGS
                        _buildSectionHeader(
                          title: 'Trending Songs',
                          onSeeAll: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const QueueScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: trendingSongs.length > 6 ? 6 : trendingSongs.length,
                          itemBuilder: (context, index) {
                            final song = trendingSongs[index];
                            final isCurrent = audio.currentSong?.id == song.id;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: SongTile(
                                song: song,
                                indexNumber: index + 1,
                                isCurrent: isCurrent,
                                isPlaying: isCurrent && audio.isPlaying,
                                onTap: () => audio.playSong(song, queueList: trendingSongs, index: index),
                                onFavoriteTap: () => audio.toggleFavorite(song),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 22),

                        // 7. POPULAR ARTISTS
                        _buildSectionHeader(
                          title: 'Popular Artists',
                          onSeeAll: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SearchScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 115,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _popularArtists.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              final artist = _popularArtists[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ArtistScreen(artistName: artist['name']!),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      width: 72,
                                      height: 72,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.brightRed, width: 1.5),
                                        boxShadow: const [
                                          BoxShadow(color: AppColors.redGlow, blurRadius: 8),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: Image.network(
                                          artist['image']!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            color: AppColors.card,
                                            child: const Icon(Icons.person, color: AppColors.brightRed),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    SizedBox(
                                      width: 80,
                                      child: Text(
                                        artist['name']!,
                                        style: const TextStyle(
                                          color: AppColors.primaryText,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 22),

                        // 8. TRENDING ALBUMS
                        _buildSectionHeader(
                          title: 'Trending Albums',
                          onSeeAll: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const AlbumScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 160,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _trendingAlbums.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 14),
                            itemBuilder: (context, index) {
                              final album = _trendingAlbums[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => AlbumScreen(
                                        albumTitle: album['title']!,
                                        artistName: album['artist']!,
                                      ),
                                    ),
                                  );
                                },
                                child: SizedBox(
                                  width: 120,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          album['image']!,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            width: 120,
                                            height: 120,
                                            color: AppColors.card,
                                            child: const Icon(Icons.album, color: AppColors.brightRed),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        album['title']!,
                                        style: const TextStyle(
                                          color: AppColors.primaryText,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        album['artist']!,
                                        style: const TextStyle(
                                          color: AppColors.secondaryText,
                                          fontSize: 11,
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
                        ),
                        const SizedBox(height: 22),

                        // 9. RECOMMENDED FOR YOU
                        _buildSectionHeader(
                          title: 'Recommended For You',
                          onSeeAll: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const QueueScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: trendingSongs.length > 3 ? 3 : trendingSongs.length,
                          itemBuilder: (context, index) {
                            final song = trendingSongs[index];
                            final isCurrent = audio.currentSong?.id == song.id;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: SongTile(
                                song: song,
                                isCurrent: isCurrent,
                                isPlaying: isCurrent && audio.isPlaying,
                                onTap: () => audio.playSong(song, queueList: trendingSongs, index: index),
                                onFavoriteTap: () => audio.toggleFavorite(song),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 22),

                        // 10. NEW RELEASES
                        _buildSectionHeader(
                          title: 'New Releases',
                          onSeeAll: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const QueueScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 160,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: trendingSongs.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 14),
                            itemBuilder: (context, index) {
                              final song = trendingSongs[index];
                              return GestureDetector(
                                onTap: () => audio.playSong(song, queueList: trendingSongs, index: index),
                                child: SizedBox(
                                  width: 120,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          song.artworkUrl,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            width: 120,
                                            height: 120,
                                            color: AppColors.card,
                                            child: const Icon(Icons.music_note, color: AppColors.brightRed),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        song.title,
                                        style: const TextStyle(
                                          color: AppColors.primaryText,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        song.artist,
                                        style: const TextStyle(
                                          color: AppColors.secondaryText,
                                          fontSize: 11,
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
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),

                // Persistent Mini Player above Navigation
                const MiniPlayer(),

                // Shared Bottom Navigation
                CustomBottomNavigation(
                  currentIndex: _currentNavIndex,
                  onTap: (index) {
                    setState(() {
                      _currentNavIndex = index;
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader({required String title, required VoidCallback onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: const Text(
            'See All',
            style: TextStyle(
              color: AppColors.brightRed,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
