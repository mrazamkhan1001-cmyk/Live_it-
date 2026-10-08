import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

import '../models/song.dart';
import '../models/playlist.dart';

/// User profile data model for non-sensitive profile information
class UserProfile {
  final String name;
  final String username;
  final String bio;

  const UserProfile({
    required this.name,
    required this.username,
    required this.bio,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'username': username,
    'bio': bio,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name']?.toString() ?? 'Azam Khan',
      username: json['username']?.toString() ?? 'azam_uchiha',
      bio: json['bio']?.toString() ?? 'Music for the ones who understand...',
    );
  }
}

/// Persistent Audio Quality Settings
class AudioQualitySettings {
  final String streamQuality;
  final String downloadQuality;

  const AudioQualitySettings({
    this.streamQuality = 'High',
    this.downloadQuality = 'Very High',
  });

  Map<String, dynamic> toJson() => {
    'streamQuality': streamQuality,
    'downloadQuality': downloadQuality,
  };

  factory AudioQualitySettings.fromJson(Map<String, dynamic> json) {
    return AudioQualitySettings(
      streamQuality: json['streamQuality']?.toString() ?? 'High',
      downloadQuality: json['downloadQuality']?.toString() ?? 'Very High',
    );
  }
}

/// Persistent Playback Preferences
class PlaybackSettings {
  final bool crossfade;
  final double crossfadeDuration;
  final bool gaplessPlayback;
  final bool normalizeVolume;
  final bool audioFocus;
  final bool resumePlayback;

  const PlaybackSettings({
    this.crossfade = true,
    this.crossfadeDuration = 3.0,
    this.gaplessPlayback = true,
    this.normalizeVolume = true,
    this.audioFocus = true,
    this.resumePlayback = true,
  });

  Map<String, dynamic> toJson() => {
    'crossfade': crossfade,
    'crossfadeDuration': crossfadeDuration,
    'gaplessPlayback': gaplessPlayback,
    'normalizeVolume': normalizeVolume,
    'audioFocus': audioFocus,
    'resumePlayback': resumePlayback,
  };

  factory PlaybackSettings.fromJson(Map<String, dynamic> json) {
    return PlaybackSettings(
      crossfade: json['crossfade'] != false,
      crossfadeDuration: (json['crossfadeDuration'] as num?)?.toDouble() ?? 3.0,
      gaplessPlayback: json['gaplessPlayback'] != false,
      normalizeVolume: json['normalizeVolume'] != false,
      audioFocus: json['audioFocus'] != false,
      resumePlayback: json['resumePlayback'] != false,
    );
  }
}

/// Persistent Equalizer Settings
class EqualizerSettings {
  final String selectedPreset;
  final double band60;
  final double band230;
  final double band910;
  final double band3k6;
  final double band14k;
  final bool bassBoost;
  final bool virtualizer;
  final bool loudness;

  const EqualizerSettings({
    this.selectedPreset = 'Custom',
    this.band60 = 5.0,
    this.band230 = 2.0,
    this.band910 = 0.0,
    this.band3k6 = 6.0,
    this.band14k = 4.0,
    this.bassBoost = true,
    this.virtualizer = false,
    this.loudness = true,
  });

  Map<String, dynamic> toJson() => {
    'selectedPreset': selectedPreset,
    'band60': band60,
    'band230': band230,
    'band910': band910,
    'band3k6': band3k6,
    'band14k': band14k,
    'bassBoost': bassBoost,
    'virtualizer': virtualizer,
    'loudness': loudness,
  };

  factory EqualizerSettings.fromJson(Map<String, dynamic> json) {
    return EqualizerSettings(
      selectedPreset: json['selectedPreset']?.toString() ?? 'Custom',
      band60: (json['band60'] as num?)?.toDouble() ?? 5.0,
      band230: (json['band230'] as num?)?.toDouble() ?? 2.0,
      band910: (json['band910'] as num?)?.toDouble() ?? 0.0,
      band3k6: (json['band3k6'] as num?)?.toDouble() ?? 6.0,
      band14k: (json['band14k'] as num?)?.toDouble() ?? 4.0,
      bassBoost: json['bassBoost'] != false,
      virtualizer: json['virtualizer'] == true,
      loudness: json['loudness'] != false,
    );
  }
}

/// Persistent Notification Settings
class NotificationSettings {
  final bool newReleases;
  final bool playlistUpdates;
  final bool recommendations;
  final bool lockScreenPlayer;

  const NotificationSettings({
    this.newReleases = true,
    this.playlistUpdates = true,
    this.recommendations = false,
    this.lockScreenPlayer = true,
  });

  Map<String, dynamic> toJson() => {
    'newReleases': newReleases,
    'playlistUpdates': playlistUpdates,
    'recommendations': recommendations,
    'lockScreenPlayer': lockScreenPlayer,
  };

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      newReleases: json['newReleases'] != false,
      playlistUpdates: json['playlistUpdates'] != false,
      recommendations: json['recommendations'] == true,
      lockScreenPlayer: json['lockScreenPlayer'] != false,
    );
  }
}

/// Persistent Sharingan Animation Settings
class AnimationSettings {
  final String selectedStyle;
  final String rotationSpeed;
  final String glowIntensity;
  final bool autoPatternChange;

  const AnimationSettings({
    this.selectedStyle = 'Sharingan (Default)',
    this.rotationSpeed = 'Medium',
    this.glowIntensity = 'High',
    this.autoPatternChange = true,
  });

  Map<String, dynamic> toJson() => {
    'selectedStyle': selectedStyle,
    'rotationSpeed': rotationSpeed,
    'glowIntensity': glowIntensity,
    'autoPatternChange': autoPatternChange,
  };

  factory AnimationSettings.fromJson(Map<String, dynamic> json) {
    return AnimationSettings(
      selectedStyle: json['selectedStyle']?.toString() ?? 'Sharingan (Default)',
      rotationSpeed: json['rotationSpeed']?.toString() ?? 'Medium',
      glowIntensity: json['glowIntensity']?.toString() ?? 'High',
      autoPatternChange: json['autoPatternChange'] != false,
    );
  }
}

/// Centralized, Defensive Persistence Layer for LIVE IT — BY AZAM KHAN
/// Manages SharedPreferences storage with schema versioning, defensive error recovery,
/// write serialization locking, and robust restoration across app restarts.
class StorageService {
  // Schema versioning
  static const int currentSchemaVersion = 1;
  static const String _keySchemaVersion = 'storage_schema_version';

  // Storage Keys
  static const String _keyUserName = 'user_name';
  static const String _keyUserProfile = 'user_profile';
  static const String _keyFavorites = 'favorite_songs';
  static const String _keyPlaylists = 'user_playlists';
  static const String _keyRecentlyPlayed = 'recently_played';
  static const String _keyRecentSearches = 'recent_searches';
  static const String _keyDownloadedSongs = 'downloaded_songs';

  // Playback & Queue Keys
  static const String _keySavedQueue = 'saved_queue_tracks';
  static const String _keyQueueIndex = 'saved_queue_index';
  static const String _keyShuffleState = 'saved_shuffle_state';
  static const String _keyRepeatState = 'saved_repeat_state';
  static const String _keySavedPositionSongId = 'saved_position_song_id';
  static const String _keySavedPositionMs = 'saved_position_ms';

  // Settings Keys
  static const String _keyAudioQuality = 'settings_audio_quality';
  static const String _keyPlaybackSettings = 'settings_playback';
  static const String _keyEqualizer = 'settings_equalizer';
  static const String _keyTheme = 'settings_theme';
  static const String _keyNotificationSettings = 'settings_notifications';
  static const String _keyAnimationSettings = 'settings_animations';

  // Async write queue mutex to prevent out-of-order writes
  static Future<void> _writeQueue = Future.value();

  /// Execute an asynchronous write operation sequentially through the mutex queue
  static Future<T> _enqueueWrite<T>(Future<T> Function() operation) {
    final completer = Completer<T>();
    _writeQueue = _writeQueue
        .then((_) => operation())
        .then((result) {
          completer.complete(result);
        })
        .catchError((Object error, StackTrace stackTrace) {
          developer.log(
            'StorageService write error: $error',
            error: error,
            stackTrace: stackTrace,
          );
          completer.completeError(error, stackTrace);
        });
    return completer.future;
  }

  /// Initialize storage and perform schema migration if necessary
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedVersion = prefs.getInt(_keySchemaVersion) ?? 0;
      if (savedVersion < currentSchemaVersion) {
        await _runMigrations(prefs, savedVersion, currentSchemaVersion);
        await prefs.setInt(_keySchemaVersion, currentSchemaVersion);
      }
    } catch (e) {
      developer.log('StorageService init error: $e');
    }
  }

  static Future<void> _runMigrations(
    SharedPreferences prefs,
    int oldVersion,
    int newVersion,
  ) async {
    // Version 0 -> 1: Standardize user name and validate json payloads
    if (oldVersion < 1) {
      final oldName = prefs.getString(_keyUserName);
      if (oldName == 'Azam' || oldName == 'Azam Uchiha') {
        await prefs.setString(_keyUserName, 'Azam Khan');
      }
    }
  }

  // --- USER PROFILE ---

  static Future<String> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_keyUserName);
      if (name == null ||
          name.isEmpty ||
          name == 'Azam' ||
          name == 'Azam Uchiha') {
        return 'Azam Khan';
      }
      return name;
    } catch (_) {
      return 'Azam Khan';
    }
  }

  static Future<void> saveUserName(String name) async {
    return _enqueueWrite(() async {
      final prefs = await SharedPreferences.getInstance();
      final cleanName = name.trim().isEmpty ? 'Azam Khan' : name.trim();
      await prefs.setString(_keyUserName, cleanName);
    });
  }

  static Future<UserProfile> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keyUserProfile);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final map = jsonDecode(jsonStr);
        if (map is Map<String, dynamic>) {
          return UserProfile.fromJson(map);
        }
      }
      final name = await getUserName();
      return UserProfile(
        name: name,
        username: '${name.toLowerCase().replaceAll(' ', '_')}_uchiha',
        bio: 'Music for the ones who understand...',
      );
    } catch (_) {
      return const UserProfile(
        name: 'Azam Khan',
        username: 'azam_uchiha',
        bio: 'Music for the ones who understand...',
      );
    }
  }

  static Future<void> saveUserProfile(UserProfile profile) async {
    return _enqueueWrite(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserProfile, jsonEncode(profile.toJson()));
      await prefs.setString(_keyUserName, profile.name);
    });
  }

  // --- FAVORITES ---

  static Future<List<Song>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keyFavorites);
      if (jsonStr == null || jsonStr.isEmpty) return [];
      final List list = jsonDecode(jsonStr);
      final List<Song> results = [];
      final Set<String> seenIds = {};

      for (final item in list) {
        if (item is Map<String, dynamic>) {
          try {
            final song = Song.fromJson(item);
            if (song.id.isNotEmpty && !seenIds.contains(song.id)) {
              seenIds.add(song.id);
              results.add(song.copyWith(isFavorite: true));
            }
          } catch (_) {}
        }
      }
      return results;
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveFavorites(List<Song> songs) async {
    return _enqueueWrite(() async {
      final prefs = await SharedPreferences.getInstance();
      final Set<String> seenIds = {};
      final List<Map<String, dynamic>> serialized = [];

      for (final s in songs) {
        if (s.id.isNotEmpty && !seenIds.contains(s.id)) {
          seenIds.add(s.id);
          serialized.add(s.copyWith(isFavorite: true).toJson());
        }
      }
      await prefs.setString(_keyFavorites, jsonEncode(serialized));
    });
  }

  // --- PLAYLISTS ---

  static Future<List<Playlist>> getPlaylists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keyPlaylists);
      if (jsonStr == null || jsonStr.isEmpty) return [];
      final List list = jsonDecode(jsonStr);
      final List<Playlist> results = [];
      final Set<String> seenIds = {};

      for (final item in list) {
        if (item is Map<String, dynamic>) {
          try {
            final playlist = Playlist.fromJson(item);
            if (playlist.id.isNotEmpty && !seenIds.contains(playlist.id)) {
              seenIds.add(playlist.id);
              results.add(playlist);
            }
          } catch (_) {}
        }
      }
      return results;
    } catch (_) {
      return [];
    }
  }

  static Future<void> savePlaylists(List<Playlist> playlists) async {
    return _enqueueWrite(() async {
      final prefs = await SharedPreferences.getInstance();
      final Set<String> seenIds = {};
      final List<Map<String, dynamic>> serialized = [];

      for (final p in playlists) {
        if (p.id.isNotEmpty && !seenIds.contains(p.id)) {
          seenIds.add(p.id);
          serialized.add(p.toJson());
        }
      }
      await prefs.setString(_keyPlaylists, jsonEncode(serialized));
    });
  }

  // --- RECENTLY PLAYED ---

  static Future<List<Song>> getRecentlyPlayed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keyRecentlyPlayed);
      if (jsonStr == null || jsonStr.isEmpty) return [];
      final List list = jsonDecode(jsonStr);
      final List<Song> results = [];
      final Set<String> seenIds = {};

      for (final item in list) {
        if (item is Map<String, dynamic>) {
          try {
            final song = Song.fromJson(item);
            if (song.id.isNotEmpty && !seenIds.contains(song.id)) {
              seenIds.add(song.id);
              results.add(song);
            }
          } catch (_) {}
        }
      }
      return results;
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveRecentlyPlayed(
    List<Song> songs, {
    int limit = 50,
  }) async {
    return _enqueueWrite(() async {
      final prefs = await SharedPreferences.getInstance();
      final Set<String> seenIds = {};
      final List<Map<String, dynamic>> serialized = [];

      for (final s in songs) {
        if (s.id.isNotEmpty && !seenIds.contains(s.id)) {
          seenIds.add(s.id);
          serialized.add(s.toJson());
          if (serialized.length >= limit) break;
        }
      }
      await prefs.setString(_keyRecentlyPlayed, jsonEncode(serialized));
    });
  }

  // --- QUEUE & PLAYBACK PERSISTENCE ---

  static Future<List<Song>> getSavedQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keySavedQueue);
      if (jsonStr == null || jsonStr.isEmpty) return [];
      final List list = jsonDecode(jsonStr);
      final List<Song> results = [];
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          try {
            final song = Song.fromJson(item);
            if (song.id.isNotEmpty) {
              results.add(song);
            }
          } catch (_) {}
        }
      }
      return results;
    } catch (_) {
      return [];
    }
  }

  static Future<int> getSavedQueueIndex() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyQueueIndex) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  static Future<void> saveQueue(List<Song> queue, int currentIndex) async {
    return _enqueueWrite(() async {
      final prefs = await SharedPreferences.getInstance();
      final serialized = queue.map((s) => s.toJson()).toList();
      await prefs.setString(_keySavedQueue, jsonEncode(serialized));
      await prefs.setInt(_keyQueueIndex, currentIndex);
    });
  }

  static Future<bool> getSavedShuffleState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyShuffleState) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> saveShuffleState(bool enabled) async {
    return _enqueueWrite(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyShuffleState, enabled);
    });
  }

  static Future<String> getSavedRepeatState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyRepeatState) ?? 'off';
    } catch (_) {
      return 'off';
    }
  }

  static Future<void> saveRepeatState(String stateName) async {
    return _enqueueWrite(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyRepeatState, stateName);
    });
  }

  static Future<Map<String, dynamic>> getSavedPosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final songId = prefs.getString(_keySavedPositionSongId);
      final ms = prefs.getInt(_keySavedPositionMs) ?? 0;
      return {'songId': songId, 'positionMs': ms};
    } catch (_) {
      return {'songId': null, 'positionMs': 0};
    }
  }

  static Future<void> savePosition(String songId, int positionMs) async {
    return _enqueueWrite(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keySavedPositionSongId, songId);
      await prefs.setInt(_keySavedPositionMs, positionMs);
    });
  }

  // --- DOWNLOADS & LOCAL FILE VALIDATION ---

  static Future<List<Song>> getDownloadedSongs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keyDownloadedSongs);
      if (jsonStr == null || jsonStr.isEmpty) return [];
      final List list = jsonDecode(jsonStr);
      final List<Song> results = [];
      final Set<String> seenIds = {};

      for (final item in list) {
        if (item is Map<String, dynamic>) {
          try {
            final song = Song.fromJson(item);
            if (song.id.isNotEmpty && !seenIds.contains(song.id)) {
              seenIds.add(song.id);
              results.add(
                song.copyWith(isDownloaded: true, source: MusicSource.local),
              );
            }
          } catch (_) {}
        }
      }
      return results;
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveDownloadedSongs(List<Song> songs) async {
    return _enqueueWrite(() async {
      final prefs = await SharedPreferences.getInstance();
      final Set<String> seenIds = {};
      final List<Map<String, dynamic>> serialized = [];

      for (final s in songs) {
        if (s.id.isNotEmpty && !seenIds.contains(s.id)) {
          seenIds.add(s.id);
          serialized.add(
            s.copyWith(isDownloaded: true, source: MusicSource.local).toJson(),
          );
        }
      }
      await prefs.setString(_keyDownloadedSongs, jsonEncode(serialized));
    });
  }

  static Future<void> addDownloadedSong(Song song) async {
    final current = await getDownloadedSongs();
    current.removeWhere((s) => s.id == song.id);
    current.insert(0, song);
    await saveDownloadedSongs(current);
  }

  static Future<void> removeDownloadedSong(String songId) async {
    final current = await getDownloadedSongs();
    current.removeWhere((s) => s.id == songId);
    await saveDownloadedSongs(current);
  }

  // --- RECENT SEARCHES ---

  static Future<List<String>> getRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_keyRecentSearches) ?? [];
    } catch (_) {
      return [];
    }
  }

  static Future<void> addRecentSearch(String term) async {
    final trimmed = term.trim();
    if (trimmed.isEmpty) return;
    return _enqueueWrite(() async {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getStringList(_keyRecentSearches) ?? [];
      current.removeWhere(
        (item) => item.toLowerCase() == trimmed.toLowerCase(),
      );
      current.insert(0, trimmed);
      if (current.length > 15) {
        current.removeRange(15, current.length);
      }
      await prefs.setStringList(_keyRecentSearches, current);
    });
  }

  static Future<void> removeRecentSearch(String term) async {
    return _enqueueWrite(() async {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getStringList(_keyRecentSearches) ?? [];
      current.removeWhere((item) => item.toLowerCase() == term.toLowerCase());
      await prefs.setStringList(_keyRecentSearches, current);
    });
  }

  static Future<void> clearRecentSearches() async {
    return _enqueueWrite(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyRecentSearches);
    });
  }

  // --- SETTINGS: AUDIO QUALITY ---

  static Future<AudioQualitySettings> getAudioQualitySettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keyAudioQuality);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final map = jsonDecode(jsonStr);
        if (map is Map<String, dynamic>) {
          return AudioQualitySettings.fromJson(map);
        }
      }
      return const AudioQualitySettings();
    } catch (_) {
      return const AudioQualitySettings();
    }
  }

  static Future<void> saveAudioQualitySettings(
    AudioQualitySettings settings,
  ) async {
    return _enqueueWrite(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAudioQuality, jsonEncode(settings.toJson()));
    });
  }

  // --- SETTINGS: PLAYBACK ---

  static Future<PlaybackSettings> getPlaybackSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keyPlaybackSettings);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final map = jsonDecode(jsonStr);
        if (map is Map<String, dynamic>) {
          return PlaybackSettings.fromJson(map);
        }
      }
      return const PlaybackSettings();
    } catch (_) {
      return const PlaybackSettings();
    }
  }

  static Future<void> savePlaybackSettings(PlaybackSettings settings) async {
    return _enqueueWrite(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _keyPlaybackSettings,
        jsonEncode(settings.toJson()),
      );
    });
  }

  // --- SETTINGS: EQUALIZER ---

  static Future<EqualizerSettings> getEqualizerSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keyEqualizer);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final map = jsonDecode(jsonStr);
        if (map is Map<String, dynamic>) {
          return EqualizerSettings.fromJson(map);
        }
      }
      return const EqualizerSettings();
    } catch (_) {
      return const EqualizerSettings();
    }
  }

  static Future<void> saveEqualizerSettings(EqualizerSettings settings) async {
    return _enqueueWrite(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyEqualizer, jsonEncode(settings.toJson()));
    });
  }

  // --- SETTINGS: THEME ---

  static Future<String> getSelectedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyTheme) ?? 'Red Uchiha (Default)';
    } catch (_) {
      return 'Red Uchiha (Default)';
    }
  }

  static Future<void> saveSelectedTheme(String theme) async {
    return _enqueueWrite(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyTheme, theme);
    });
  }

  // --- SETTINGS: NOTIFICATIONS ---

  static Future<NotificationSettings> getNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keyNotificationSettings);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final map = jsonDecode(jsonStr);
        if (map is Map<String, dynamic>) {
          return NotificationSettings.fromJson(map);
        }
      }
      return const NotificationSettings();
    } catch (_) {
      return const NotificationSettings();
    }
  }

  static Future<void> saveNotificationSettings(
    NotificationSettings settings,
  ) async {
    return _enqueueWrite(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _keyNotificationSettings,
        jsonEncode(settings.toJson()),
      );
    });
  }

  // --- SETTINGS: ANIMATIONS ---

  static Future<AnimationSettings> getAnimationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keyAnimationSettings);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final map = jsonDecode(jsonStr);
        if (map is Map<String, dynamic>) {
          return AnimationSettings.fromJson(map);
        }
      }
      return const AnimationSettings();
    } catch (_) {
      return const AnimationSettings();
    }
  }

  static Future<void> saveAnimationSettings(AnimationSettings settings) async {
    return _enqueueWrite(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _keyAnimationSettings,
        jsonEncode(settings.toJson()),
      );
    });
  }
}
