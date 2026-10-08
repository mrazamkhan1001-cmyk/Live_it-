import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import 'favorites_screen.dart';
import 'playlist_screen.dart';
import 'album_screen.dart';
import 'artist_screen.dart';
import 'downloads_screen.dart';
import 'recently_played_screen.dart';

/// Pixel-Exact Ultra-HD Rebuilt LibraryScreen matching target screenshot media_1791413816295.png
class LibraryScreen extends StatefulWidget {
  final void Function(int)? onNavigateToTab;

  const LibraryScreen({super.key, this.onNavigateToTab});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (context, audio, child) {
        final favoritesCount = audio.favorites.length;
        final playlistsCount = audio.playlists.length;
        final downloadsCount = audio.downloadedSongs.length;
        final recentCount = audio.recentlyPlayed.length;

        return Container(
          color: const Color(0xFF030303),
          child: Stack(
            children: [
              // 1. EXPANDED TOP ITACHI ARTWORK HEADER BACKGROUND (Reveals Itachi's face, red moon & anime atmosphere)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 440,
                child: ShaderMask(
                  shaderCallback: (rect) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black,
                        Colors.black87,
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.70, 1.0],
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.dstIn,
                  child: Image.asset(
                    'assets/images/itachi_library_bg.png',
                    fit: BoxFit.cover,
                    alignment: const Alignment(0.20, -0.20),
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/itachi_face_bg.png',
                      fit: BoxFit.cover,
                      alignment: const Alignment(0.20, -0.20),
                    ),
                  ),
                ),
              ),

              // 2. MAIN RESPONSIVE CONTENT COLUMN (Eliminates bottom gap by matching available viewport height)
              SafeArea(
                top: true,
                bottom: false,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double availableHeight = constraints.maxHeight;

                    // Header + Title + Subtitle section occupies ~142 logical px
                    const double headerHeight = 142.0;
                    const double topCardGap = 22.0;
                    const double bottomGap = 10.0;

                    final double spaceForCards =
                        availableHeight - headerHeight - topCardGap - bottomGap;

                    // Dynamically calculate balanced card height & vertical margin so Card 6 sits exactly 10px above MiniPlayer
                    double cardHeight;
                    double cardVerticalMargin;

                    if (spaceForCards >= 460) {
                      cardHeight = ((spaceForCards - 44.0) / 6.0).clamp(
                        76.0,
                        86.0,
                      );
                      final double leftoverSpacing =
                          spaceForCards - (6.0 * cardHeight);
                      cardVerticalMargin = (leftoverSpacing / 12.0).clamp(
                        3.0,
                        5.5,
                      );
                    } else {
                      cardHeight = 76.0;
                      cardVerticalMargin = 4.0;
                    }

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: bottomGap),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: availableHeight - bottomGap,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // TOP HEADER SECTION: LIVE IT / BY AZAM KHAN + Search/More + Your Library
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 14, 12, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Brand Header: LIVE IT / BY AZAM KHAN
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          RichText(
                                            text: const TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'LIVE ',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 38,
                                                    fontWeight: FontWeight.w900,
                                                    fontStyle: FontStyle.italic,
                                                    letterSpacing: 1.5,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: 'IT',
                                                  style: TextStyle(
                                                    color: Color(0xFFFF1018),
                                                    fontSize: 34,
                                                    fontWeight: FontWeight.w900,
                                                    fontStyle: FontStyle.italic,
                                                    letterSpacing: 1.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 1),
                                          // Seamless UI-matching crimson text with subtle depth shadow and ambient glow
                                          const Text(
                                            'BY AZAM KHAN',
                                            style: TextStyle(
                                              color: Color(0xFFFF1018),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1.8,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black,
                                                  offset: Offset(0, 1.5),
                                                  blurRadius: 3,
                                                ),
                                                Shadow(
                                                  color: Color(0x88FF1018),
                                                  offset: Offset(0, 0),
                                                  blurRadius: 6,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Top-Right Header Icons: Search & More
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.search_rounded,
                                              color: Colors.white,
                                              size: 22,
                                            ),
                                            onPressed: () {
                                              widget.onNavigateToTab?.call(1);
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.more_vert_rounded,
                                              color: Colors.white,
                                              size: 22,
                                            ),
                                            onPressed: () {},
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),

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
                                  // Subtitle in pure white
                                  const Text(
                                    'All your music in one place.',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: topCardGap),

                            // SIX HIGH-QUALITY ATMOSPHERIC CARDS (Responsively balanced height & margin)
                            // Card 1: Liked Songs
                            _buildLibraryCard(
                              title: 'Liked Songs',
                              subtitle: favoritesCount == 0
                                  ? '0 songs'
                                  : '$favoritesCount ${favoritesCount == 1 ? "song" : "songs"}',
                              icon: Icons.favorite,
                              artAsset: 'assets/images/art1_crop.png',
                              height: cardHeight,
                              verticalMargin: cardVerticalMargin,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const FavoritesScreen(),
                                  ),
                                );
                              },
                            ),

                            // Card 2: Playlists
                            _buildLibraryCard(
                              title: 'Playlists',
                              subtitle: playlistsCount == 0
                                  ? '0 playlists'
                                  : '$playlistsCount ${playlistsCount == 1 ? "playlist" : "playlists"}',
                              icon: Icons.segment_rounded,
                              artAsset: 'assets/images/art2_crop.png',
                              height: cardHeight,
                              verticalMargin: cardVerticalMargin,
                              onTap: () {
                                final defaultPlaylist =
                                    audio.playlists.isNotEmpty
                                    ? audio.playlists.first
                                    : null;
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PlaylistScreen(
                                      playlist: defaultPlaylist,
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Card 3: Albums
                            _buildLibraryCard(
                              title: 'Albums',
                              subtitle: '0 albums',
                              icon: Icons.disc_full_rounded,
                              artAsset: 'assets/images/art3_crop.png',
                              height: cardHeight,
                              verticalMargin: cardVerticalMargin,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const AlbumScreen(),
                                  ),
                                );
                              },
                            ),

                            // Card 4: Artists
                            _buildLibraryCard(
                              title: 'Artists',
                              subtitle: '0 followed artists',
                              icon: Icons.people_alt_rounded,
                              artAsset: 'assets/images/art4_crop.png',
                              height: cardHeight,
                              verticalMargin: cardVerticalMargin,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ArtistScreen(),
                                  ),
                                );
                              },
                            ),

                            // Card 5: Downloads
                            _buildLibraryCard(
                              title: 'Downloads',
                              subtitle: downloadsCount == 0
                                  ? '0 downloads'
                                  : '$downloadsCount ${downloadsCount == 1 ? "download" : "downloads"}',
                              icon: Icons.arrow_downward_rounded,
                              artAsset: 'assets/images/art5_crop.png',
                              height: cardHeight,
                              verticalMargin: cardVerticalMargin,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const DownloadsScreen(),
                                  ),
                                );
                              },
                            ),

                            // Card 6: Recently Played
                            _buildLibraryCard(
                              title: 'Recently Played',
                              subtitle: recentCount == 0
                                  ? 'Nothing played yet'
                                  : '$recentCount ${recentCount == 1 ? "track" : "tracks"}',
                              icon: Icons.access_time_filled_rounded,
                              artAsset: 'assets/images/art6_crop.png',
                              height: cardHeight,
                              verticalMargin: cardVerticalMargin,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const RecentlyPlayedScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
    required double height,
    required double verticalMargin,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14, vertical: verticalMargin),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            LiveItHaptics.light();
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF140205), Color(0xFF070002)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              border: Border.all(color: const Color(0xFFFF1018), width: 1.3),
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
                  // Right Side Target Artwork Image with Smooth Gradient Blend
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
                              stops: [0.0, 0.40],
                            ).createShader(rect);
                          },
                          blendMode: BlendMode.dstIn,
                          child: Image.asset(
                            artAsset,
                            width: 280,
                            height: height,
                            fit: BoxFit.cover,
                            alignment: Alignment.centerRight,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink(),
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
                        // Left Red Icon Container (50x50px Square with Glowing Border)
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F0004),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFFF1018),
                              width: 1.2,
                            ),
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
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                subtitle,
                                style: const TextStyle(
                                  color: Color(0xFF9E9E9E),
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
