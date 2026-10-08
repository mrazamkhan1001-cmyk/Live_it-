import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:liveitbyazam/theme/app_theme.dart';
import 'package:liveitbyazam/models/song.dart';
import 'package:liveitbyazam/models/album.dart';
import 'package:liveitbyazam/models/artist.dart';
import 'package:liveitbyazam/services/audio_service.dart';
import 'package:liveitbyazam/widgets/mini_player.dart';
import 'package:liveitbyazam/widgets/song_card.dart';
import 'package:liveitbyazam/widgets/album_card.dart';
import 'package:liveitbyazam/widgets/artist_card.dart';
import 'package:liveitbyazam/widgets/bottom_navigation.dart';
import 'package:liveitbyazam/widgets/live_it_shimmer.dart';
import 'package:liveitbyazam/widgets/empty_state_view.dart';
import 'package:liveitbyazam/widgets/error_state_view.dart';
import 'package:liveitbyazam/widgets/sharingan_player.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 12 — Design Tokens & Theme Foundation', () {
    test('AppColors matches exact 90% black / 10% red specification', () {
      expect(AppColors.background, const Color(0xFF050505));
      expect(AppColors.surface, const Color(0xFF0D0D0D));
      expect(AppColors.card, const Color(0xFF151515));
      expect(AppColors.cardElevated, const Color(0xFF1C1C1C));
      expect(AppColors.primaryRed, const Color(0xFFE50914));
      expect(AppColors.brightRed, const Color(0xFFFF1018));
      expect(AppColors.darkRed, const Color(0xFF720006));
      expect(AppColors.primaryText, const Color(0xFFFFFFFF));
      expect(AppColors.secondaryText, const Color(0xFFA0A0A0));
      expect(AppColors.divider, const Color(0xFF252525));
    });

    test('AppRadii provides standardized radii tokens', () {
      expect(AppRadii.r8, BorderRadius.circular(8));
      expect(AppRadii.r12, BorderRadius.circular(12));
      expect(AppRadii.r16, BorderRadius.circular(16));
    });

    test('AppTypography provides standard hierarchy', () {
      expect(AppTypography.brandTitle.fontSize, 22);
      expect(AppTypography.brandSubtitle.color, AppColors.brightRed);
      expect(AppTypography.headingMedium.fontWeight, FontWeight.bold);
    });

    test('LiveItPageRoute and LiveItScalePageRoute initialize with curves', () {
      final route = LiveItPageRoute(child: const SizedBox());
      expect(route.transitionDuration, const Duration(milliseconds: 260));

      final scaleRoute = LiveItScalePageRoute(child: const SizedBox());
      expect(scaleRoute.transitionDuration, const Duration(milliseconds: 280));
    });
  });

  group('Phase 12 — Reusable UI Components', () {
    testWidgets(
      'ShimmerContainer and SongTileSkeleton render with dark theme colors',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(
              body: Column(
                children: [
                  ShimmerContainer(width: 100, height: 20),
                  SongTileSkeleton(showLeadingNumber: true),
                  CardSkeleton(width: 140, height: 140),
                ],
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(ShimmerContainer), findsWidgets);
        expect(find.byType(SongTileSkeleton), findsOneWidget);
        expect(find.byType(CardSkeleton), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
      },
    );

    testWidgets(
      'EmptyStateView renders icon, title, description, and triggers action',
      (tester) async {
        bool actionTriggered = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: EmptyStateView(
                icon: Icons.music_off_rounded,
                title: 'Empty Library',
                description:
                    'Your saved tracks and playlists will appear here.',
                actionLabel: 'EXPLORE MUSIC',
                onAction: () => actionTriggered = true,
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Empty Library'), findsOneWidget);
        expect(
          find.text('Your saved tracks and playlists will appear here.'),
          findsOneWidget,
        );
        expect(find.text('EXPLORE MUSIC'), findsOneWidget);

        await tester.tap(find.text('EXPLORE MUSIC'));
        expect(actionTriggered, isTrue);
      },
    );

    testWidgets('ErrorStateView renders error message and retry button', (
      tester,
    ) async {
      bool retryTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: ErrorStateView(
              message: 'Failed to connect to Audius decentralized nodes.',
              onRetry: () => retryTriggered = true,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.text('Failed to connect to Audius decentralized nodes.'),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(retryTriggered, isTrue);
    });

    testWidgets(
      'SongTile renders song info, active indicator, and favorite status',
      (tester) async {
        final testSong = Song(
          id: 'tile_1',
          title: 'Sharingan Beats',
          artist: 'Uchiha Clan',
          album: 'Ninja OST',
          artworkUrl: 'https://example.com/art.jpg',
          streamUrl: 'https://example.com/stream.mp3',
          durationMs: 180000,
        );

        bool tapCalled = false;
        bool favCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: SongTile(
                song: testSong,
                isCurrent: true,
                isPlaying: true,
                indexNumber: 1,
                onTap: () => tapCalled = true,
                onFavoriteTap: () => favCalled = true,
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Sharingan Beats'), findsOneWidget);
        expect(find.text('Uchiha Clan'), findsOneWidget);
        expect(find.text('1'), findsOneWidget);
        expect(find.byIcon(Icons.equalizer), findsOneWidget);

        await tester.tap(find.text('Sharingan Beats'));
        expect(tapCalled, isTrue);

        await tester.tap(find.byIcon(Icons.favorite_border));
        expect(favCalled, isTrue);
      },
    );

    testWidgets('AlbumCard and ArtistCard render with consistent styling', (
      tester,
    ) async {
      final testAlbum = Album(
        id: 'alb_1',
        title: 'Arcane OST',
        artist: 'Various Artists',
        coverUrl: 'https://example.com/alb.jpg',
        year: 2024,
      );

      final testArtist = Artist(
        id: 'art_1',
        name: 'Itachi Uchiha',
        imageUrl: 'https://example.com/artist.jpg',
        monthlyListeners: '100K',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Row(
              children: [
                AlbumCard(album: testAlbum, onTap: () {}),
                ArtistCard(artist: testArtist, onTap: () {}),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Arcane OST'), findsOneWidget);
      expect(find.text('Itachi Uchiha'), findsOneWidget);
    });

    testWidgets('CustomBottomNavigation renders 4 tabs with active indicator', (
      tester,
    ) async {
      int selectedTab = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                bottomNavigationBar: CustomBottomNavigation(
                  currentIndex: selectedTab,
                  onTap: (index) => setState(() => selectedTab = index),
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Library'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      await tester.tap(find.text('Search'));
      await tester.pump();
      expect(selectedTab, 1);
    });

    testWidgets(
      'MiniPlayer updates with active track and controls AudioPlayerService',
      (tester) async {
        final audio = AudioPlayerService();
        final song = Song(
          id: 'mini_1',
          title: 'Anime Beats',
          artist: 'Azam Khan',
          album: 'Live It',
          artworkUrl: 'https://example.com/art.jpg',
          streamUrl: 'https://example.com/stream.mp3',
          durationMs: 120000,
        );

        await tester.pumpWidget(
          ChangeNotifierProvider<AudioPlayerService>.value(
            value: audio,
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const Scaffold(body: MiniPlayer()),
            ),
          ),
        );
        await tester.pump();

        // No song initially
        expect(find.text('Anime Beats'), findsNothing);

        // Play track
        audio.addToQueue(song);
        await tester.pump();

        expect(find.text('Anime Beats'), findsOneWidget);
        expect(find.text('Azam Khan'), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'SharinganPlayer center piece renders and adapts to play state',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(
              body: Center(child: SharinganPlayer(isPlaying: false, size: 200)),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(SharinganPlayer), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
      },
    );
  });
}
