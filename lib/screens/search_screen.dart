import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../services/audius_service.dart';
import '../theme/app_theme.dart';
import '../models/song.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/mini_player.dart';
import 'home_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';

/// Rebuilt SearchScreen matching SEARCH reference screenshot
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _currentNavIndex = 1; // Search tab index
  final TextEditingController _searchController = TextEditingController(text: 'Imagine Dragons');
  String _selectedFilter = 'All';
  bool _isLoading = false;
  List<Song> _searchResults = [];

  final List<String> _filters = ['All', 'Songs', 'Artists', 'Albums', 'Playlists'];

  @override
  void initState() {
    super.initState();
    _performSearch(_searchController.text);
  }

  void _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _isLoading = true);
    final results = await AudiusService.searchTracks(query);
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentNavIndex == 0) return const HomeScreen();
    if (_currentNavIndex == 2) return const LibraryScreen();
    if (_currentNavIndex == 3) return const ProfileScreen();

    return Consumer<AudioPlayerService>(
      builder: (context, audio, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Bar: Back Arrow & Title "Search"
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: AppColors.primaryText, size: 24),
                              onPressed: () {
                                setState(() {
                                  _currentNavIndex = 0;
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Search',
                              style: TextStyle(
                                color: AppColors.primaryText,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Search Input Field with Clear X Button
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.divider, width: 1),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: AppColors.primaryText, fontSize: 14),
                            onSubmitted: (val) => _performSearch(val),
                            decoration: InputDecoration(
                              hintText: 'Search songs, artists, albums...',
                              hintStyle: const TextStyle(color: AppColors.secondaryText, fontSize: 14),
                              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.secondaryText, size: 20),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.close_rounded, color: AppColors.secondaryText, size: 20),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchResults = [];
                                        });
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Filter Chips (All, Songs, Artists, Albums, Playlists)
                        SizedBox(
                          height: 32,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _filters.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final filter = _filters[index];
                              final isSelected = filter == _selectedFilter;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedFilter = filter),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.brightRed : AppColors.card,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected ? AppColors.brightRed : AppColors.divider,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    filter,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Results List Area
                        Expanded(
                          child: _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(color: AppColors.brightRed),
                                )
                              : _searchResults.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No songs found.',
                                        style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
                                      ),
                                    )
                                  : ListView.separated(
                                      itemCount: _searchResults.length,
                                      separatorBuilder: (_, __) => const Divider(color: AppColors.divider, height: 1),
                                      itemBuilder: (context, index) {
                                        final song = _searchResults[index];
                                        return Material(
                                          color: Colors.transparent,
                                          child: ListTile(
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                            leading: ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.network(
                                                song.artworkUrl,
                                                width: 46,
                                                height: 46,
                                                fit: BoxFit.cover,
                                                filterQuality: FilterQuality.high,
                                                errorBuilder: (_, __, ___) => Container(
                                                  width: 46,
                                                  height: 46,
                                                  color: AppColors.card,
                                                  child: const Icon(Icons.music_note, color: AppColors.brightRed),
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              song.title,
                                              style: const TextStyle(
                                                color: AppColors.primaryText,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
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
                                                  icon: const Icon(Icons.play_circle_outline_rounded, color: AppColors.brightRed, size: 26),
                                                  onPressed: () => audio.playSong(song, queueList: _searchResults, index: index),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.more_vert_rounded, color: AppColors.secondaryText, size: 20),
                                                  onPressed: () {},
                                                ),
                                              ],
                                            ),
                                            onTap: () => audio.playSong(song, queueList: _searchResults, index: index),
                                          ),
                                        );
                                      },
                                    ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Persistent Mini Player above Navigation
                const MiniPlayer(),

                // Shared Bottom Navigation Bar
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
}
