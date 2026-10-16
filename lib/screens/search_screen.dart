import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/audio_service.dart';
import '../services/audius_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../models/song.dart';
import '../models/artist.dart';
import '../models/album.dart';
import '../models/playlist.dart';
import '../widgets/live_it_shimmer.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_state_view.dart';
import 'artist_screen.dart';
import 'album_screen.dart';
import 'playlist_screen.dart';
import 'recently_played_screen.dart';

/// Phase 8: Authoritative Search Screen for LIVE IT — BY AZAM KHAN.
/// Real-time decentralized Audius search engine with debouncing, stale-response protection,
/// multi-category results (All, Songs, Artists, Albums, Playlists), search history, and single-player engine playback.
class SearchScreen extends StatefulWidget {
  final void Function(int)? onNavigateToTab;

  const SearchScreen({super.key, this.onNavigateToTab});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  int _activeRequestId = 0;
  String _selectedCategory = 'All';
  bool _isLoading = false;
  String? _errorMessage;

  // Cached Search Results
  List<Song> _songResults = [];
  List<Artist> _artistResults = [];
  List<Album> _albumResults = [];
  List<Playlist> _playlistResults = [];

  // Recent Search Terms
  List<String> _recentSearches = [];

  final List<String> _categories = [
    'All',
    'Songs',
    'Artists',
    'Albums',
    'Playlists',
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final history = await StorageService.getRecentSearches();
    if (mounted) {
      setState(() {
        _recentSearches = history;
      });
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = null;
        _songResults.clear();
        _artistResults.clear();
        _albumResults.clear();
        _playlistResults.clear();
      });
      return;
    }

    setState(() {}); // Rebuild suffix clear icon

    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(trimmed);
    });
  }

  Future<void> _performSearch(String query, {bool forceRefresh = false}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = null;
        _songResults.clear();
        _artistResults.clear();
        _albumResults.clear();
        _playlistResults.clear();
      });
      return;
    }

    final requestId = ++_activeRequestId;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Save search term to recent history
      StorageService.addRecentSearch(trimmed)
          .then((_) => _loadRecentSearches());

      // Parallel fetch across Audius endpoints depending on active or all categories
      final trackFuture = AudiusService.searchTracks(
        trimmed,
        limit: 20,
        forceRefresh: forceRefresh,
      );
      final artistFuture = AudiusService.searchArtists(
        trimmed,
        limit: 12,
        forceRefresh: forceRefresh,
      );
      final playlistFuture = AudiusService.searchPlaylists(
        trimmed,
        limit: 12,
        forceRefresh: forceRefresh,
      );
      final albumFuture = AudiusService.searchAlbums(
        trimmed,
        limit: 12,
        forceRefresh: forceRefresh,
      );

      final results = await Future.wait([
        trackFuture,
        artistFuture,
        playlistFuture,
        albumFuture,
      ]);

      if (!mounted || requestId != _activeRequestId) {
        // Discard stale responses
        return;
      }

      setState(() {
        _songResults = results[0] as List<Song>;
        _artistResults = results[1] as List<Artist>;
        _playlistResults = results[2] as List<Playlist>;
        _albumResults = results[3] as List<Album>;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted || requestId != _activeRequestId) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e is AudiusException ? e.message : 'Unable to load results from Audius. Please check connection and try again.';
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _debounce?.cancel();
    setState(() {
      _isLoading = false;
      _errorMessage = null;
      _songResults.clear();
      _artistResults.clear();
      _albumResults.clear();
      _playlistResults.clear();
    });
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _showTrackMoreOptions(
    BuildContext context,
    Song song,
    AudioPlayerService audio, {
    bool isRecent = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final isFav = audio.isSongFavorite(song.id);
        final isRecentItem =
            isRecent || audio.recentlyPlayed.any((s) => s.id == song.id);
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
                    audio.playSong(
                      song,
                      queueList: _songResults.isNotEmpty ? _songResults : [song],
                    );
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
                if (isRecentItem)
                  ListTile(
                    leading: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.brightRed,
                    ),
                    title: const Text(
                      'Remove from Recent Searches',
                      style: TextStyle(color: AppColors.primaryText),
                    ),
                    onTap: () {
                      audio.removeFromRecentlyPlayed(song);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Removed "${song.title}" from recent searches',
                          ),
                          backgroundColor: AppColors.card,
                          duration: const Duration(seconds: 2),
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
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Full-screen Cinematic Itachi & Red Moon Background Artwork
              Positioned.fill(
                child: Image.asset(
                  'assets/images/search_background.png',
                  fit: BoxFit.cover,
                  alignment: const Alignment(0.0, -0.20),
                  filterQuality: FilterQuality.high,
                ),
              ),

              // 2. Subtle Dark Gradient Overlay for Readability & Contrast
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.70),
                        Colors.black.withValues(alpha: 0.25),
                        Colors.black.withValues(alpha: 0.55),
                        Colors.black.withValues(alpha: 0.90),
                      ],
                      stops: const [0.0, 0.22, 0.60, 1.0],
                    ),
                  ),
                ),
              ),

              // 3. Search Foreground Content
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. TOP HEADER & SEARCH INPUT
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 14,
                        bottom: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Large white Search heading aligned to the left
                          Row(
                            children: [
                              if (widget.onNavigateToTab != null ||
                                  Navigator.of(context).canPop()) ...[
                                IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    if (widget.onNavigateToTab != null) {
                                      widget.onNavigateToTab!(0);
                                    } else if (Navigator.of(context).canPop()) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                                ),
                                const SizedBox(width: 12),
                              ],
                              const Text(
                                'Search',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Search Input Field
                          Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFF141414).withValues(alpha: 0.80),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: AppColors.brightRed.withValues(alpha: 0.85),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.brightRed.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                              onChanged: _onSearchChanged,
                              onSubmitted: (val) {
                                _debounce?.cancel();
                                _performSearch(val);
                              },
                              decoration: InputDecoration(
                                hintText: 'Search songs, artists, albums...',
                                hintStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.45),
                                  fontSize: 14.5,
                                ),
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(left: 16, right: 10),
                                  child: Icon(
                                    Icons.search_rounded,
                                    color: Colors.white70,
                                    size: 22,
                                  ),
                                ),
                                prefixIconConstraints: const BoxConstraints(
                                  minWidth: 48,
                                  minHeight: 48,
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          color: Colors.white70,
                                          size: 20,
                                        ),
                                        onPressed: _clearSearch,
                                      )
                                    : (_isLoading
                                        ? const Padding(
                                            padding: EdgeInsets.all(14.0),
                                            child: SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.brightRed,
                                              ),
                                            ),
                                          )
                                        : null),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 8,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Category Filter Pills: All, Songs, Artists, Albums, Playlists
                          SizedBox(
                            height: 38,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _categories.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 10),
                              itemBuilder: (context, index) {
                                final cat = _categories[index];
                                final isSelected = cat == _selectedCategory;
                                return GestureDetector(
                                  onTap: () => _selectCategory(cat),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.brightRed
                                          : const Color(0xFF161616).withValues(alpha: 0.85),
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.brightRed
                                            : Colors.white.withValues(alpha: 0.15),
                                        width: 1.0,
                                      ),
                                      boxShadow: isSelected
                                          ? const [
                                              BoxShadow(
                                                color: AppColors.redGlow,
                                                blurRadius: 10,
                                                spreadRadius: 1,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Center(
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
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2. SEARCH RESULTS VIEWPORT
                    Expanded(child: _buildResultsContent(context, audio)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResultsContent(BuildContext context, AudioPlayerService audio) {
    final query = _searchController.text.trim();

    // INITIAL LANDING STATE (No query entered yet)
    if (query.isEmpty) {
      return _buildInitialLanding(context, audio);
    }

    // LOADING STATE (Clean Shimmer Skeleton)
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 90),
        itemCount: 8,
        itemBuilder: (context, index) => const SongTileSkeleton(),
      );
    }

    // ERROR STATE
    if (_errorMessage != null) {
      return ErrorStateView(
        message: _errorMessage!,
        retryLabel: 'Retry Search',
        onRetry: () => _performSearch(query, forceRefresh: true),
      );
    }

    // CATEGORY SPECIFIC VIEW DISPATCHER
    switch (_selectedCategory) {
      case 'Songs':
        return _buildSongsView(context, audio);
      case 'Artists':
        return _buildArtistsView(context);
      case 'Albums':
        return _buildAlbumsView(context);
      case 'Playlists':
        return _buildPlaylistsView(context);
      case 'All':
      default:
        return _buildAllCombinedView(context, audio);
    }
  }

  /// Initial state before search query with privacy-conscious recent searches
  Widget _buildInitialLanding(BuildContext context, AudioPlayerService audio) {
    final recentSongs = audio.recentlyPlayed;
    final hasRecentSongs = recentSongs.isNotEmpty;
    final hasRecentQueries = _recentSearches.isNotEmpty;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. RECENT SEARCHES SECTION (if recent songs or queries exist)
          if (hasRecentSongs || hasRecentQueries) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Recent Searches',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const RecentlyPlayedScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Recent search cards from user's actual history
            if (hasRecentSongs)
              ...recentSongs.take(4).map((song) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414).withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        audio.playSong(song, queueList: recentSongs);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            // Square album artwork with rounded corners and subtle red border
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.brightRed.withValues(alpha: 0.5),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.brightRed.withValues(alpha: 0.15),
                                    blurRadius: 6,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(9),
                                child: Image.network(
                                  song.artworkUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: const Color(0xFF202020),
                                    child: const Icon(
                                      Icons.music_note_rounded,
                                      color: AppColors.brightRed,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Track Title & Artist
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    song.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    song.artist,
                                    style: const TextStyle(
                                      color: Color(0xFFA0A0A0),
                                      fontSize: 12.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            // History/clock icon (restores query to search field)
                            IconButton(
                              icon: const Icon(
                                Icons.access_time_rounded,
                                color: Color(0xFFA0A0A0),
                                size: 20,
                              ),
                              tooltip: 'Search for track',
                              onPressed: () {
                                _searchController.text = song.title;
                                _onSearchChanged(song.title);
                              },
                            ),

                            // Three-dot overflow menu
                            IconButton(
                              icon: const Icon(
                                Icons.more_vert_rounded,
                                color: Color(0xFFA0A0A0),
                                size: 20,
                              ),
                              tooltip: 'More options',
                              onPressed: () => _showTrackMoreOptions(
                                context,
                                song,
                                audio,
                                isRecent: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),

            // Textual search query chips if any
            if (hasRecentQueries) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _recentSearches.take(6).map((term) {
                  return InkWell(
                    onTap: () {
                      _searchController.text = term;
                      _onSearchChanged(term);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141414).withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.history_rounded,
                            size: 14,
                            color: Color(0xFFA0A0A0),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            term,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () async {
                              await StorageService.removeRecentSearch(term);
                              _loadRecentSearches();
                            },
                            child: const Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: Color(0xFFA0A0A0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 28),
          ],

          // 2. CINEMATIC CENTRAL SEARCH ILLUSTRATION & MESSAGE
          Padding(
            padding: EdgeInsets.only(
              top: (hasRecentSongs || hasRecentQueries) ? 12 : 50,
              bottom: 30,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: const Color(0xFF141414).withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.brightRed.withValues(alpha: 0.7),
                        width: 1.8,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.redGlow,
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.search_rounded,
                      color: AppColors.brightRed,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Search for your next favorite track.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Discover songs, artists, albums, and playlists on Audius.',
                    style: TextStyle(
                      color: Color(0xFFA0A0A0),
                      fontSize: 13.5,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Combined "All" tab view
  Widget _buildAllCombinedView(BuildContext context, AudioPlayerService audio) {
    final hasSongs = _songResults.isNotEmpty;
    final hasArtists = _artistResults.isNotEmpty;
    final hasAlbums = _albumResults.isNotEmpty;
    final hasPlaylists = _playlistResults.isNotEmpty;

    if (!hasSongs && !hasArtists && !hasAlbums && !hasPlaylists) {
      return _buildEmptyState(
        'No results found for "${_searchController.text.trim()}".',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. TOP SONGS SUBSECTION
          if (hasSongs) ...[
            _buildSectionHeader(
              title: 'Songs',
              count: _songResults.length,
              onSeeAll: () => _selectCategory('Songs'),
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _songResults.length > 5 ? 5 : _songResults.length,
              separatorBuilder: (_, __) =>
                  const Divider(color: AppColors.divider, height: 1),
              itemBuilder: (context, index) {
                final song = _songResults[index];
                return _buildSongTile(
                  context,
                  song,
                  index,
                  _songResults,
                  audio,
                );
              },
            ),
            const SizedBox(height: 24),
          ],

          // 2. TOP ARTISTS SUBSECTION
          if (hasArtists) ...[
            _buildSectionHeader(
              title: 'Artists',
              count: _artistResults.length,
              onSeeAll: () => _selectCategory('Artists'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _artistResults.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final artist = _artistResults[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ArtistScreen(artistName: artist.name),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 80,
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
                                artist.imageUrl,
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
                          Text(
                            artist.name,
                            style: const TextStyle(
                              color: AppColors.primaryText,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // 3. TOP ALBUMS SUBSECTION
          if (hasAlbums) ...[
            _buildSectionHeader(
              title: 'Albums & Releases',
              count: _albumResults.length,
              onSeeAll: () => _selectCategory('Albums'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 165,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _albumResults.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final album = _albumResults[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AlbumScreen(
                            albumTitle: album.title,
                            artistName: album.artist,
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
                              album.coverUrl,
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
                            album.title,
                            style: const TextStyle(
                              color: AppColors.primaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            album.artist,
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
          ],

          // 4. TOP PLAYLISTS SUBSECTION
          if (hasPlaylists) ...[
            _buildSectionHeader(
              title: 'Playlists',
              count: _playlistResults.length,
              onSeeAll: () => _selectCategory('Playlists'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 165,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _playlistResults.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final playlist = _playlistResults[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PlaylistScreen(playlist: playlist),
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
                              playlist.coverUrl,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 120,
                                height: 120,
                                color: AppColors.card,
                                child: const Icon(
                                  Icons.queue_music,
                                  color: AppColors.brightRed,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            playlist.title,
                            style: const TextStyle(
                              color: AppColors.primaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            playlist.userName ?? 'Audius Playlist',
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
          ],
        ],
      ),
    );
  }

  /// Dedicated "Songs" tab view
  Widget _buildSongsView(BuildContext context, AudioPlayerService audio) {
    if (_songResults.isEmpty) {
      return _buildEmptyState(
        'No songs found for "${_searchController.text.trim()}".',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 90),
      itemCount: _songResults.length,
      separatorBuilder: (_, __) =>
          const Divider(color: AppColors.divider, height: 1),
      itemBuilder: (context, index) {
        final song = _songResults[index];
        return _buildSongTile(context, song, index, _songResults, audio);
      },
    );
  }

  /// Dedicated "Artists" tab view
  Widget _buildArtistsView(BuildContext context) {
    if (_artistResults.isEmpty) {
      return _buildEmptyState(
        'No artists found for "${_searchController.text.trim()}".',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 90),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.75,
        crossAxisSpacing: 14,
        mainAxisSpacing: 16,
      ),
      itemCount: _artistResults.length,
      itemBuilder: (context, index) {
        final artist = _artistResults[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ArtistScreen(artistName: artist.name),
              ),
            );
          },
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.brightRed, width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: AppColors.redGlow, blurRadius: 8),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    artist.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.card,
                      child: const Icon(
                        Icons.person,
                        color: AppColors.brightRed,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                artist.name,
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                artist.monthlyListeners,
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Dedicated "Albums" tab view
  Widget _buildAlbumsView(BuildContext context) {
    if (_albumResults.isEmpty) {
      return _buildEmptyState(
        'No albums found for "${_searchController.text.trim()}".',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 90),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.76,
        crossAxisSpacing: 14,
        mainAxisSpacing: 16,
      ),
      itemCount: _albumResults.length,
      itemBuilder: (context, index) {
        final album = _albumResults[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AlbumScreen(
                  albumTitle: album.title,
                  artistName: album.artist,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    album.coverUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.card,
                      child: const Icon(
                        Icons.album,
                        color: AppColors.brightRed,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                album.title,
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${album.artist} • ${album.year}',
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Dedicated "Playlists" tab view
  Widget _buildPlaylistsView(BuildContext context) {
    if (_playlistResults.isEmpty) {
      return _buildEmptyState(
        'No playlists found for "${_searchController.text.trim()}".',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 90),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.76,
        crossAxisSpacing: 14,
        mainAxisSpacing: 16,
      ),
      itemCount: _playlistResults.length,
      itemBuilder: (context, index) {
        final playlist = _playlistResults[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PlaylistScreen(playlist: playlist),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    playlist.coverUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.card,
                      child: const Icon(
                        Icons.queue_music,
                        color: AppColors.brightRed,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                playlist.title,
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                playlist.userName ?? 'Audius Playlist',
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSongTile(
    BuildContext context,
    Song song,
    int index,
    List<Song> queueList,
    AudioPlayerService audio,
  ) {
    final isCurrent = audio.currentSong?.id == song.id;
    final isPlaying = isCurrent && audio.isPlaying;

    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        onTap: () => audio.playSong(song, queueList: queueList, index: index),
        leading: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                song.artworkUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, __, ___) => Container(
                  width: 48,
                  height: 48,
                  color: AppColors.card,
                  child: const Icon(
                    Icons.music_note,
                    color: AppColors.brightRed,
                  ),
                ),
              ),
            ),
            if (isCurrent)
              Container(
                width: 48,
                height: 48,
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
        title: Text(
          song.title,
          style: TextStyle(
            color: isCurrent ? AppColors.brightRed : AppColors.primaryText,
            fontSize: 14,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          song.artist,
          style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isPlaying
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_outline_rounded,
                color: AppColors.brightRed,
                size: 26,
              ),
              onPressed: () {
                if (isCurrent) {
                  audio.togglePlayPause();
                } else {
                  audio.playSong(song, queueList: queueList, index: index);
                }
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: AppColors.secondaryText,
                size: 20,
              ),
              onPressed: () => _showTrackMoreOptions(context, song, audio),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required int count,
    required VoidCallback onSeeAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.divider),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
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

  Widget _buildEmptyState(String message) {
    return EmptyStateView(
      icon: Icons.search_off_rounded,
      title: 'No Results Found',
      description:
          '$message\nTry checking your spelling, using different keywords, or exploring another category.',
    );
  }
}
