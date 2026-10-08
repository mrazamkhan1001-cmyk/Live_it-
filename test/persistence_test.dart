import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:liveitbyazam/models/song.dart';
import 'package:liveitbyazam/models/playlist.dart';
import 'package:liveitbyazam/services/audio_service.dart';
import 'package:liveitbyazam/services/download_service.dart';
import 'package:liveitbyazam/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<dynamic> handleMethodCall(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'init':
        final dynamic args = methodCall.arguments;
        final String? id = args is Map ? args['id']?.toString() : null;
        if (id != null) {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
                MethodChannel('com.ryanheise.just_audio.methods.$id'),
                handleMethodCall,
              );
        }
        return {};
      case 'load':
        return {'duration': 180000000};
      case 'play':
      case 'pause':
      case 'stop':
      case 'seek':
      case 'dispose':
        return {};
      default:
        return {};
    }
  }

  const MethodChannel channel = MethodChannel(
    'com.ryanheise.just_audio.methods',
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, handleMethodCall);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  group('Phase 13 — Persistence & Reliability Tests', () {
    test(
      'Test A — User profile persistence, restoration, and defaults',
      () async {
        // 1. Initial default profile
        final initialName = await StorageService.getUserName();
        expect(initialName, 'Azam Khan');

        // 2. Save custom profile
        const testProfile = UserProfile(
          name: 'Itachi Uchiha',
          username: 'itachi_akatsuki',
          bio: 'Forgive me, Sasuke... this is the last time.',
        );
        await StorageService.saveUserProfile(testProfile);

        // 3. Re-read profile
        final restoredProfile = await StorageService.getUserProfile();
        expect(restoredProfile.name, 'Itachi Uchiha');
        expect(restoredProfile.username, 'itachi_akatsuki');
        expect(
          restoredProfile.bio,
          'Forgive me, Sasuke... this is the last time.',
        );

        // 4. getUserName matches
        final restoredName = await StorageService.getUserName();
        expect(restoredName, 'Itachi Uchiha');
      },
    );

    test(
      'Test B — Favorites persistence, duplicate prevention, and removal',
      () async {
        final song1 = Song(
          id: 'fav_1',
          title: 'Mangekyo Trance',
          artist: 'Azam Khan',
          album: 'Live It OST',
          artworkUrl: 'https://example.com/art1.jpg',
          streamUrl: 'https://example.com/stream1.mp3',
          durationMs: 180000,
        );
        final song2 = Song(
          id: 'fav_2',
          title: 'Amaterasu Fire',
          artist: 'Azam Khan',
          album: 'Live It OST',
          artworkUrl: 'https://example.com/art2.jpg',
          streamUrl: 'https://example.com/stream2.mp3',
          durationMs: 210000,
        );

        // Save with duplicate song1
        await StorageService.saveFavorites([song1, song2, song1]);

        // Verify deduplication and isFavorite flag
        final restored = await StorageService.getFavorites();
        expect(restored.length, 2);
        expect(restored[0].id, 'fav_1');
        expect(restored[0].isFavorite, isTrue);
        expect(restored[1].id, 'fav_2');
        expect(restored[1].isFavorite, isTrue);

        // Remove fav_1
        await StorageService.saveFavorites([song2]);
        final afterRemoval = await StorageService.getFavorites();
        expect(afterRemoval.length, 1);
        expect(afterRemoval.first.id, 'fav_2');
      },
    );

    test(
      'Test C — Playlists persistence, ordering, and CRUD operations',
      () async {
        final songA = Song(
          id: 'song_a',
          title: 'Track A',
          artist: 'Artist A',
          album: 'Album A',
          artworkUrl: 'https://example.com/a.jpg',
          streamUrl: 'https://example.com/a.mp3',
          durationMs: 150000,
        );
        final songB = Song(
          id: 'song_b',
          title: 'Track B',
          artist: 'Artist B',
          album: 'Album B',
          artworkUrl: 'https://example.com/b.jpg',
          streamUrl: 'https://example.com/b.mp3',
          durationMs: 160000,
        );

        final playlist1 = Playlist(
          id: 'pl_100',
          title: 'Shinobi Chill',
          description: 'Night vibes',
          coverUrl: 'https://example.com/pl.jpg',
          userName: 'Azam Khan',
          trackCount: 2,
          songs: [songA, songB],
          isUserCreated: true,
        );

        await StorageService.savePlaylists([playlist1]);

        final restored = await StorageService.getPlaylists();
        expect(restored.length, 1);
        expect(restored.first.id, 'pl_100');
        expect(restored.first.title, 'Shinobi Chill');
        expect(restored.first.songs.length, 2);
        expect(restored.first.songs[0].id, 'song_a');
        expect(restored.first.songs[1].id, 'song_b');
      },
    );

    test('Test D — Recently Played newest first ordering, duplicate handling, and limits', () async {
      final songs = List.generate(
        60,
        (i) => Song(
          id: 'recent_$i',
          title: 'Song $i',
          artist: 'Artist $i',
          album: 'Album $i',
          artworkUrl: 'https://example.com/$i.jpg',
          streamUrl: 'https://example.com/$i.mp3',
          durationMs: 120000,
        ),
      );

      // Save 60 songs (limit is 50)
      await StorageService.saveRecentlyPlayed(songs, limit: 50);

      final restored = await StorageService.getRecentlyPlayed();
      expect(restored.length, 50);
      expect(restored.first.id, 'recent_0');
      expect(restored.last.id, 'recent_49');

      // Now insert recent_10 at the beginning and re-save
      final updated = [songs[10], ...restored];
      await StorageService.saveRecentlyPlayed(updated, limit: 50);

      final reChecked = await StorageService.getRecentlyPlayed();
      expect(reChecked.length, 50);
      expect(reChecked.first.id, 'recent_10');
      // Ensure recent_10 is not duplicated
      expect(reChecked.where((s) => s.id == 'recent_10').length, 1);
    });

    test(
      'Test E — Queue, index, shuffle, repeat restoration WITHOUT auto-playing',
      () async {
        final queueSong1 = Song(
          id: 'q_1',
          title: 'Queue 1',
          artist: 'Azam',
          album: 'Album',
          artworkUrl: 'https://example.com/1.jpg',
          streamUrl: 'https://example.com/1.mp3',
          durationMs: 200000,
        );
        final queueSong2 = Song(
          id: 'q_2',
          title: 'Queue 2',
          artist: 'Azam',
          album: 'Album',
          artworkUrl: 'https://example.com/2.jpg',
          streamUrl: 'https://example.com/2.mp3',
          durationMs: 220000,
        );

        // Save queue state in storage
        await StorageService.saveQueue([queueSong1, queueSong2], 1);
        await StorageService.saveShuffleState(true);
        await StorageService.saveRepeatState(RepeatState.all.name);

        // Instantiate AudioPlayerService
        final audioService = AudioPlayerService();
        await audioService.initialized;

        // Verify restored state
        expect(audioService.queue.length, 2);
        expect(audioService.currentIndex, 1);
        expect(audioService.currentSong?.id, 'q_2');
        expect(audioService.isShuffle, isTrue);
        expect(audioService.repeatState, RepeatState.all);

        // CRITICAL: Ensure playback did not automatically start on restoration
        expect(audioService.isPlaying, isFalse);
        expect(audioService.playbackState, isNot(PlaybackState.playing));
      },
    );

    test('Test F — Settings and theme persistence and restoration', () async {
      // 1. Audio Quality
      const quality = AudioQualitySettings(
        streamQuality: 'Very High',
        downloadQuality: 'High',
      );
      await StorageService.saveAudioQualitySettings(quality);
      final restoredQuality = await StorageService.getAudioQualitySettings();
      expect(restoredQuality.streamQuality, 'Very High');
      expect(restoredQuality.downloadQuality, 'High');

      // 2. Playback settings
      const playback = PlaybackSettings(
        crossfade: true,
        crossfadeDuration: 6.0,
        gaplessPlayback: true,
        normalizeVolume: false,
        audioFocus: true,
        resumePlayback: false,
      );
      await StorageService.savePlaybackSettings(playback);
      final restoredPlayback = await StorageService.getPlaybackSettings();
      expect(restoredPlayback.crossfadeDuration, 6.0);
      expect(restoredPlayback.normalizeVolume, isFalse);
      expect(restoredPlayback.resumePlayback, isFalse);

      // 3. Equalizer
      const eq = EqualizerSettings(
        selectedPreset: 'Rock',
        band60: 7.0,
        band230: 3.0,
        band910: -2.0,
        band3k6: 4.0,
        band14k: 6.0,
        bassBoost: true,
        virtualizer: true,
        loudness: false,
      );
      await StorageService.saveEqualizerSettings(eq);
      final restoredEq = await StorageService.getEqualizerSettings();
      expect(restoredEq.selectedPreset, 'Rock');
      expect(restoredEq.band60, 7.0);
      expect(restoredEq.virtualizer, isTrue);
      expect(restoredEq.loudness, isFalse);

      // 4. Notifications
      const notif = NotificationSettings(
        newReleases: false,
        playlistUpdates: true,
        recommendations: true,
        lockScreenPlayer: true,
      );
      await StorageService.saveNotificationSettings(notif);
      final restoredNotif = await StorageService.getNotificationSettings();
      expect(restoredNotif.newReleases, isFalse);
      expect(restoredNotif.recommendations, isTrue);

      // 5. Animations
      const anim = AnimationSettings(
        selectedStyle: 'Mangekyou',
        rotationSpeed: 'Fast',
        glowIntensity: 'Low',
        autoPatternChange: false,
      );
      await StorageService.saveAnimationSettings(anim);
      final restoredAnim = await StorageService.getAnimationSettings();
      expect(restoredAnim.selectedStyle, 'Mangekyou');
      expect(restoredAnim.rotationSpeed, 'Fast');
      expect(restoredAnim.autoPatternChange, isFalse);

      // 6. Theme
      await StorageService.saveSelectedTheme('Amaterasu Black');
      final restoredTheme = await StorageService.getSelectedTheme();
      expect(restoredTheme, 'Amaterasu Black');
    });

    test('Test G — Downloads validation (prunes missing/0-byte files, keeps valid files)', () async {
      final tempDir = Directory.systemTemp.createTempSync('liveit_dl_test_');

      // Create a valid non-empty file
      final validFile = File('${tempDir.path}/valid_song.mp3');
      validFile.writeAsBytesSync([1, 2, 3, 4, 5]);

      // Create a 0-byte file
      final emptyFile = File('${tempDir.path}/empty_song.mp3');
      emptyFile.writeAsBytesSync([]);

      final validSong = Song(
        id: 'valid_song',
        title: 'Valid Song',
        artist: 'Azam',
        album: 'Album',
        artworkUrl: '',
        streamUrl: validFile.path,
        durationMs: 100000,
        isDownloaded: true,
        source: MusicSource.local,
      );

      final emptySong = Song(
        id: 'empty_song',
        title: 'Empty Song',
        artist: 'Azam',
        album: 'Album',
        artworkUrl: '',
        streamUrl: emptyFile.path,
        durationMs: 100000,
        isDownloaded: true,
        source: MusicSource.local,
      );

      final missingSong = Song(
        id: 'missing_song',
        title: 'Missing Song',
        artist: 'Azam',
        album: 'Album',
        artworkUrl: '',
        streamUrl: '${tempDir.path}/does_not_exist.mp3',
        durationMs: 100000,
        isDownloaded: true,
        source: MusicSource.local,
      );

      await StorageService.saveDownloadedSongs([
        validSong,
        emptySong,
        missingSong,
      ]);

      // Initialize DownloadService
      final verified = await DownloadService.init();

      // Only validSong should survive validation
      expect(verified.length, 1);
      expect(verified.first.id, 'valid_song');
      expect(DownloadService.getStatus('valid_song'), DownloadStatus.completed);
      expect(
        DownloadService.getStatus('empty_song'),
        isNot(DownloadStatus.completed),
      );
      expect(
        DownloadService.getStatus('missing_song'),
        isNot(DownloadStatus.completed),
      );

      // Cleanup
      try {
        tempDir.deleteSync(recursive: true);
      } catch (_) {}
    });

    test(
      'Test H — Corrupted and malformed JSON recovery without crashing',
      () async {
        final prefs = await SharedPreferences.getInstance();

        // Insert malformed JSON into critical keys
        await prefs.setString('favorite_songs', '{malformed_json...');
        await prefs.setString('user_playlists', '[{"invalid_json":}');
        await prefs.setString('recently_played', 'NOT_JSON_AT_ALL');
        await prefs.setString('saved_queue_tracks', '12345');
        await prefs.setString('settings_playback', 'null');
        await prefs.setString('settings_equalizer', '{corrupt: true');

        // Verify methods recover gracefully without throwing exceptions
        final favorites = await StorageService.getFavorites();
        expect(favorites, isEmpty);

        final playlists = await StorageService.getPlaylists();
        expect(playlists, isEmpty);

        final recentlyPlayed = await StorageService.getRecentlyPlayed();
        expect(recentlyPlayed, isEmpty);

        final queue = await StorageService.getSavedQueue();
        expect(queue, isEmpty);

        final playback = await StorageService.getPlaybackSettings();
        expect(playback.crossfade, isTrue); // Returns default

        final equalizer = await StorageService.getEqualizerSettings();
        expect(equalizer.selectedPreset, 'Custom'); // Returns default
      },
    );

    test('Test I — Rapid concurrent writes preserve latest mutation through mutex queue', () async {
      // Launch 25 rapid concurrent writes to user name
      final futures = <Future<void>>[];
      for (int i = 1; i <= 25; i++) {
        futures.add(StorageService.saveUserName('Azam User #$i'));
      }
      await Future.wait(futures);

      final finalName = await StorageService.getUserName();
      expect(finalName, 'Azam User #25');
    });

    test('Test J — Schema versioning and migration executes safely', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('storage_schema_version', 0);
      await prefs.setString('user_name', 'Azam Uchiha');

      // Run init/migration
      await StorageService.init();

      expect(
        prefs.getInt('storage_schema_version'),
        StorageService.currentSchemaVersion,
      );
      expect(await StorageService.getUserName(), 'Azam Khan');
    });
  });
}
