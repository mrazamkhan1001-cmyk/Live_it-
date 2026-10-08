import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:liveitbyazam/models/song.dart';
import 'package:liveitbyazam/services/audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AudioPlayerService audioService;

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

  final sampleSongs = [
    Song(
      id: 'song_1',
      title: 'Blue Bird',
      artist: 'Ikimono Gakari',
      album: 'Naruto Shippuden',
      artworkUrl: 'https://audius.co/art1.jpg',
      streamUrl: 'https://audius.co/stream1.mp3',
      durationMs: 180000,
      source: MusicSource.audius,
    ),
    Song(
      id: 'song_2',
      title: 'Silhouette',
      artist: 'KANA-BOON',
      album: 'Naruto Shippuden',
      artworkUrl: 'https://audius.co/art2.jpg',
      streamUrl: 'https://audius.co/stream2.mp3',
      durationMs: 200000,
      source: MusicSource.audius,
    ),
    Song(
      id: 'song_3',
      title: 'Sign',
      artist: 'FLOW',
      album: 'Naruto Shippuden',
      artworkUrl: 'https://audius.co/art3.jpg',
      streamUrl: 'https://audius.co/stream3.mp3',
      durationMs: 190000,
      source: MusicSource.audius,
    ),
  ];

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    audioService = AudioPlayerService();
    await audioService.initialized;
  });

  group('Phase 4 Audio Engine - Single Source of Truth & State Tests', () {
    test('Initial state is idle or ready with default queue', () {
      expect(audioService.isShuffle, isFalse);
      expect(audioService.repeatState, RepeatState.off);
      expect(audioService.position, Duration.zero);
      expect(audioService.isPlaying, isFalse);
    });

    test(
      'Queue manipulation: set queue, reorder, add, remove, and clear',
      () async {
        // 1. Play with queue
        await audioService.playSong(
          sampleSongs[0],
          queueList: sampleSongs,
          index: 0,
        );
        expect(audioService.queue.length, 3);
        expect(audioService.currentSong?.id, 'song_1');
        expect(audioService.currentIndex, 0);

        // 2. Add to queue
        final extraSong = Song(
          id: 'song_4',
          title: 'Guren',
          artist: 'DOES',
          album: 'Anime',
          artworkUrl: '',
          streamUrl: 'https://audius.co/stream4.mp3',
          durationMs: 210000,
        );
        audioService.addToQueue(extraSong);
        expect(audioService.queue.length, 4);
        expect(audioService.queue.last.id, 'song_4');

        // 3. Reorder queue
        audioService.reorderQueue(0, 2); // move song_1 to index 1
        expect(audioService.queue[1].id, 'song_1');
        expect(audioService.currentIndex, 1);

        // 4. Remove from queue
        audioService.removeFromQueue(3);
        expect(audioService.queue.length, 3);

        // 5. Clear queue
        audioService.clearQueue();
        expect(audioService.queue.isEmpty, isTrue);
        expect(audioService.currentSong, isNull);
        expect(audioService.currentIndex, 0);
      },
    );

    test('Repeat Modes: off -> all -> one -> off toggle cycle', () {
      expect(audioService.repeatState, RepeatState.off);

      audioService.toggleRepeat();
      expect(audioService.repeatState, RepeatState.all);
      expect(audioService.repeatMode, RepeatMode.all);

      audioService.toggleRepeat();
      expect(audioService.repeatState, RepeatState.one);
      expect(audioService.repeatMode, RepeatMode.one);

      audioService.toggleRepeat();
      expect(audioService.repeatState, RepeatState.off);
      expect(audioService.repeatMode, RepeatMode.off);

      // Explicit setter
      audioService.setRepeatMode(RepeatState.one);
      expect(audioService.repeatState, RepeatState.one);
    });

    test('Shuffle Mode: toggle and setter logic', () {
      expect(audioService.isShuffle, isFalse);
      expect(audioService.shuffleEnabled, isFalse);

      audioService.toggleShuffle();
      expect(audioService.isShuffle, isTrue);
      expect(audioService.shuffleEnabled, isTrue);

      audioService.setShuffle(false);
      expect(audioService.isShuffle, isFalse);
      expect(audioService.shuffleEnabled, isFalse);
    });

    test('Favorite management and persistence updates', () async {
      expect(audioService.isSongFavorite('song_1'), isFalse);

      await audioService.toggleFavorite(sampleSongs[0]);
      expect(audioService.isSongFavorite('song_1'), isTrue);
      expect(audioService.favorites.length, 1);

      await audioService.toggleFavorite(sampleSongs[0]);
      expect(audioService.isSongFavorite('song_1'), isFalse);
      expect(audioService.favorites.isEmpty, isTrue);
    });

    test('Username profile update and formatting', () async {
      await audioService.setUserName('Azam Uchiha');
      expect(audioService.rawUserName, 'Azam Khan');

      await audioService.setUserName('Sasuke');
      expect(audioService.rawUserName, 'Sasuke');
      expect(audioService.uchihaUserName, 'Sasuke');
    });

    test('Stop command resets position and sets idle state', () async {
      await audioService.playSong(
        sampleSongs[0],
        queueList: sampleSongs,
        index: 0,
      );
      await audioService.stop();
      expect(audioService.position, Duration.zero);
      expect(audioService.playbackState, PlaybackState.idle);
    });
  });
}
