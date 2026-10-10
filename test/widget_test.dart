import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:liveitbyazam/main.dart';
import 'package:liveitbyazam/screens/loading_screen.dart';
import 'package:liveitbyazam/screens/login_screen.dart';
import 'package:liveitbyazam/screens/signup_screen.dart';
import 'package:liveitbyazam/screens/main_shell_screen.dart';
import 'package:liveitbyazam/screens/home_screen.dart';
import 'package:liveitbyazam/screens/search_screen.dart';
import 'package:liveitbyazam/screens/library_screen.dart';
import 'package:liveitbyazam/screens/profile_screen.dart';
import 'package:liveitbyazam/models/song.dart';
import 'package:liveitbyazam/screens/downloads_screen.dart';
import 'package:liveitbyazam/screens/fullscreen_player_screen.dart';
import 'package:liveitbyazam/screens/player_screen.dart';
import 'package:liveitbyazam/screens/settings_screen.dart';
import 'package:liveitbyazam/services/audio_service.dart';
import 'package:liveitbyazam/services/storage_service.dart';
import 'package:liveitbyazam/theme/app_theme.dart';
import 'package:liveitbyazam/widgets/sharingan_player.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  testWidgets('Startup Flow - App launches with LoadingScreen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const LiveItApp());
    expect(find.byType(LoadingScreen), findsOneWidget);
  });

  testWidgets('MainShellScreen - hosts IndexedStack with 4 primary tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AudioPlayerService>(
        create: (_) => AudioPlayerService(),
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const MainShellScreen(),
        ),
      ),
    );
    await tester.pump();

    // Verify MainShellScreen and IndexedStack are present
    final IndexedStack indexedStack = tester.widget(find.byType(IndexedStack));
    expect(indexedStack.children.length, 4);
    expect(indexedStack.children[0], isA<HomeScreen>());
    expect(indexedStack.children[1], isA<SearchScreen>());
    expect(indexedStack.children[2], isA<LibraryScreen>());
    expect(indexedStack.children[3], isA<ProfileScreen>());
  });

  testWidgets(
    'MainShellScreen - tab switching preserves widget tree without pushing routes',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AudioPlayerService>(
          create: (_) => AudioPlayerService(),
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const MainShellScreen(),
          ),
        ),
      );

      // Tap on Search tab (index 1)
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      final indexedStackFinder = find.byType(IndexedStack);
      final IndexedStack indexedStack = tester.widget(indexedStackFinder);
      expect(indexedStack.index, 1);

      // Tap on Library tab (index 2)
      await tester.tap(find.text('Library'));
      await tester.pumpAndSettle();

      final IndexedStack indexedStack2 = tester.widget(indexedStackFinder);
      expect(indexedStack2.index, 2);

      // Tap on Profile tab (index 3)
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      final IndexedStack indexedStack3 = tester.widget(indexedStackFinder);
      expect(indexedStack3.index, 3);
    },
  );

  testWidgets('LibraryScreen - renders header and all 6 library cards', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AudioPlayerService>(
        create: (_) => AudioPlayerService(),
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const MainShellScreen(initialIndex: 2),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your Library'), findsOneWidget);
    expect(find.text('All your music in one place.'), findsOneWidget);
    expect(find.text('Liked Songs'), findsOneWidget);
    expect(find.text('Playlists'), findsOneWidget);
    expect(find.text('Albums'), findsOneWidget);
    expect(find.text('Artists'), findsOneWidget);
    expect(find.text('Downloads'), findsOneWidget);
    expect(find.text('Recently Played'), findsOneWidget);
  });

  testWidgets(
    'PlayerScreen - renders Sharingan centerpiece, centered song info, controls, and bottom actions',
    (WidgetTester tester) async {
      final audioService = AudioPlayerService();
      final testSong = Song(
        id: 'test_123',
        title: 'Uchiha Vengeance',
        artist: 'Azam Khan',
        album: 'Mangekyo Beats',
        artworkUrl: 'https://audius.co/art.jpg',
        streamUrl: 'https://audius.co/stream.mp3',
        durationMs: 240000,
      );

      audioService.addToQueue(testSong);

      await tester.pumpWidget(
        ChangeNotifierProvider<AudioPlayerService>.value(
          value: audioService,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const PlayerScreen(),
          ),
        ),
      );
      await tester.pump();

      // Verify Header & Centered Song Info
      expect(find.text('NOW PLAYING'), findsOneWidget);
      expect(find.text('Uchiha Vengeance'), findsOneWidget);
      expect(find.text('Azam Khan'), findsOneWidget);

      // Verify Sharingan Centerpiece Visualizer
      expect(find.byType(SharinganPlayer), findsOneWidget);

      // Verify Progress Slider
      expect(find.byType(Slider), findsOneWidget);

      // Verify 5 Playback Controls
      expect(find.byIcon(Icons.shuffle), findsOneWidget);
      expect(find.byIcon(Icons.skip_previous_rounded), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.byIcon(Icons.skip_next_rounded), findsOneWidget);
      expect(find.byIcon(Icons.repeat), findsOneWidget);

      // Verify 3 Bottom Actions
      expect(find.text('Favorite'), findsOneWidget);
      expect(find.text('Lyrics'), findsOneWidget);
      expect(find.text('Queue'), findsOneWidget);
    },
  );

  testWidgets(
    'FullscreenPlayerScreen - renders Sharingan centerpiece, fullscreen context badge, and controls',
    (WidgetTester tester) async {
      final audioService = AudioPlayerService();
      final testSong = Song(
        id: 'fs_1',
        title: 'Amaterasu Flames',
        artist: 'Azam Khan',
        album: 'Mangekyo Album',
        artworkUrl: 'https://audius.co/amaterasu.jpg',
        streamUrl: 'https://audius.co/amaterasu.mp3',
        durationMs: 300000,
      );

      audioService.addToQueue(testSong);

      await tester.pumpWidget(
        ChangeNotifierProvider<AudioPlayerService>.value(
          value: audioService,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const FullscreenPlayerScreen(),
          ),
        ),
      );
      await tester.pump();

      // Verify Header & Fullscreen Badge
      expect(find.text('LIVE IT FULLSCREEN'), findsOneWidget);
      expect(find.text('Amaterasu Flames'), findsOneWidget);
      expect(find.text('Azam Khan'), findsOneWidget);

      // Verify Sharingan Centerpiece
      expect(find.byType(SharinganPlayer), findsOneWidget);

      // Verify Exit Fullscreen Button
      expect(find.byIcon(Icons.fullscreen_exit), findsOneWidget);

      // Verify Controls & Actions
      expect(find.byIcon(Icons.shuffle), findsOneWidget);
      expect(find.byIcon(Icons.skip_previous_rounded), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.byIcon(Icons.skip_next_rounded), findsOneWidget);
      expect(find.byIcon(Icons.repeat), findsOneWidget);
      expect(find.text('Favorite'), findsOneWidget);
      expect(find.text('Lyrics'), findsOneWidget);
      expect(find.text('Queue'), findsOneWidget);
    },
  );

  testWidgets(
    'Fullscreen Navigation - Entering and popping fullscreen preserves active audio session',
    (WidgetTester tester) async {
      final audioService = AudioPlayerService();
      final testSong = Song(
        id: 'fs_nav_1',
        title: 'Susanoo Awakening',
        artist: 'Azam Khan',
        album: 'Eternal Power',
        artworkUrl: 'https://audius.co/susanoo.jpg',
        streamUrl: 'https://audius.co/susanoo.mp3',
        durationMs: 220000,
      );

      audioService.addToQueue(testSong);

      await tester.pumpWidget(
        ChangeNotifierProvider<AudioPlayerService>.value(
          value: audioService,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const PlayerScreen(),
          ),
        ),
      );
      await tester.pump();

      // Tap fullscreen button on PlayerScreen
      await tester.tap(find.byIcon(Icons.fullscreen));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Confirm FullscreenPlayerScreen is now displayed with the exact same song
      expect(find.byType(FullscreenPlayerScreen), findsOneWidget);
      expect(find.text('Susanoo Awakening'), findsOneWidget);

      // Tap Exit Fullscreen button
      await tester.tap(find.byIcon(Icons.fullscreen_exit));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Confirm PlayerScreen is back with the same song and zero resets
      expect(find.byType(PlayerScreen), findsOneWidget);
      expect(find.text('Susanoo Awakening'), findsOneWidget);
      expect(audioService.currentSong?.id, 'fs_nav_1');
    },
  );

  testWidgets(
    'FullscreenPlayerScreen - controls interact with AudioPlayerService',
    (WidgetTester tester) async {
      final audioService = AudioPlayerService();
      final testSong = Song(
        id: 'fs_ctrl_1',
        title: 'Chidori Stream',
        artist: 'Azam Khan',
        album: 'Lightning Release',
        artworkUrl: 'https://audius.co/chidori.jpg',
        streamUrl: 'https://audius.co/chidori.mp3',
        durationMs: 180000,
      );

      audioService.addToQueue(testSong);

      await tester.pumpWidget(
        ChangeNotifierProvider<AudioPlayerService>.value(
          value: audioService,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const FullscreenPlayerScreen(),
          ),
        ),
      );
      await tester.pump();

      // 1. Toggle Shuffle
      expect(audioService.isShuffle, isFalse);
      await tester.tap(find.byIcon(Icons.shuffle));
      await tester.pump();
      expect(audioService.isShuffle, isTrue);

      // 2. Toggle Repeat
      expect(audioService.repeatState, RepeatState.off);
      await tester.tap(find.byIcon(Icons.repeat));
      await tester.pump();
      expect(audioService.repeatState, RepeatState.all);

      // 3. Toggle Favorite
      expect(audioService.isSongFavorite('fs_ctrl_1'), isFalse);
      await tester.tap(find.text('Favorite'));
      await tester.pump();
      expect(audioService.isSongFavorite('fs_ctrl_1'), isTrue);
    },
  );

  testWidgets(
    'Phase 7 HomeScreen - renders LIVE IT branding, greeting, search, category chips, and discovery sections',
    (WidgetTester tester) async {
      final audioService = AudioPlayerService();
      final testSong1 = Song(
        id: 'home_1',
        title: 'Uchiha Legacy',
        artist: 'Azam Khan',
        album: 'Konoha Beats',
        artworkUrl: 'https://audius.co/art1.jpg',
        streamUrl: 'https://audius.co/stream1.mp3',
        durationMs: 200000,
      );
      final testSong2 = Song(
        id: 'home_2',
        title: 'Mangekyo Trance',
        artist: 'Naruto Beats',
        album: 'Shinobi Sound',
        artworkUrl: 'https://audius.co/art2.jpg',
        streamUrl: 'https://audius.co/stream2.mp3',
        durationMs: 240000,
      );

      audioService.addToQueue(testSong1);
      audioService.addToQueue(testSong2);

      int switchedTab = -1;

      await tester.pumpWidget(
        ChangeNotifierProvider<AudioPlayerService>.value(
          value: audioService,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: HomeScreen(
              onNavigateToTab: (tab) {
                switchedTab = tab;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verify Branding & Header
      expect(find.text('LIVE IT'), findsOneWidget);
      expect(find.text('BY AZAM KHAN'), findsOneWidget);
      expect(find.byIcon(Icons.menu_rounded), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

      // 2. Verify Search Bar
      expect(find.text('Search songs, artists, albums...'), findsOneWidget);
      await tester.tap(find.text('Search songs, artists, albums...'));
      await tester.pump();
      expect(switchedTab, 1);

      // 3. Verify Categories
      expect(find.text('For You'), findsOneWidget);
      expect(find.text('Anime'), findsOneWidget);
      expect(find.text('Chill'), findsOneWidget);
      expect(find.text('Rap'), findsOneWidget);
      expect(find.text('Lo-fi'), findsOneWidget);

      // 4. Verify Featured Hero Banner
      expect(find.text('Uchiha Vibes'), findsOneWidget);
      expect(find.text('Music for the ones who understand...'), findsOneWidget);

      // 5. Verify Discovery Section Headers
      expect(find.text('Recently Played'), findsOneWidget);
      expect(find.text('Trending Songs'), findsOneWidget);
      expect(find.text('Popular Artists'), findsOneWidget);
      expect(find.text('Trending Albums'), findsOneWidget);
      expect(find.text('Recommended For You'), findsOneWidget);
      expect(find.text('New Releases'), findsOneWidget);

      // 6. Verify Popular Artists
      expect(find.text('Audius Lo-Fi'), findsOneWidget);
      expect(find.text('Naruto Beats'), findsWidgets);

      // 7. Verify Trending Albums
      expect(find.text('Arcane Soundtrack'), findsOneWidget);
    },
  );

  testWidgets(
    'Phase 7 HomeScreen - Quick Menu opens and renders navigation actions',
    (WidgetTester tester) async {
      final audioService = AudioPlayerService();

      await tester.pumpWidget(
        ChangeNotifierProvider<AudioPlayerService>.value(
          value: audioService,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap menu button
      await tester.tap(find.byIcon(Icons.menu_rounded));
      await tester.pumpAndSettle();

      // Verify Quick Menu items
      expect(find.text('LIVE IT — QUICK MENU'), findsOneWidget);
      expect(find.text('Audio Equalizer'), findsOneWidget);
      expect(find.text('Liked Songs'), findsOneWidget);
      expect(find.text('Downloads'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('About LIVE IT'), findsOneWidget);
    },
  );

  testWidgets(
    'Phase 7 HomeScreen - Notifications sheet opens on notification bell tap',
    (WidgetTester tester) async {
      final audioService = AudioPlayerService();

      await tester.pumpWidget(
        ChangeNotifierProvider<AudioPlayerService>.value(
          value: audioService,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap notification button
      await tester.tap(find.byIcon(Icons.notifications_none_rounded));
      await tester.pumpAndSettle();

      // Verify Notifications content
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Audius Network Connected'), findsOneWidget);
      expect(find.text('Trending Chart Updated'), findsOneWidget);
    },
  );

  testWidgets(
    'Phase 8 SearchScreen - renders header, input, category chips, and landing state',
    (WidgetTester tester) async {
      final audioService = AudioPlayerService();

      await tester.pumpWidget(
        ChangeNotifierProvider<AudioPlayerService>.value(
          value: audioService,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const SearchScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verify Header
      expect(find.text('Search'), findsOneWidget);

      // 2. Verify Search Input & Placeholder
      expect(find.text('Search songs, artists, albums...'), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsWidgets);

      // 3. Verify Category Tabs
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Songs'), findsOneWidget);
      expect(find.text('Artists'), findsOneWidget);
      expect(find.text('Albums'), findsOneWidget);
      expect(find.text('Playlists'), findsOneWidget);

      // 4. Verify Initial Landing Message
      expect(find.text('Search for your next favorite track.'), findsOneWidget);
      expect(
        find.text('Discover songs, artists, albums, and playlists on Audius.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Phase 8 SearchScreen - category switching updates selected tab',
    (WidgetTester tester) async {
      final audioService = AudioPlayerService();

      await tester.pumpWidget(
        ChangeNotifierProvider<AudioPlayerService>.value(
          value: audioService,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const SearchScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on 'Artists' category chip
      await tester.tap(find.text('Artists'));
      await tester.pumpAndSettle();

      // Tap on 'Albums' category chip
      await tester.tap(find.text('Albums'));
      await tester.pumpAndSettle();

      // Tap on 'Playlists' category chip
      await tester.tap(find.text('Playlists'));
      await tester.pumpAndSettle();

      // Tap on 'All' category chip
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'Phase 8 SearchScreen - typing and clear button clears query and resets landing state',
    (WidgetTester tester) async {
      final audioService = AudioPlayerService();

      await tester.pumpWidget(
        ChangeNotifierProvider<AudioPlayerService>.value(
          value: audioService,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const SearchScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter query
      await tester.enterText(find.byType(TextField), 'Naruto');
      await tester.pump();

      // Verify clear button appears
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Tap clear button
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // Confirm text is cleared and landing state is visible
      expect(find.text('Search for your next favorite track.'), findsOneWidget);
    },
  );

  testWidgets(
    'Phase 8 SearchScreen - audio playback and more-options modal interaction',
    (WidgetTester tester) async {
      final audioService = AudioPlayerService();
      final searchSong = Song(
        id: 'search_track_1',
        title: 'Sharingan Discovery',
        artist: 'Azam Khan',
        album: 'Audius Catalog',
        artworkUrl: 'https://audius.co/art_search.jpg',
        streamUrl: 'https://audius.co/stream_search.mp3',
        durationMs: 210000,
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<AudioPlayerService>.value(
          value: audioService,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const SearchScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Directly play the song in AudioPlayerService to simulate search track playback
      audioService.playSong(searchSong, queueList: [searchSong]);
      await tester.pump();

      expect(audioService.currentSong?.title, 'Sharingan Discovery');
      expect(audioService.currentSong?.artist, 'Azam Khan');
      expect(audioService.queue.length, 1);
    },
  );

  testWidgets(
    'Phase 10 DownloadsScreen - renders empty state when no tracks downloaded',
    (WidgetTester tester) async {
      final audioService = AudioPlayerService();
      await tester.pumpWidget(
        ChangeNotifierProvider<AudioPlayerService>.value(
          value: audioService,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const DownloadsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Downloads'), findsOneWidget);
      expect(find.text('No Downloaded Tracks'), findsOneWidget);
      expect(find.text('EXPLORE MUSIC'), findsOneWidget);
    },
  );

  testWidgets(
    'LoginScreen - renders login_background.png, LIVE IT branding, inputs, and actions',
    (WidgetTester tester) async {
      final audioService = AudioPlayerService();
      await tester.pumpWidget(
        ChangeNotifierProvider<AudioPlayerService>.value(
          value: audioService,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify background image asset
      final imageFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/images/login_background.png' &&
            widget.fit == BoxFit.cover,
      );
      expect(imageFinder, findsOneWidget);

      // Verify official LIVE IT logo image asset in upper-left
      final logoFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/images/live_it_logo.png' &&
            widget.width == 100 &&
            widget.fit == BoxFit.contain,
      );
      expect(logoFinder, findsOneWidget);

      // Verify plain-text LIVE IT branding is absent from LoginScreen
      expect(find.text('LIVE IT'), findsNothing);
      expect(find.text('BY AZAM KHAN'), findsNothing);

      // Verify welcome texts
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(
        find.text('Music for the ones who understand...'),
        findsOneWidget,
      );

      // Verify Email and Password fields
      expect(find.byType(TextField), findsNWidgets(2));
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(find.byType(TextField).last, 'secret123');
      await tester.pump();

      expect(find.text('test@example.com'), findsOneWidget);

      // Verify Remember Me checkbox toggle
      final checkboxFinder = find.byType(Checkbox);
      expect(checkboxFinder, findsOneWidget);
      await tester.tap(checkboxFinder);
      await tester.pump();

      // Verify Login button exists
      final loginBtnFinder = find.byType(ElevatedButton);
      expect(loginBtnFinder, findsOneWidget);

      // Verify Apple and Discord icons are absent
      expect(find.byIcon(Icons.apple), findsNothing);

      // Verify Google icon and Continue with Google button exist
      expect(
        find.byWidgetPredicate(
          (w) => w.runtimeType.toString() == '_GoogleLogoIcon',
        ),
        findsOneWidget,
      );
      expect(find.text('Continue with Google'), findsOneWidget);
    },
  );

  testWidgets('LoginScreen - Sign Up navigation navigates to SignupScreen', (
    WidgetTester tester,
  ) async {
    final audioService = AudioPlayerService();
    await tester.pumpWidget(
      ChangeNotifierProvider<AudioPlayerService>.value(
        value: audioService,
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final signUpFinder = find.text('Sign Up');
    expect(signUpFinder, findsOneWidget);
    await tester.tap(signUpFinder);
    await tester.pumpAndSettle();

    expect(find.byType(SignupScreen), findsOneWidget);
  });

  testWidgets(
    'SignupScreen - renders signup_background.png, fields, and white Google button',
    (WidgetTester tester) async {
      final audioService = AudioPlayerService();
      await tester.pumpWidget(
        ChangeNotifierProvider<AudioPlayerService>.value(
          value: audioService,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const SignupScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify signup background image asset
      final imageFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/images/signup_background.png' &&
            widget.fit == BoxFit.cover,
      );
      expect(imageFinder, findsOneWidget);

      // Verify official LIVE IT logo image asset in upper-left
      final logoFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/images/live_it_logo.png' &&
            widget.width == 100 &&
            widget.fit == BoxFit.contain,
      );
      expect(logoFinder, findsOneWidget);

      // Verify title and subtitle
      expect(find.text('Create Account'), findsNWidgets(2)); // Title + Button text
      expect(
        find.text('Join the community of music lovers.'),
        findsOneWidget,
      );

      // Verify 5 input fields (Full Name, Email, Username, Password, Confirm Password)
      expect(find.byType(TextField), findsNWidgets(5));

      // Verify Apple and Discord buttons are absent
      expect(find.byIcon(Icons.apple), findsNothing);

      // Verify Google icon and white Continue with Google button exist
      expect(
        find.byWidgetPredicate(
          (w) => w.runtimeType.toString() == '_GoogleLogoIcon',
        ),
        findsOneWidget,
      );
      expect(find.text('Continue with Google'), findsOneWidget);

      // Verify back navigation to Login
      final backButtonFinder = find.byIcon(Icons.arrow_back);
      expect(backButtonFinder, findsOneWidget);
    },
  );

  testWidgets(
    'ProfileScreen - renders Logout button and handles Cancel in confirmation dialog',
    (WidgetTester tester) async {
      final audioService = AudioPlayerService();
      await tester.pumpWidget(
        ChangeNotifierProvider<AudioPlayerService>.value(
          value: audioService,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const ProfileScreen(),
          ),
        ),
      );
      // Verify Profile background image asset
      final bgFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/images/profile_background.png' &&
            widget.fit == BoxFit.cover,
      );
      expect(bgFinder, findsOneWidget);

      final logoutFinder = find.text('Logout');
      expect(logoutFinder, findsOneWidget);
      await tester.ensureVisible(logoutFinder);
      await tester.pumpAndSettle();

      // Tap Logout to open confirmation dialog
      await tester.tap(logoutFinder);
      await tester.pumpAndSettle();

      expect(find.text('Log out?'), findsOneWidget);
      expect(
        find.text('Are you sure you want to log out of your account?'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);

      // Tap Cancel to dismiss dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Log out?'), findsNothing);
      expect(find.byType(ProfileScreen), findsOneWidget);
    },
  );

  testWidgets(
    'ProfileScreen - Logout confirmation triggers sign-out and navigates to LoginScreen',
    (WidgetTester tester) async {
      final audioService = AudioPlayerService();
      await tester.pumpWidget(
        ChangeNotifierProvider<AudioPlayerService>.value(
          value: audioService,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const ProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final logoutFinder = find.text('Logout');
      await tester.ensureVisible(logoutFinder);
      await tester.pumpAndSettle();

      // Open dialog and confirm logout
      await tester.tap(logoutFinder);
      await tester.pumpAndSettle();

      final confirmBtn = find.widgetWithText(ElevatedButton, 'Logout');
      expect(confirmBtn, findsOneWidget);
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      // Verify navigation to LoginScreen
      expect(find.byType(LoginScreen), findsOneWidget);
    },
  );

  testWidgets(
    'SettingsScreen - renders Logout button and opens confirmation dialog',
    (WidgetTester tester) async {
      final audioService = AudioPlayerService();
      await tester.pumpWidget(
        ChangeNotifierProvider<AudioPlayerService>.value(
          value: audioService,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll down until Logout tile is built and visible
      final logoutFinder = find.text('Logout');
      await tester.scrollUntilVisible(
        logoutFinder,
        300,
        scrollable: find.byType(Scrollable),
      );
      await tester.pumpAndSettle();

      expect(logoutFinder, findsOneWidget);

      await tester.tap(logoutFinder);
      await tester.pumpAndSettle();

      expect(find.text('Log out?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Log out?'), findsNothing);
      expect(find.byType(SettingsScreen), findsOneWidget);
    },
  );
}



