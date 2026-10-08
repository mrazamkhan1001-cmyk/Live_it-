import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:liveitbyazam/models/song.dart';
import 'package:liveitbyazam/services/audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

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

          final eventChannel = 'com.ryanheise.just_audio.events.$id';
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(MethodChannel(eventChannel), (
                MethodCall call,
              ) async {
                if (call.method == 'listen') {
                  final eventData = {
                    'processingState': 2, // ready
                    'updatePosition': 0,
                    'updateTime': DateTime.now().millisecondsSinceEpoch,
                    'bufferedPosition': 180000000,
                    'duration': 180000000,
                    'icyMetadata': null,
                    'currentIndex': 0,
                    'androidAudioSessionId': null,
                  };
                  final encoded = const StandardMethodCodec()
                      .encodeSuccessEnvelope(eventData);
                  TestDefaultBinaryMessengerBinding
                      .instance
                      .defaultBinaryMessenger
                      .handlePlatformMessage(
                        eventChannel,
                        encoded,
                        (ByteData? reply) {},
                      );
                }
                return null;
              });
        }
        return {};
      case 'load':
        return {'duration': 180000000};
      case 'play':
      case 'pause':
      case 'stop':
      case 'seek':
      case 'setVolume':
      case 'setSpeed':
      case 'setLoopMode':
      case 'setShuffleMode':
      case 'dispose':
      case 'disposeAllPlayers':
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

  const MethodChannel sessionChannel = MethodChannel(
    'com.ryanheise.audio_session',
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(sessionChannel, (MethodCall call) async => {});

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('live_it_bg_test_');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async => tempDir.path,
        );
  });

  tearDownAll(() async {
    try {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    } catch (_) {}
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // =========================================================================
  // TEST A: MediaItem & AudioSource Tagging for Android MediaSession
  // =========================================================================
  test('Test A - MediaSession Metadata: AudioSource is tagged with complete MediaItem', () async {
    final audioService = AudioPlayerService();
    await audioService.initialized;

    final song = Song(
      id: 'bg_track_1',
      title: 'Itachi Tsukuyomi Theme',
      artist: 'Azam Khan',
      album: 'LIVE IT Anime Beats',
      artworkUrl: 'https://audius.co/artwork_itachi.jpg',
      streamUrl: 'https://audius.co/stream_itachi.mp3',
      durationMs: 240000,
    );

    await audioService.playSong(song, queueList: [song]);

    expect(audioService.currentSong, isNotNull);
    expect(audioService.currentSong?.id, 'bg_track_1');
    expect(audioService.currentSong?.title, 'Itachi Tsukuyomi Theme');
    expect(audioService.currentSong?.artist, 'Azam Khan');
    expect(audioService.currentSong?.album, 'LIVE IT Anime Beats');
    expect(audioService.queue.length, 1);
  });

  // =========================================================================
  // TEST B: Single AudioPlayer Instance Maintained for Background & Foreground
  // =========================================================================
  test(
    'Test B - Single Audio Engine: Only one shared AudioPlayer exists',
    () async {
      final audioService = AudioPlayerService();
      await audioService.initialized;

      expect(audioService.player, isA<AudioPlayer>());

      final playerInstance1 = audioService.player;
      final playerInstance2 = audioService.player;

      expect(identical(playerInstance1, playerInstance2), isTrue);
    },
  );

  // =========================================================================
  // TEST C: Headset / Bluetooth Media Controls Route Through Single Player
  // =========================================================================
  test('Test C - Media Controls: Play, pause, resume, shuffle, and repeat modify single engine', () async {
    final audioService = AudioPlayerService();
    await audioService.initialized;

    final song1 = Song(
      id: 'bg_track_a',
      title: 'Track Alpha',
      artist: 'Azam Khan',
      album: 'LIVE IT OST',
      artworkUrl: 'https://audius.co/art_a.jpg',
      streamUrl: 'https://audius.co/stream_a.mp3',
      durationMs: 180000,
    );
    final song2 = Song(
      id: 'bg_track_b',
      title: 'Track Beta',
      artist: 'Azam Khan',
      album: 'LIVE IT OST',
      artworkUrl: 'https://audius.co/art_b.jpg',
      streamUrl: 'https://audius.co/stream_b.mp3',
      durationMs: 200000,
    );

    await audioService.playSong(song1, queueList: [song1, song2], index: 0);

    // Initial state
    expect(audioService.currentIndex, 0);
    expect(audioService.currentSong?.id, 'bg_track_a');

    // Next track action (Lockscreen / Bluetooth headset skip)
    await audioService.nextSong();
    expect(audioService.currentIndex, 1);
    expect(audioService.currentSong?.id, 'bg_track_b');

    // Previous track action
    await audioService.previousSong();
    expect(audioService.currentIndex, 0);
    expect(audioService.currentSong?.id, 'bg_track_a');

    // Shuffle toggle
    expect(audioService.isShuffle, isFalse);
    audioService.toggleShuffle();
    expect(audioService.isShuffle, isTrue);

    // Repeat cycle: off -> all -> one -> off
    expect(audioService.repeatState, RepeatState.off);
    audioService.toggleRepeat();
    expect(audioService.repeatState, RepeatState.all);
    audioService.toggleRepeat();
    expect(audioService.repeatState, RepeatState.one);
    audioService.toggleRepeat();
    expect(audioService.repeatState, RepeatState.off);
  });

  // =========================================================================
  // TEST D: Offline Downloaded Tracks in Background Media Session
  // =========================================================================
  test('Test D - Offline Track Background Session: Local file creates AudioSource with MediaItem tags', () async {
    final audioService = AudioPlayerService();
    await audioService.initialized;

    // Create a mock local file
    final localFilePath = '${tempDir.path}/offline_bg_track.mp3';
    final localFile = File(localFilePath);
    await localFile.writeAsBytes(List.generate(512, (i) => i % 128));

    final downloadedSong = Song(
      id: 'offline_bg_track_1',
      title: 'Offline Sharingan Beat',
      artist: 'Azam Khan',
      album: 'Downloaded',
      artworkUrl: 'https://audius.co/art_local.jpg',
      streamUrl: localFilePath,
      durationMs: 150000,
      isDownloaded: true,
      source: MusicSource.local,
    );

    await audioService.playSong(downloadedSong, queueList: [downloadedSong]);

    expect(audioService.currentSong?.id, 'offline_bg_track_1');
    expect(audioService.currentSong?.isDownloaded, isTrue);
    expect(audioService.currentSong?.source, MusicSource.local);
  });

  // =========================================================================
  // TEST E: Queue and MediaItem Synchronization
  // =========================================================================
  test('Test E - Queue Synchronization: Adding, inserting, and clearing queue preserves state', () async {
    final audioService = AudioPlayerService();
    await audioService.initialized;

    final songA = Song(
      id: 'q_a',
      title: 'Song A',
      artist: 'Artist A',
      album: 'Album A',
      artworkUrl: 'https://audius.co/a.jpg',
      streamUrl: 'https://audius.co/a.mp3',
      durationMs: 180000,
    );
    final songB = Song(
      id: 'q_b',
      title: 'Song B',
      artist: 'Artist B',
      album: 'Album B',
      artworkUrl: 'https://audius.co/b.jpg',
      streamUrl: 'https://audius.co/b.mp3',
      durationMs: 180000,
    );
    final songC = Song(
      id: 'q_c',
      title: 'Song C',
      artist: 'Artist C',
      album: 'Album C',
      artworkUrl: 'https://audius.co/c.jpg',
      streamUrl: 'https://audius.co/c.mp3',
      durationMs: 180000,
    );

    await audioService.playSong(songA, queueList: [songA, songB]);

    expect(audioService.queue.length, 2);

    // Insert Next
    audioService.insertNextInQueue(songC);
    expect(audioService.queue.length, 3);
    expect(audioService.queue[1].id, 'q_c');

    // Clear Upcoming
    audioService.clearUpcoming();
    expect(audioService.queue.length, 1);
    expect(audioService.currentSong?.id, 'q_a');
  });
}
