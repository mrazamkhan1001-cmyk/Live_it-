import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:liveitbyazam/models/song.dart';
import 'package:liveitbyazam/services/audio_service.dart';
import 'package:liveitbyazam/services/download_service.dart';
import 'package:liveitbyazam/services/storage_service.dart';

/// Custom Mock Client for testing download streams and failure scenarios
class MockStreamClient extends http.BaseClient {
  final Future<http.StreamedResponse> Function(http.BaseRequest request)
  handler;

  MockStreamClient(this.handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      handler(request);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory testDir;

  setUpAll(() async {
    testDir = await Directory.systemTemp.createTemp('live_it_download_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            return testDir.path;
          },
        );
  });

  tearDownAll(() async {
    try {
      if (await testDir.exists()) {
        await testDir.delete(recursive: true);
      }
    } catch (_) {}
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await DownloadService.clearAllDownloads();
  });

  // =========================================================================
  // TEST A: Completion waits for writing (Fixing Asynchronous Race Condition)
  // =========================================================================
  test('Test A - Completion waits for writing: download not complete until file fully written', () async {
    final song = Song(
      id: 'track_race_condition_test',
      title: 'Uchiha Requiem',
      artist: 'Azam Khan',
      album: 'Live It OST',
      artworkUrl: 'https://example.com/art.jpg',
      streamUrl: 'https://example.com/stream.mp3',
      durationMs: 180000,
      isDownloadable: true,
    );

    final streamController = StreamController<List<int>>();
    final testBytes = utf8.encode('LiveItCompleteAudioPayloadData1234567890');

    final mockClient = MockStreamClient((request) async {
      return http.StreamedResponse(
        streamController.stream,
        200,
        contentLength: testBytes.length,
      );
    });

    // 1. Initiate download
    final downloadFuture = DownloadService.downloadSong(
      song,
      customClient: mockClient,
    );

    // 2. Allow download task to start
    await Future.delayed(const Duration(milliseconds: 30));

    // Verify status is downloading, NOT completed
    expect(DownloadService.getStatus(song.id), DownloadStatus.downloading);
    expect(
      DownloadService.downloadedSongs.any((s) => s.id == song.id),
      isFalse,
    );

    // 3. Emit partial chunk
    streamController.add(testBytes.sublist(0, 10));
    await Future.delayed(const Duration(milliseconds: 20));

    // Still downloading
    expect(DownloadService.getStatus(song.id), DownloadStatus.downloading);
    expect(
      DownloadService.downloadedSongs.any((s) => s.id == song.id),
      isFalse,
    );

    // 4. Emit remaining bytes and close stream
    streamController.add(testBytes.sublist(10));
    await streamController.close();

    // 5. Await full completion
    final savedFile = await downloadFuture;

    // 6. Verify completion is reported only after write & rename finalized
    expect(savedFile, isNotNull);
    expect(await savedFile!.exists(), isTrue);
    expect(DownloadService.getStatus(song.id), DownloadStatus.completed);
    expect(DownloadService.downloadedSongs.any((s) => s.id == song.id), isTrue);
  });

  // =========================================================================
  // TEST B: File integrity validation
  // =========================================================================
  test('Test B - File integrity: saved file matches downloaded payload and validates size', () async {
    final song = Song(
      id: 'track_integrity_test',
      title: 'Sharingan Theme',
      artist: 'Azam Khan',
      album: 'Live It OST',
      artworkUrl: 'https://example.com/art.jpg',
      streamUrl: 'https://example.com/stream.mp3',
      durationMs: 200000,
      isDownloadable: true,
    );

    final expectedPayload = List.generate(1024, (i) => i % 256);

    final mockClient = MockStreamClient((request) async {
      return http.StreamedResponse(
        Stream.value(expectedPayload),
        200,
        contentLength: expectedPayload.length,
      );
    });

    final file = await DownloadService.downloadSong(
      song,
      customClient: mockClient,
    );

    expect(file, isNotNull);
    expect(await file!.length(), expectedPayload.length);
    final savedBytes = await file.readAsBytes();
    expect(savedBytes, expectedPayload);
    expect(DownloadService.getStatus(song.id), DownloadStatus.completed);
  });

  // =========================================================================
  // TEST C: Interrupted download handling
  // =========================================================================
  test('Test C - Interrupted download: network failure cleans up temp files without marking complete', () async {
    final song = Song(
      id: 'track_interrupted_test',
      title: 'Broken Connection',
      artist: 'Azam Khan',
      album: 'Live It OST',
      artworkUrl: 'https://example.com/art.jpg',
      streamUrl: 'https://example.com/stream.mp3',
      durationMs: 150000,
      isDownloadable: true,
    );

    final streamController = StreamController<List<int>>();

    final mockClient = MockStreamClient((request) async {
      return http.StreamedResponse(
        streamController.stream,
        200,
        contentLength: 1000,
      );
    });

    final downloadFuture = DownloadService.downloadSong(
      song,
      customClient: mockClient,
    );

    await Future.delayed(const Duration(milliseconds: 20));
    streamController.add([1, 2, 3, 4, 5]);

    // Simulate network error mid-download
    streamController.addError(
      const SocketException('Network connection severed'),
    );
    await streamController.close();

    final result = await downloadFuture;

    expect(result, isNull);
    expect(DownloadService.getStatus(song.id), DownloadStatus.failed);
    expect(
      DownloadService.downloadedSongs.any((s) => s.id == song.id),
      isFalse,
    );

    // Verify no stray partial files
    final dir = Directory('${testDir.path}/downloads');
    if (await dir.exists()) {
      final tmpFile = File('${dir.path}/${song.id}.tmp');
      final mp3File = File('${dir.path}/${song.id}.mp3');
      expect(await tmpFile.exists(), isFalse);
      expect(await mp3File.exists(), isFalse);
    }
  });

  // =========================================================================
  // TEST D: Cancellation
  // =========================================================================
  test('Test D - Cancellation: stops download, removes temporary files, sets cancelled status', () async {
    final song = Song(
      id: 'track_cancel_test',
      title: 'Cancelled Track',
      artist: 'Azam Khan',
      album: 'Live It OST',
      artworkUrl: 'https://example.com/art.jpg',
      streamUrl: 'https://example.com/stream.mp3',
      durationMs: 190000,
      isDownloadable: true,
    );

    final streamController = StreamController<List<int>>();

    final mockClient = MockStreamClient((request) async {
      return http.StreamedResponse(
        streamController.stream,
        200,
        contentLength: 5000,
      );
    });

    final downloadFuture = DownloadService.downloadSong(
      song,
      customClient: mockClient,
    );

    await Future.delayed(const Duration(milliseconds: 20));
    streamController.add([1, 2, 3]);

    // Cancel download
    await DownloadService.cancelDownload(song.id);

    final result = await downloadFuture;

    expect(result, isNull);
    expect(DownloadService.getStatus(song.id), DownloadStatus.cancelled);
    expect(
      DownloadService.downloadedSongs.any((s) => s.id == song.id),
      isFalse,
    );

    // Clean up stream controller
    try {
      await streamController.close();
    } catch (_) {}
  });

  // =========================================================================
  // TEST E: Concurrent duplicate requests prevented
  // =========================================================================
  test('Test E - Concurrent requests: multiple requests for same song return identical Future', () async {
    final song = Song(
      id: 'track_concurrent_test',
      title: 'Simultaneous Stream',
      artist: 'Azam Khan',
      album: 'Live It OST',
      artworkUrl: 'https://example.com/art.jpg',
      streamUrl: 'https://example.com/stream.mp3',
      durationMs: 210000,
      isDownloadable: true,
    );

    final payload = utf8.encode('ConcurrentPayload');

    final mockClient = MockStreamClient((request) async {
      await Future.delayed(const Duration(milliseconds: 30));
      return http.StreamedResponse(
        Stream.value(payload),
        200,
        contentLength: payload.length,
      );
    });

    final future1 = DownloadService.downloadSong(
      song,
      customClient: mockClient,
    );
    final future2 = DownloadService.downloadSong(
      song,
      customClient: mockClient,
    );

    final results = await Future.wait([future1, future2]);

    expect(results[0], isNotNull);
    expect(results[1], isNotNull);
    expect(results[0]!.path, results[1]!.path);
    expect(DownloadService.getStatus(song.id), DownloadStatus.completed);
  });

  // =========================================================================
  // TEST F: Provider permission restriction enforcement
  // =========================================================================
  test('Test F - Provider permissions: non-downloadable tracks are rejected immediately', () async {
    final restrictedSong = Song(
      id: 'track_restricted_test',
      title: 'Restricted Audio',
      artist: 'Audius Exclusive',
      album: 'Protected Album',
      artworkUrl: 'https://example.com/art.jpg',
      streamUrl: 'https://example.com/stream.mp3',
      durationMs: 180000,
      isDownloadable: false, // Provider denies download
    );

    final result = await DownloadService.downloadSong(restrictedSong);

    expect(result, isNull);
    expect(DownloadService.getStatus(restrictedSong.id), DownloadStatus.failed);
    expect(
      DownloadService.getErrorMessage(restrictedSong.id),
      contains('provider permission'),
    );
    expect(
      DownloadService.downloadedSongs.any((s) => s.id == restrictedSong.id),
      isFalse,
    );
  });

  // =========================================================================
  // TEST G: Restart recovery & stale record cleanup
  // =========================================================================
  test('Test G - Restart recovery: verifies existing files and drops stale missing records', () async {
    final validSong = Song(
      id: 'track_restart_valid',
      title: 'Valid Saved Track',
      artist: 'Azam Khan',
      album: 'Live It OST',
      artworkUrl: 'https://example.com/art.jpg',
      streamUrl: 'https://example.com/stream.mp3',
      durationMs: 180000,
      isDownloadable: true,
    );

    final mockClient = MockStreamClient((request) async {
      return http.StreamedResponse(
        Stream.value(utf8.encode('ValidAudioData')),
        200,
        contentLength: 14,
      );
    });

    // 1. Download valid song
    await DownloadService.downloadSong(validSong, customClient: mockClient);

    // 2. Inject a stale record into storage whose local file does not exist
    final staleSong = Song(
      id: 'track_stale_ghost',
      title: 'Ghost Track',
      artist: 'Azam Khan',
      album: 'Live It OST',
      artworkUrl: 'https://example.com/art.jpg',
      streamUrl: '${testDir.path}/downloads/non_existent_file.mp3',
      durationMs: 180000,
      isDownloaded: true,
      source: MusicSource.local,
    );
    await StorageService.addDownloadedSong(staleSong);

    // 3. Re-initialize DownloadService (simulating app restart)
    final restoredSongs = await DownloadService.init();

    // 4. Verify valid song is kept and ghost song is purged
    expect(restoredSongs.any((s) => s.id == 'track_restart_valid'), isTrue);
    expect(restoredSongs.any((s) => s.id == 'track_stale_ghost'), isFalse);
    expect(
      DownloadService.getStatus('track_restart_valid'),
      DownloadStatus.completed,
    );
    expect(
      DownloadService.getStatus('track_stale_ghost'),
      DownloadStatus.notDownloaded,
    );
  });

  // =========================================================================
  // TEST H: Safe Deletion & Storage Accounting
  // =========================================================================
  test('Test H - Safe Deletion: deletes local file and updates storage metrics accurately', () async {
    final song = Song(
      id: 'track_delete_test',
      title: 'Temporary Track',
      artist: 'Azam Khan',
      album: 'Live It OST',
      artworkUrl: 'https://example.com/art.jpg',
      streamUrl: 'https://example.com/stream.mp3',
      durationMs: 180000,
      isDownloadable: true,
    );

    final testPayload = utf8.encode('DeleteMeAudioPayload12345');

    final mockClient = MockStreamClient((request) async {
      return http.StreamedResponse(
        Stream.value(testPayload),
        200,
        contentLength: testPayload.length,
      );
    });

    await DownloadService.downloadSong(song, customClient: mockClient);

    final bytesBefore = await DownloadService.getTotalDownloadSizeBytes();
    expect(bytesBefore, testPayload.length);

    // Delete download
    final success = await DownloadService.deleteDownload(song.id);

    expect(success, isTrue);
    expect(DownloadService.getStatus(song.id), DownloadStatus.notDownloaded);
    expect(
      DownloadService.downloadedSongs.any((s) => s.id == song.id),
      isFalse,
    );

    final bytesAfter = await DownloadService.getTotalDownloadSizeBytes();
    expect(bytesAfter, 0);
  });

  // =========================================================================
  // TEST I: AudioPlayerService Offline File Integration
  // =========================================================================
  test('Test I - Offline Playback: AudioPlayerService exposes downloaded songs and uses single player', () async {
    final audioService = AudioPlayerService();
    await audioService.initialized;

    expect(audioService.player, isNotNull);
    expect(audioService.downloadedSongs, isA<List<Song>>());
  });
}
