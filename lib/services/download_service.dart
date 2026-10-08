import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../models/song.dart';
import 'storage_service.dart';

/// Explicit status states for track downloads
enum DownloadStatus {
  notDownloaded,
  queued,
  downloading,
  completed,
  failed,
  cancelled,
}

/// Phase 10: Robust, Race-Condition-Free Download Service
/// Ensures files are completely written, flushed, validated, and finalized
/// before reporting completion or returning the local file.
class DownloadService extends ChangeNotifier {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  static final Map<String, DownloadStatus> _status = {};
  static final Map<String, double> _progress = {};
  static final Map<String, String> _errorMessages = {};
  static final Map<String, http.Client> _activeClients = {};
  static final Map<String, IOSink> _activeSinks = {};
  static final Map<String, Completer<File?>> _activeCompleters = {};

  static List<Song> _downloadedSongs = [];
  static List<Song> get downloadedSongs => List.unmodifiable(_downloadedSongs);

  /// Check current status of a track
  static DownloadStatus getStatus(String songId) {
    if (_downloadedSongs.any((s) => s.id == songId)) {
      return DownloadStatus.completed;
    }
    return _status[songId] ?? DownloadStatus.notDownloaded;
  }

  /// Check current progress (0.0 to 1.0)
  static double getProgress(String songId) => _progress[songId] ?? 0.0;

  /// Check error message if failed
  static String? getErrorMessage(String songId) => _errorMessages[songId];

  /// Initialize and restore verified downloaded songs from storage on app launch
  static Future<List<Song>> init() async {
    final savedSongs = await StorageService.getDownloadedSongs();
    final List<Song> verifiedSongs = [];

    final dir = await _getDownloadsDirectory();

    // Clean up any stale .tmp files from previous interrupted sessions
    try {
      if (await dir.exists()) {
        final entities = dir.listSync();
        for (final entity in entities) {
          if (entity is File && entity.path.endsWith('.tmp')) {
            try {
              entity.deleteSync();
            } catch (_) {}
          }
        }
      }
    } catch (_) {}

    // Verify each saved song's local file actually exists and is non-empty
    for (final song in savedSongs) {
      final file = File(song.streamUrl);
      if (await file.exists() && (await file.length()) > 0) {
        verifiedSongs.add(song);
        _status[song.id] = DownloadStatus.completed;
        _progress[song.id] = 1.0;
      }
    }

    _downloadedSongs = verifiedSongs;
    await StorageService.saveDownloadedSongs(verifiedSongs);
    _instance.notifyListeners();
    return verifiedSongs;
  }

  /// Get or create downloads directory in application storage
  static Future<Directory> _getDownloadsDirectory() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${appDir.path}/downloads');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      return downloadDir;
    } catch (_) {
      // Fallback for testing environments or platforms without path_provider channel
      final tempDir = Directory.systemTemp;
      final downloadDir = Directory('${tempDir.path}/live_it_downloads');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      return downloadDir;
    }
  }

  /// Download a track with provider permission check, atomic file finalization,
  /// and guaranteed completion awaiting.
  static Future<File?> downloadSong(
    Song song, {
    void Function(double progress)? onProgress,
    http.Client? customClient,
  }) async {
    // 1. Check provider download permission
    if (!song.isDownloadable) {
      _status[song.id] = DownloadStatus.failed;
      _errorMessages[song.id] =
          'Track cannot be downloaded (provider permission restricted).';
      _instance.notifyListeners();
      return null;
    }

    // 2. Check if already downloading (prevent duplicate concurrent writes)
    if (_activeCompleters.containsKey(song.id)) {
      return _activeCompleters[song.id]!.future;
    }

    final completer = Completer<File?>();
    _activeCompleters[song.id] = completer;

    final downloadDir = await _getDownloadsDirectory();
    final finalFilePath = '${downloadDir.path}/${song.id}.mp3';
    final tempFilePath = '${downloadDir.path}/${song.id}.tmp';

    final finalFile = File(finalFilePath);
    final tempFile = File(tempFilePath);

    // 3. If valid completed file already exists on disk
    if (await finalFile.exists() && (await finalFile.length()) > 0) {
      _status[song.id] = DownloadStatus.completed;
      _progress[song.id] = 1.0;
      onProgress?.call(1.0);
      _activeCompleters.remove(song.id);
      completer.complete(finalFile);
      _instance.notifyListeners();
      return finalFile;
    }

    // 4. Initialize download task state
    _status[song.id] = DownloadStatus.downloading;
    _progress[song.id] = 0.0;
    _errorMessages.remove(song.id);
    _instance.notifyListeners();

    // Clean up stale temp file if present
    if (await tempFile.exists()) {
      try {
        await tempFile.delete();
      } catch (_) {}
    }

    final client = customClient ?? http.Client();
    _activeClients[song.id] = client;
    IOSink? sink;

    try {
      final request = http.Request('GET', Uri.parse(song.streamUrl));
      final response = await client.send(request);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException('Server returned HTTP ${response.statusCode}');
      }

      final totalBytes = response.contentLength ?? 0;
      int downloadedBytes = 0;

      sink = tempFile.openWrite();
      _activeSinks[song.id] = sink;

      await response.stream.forEach((chunk) {
        if (_status[song.id] == DownloadStatus.cancelled) {
          throw Exception('Download cancelled by user.');
        }

        sink!.add(chunk);
        downloadedBytes += chunk.length;

        if (totalBytes > 0) {
          final p = (downloadedBytes / totalBytes).clamp(0.0, 1.0);
          _progress[song.id] = p;
          onProgress?.call(p);
        } else {
          // Indeterminate progress representation
          _progress[song.id] = 0.5;
          onProgress?.call(0.5);
        }
        _instance.notifyListeners();
      });

      // 5. Complete and flush file writing
      await sink.flush();
      await sink.close();
      sink = null;
      _activeSinks.remove(song.id);

      // 6. Validate written file integrity
      if (!await tempFile.exists()) {
        throw Exception('Temporary download file was not created.');
      }

      final writtenLength = await tempFile.length();
      if (writtenLength == 0) {
        throw Exception('Downloaded file is empty (0 bytes).');
      }

      if (totalBytes > 0 && writtenLength < totalBytes) {
        throw Exception(
          'Incomplete download: received $writtenLength of $totalBytes bytes.',
        );
      }

      // 7. Atomic rename commit from .tmp to .mp3
      if (await finalFile.exists()) {
        try {
          await finalFile.delete();
        } catch (_) {}
      }
      try {
        await tempFile.rename(finalFilePath);
      } catch (_) {
        await tempFile.copy(finalFilePath);
        try {
          await tempFile.delete();
        } catch (_) {}
      }

      // 8. Commit status ONLY after full completion
      _status[song.id] = DownloadStatus.completed;
      _progress[song.id] = 1.0;
      onProgress?.call(1.0);

      final localSong = song.copyWith(
        isDownloaded: true,
        streamUrl: finalFilePath,
        source: MusicSource.local,
      );

      _downloadedSongs.removeWhere((s) => s.id == song.id);
      _downloadedSongs.insert(0, localSong);
      await StorageService.addDownloadedSong(localSong);

      completer.complete(finalFile);
      _instance.notifyListeners();
      return finalFile;
    } catch (e) {
      // Clean up on failure or cancellation
      try {
        await sink?.close();
      } catch (_) {}
      _activeSinks.remove(song.id);

      if (await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }

      if (_status[song.id] != DownloadStatus.cancelled) {
        _status[song.id] = DownloadStatus.failed;
        _errorMessages[song.id] = e.toString();
      }

      _progress.remove(song.id);
      completer.complete(null);
      _instance.notifyListeners();
      return null;
    } finally {
      client.close();
      _activeClients.remove(song.id);
      _activeCompleters.remove(song.id);
    }
  }

  /// Cancel an ongoing download
  static Future<void> cancelDownload(String songId) async {
    _status[songId] = DownloadStatus.cancelled;
    _activeClients[songId]?.close();
    try {
      await _activeSinks[songId]?.close();
    } catch (_) {}

    _activeClients.remove(songId);
    _activeSinks.remove(songId);
    _progress.remove(songId);

    try {
      final dir = await _getDownloadsDirectory();
      final tempFile = File('${dir.path}/$songId.tmp');
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    } catch (_) {}

    _instance.notifyListeners();
  }

  /// Delete a downloaded track from local device
  static Future<bool> deleteDownload(String songId) async {
    try {
      final dir = await _getDownloadsDirectory();
      final file = File('${dir.path}/$songId.mp3');
      if (await file.exists()) {
        await file.delete();
      }

      _downloadedSongs.removeWhere((s) => s.id == songId);
      await StorageService.removeDownloadedSong(songId);

      _status[songId] = DownloadStatus.notDownloaded;
      _progress.remove(songId);
      _errorMessages.remove(songId);

      _instance.notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Clear all downloaded tracks from device
  static Future<void> clearAllDownloads() async {
    try {
      final dir = await _getDownloadsDirectory();
      if (await dir.exists()) {
        final entities = dir.listSync();
        for (final entity in entities) {
          if (entity is File) {
            try {
              entity.deleteSync();
            } catch (_) {}
          }
        }
      }

      _downloadedSongs.clear();
      await StorageService.saveDownloadedSongs([]);
      _status.clear();
      _progress.clear();
      _errorMessages.clear();

      _instance.notifyListeners();
    } catch (_) {}
  }

  /// Get total disk space used by downloaded tracks in bytes
  static Future<int> getTotalDownloadSizeBytes() async {
    try {
      final dir = await _getDownloadsDirectory();
      if (!await dir.exists()) return 0;
      int total = 0;
      final entities = dir.listSync();
      for (final entity in entities) {
        if (entity is File && entity.path.endsWith('.mp3')) {
          try {
            total += entity.lengthSync();
          } catch (_) {}
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }
}
