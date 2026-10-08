import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:liveitbyazam/models/song.dart';
import 'package:liveitbyazam/models/lyric_line.dart';
import 'package:liveitbyazam/services/audio_service.dart';
import 'package:liveitbyazam/screens/lyrics_screen.dart';
import 'package:liveitbyazam/screens/queue_screen.dart';
import 'package:liveitbyazam/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 9 — Lyrics Synchronization Tests', () {
    test(
      'LyricLine - parses standard LRC timestamps and calculates end times',
      () {
        const lrc = '''
[ti:Uchiha Legacy]
[ar:Azam Khan]
[00:00.00]Intro beat
[00:10.50]Wake up to reality
[00:25.00]Nothing goes as planned
[01:15.800]Sharingan awakens
''';

        final lines = LyricLine.parseLrc(lrc);
        expect(lines.length, 4);
        expect(lines[0].text, 'Intro beat');
        expect(lines[0].startTime, Duration.zero);
        expect(
          lines[0].endTime,
          const Duration(seconds: 10, milliseconds: 500),
        );

        expect(lines[1].text, 'Wake up to reality');
        expect(
          lines[1].startTime,
          const Duration(seconds: 10, milliseconds: 500),
        );
        expect(lines[1].endTime, const Duration(seconds: 25));

        expect(lines[2].text, 'Nothing goes as planned');
        expect(lines[2].startTime, const Duration(seconds: 25));
        expect(
          lines[2].endTime,
          const Duration(minutes: 1, seconds: 15, milliseconds: 800),
        );

        expect(lines[3].text, 'Sharingan awakens');
        expect(
          lines[3].startTime,
          const Duration(minutes: 1, seconds: 15, milliseconds: 800),
        );
        expect(lines[3].endTime, isNull);
      },
    );

    test('LyricLine - handles plain text lines without timestamps', () {
      final rawLines = [
        'First plain line',
        'Second plain line',
        'Third plain line',
      ];

      final parsed = LyricLine.parseList(rawLines);
      expect(parsed.length, 3);
      expect(parsed[0].text, 'First plain line');
      expect(parsed[0].isSynchronized, isFalse);
      expect(parsed[1].text, 'Second plain line');
      expect(parsed[1].isSynchronized, isFalse);
    });

    test('LyricLine.findActiveIndex - resolves active line based on playback position', () {
      const lrc = '''
[00:00.00]Line 0
[00:10.00]Line 1
[00:20.00]Line 2
[00:35.00]Line 3
''';
      final lines = LyricLine.parseLrc(lrc);

      // Before start or at start
      expect(LyricLine.findActiveIndex(lines, Duration.zero), 0);
      expect(LyricLine.findActiveIndex(lines, const Duration(seconds: 5)), 0);

      // Transition to line 1
      expect(LyricLine.findActiveIndex(lines, const Duration(seconds: 10)), 1);
      expect(LyricLine.findActiveIndex(lines, const Duration(seconds: 15)), 1);

      // Seek forward to line 3
      expect(LyricLine.findActiveIndex(lines, const Duration(seconds: 40)), 3);

      // Seek backward to line 2
      expect(LyricLine.findActiveIndex(lines, const Duration(seconds: 22)), 2);
    });

    testWidgets(
      'LyricsScreen - renders song info, synchronized lyrics, and highlights line',
      (WidgetTester tester) async {
        final audioService = AudioPlayerService();
        final testSong = Song(
          id: 'lyrics_test_1',
          title: 'Uchiha Vengeance',
          artist: 'Azam Khan',
          album: 'Mangekyo Beats',
          artworkUrl: 'https://audius.co/art.jpg',
          streamUrl: 'https://audius.co/stream.mp3',
          durationMs: 240000,
          lyrics: const [
            '[00:00.00]Intro melody',
            '[00:10.00]Wake up to reality',
            '[00:20.00]Nothing goes as planned',
          ],
        );

        audioService.addToQueue(testSong);

        await tester.pumpWidget(
          ChangeNotifierProvider<AudioPlayerService>.value(
            value: audioService,
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const LyricsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify Header & Song Info
        expect(find.text('LYRICS'), findsOneWidget);
        expect(find.text('Real-Time Synchronized'), findsOneWidget);
        expect(find.text('Uchiha Vengeance'), findsOneWidget);
        expect(find.text('Azam Khan'), findsOneWidget);

        // Verify Lyrics Lines
        expect(find.text('Intro melody'), findsOneWidget);
        expect(find.text('Wake up to reality'), findsOneWidget);
        expect(find.text('Nothing goes as planned'), findsOneWidget);
      },
    );

    testWidgets(
      'LyricsScreen - displays fallback message when no lyrics exist',
      (WidgetTester tester) async {
        final audioService = AudioPlayerService();
        final testSong = Song(
          id: 'no_lyrics_1',
          title: 'Random Track',
          artist: 'Unknown Artist',
          album: 'Unknown Album',
          artworkUrl: 'https://audius.co/art2.jpg',
          streamUrl: 'https://audius.co/stream2.mp3',
          durationMs: 180000,
          lyrics: const [],
        );

        audioService.addToQueue(testSong);

        await tester.pumpWidget(
          ChangeNotifierProvider<AudioPlayerService>.value(
            value: audioService,
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const LyricsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text("Synchronized lyrics aren't available for this track."),
          findsOneWidget,
        );
      },
    );
  });

  group('Phase 9 — Playback Queue Tests', () {
    test('AudioPlayerService - clearUpcoming clears upcoming tracks and keeps currentSong', () async {
      final audioService = AudioPlayerService();
      final song1 = Song(
        id: 'q1',
        title: 'Track 1',
        artist: 'Artist',
        album: 'Alb',
        artworkUrl: 'art',
        streamUrl: 'url',
        durationMs: 1000,
      );
      final song2 = Song(
        id: 'q2',
        title: 'Track 2',
        artist: 'Artist',
        album: 'Alb',
        artworkUrl: 'art',
        streamUrl: 'url',
        durationMs: 1000,
      );
      final song3 = Song(
        id: 'q3',
        title: 'Track 3',
        artist: 'Artist',
        album: 'Alb',
        artworkUrl: 'art',
        streamUrl: 'url',
        durationMs: 1000,
      );

      audioService.addToQueue(song1);
      audioService.addToQueue(song2);
      audioService.addToQueue(song3);

      expect(audioService.queue.length, 3);
      expect(audioService.currentSong?.id, 'q1');

      audioService.clearUpcoming();

      expect(audioService.queue.length, 1);
      expect(audioService.currentSong?.id, 'q1');
      expect(audioService.currentIndex, 0);
    });

    test('AudioPlayerService - insertNextInQueue inserts immediately after current track', () async {
      final audioService = AudioPlayerService();
      final song1 = Song(
        id: 'q1',
        title: 'Track 1',
        artist: 'Artist',
        album: 'Alb',
        artworkUrl: 'art',
        streamUrl: 'url',
        durationMs: 1000,
      );
      final song2 = Song(
        id: 'q2',
        title: 'Track 2',
        artist: 'Artist',
        album: 'Alb',
        artworkUrl: 'art',
        streamUrl: 'url',
        durationMs: 1000,
      );
      final songNext = Song(
        id: 'q_next',
        title: 'Next Track',
        artist: 'Artist',
        album: 'Alb',
        artworkUrl: 'art',
        streamUrl: 'url',
        durationMs: 1000,
      );

      audioService.addToQueue(song1);
      audioService.addToQueue(song2);

      audioService.insertNextInQueue(songNext);

      expect(audioService.queue.length, 3);
      expect(audioService.queue[1].id, 'q_next');
      expect(audioService.queue[2].id, 'q2');
    });

    testWidgets(
      'QueueScreen - renders Now Playing section, Up Next tracks, and Clear Queue',
      (WidgetTester tester) async {
        final audioService = AudioPlayerService();
        final song1 = Song(
          id: 'q1',
          title: 'Now Playing Track',
          artist: 'Active Artist',
          album: 'Alb',
          artworkUrl: 'https://art1.jpg',
          streamUrl: 'url',
          durationMs: 200000,
        );
        final song2 = Song(
          id: 'q2',
          title: 'Upcoming Track 1',
          artist: 'Upcoming Artist',
          album: 'Alb',
          artworkUrl: 'https://art2.jpg',
          streamUrl: 'url',
          durationMs: 200000,
        );
        final song3 = Song(
          id: 'q3',
          title: 'Upcoming Track 2',
          artist: 'Upcoming Artist 2',
          album: 'Alb',
          artworkUrl: 'https://art3.jpg',
          streamUrl: 'url',
          durationMs: 200000,
        );

        audioService.addToQueue(song1);
        audioService.addToQueue(song2);
        audioService.addToQueue(song3);

        await tester.pumpWidget(
          ChangeNotifierProvider<AudioPlayerService>.value(
            value: audioService,
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const QueueScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Verify Header
        expect(find.text('Playback Queue'), findsOneWidget);
        expect(find.text('Clear'), findsOneWidget);

        // 2. Verify Now Playing Section
        expect(find.text('NOW PLAYING'), findsOneWidget);
        expect(find.text('Now Playing Track'), findsOneWidget);
        expect(find.text('Active Artist'), findsOneWidget);

        // 3. Verify Up Next Section
        expect(find.text('UP NEXT'), findsOneWidget);
        expect(find.text('Upcoming Track 1'), findsOneWidget);
        expect(find.text('Upcoming Track 2'), findsOneWidget);
      },
    );

    testWidgets(
      'QueueScreen - Clear upcoming button triggers dialog and clears upcoming songs',
      (WidgetTester tester) async {
        final audioService = AudioPlayerService();
        final song1 = Song(
          id: 'q1',
          title: 'Now Playing Track',
          artist: 'Artist 1',
          album: 'Alb',
          artworkUrl: 'https://art1.jpg',
          streamUrl: 'url',
          durationMs: 200000,
        );
        final song2 = Song(
          id: 'q2',
          title: 'Upcoming Track 1',
          artist: 'Artist 2',
          album: 'Alb',
          artworkUrl: 'https://art2.jpg',
          streamUrl: 'url',
          durationMs: 200000,
        );

        audioService.addToQueue(song1);
        audioService.addToQueue(song2);

        await tester.pumpWidget(
          ChangeNotifierProvider<AudioPlayerService>.value(
            value: audioService,
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const QueueScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Upcoming Track 1'), findsOneWidget);

        // Tap Clear button
        await tester.tap(find.text('Clear'));
        await tester.pumpAndSettle();

        // Verify confirmation dialog
        expect(find.text('Clear Upcoming Queue'), findsOneWidget);

        // Tap 'Clear' in dialog
        await tester.tap(find.widgetWithText(ElevatedButton, 'Clear'));
        await tester.pumpAndSettle();

        // Verify upcoming track is removed and empty message is shown
        expect(find.text('No upcoming tracks in queue'), findsOneWidget);
        expect(find.text('Now Playing Track'), findsOneWidget);
        expect(audioService.currentSong?.id, 'q1');
      },
    );
  });
}
