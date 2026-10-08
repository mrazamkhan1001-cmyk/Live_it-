import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../widgets/mini_player.dart';
import '../widgets/bottom_navigation.dart';
import 'favorites_screen.dart';
import 'playlist_screen.dart';
import 'album_screen.dart';
import 'artist_screen.dart';
import 'downloads_screen.dart';
import 'recently_played_screen.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';

/// Pixel-Exact Ultra-HD Rebuilt LibraryScreen matching target screenshot media_1791413816295.png
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  int _currentNavIndex = 2; // Library tab active

  @override
  Widget build(BuildContext context) {
    if (_currentNavIndex == 0) return const HomeScreen();
    if (_currentNavIndex == 1) return const SearchScreen();
    if (_currentNavIndex == 3) return const ProfileScreen();

    return Consumer<AudioPlayerService>(
      builder: (context, audio, child) {
        final favoritesCount = audio.favorites.length;
        final playlistsCount = audio.playlists.length;
        final downloadsCount = audio.queue.where((s) => s.isDownloaded).length;
        final recentCount = audio.recentlyPlayed.length;

        return Scaffold(
          backgroundColor: const Color(0xFF030303),
          body: Stack(
            children: [
              // TOP ITACHI RED ARTWORK HEADER BACKGROUND
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 250,
                child: ShaderMask(
                  shaderCallback: (rect) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black,
                        Colors.transparent,
                      ],
                      stops: [0.35, 1.0],
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.dstIn,
                  child: Image.asset(
                    'assets/images/itachi_login_bg.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topRight,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/itachi_face_bg.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topRight,
                    ),
                  ),
                ),
              ),

              // MAIN CONTENT SCROLLABLE COLUMN
              SafeArea(
                top: true,
                bottom: false,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. TOP HEADER (LIVE IT / BY AZAM KHAN Branding + Search/More + Your Library)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 10, 12, 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Brand Header: LIVE IT / BY AZAM KHAN
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          RichText(
                                            text: const TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'LIVE ',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.w900,
                                                    fontStyle: FontStyle.italic,
                                                    letterSpacing: 1.5,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: 'IT',
                                                  style: TextStyle(
                                                    color: Color(0xFFFF1018),
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.w900,
                                                    fontStyle: FontStyle.italic,
                                                    letterSpacing: 1.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 1),
                                          const Text(
                                            'BY AZAM KHAN',
                                            style: TextStyle(
                                              color: Color(0xFFFF1018),
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Top-Right Header Icons: Search & More
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.search_rounded, color: Colors.white, size: 22),
                                            onPressed: () {
                                              setState(() {
                                                _currentNavIndex = 1;
                                              });
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 22),
                                            onPressed: () {},
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Section Header: Your Library + Subtitle
                                  const Text(
                                    'Your Library',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'All your music in one place.',
                                    style: TextStyle(
                                      color: Color(0xFF9E9E9E),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),

                            // 2. SIX HIGH-QUALITY ATMOSPHERIC CARDS (Height: 78px)
                            // Card 1: Liked Songs
                            _buildLibraryCard(
                              title: 'Liked Songs',
                              subtitle: favoritesCount == 0 ? '0 songs' : '$favoritesCount ${favoritesCount == 1 ? "song" : "songs"}',
                              icon: Icons.favorite,
                              artAsset: 'assets/images/art1_crop.png',
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                                );
                              },
                            ),

                            // Card 2: Playlists
                            _buildLibraryCard(
                              title: 'Playlists',
                              subtitle: playlistsCount == 0 ? '0 playlists' : '$playlistsCount ${playlistsCount == 1 ? "playlist" : "playlists"}',
                              icon: Icons.segment_rounded,
                              artAsset: 'assets/images/art2_crop.png',
                              onTap: () {
                                final defaultPlaylist = audio.playlists.isNotEmpty ? audio.playlists.first : null;
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => PlaylistScreen(playlist: defaultPlaylist)),
                                );
                              },
                            ),

                            // Card 3: Albums
                            _buildLibraryCard(
                              title: 'Albums',
                              subtitle: '0 albums',
                              icon: Icons.disc_full_rounded,
                              artAsset: 'assets/images/art3_crop.png',
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const AlbumScreen()),
                                );
                              },
                            ),

                            // Card 4: Artists
                            _buildLibraryCard(
                              title: 'Artists',
                              subtitle: '0 followed artists',
                              icon: Icons.people_alt_rounded,
                              artAsset: 'assets/images/art4_crop.png',
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const ArtistScreen()),
                                );
                              },
                            ),

                            // Card 5: Downloads
                            _buildLibraryCard(
                              title: 'Downloads',
                              subtitle: downloadsCount == 0 ? '0 downloads' : '$downloadsCount ${downloadsCount == 1 ? "download" : "downloads"}',
                              icon: Icons.arrow_downward_rounded,
                              artAsset: 'assets/images/art5_crop.png',
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const DownloadsScreen()),
                                );
                              },
                            ),

                            // Card 6: Recently Played
                            _buildLibraryCard(
                              title: 'Recently Played',
                              subtitle: recentCount == 0 ? 'Nothing played yet' : '$recentCount ${recentCount == 1 ? "track" : "tracks"}',
                              icon: Icons.access_time_filled_rounded,
                              artAsset: 'assets/images/art6_crop.png',
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const RecentlyPlayedScreen()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 3. CONDITIONAL FLOATING MINI PLAYER (Only when song is active)
                    if (audio.currentSong != null) const MiniPlayer(),

                    // 4. COMPACT BOTTOM NAVIGATION BAR WITH ACTIVE RED BADGE
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildLibraryCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String artAsset,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 78,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF140205), Color(0xFF070002)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              border: Border.all(color: const Color(0xFFFF1018), width: 1.4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x44FF1018),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Right Side Exact Target Artwork Image with Gradient Blend
                  Positioned.fill(
                    child: Row(
                      children: [
                        const Spacer(),
                        ShaderMask(
                          shaderCallback: (rect) {
                            return const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Colors.transparent, Colors.black],
                              stops: [0.0, 0.35],
                            ).createShader(rect);
                          },
                          blendMode: BlendMode.dstIn,
                          child: Image.asset(
                            artAsset,
                            width: 280,
                            height: 78,
                            fit: BoxFit.cover,
                            alignment: Alignment.centerRight,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Card Interactive Content Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        // Left Red Icon Container (52x52px Square with Glowing Border)
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F0004),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFF1018), width: 1.2),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x66FF1018),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Icon(
                            icon,
                            color: const Color(0xFFFF1018),
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Title & Subtitle Column
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                subtitle,
                                style: const TextStyle(
                                  color: Color(0xFF9E9E9E),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Far Right Chevron Arrow
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
