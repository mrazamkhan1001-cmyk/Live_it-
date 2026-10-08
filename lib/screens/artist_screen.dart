import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/song_card.dart';
import 'song_details_screen.dart';

/// Artist Screen matching Section 10 & Mockup #8
class ArtistScreen extends StatefulWidget {
  final String artistName;

  const ArtistScreen({super.key, this.artistName = 'Imagine Dragons'});

  @override
  State<ArtistScreen> createState() => _ArtistScreenState();
}

class _ArtistScreenState extends State<ArtistScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (context, audio, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Artist Banner Header matching Mockup #8
                Stack(
                  children: [
                    Container(
                      height: 260,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=1000'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
                        ),
                      ),
                    ),
                    Container(
                      height: 260,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, AppColors.background],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.artistName,
                            style: const TextStyle(
                              color: AppColors.primaryText,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '25.4M monthly listeners',
                            style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
                          ),
                          const SizedBox(height: 12),

                          // Follow Button matching Mockup #8
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isFollowing = !_isFollowing;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isFollowing ? AppColors.card : AppColors.brightRed,
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: _isFollowing ? AppColors.divider : AppColors.brightRed),
                              ),
                            ),
                            child: Text(
                              _isFollowing ? 'Following' : 'Follow',
                              style: TextStyle(
                                color: _isFollowing ? AppColors.primaryText : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Tabs (Popular, Albums, About) matching Mockup #8
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.brightRed,
                  labelColor: AppColors.brightRed,
                  unselectedLabelColor: AppColors.secondaryText,
                  tabs: const [
                    Tab(text: 'Popular'),
                    Tab(text: 'Albums'),
                    Tab(text: 'About'),
                  ],
                ),
                const SizedBox(height: 16),

                // Tab Content List
                SizedBox(
                  height: 400,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Popular Songs List matching Mockup #8
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: audio.queue.length,
                        itemBuilder: (context, index) {
                          final song = audio.queue[index];
                          final isCurrent = audio.currentSong?.id == song.id;

                          return SongTile(
                            song: song,
                            isCurrent: isCurrent,
                            isPlaying: isCurrent && audio.isPlaying,
                            onTap: () => audio.playSong(song, index: index),
                            onMoreTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => SongDetailsScreen(song: song)),
                              );
                            },
                          );
                        },
                      ),

                      // Albums Tab
                      const Center(child: Text('No albums loaded', style: TextStyle(color: AppColors.secondaryText))),

                      // About Tab
                      const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'Imagine Dragons is an American pop rock band from Las Vegas, Nevada, consisting of lead singer Dan Reynolds, guitarist Wayne Sermon, bassist Ben McKee, and drummer Daniel Platzman.',
                          style: TextStyle(color: AppColors.secondaryText, height: 1.5),
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
}
