import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../models/playlist.dart';
import '../services/audio_service.dart';
import '../services/audius_service.dart';
import '../theme/app_theme.dart';
import '../widgets/song_card.dart';
import '../widgets/live_it_shimmer.dart';
import '../widgets/empty_state_view.dart';
import 'playlist_screen.dart';
import 'album_screen.dart';
import 'artist_screen.dart';
import 'recently_played_screen.dart';
import 'queue_screen.dart';
import 'equalizer_screen.dart';
import 'favorites_screen.dart';
import 'downloads_screen.dart';
import 'settings_screen.dart';
import 'about_screen.dart';

/// Phase 7: Fully Expanded Music Discovery Dashboard (HomeScreen)
/// Builds a rich, dynamic streaming experience with real Audius data,
/// category filtering, personalized recommendations, and single-player playback.
class HomeScreen extends StatefulWidget {
  final void Function(int)? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'For You';
  bool _isLoadingCategory = false;
  final Map<String, List<Song>> _categoryCache = {};

  final List<String> _categories = [
    'For You',
    'Anime',
    'Chill',
    'Rap',
    'Lo-fi',
    'Trending',
    'Bollywood',
    'Hollywood',
    'Rock',
    'Electronic',
  ];

  final List<Map<String, String>> _popularArtists = [
    {
      'name': 'Audius Lo-Fi',
      'image':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500',
    },
    {
      'name': 'Naruto Beats',
      'image':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500',
    },
    {
      'name': 'Sharingan Ninja',
      'image':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500',
    },
    {
      'name': 'Konoha Vibes',
      'image':
          'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=500',
    },
    {
      'name': 'Glass Animals',
      'image':
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=500',
    },
    {
      'name': 'The Living Tombstone',
      'image':
          'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=500',
    },
  ];

  final List<Map<String, String>> _trendingAlbums = [
    {
      'title': 'Arcane Soundtrack',
      'artist': 'Various Artists',
      'image':
          'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500',
    },
    {
      'title': 'Sharingan Beats',
      'artist': 'Uchiha Clan',
      'image':
          'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=500',
    },
    {
      'title': 'Lo-Fi Chill Hop',
      'artist': 'Konoha Records',
      'image':
          'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500',
    },
    {
      'title': 'Uchiha Chronicles',
      'artist': 'Azam Khan',
      'image':
          'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500',
    },
  ];

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> _selectCategory(String category) async {
    if (_selectedCategory == category) return;
    setState(() {
      _selectedCategory = category;
    });

    if (category == 'For You' || category == 'Trending') {
      return;
    }

    if (!_categoryCache.containsKey(category)) {
      setState(() {
        _isLoadingCategory = true;
      });

      try {
        String query = category;
        if (category == 'Anime') query = 'Anime Naruto OST';
        if (category == 'Chill') query = 'Chill Lo-Fi Chillhop';
        if (category == 'Rap') query = 'Hip-Hop Rap Beats';
        if (category == 'Lo-fi') query = 'Lofi Beats Lo-Fi';
        if (category == 'Bollywood') query = 'Bollywood Hindi';
        if (category == 'Hollywood') query = 'Pop Hits Hollywood';
        if (category == 'Rock') query = 'Rock Alternative';
        if (category == 'Electronic') query = 'EDM Electronic Dance';

        final tracks = await AudiusService.searchTracks(query, limit: 15);
        if (mounted) {
          setState(() {
            _categoryCache[category] = tracks;
            _isLoadingCategory = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _isLoadingCategory = false;
          });
        }
      }
    }
  }

  void _showQuickMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
                const Text(
                  'LIVE IT — QUICK MENU',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(
                    Icons.equalizer_rounded,
                    color: AppColors.brightRed,
                  ),
                  title: const Text(
                    'Audio Equalizer',
                    style: TextStyle(color: AppColors.primaryText),
                  ),
                  subtitle: const Text(
                    'Custom Uchiha frequency tuning',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.secondaryText,
                    size: 14,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const EqualizerScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.favorite_rounded,
                    color: AppColors.brightRed,
                  ),
                  title: const Text(
                    'Liked Songs',
                    style: TextStyle(color: AppColors.primaryText),
                  ),
                  subtitle: const Text(
                    'Your saved favorite tracks',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.secondaryText,
                    size: 14,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FavoritesScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.download_done_rounded,
                    color: AppColors.brightRed,
                  ),
                  title: const Text(
                    'Downloads',
                    style: TextStyle(color: AppColors.primaryText),
                  ),
                  subtitle: const Text(
                    'Offline music storage',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.secondaryText,
                    size: 14,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DownloadsScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.settings_rounded,
                    color: AppColors.brightRed,
                  ),
                  title: const Text(
                    'Settings',
                    style: TextStyle(color: AppColors.primaryText),
                  ),
                  subtitle: const Text(
                    'Preferences & Audio Quality',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.secondaryText,
                    size: 14,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.brightRed,
                  ),
                  title: const Text(
                    'About LIVE IT',
                    style: TextStyle(color: AppColors.primaryText),
                  ),
                  subtitle: const Text(
                    'Version & Uchiha credits',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.secondaryText,
                    size: 14,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
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

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
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
                const Row(
                  children: [
                    Icon(
                      Icons.notifications_active_rounded,
                      color: AppColors.brightRed,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Notifications',
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.cloud_done_rounded,
                        color: AppColors.brightRed,
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Audius Network Connected',
                              style: TextStyle(
                                color: AppColors.primaryText,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Streaming high-fidelity decentralized music catalog.',
                              style: TextStyle(
                                color: AppColors.secondaryText,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.whatshot_rounded,
                        color: AppColors.brightRed,
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trending Chart Updated',
                              style: TextStyle(
                                color: AppColors.primaryText,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Fresh anime beats & popular Audius releases are ready.',
                              style: TextStyle(
                                color: AppColors.secondaryText,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
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

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (context, audio, child) {
        final trendingSongs = audio.queue;
        final recentSongs = audio.recentlyPlayed;
        final userName = audio.uchihaUserName;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await audio.refreshTrending(forceRefresh: true);
                if (_selectedCategory != 'For You') {
                  _categoryCache.remove(_selectedCategory);
                  await _selectCategory(_selectedCategory);
                }
              },
              color: AppColors.brightRed,
              backgroundColor: AppColors.card,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: 90,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. TOP HEADER (Menu left, LIVE IT logo center, Bell right)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.menu_rounded,
                            color: AppColors.primaryText,
                            size: 24,
                          ),
                          onPressed: () => _showQuickMenu(context),
                        ),
                        const Column(
                          children: [
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
                              icon: const Icon(
                                Icons.notifications_none_rounded,
                                color: AppColors.primaryText,
                                size: 24,
                              ),
                              onPressed: () => _showNotifications(context),
                            ),
                            Positioned(
                              right: 12,
                              top: 12,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.brightRed,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.redGlow,
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // 2. TIME-AWARE GREETING TEXT
                    Text(
                      '${_getGreeting()}, $userName',
                      style: const TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 3. SEARCH BAR INPUT
                    GestureDetector(
                      onTap: () {
                        widget.onNavigateToTab?.call(1);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.divider,
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.search_rounded,
                              color: AppColors.secondaryText,
                              size: 20,
                            ),
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

                    // 4. CATEGORIES HORIZONTALLY SCROLLABLE CHIPS
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          final isSelected = cat == _selectedCategory;
                          return GestureDetector(
                            onTap: () => _selectCategory(cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.brightRed
                                    : AppColors.card,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.brightRed
                                      : AppColors.divider,
                                  width: 1,
                                ),
                                boxShadow: isSelected
                                    ? const [
                                        BoxShadow(
                                          color: AppColors.redGlow,
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // DISPLAY CONDITIONAL CONTENT: Category Feed OR Full Discovery Feed
                    if (_selectedCategory != 'For You')
                      _buildCategoryFeed(context, audio)
                    else ...[
                      // 5. FEATURED HERO CARD
                      GestureDetector(
                        onTap: () {
                          final playlist = Playlist(
                            id: 'featured_uchiha',
                            title: 'Uchiha Vibes',
                            description: 'Music for the ones who understand...',
                            coverUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=500',
                            songs: trendingSongs,
                          );
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  PlaylistScreen(playlist: playlist),
                            ),
                          );
                        },
                        child: Container(
                          height: 165,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.brightRed.withValues(alpha: 0.6),
                              width: 1.2,
                            ),
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
                                          Colors.black.withValues(alpha: 0.88),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Uchiha Vibes',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
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
                                      GestureDetector(
                                        onTap: () {
                                          if (trendingSongs.isNotEmpty) {
                                            audio.playSong(
                                              trendingSongs.first,
                                              queueList: trendingSongs,
                                              index: 0,
                                            );
                                          }
                                        },
                                        child: Container(
                                          width: 46,
                                          height: 46,
                                          decoration: const BoxDecoration(
                                            color: AppColors.brightRed,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.redGlow,
                                                blurRadius: 14,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.play_arrow_rounded,
                                            color: Colors.white,
                                            size: 30,
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
                      ),
                      const SizedBox(height: 24),

                      // 6. RECENTLY PLAYED
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
                      recentSongs.isEmpty
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.divider,
                                  width: 1,
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.history_rounded,
                                    color: AppColors.secondaryText,
                                    size: 22,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'No recently played songs yet',
                                    style: TextStyle(
                                      color: AppColors.secondaryText,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox(
                              height: 160,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: recentSongs.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  final song = recentSongs[index];
                                  return GestureDetector(
                                    onTap: () => audio.playSong(
                                      song,
                                      queueList: recentSongs,
                                      index: index,
                                    ),
                                    child: SizedBox(
                                      width: 110,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Image.network(
                                              song.artworkUrl,
                                              width: 110,
                                              height: 110,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Container(
                                                    width: 110,
                                                    height: 110,
                                                    color: AppColors.card,
                                                    child: const Icon(
                                                      Icons.music_note,
                                                      color:
                                                          AppColors.brightRed,
                                                    ),
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
                      const SizedBox(height: 24),

                      // 7. TRENDING NOW / TRENDING SONGS
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
                      const SizedBox(height: 10),
                      trendingSongs.isEmpty
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 24,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.divider,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.music_off_rounded,
                                    color: AppColors.secondaryText,
                                    size: 28,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'No trending songs loaded.',
                                    style: TextStyle(
                                      color: AppColors.secondaryText,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextButton.icon(
                                    onPressed: () => audio.refreshTrending(
                                      forceRefresh: true,
                                    ),
                                    icon: const Icon(
                                      Icons.refresh,
                                      size: 16,
                                      color: AppColors.brightRed,
                                    ),
                                    label: const Text(
                                      'Refresh',
                                      style: TextStyle(
                                        color: AppColors.brightRed,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: trendingSongs.length > 6
                                  ? 6
                                  : trendingSongs.length,
                              itemBuilder: (context, index) {
                                final song = trendingSongs[index];
                                final isCurrent =
                                    audio.currentSong?.id == song.id;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: SongTile(
                                    song: song,
                                    indexNumber: index + 1,
                                    isCurrent: isCurrent,
                                    isPlaying: isCurrent && audio.isPlaying,
                                    onTap: () => audio.playSong(
                                      song,
                                      queueList: trendingSongs,
                                      index: index,
                                    ),
                                    onFavoriteTap: () =>
                                        audio.toggleFavorite(song),
                                  ),
                                );
                              },
                            ),
                      const SizedBox(height: 24),

                      // 8. POPULAR ARTISTS
                      _buildSectionHeader(
                        title: 'Popular Artists',
                        onSeeAll: () {
                          widget.onNavigateToTab?.call(1);
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 115,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _popularArtists.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            final artist = _popularArtists[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ArtistScreen(
                                      artistName: artist['name']!,
                                    ),
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
                                      border: Border.all(
                                        color: AppColors.brightRed,
                                        width: 1.5,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: AppColors.redGlow,
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: Image.network(
                                        artist['image']!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: AppColors.card,
                                          child: const Icon(
                                            Icons.person,
                                            color: AppColors.brightRed,
                                          ),
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
                      const SizedBox(height: 24),

                      // 9. TRENDING ALBUMS
                      _buildSectionHeader(
                        title: 'Trending Albums',
                        onSeeAll: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AlbumScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 172,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _trendingAlbums.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 14),
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
                                          child: const Icon(
                                            Icons.album,
                                            color: AppColors.brightRed,
                                          ),
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
                      const SizedBox(height: 24),

                      // 10. RECOMMENDED FOR YOU
                      _buildSectionHeader(
                        title: 'Recommended For You',
                        onSeeAll: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const QueueScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      trendingSongs.isEmpty
                          ? const SizedBox.shrink()
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: trendingSongs.length > 3
                                  ? 3
                                  : trendingSongs.length,
                              itemBuilder: (context, index) {
                                final song = trendingSongs[index];
                                final isCurrent =
                                    audio.currentSong?.id == song.id;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: SongTile(
                                    song: song,
                                    isCurrent: isCurrent,
                                    isPlaying: isCurrent && audio.isPlaying,
                                    onTap: () => audio.playSong(
                                      song,
                                      queueList: trendingSongs,
                                      index: index,
                                    ),
                                    onFavoriteTap: () =>
                                        audio.toggleFavorite(song),
                                  ),
                                );
                              },
                            ),
                      const SizedBox(height: 24),

                      // 11. NEW RELEASES / RECENTLY ADDED
                      _buildSectionHeader(
                        title: 'New Releases',
                        onSeeAll: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const QueueScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 172,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: trendingSongs.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 14),
                          itemBuilder: (context, index) {
                            final song = trendingSongs[index];
                            return GestureDetector(
                              onTap: () => audio.playSong(
                                song,
                                queueList: trendingSongs,
                                index: index,
                              ),
                              child: SizedBox(
                                width: 120,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.network(
                                            song.artworkUrl,
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Container(
                                                  width: 120,
                                                  height: 120,
                                                  color: AppColors.card,
                                                  child: const Icon(
                                                    Icons.music_note,
                                                    color: AppColors.brightRed,
                                                  ),
                                                ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 6,
                                          left: 6,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.brightRed,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'NEW',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
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
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryFeed(BuildContext context, AudioPlayerService audio) {
    if (_isLoadingCategory) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_selectedCategory Vibes',
                style: AppTypography.headingMedium,
              ),
              const ShimmerContainer(width: 80, height: 14),
            ],
          ),
          const SizedBox(height: 14),
          const SongTileSkeleton(),
          const SongTileSkeleton(),
          const SongTileSkeleton(),
          const SongTileSkeleton(),
          const SongTileSkeleton(),
        ],
      );
    }

    final categoryTracks = _categoryCache[_selectedCategory] ?? audio.queue;

    if (categoryTracks.isEmpty) {
      return EmptyStateView(
        icon: Icons.music_off_rounded,
        title: 'No $_selectedCategory Tracks',
        description: 'Unable to load tracks for this category. Please try refreshing or select another vibe.',
        actionLabel: 'RETRY',
        actionIcon: Icons.refresh_rounded,
        onAction: () {
          _categoryCache.remove(_selectedCategory);
          _selectCategory(_selectedCategory);
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_selectedCategory Vibes',
                  style: const TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${categoryTracks.length} tracks from Audius',
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (categoryTracks.isNotEmpty) {
                  audio.playSong(
                    categoryTracks.first,
                    queueList: categoryTracks,
                    index: 0,
                  );
                }
              },
              icon: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 18,
              ),
              label: const Text(
                'Play All',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brightRed,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categoryTracks.length,
          itemBuilder: (context, index) {
            final song = categoryTracks[index];
            final isCurrent = audio.currentSong?.id == song.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SongTile(
                song: song,
                indexNumber: index + 1,
                isCurrent: isCurrent,
                isPlaying: isCurrent && audio.isPlaying,
                onTap: () => audio.playSong(
                  song,
                  queueList: categoryTracks,
                  index: index,
                ),
                onFavoriteTap: () => audio.toggleFavorite(song),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onSeeAll,
  }) {
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
