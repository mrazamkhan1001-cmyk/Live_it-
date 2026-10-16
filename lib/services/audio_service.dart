import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';

import 'package:firebase_auth/firebase_auth.dart' show User;

import '../models/song.dart';
import '../models/playlist.dart';
import '../utils/user_utils.dart';
import 'audius_service.dart';
import 'auth_service.dart';
import 'download_service.dart';
import 'storage_service.dart';

/// Central Playback State Machine
enum PlaybackState {
  idle,
  loading,
  buffering,
  ready,
  playing,
  paused,
  completed,
  error,
}

/// Central Repeat Modes
enum RepeatState { off, all, one }

typedef RepeatMode = RepeatState;

/// PHASE 4, PHASE 10 & PHASE 11: Single Authoritative Audio Player Engine for LIVE IT — BY AZAM KHAN.
/// Controls playback, queues, positions, durations, shuffle, repeat, error handling,
/// stream synchronization, offline local-file playback, and Android MediaSession background playback.
class AudioPlayerService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  Song? _currentSong;
  List<Song> _queue = [];
  int _currentIndex = 0;

  PlaybackState _playbackState = PlaybackState.idle;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  bool _isShuffle = false;
  RepeatState _repeatState = RepeatState.off;

  String? _playbackError;
  int _activeRequestId = 0;
  bool _wasPlayingBeforeInterruption = false;

  String _userName = '';
  UserProfile _userProfile = const UserProfile.empty();
  List<Song> _favorites = [];
  List<Playlist> _playlists = [];
  List<Song> _recentlyPlayed = [];

  late final Future<void> initialized;

  AudioPlayerService() {
    initialized = _init();
  }

  // --- GETTERS (Single Source of Truth) ---
  AudioPlayer get player => _player;
  Song? get currentSong => _currentSong;
  Song? get currentTrack => _currentSong;
  List<Song> get queue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;

  PlaybackState get playbackState => _playbackState;
  bool get isPlaying => _player.playing;
  bool get isLoading => _playbackState == PlaybackState.loading;
  bool get isBuffering => _playbackState == PlaybackState.buffering;
  String? get playbackError => _playbackError;
  String? get errorMessage => _playbackError;

  Duration get position => _position;
  Duration get duration => _duration;

  bool get isShuffle => _isShuffle;
  bool get shuffleEnabled => _isShuffle;

  RepeatState get repeatState => _repeatState;
  RepeatState get repeatMode => _repeatState;

  String get rawUserName => _userName;
  String get uchihaUserName => _userName;
  String get userName => _userName;
  UserProfile get userProfile => _userProfile;

  List<Song> get favorites => _favorites;
  List<Playlist> get playlists => _playlists;
  List<Song> get recentlyPlayed => _recentlyPlayed;

  // Phase 10: Downloaded songs & download status accessors
  List<Song> get downloadedSongs => DownloadService.downloadedSongs;
  bool isSongDownloaded(String songId) =>
      DownloadService.getStatus(songId) == DownloadStatus.completed;
  DownloadStatus getDownloadStatus(String songId) =>
      DownloadService.getStatus(songId);
  double getDownloadProgress(String songId) =>
      DownloadService.getProgress(songId);

  Future<void> _init() async {
    await StorageService.init();
    final currentUser = AuthService.instance.currentUser;
    final savedProfile = await StorageService.getUserProfile(
      uid: currentUser?.uid,
      authUser: currentUser,
    );
    if (_userProfile.isEmpty) {
      _userProfile = savedProfile;
      _userName = _userProfile.name;
    }
    if (_favorites.isEmpty) {
      _favorites = await StorageService.getFavorites(uid: currentUser?.uid);
    }
    if (_playlists.isEmpty) {
      _playlists = await StorageService.getPlaylists(uid: currentUser?.uid);
    }
    if (_recentlyPlayed.isEmpty) {
      _recentlyPlayed = await StorageService.getRecentlyPlayed(uid: currentUser?.uid);
    }

    // Restore Shuffle & Repeat preferences
    _isShuffle = await StorageService.getSavedShuffleState();
    final repeatStr = await StorageService.getSavedRepeatState();
    _repeatState = RepeatState.values.firstWhere(
      (e) => e.name == repeatStr,
      orElse: () => RepeatState.off,
    );

    // Initialize downloads & verify persisted local files on startup
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      try {
        await DownloadService.init();
        DownloadService().addListener(() {
          notifyListeners();
        });
      } catch (_) {}
    }

    // Phase 11: Configure AudioSession for audio focus, phone call interruptions, and becoming noisy (headphone unplug)
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      try {
        final session = await AudioSession.instance;
        await session.configure(const AudioSessionConfiguration.music());

        session.interruptionEventStream.listen((event) {
          if (event.begin) {
            switch (event.type) {
              case AudioInterruptionType.duck:
                _player.setVolume(0.5);
                break;
              case AudioInterruptionType.pause:
              case AudioInterruptionType.unknown:
                if (_player.playing) {
                  _wasPlayingBeforeInterruption = true;
                  _player.pause();
                }
                break;
            }
          } else {
            switch (event.type) {
              case AudioInterruptionType.duck:
                _player.setVolume(1.0);
                break;
              case AudioInterruptionType.pause:
                if (_wasPlayingBeforeInterruption) {
                  _wasPlayingBeforeInterruption = false;
                  _player.play();
                }
                break;
              case AudioInterruptionType.unknown:
                break;
            }
          }
        });

        session.becomingNoisyEventStream.listen((_) {
          // Automatically pause when headphones or bluetooth audio disconnect
          _player.pause();
        });
      } catch (_) {
        // Graceful fallback for tests or platforms without native audio session
      }
    }

    // Attach stream listeners to the central AudioPlayer
    _player.playerStateStream.listen((playerState) {
      switch (playerState.processingState) {
        case ProcessingState.idle:
          _playbackState = PlaybackState.idle;
          break;
        case ProcessingState.loading:
          _playbackState = PlaybackState.loading;
          break;
        case ProcessingState.buffering:
          _playbackState = PlaybackState.buffering;
          break;
        case ProcessingState.ready:
          _playbackState = playerState.playing
              ? PlaybackState.playing
              : PlaybackState.paused;
          break;
        case ProcessingState.completed:
          _playbackState = PlaybackState.completed;
          _handleSongEnd();
          break;
      }
      notifyListeners();
    });

    _player.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _player.durationStream.listen((dur) {
      _duration = dur ?? Duration.zero;
      notifyListeners();
    });

    _player.playbackEventStream.listen(
      (_) {},
      onError: (Object e, StackTrace st) {
        _playbackError = 'Playback error: $e';
        _playbackState = PlaybackState.error;
        notifyListeners();
      },
    );

    // Restore saved queue or fetch trending tracks without auto-playing
    final savedQueue = await StorageService.getSavedQueue();
    final savedIndex = await StorageService.getSavedQueueIndex();

    if (savedQueue.isNotEmpty) {
      _queue = savedQueue;
      _currentIndex = (savedIndex >= 0 && savedIndex < _queue.length)
          ? savedIndex
          : 0;
      _currentSong = _queue[_currentIndex];
      if (!Platform.environment.containsKey('FLUTTER_TEST')) {
        _loadSong(_currentSong!, autoPlay: false);
      }
      notifyListeners();
    } else if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      AudiusService.fetchTrendingTracks()
          .then((initialSongs) {
            if (initialSongs.isNotEmpty && _queue.isEmpty) {
              _queue = initialSongs;
              _currentIndex = 0;
              _currentSong = _queue.first;
              _loadSong(_currentSong!, autoPlay: false);
              StorageService.saveQueue(_queue, _currentIndex);
              notifyListeners();
            }
          })
          .catchError((_) {
            // Graceful offline fallback
          });
    }
  }

  Future<void> refreshTrending({bool forceRefresh = true}) async {
    try {
      final songs = await AudiusService.fetchTrendingTracks(
        forceRefresh: forceRefresh,
      );
      if (songs.isNotEmpty) {
        _queue = songs;
        _currentSong ??= songs.first;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> setUserName(String name) async {
    _userName = name.replaceAll(' Uchiha', '').trim();
    if (_userName.isEmpty) {
      final currentUser = AuthService.instance.currentUser;
      _userName = UserUtils.resolveDisplayName(
        authDisplayName: currentUser?.displayName,
        email: currentUser?.email,
      );
    }
    _userProfile = _userProfile.copyWith(name: _userName);
    final currentUser = AuthService.instance.currentUser;
    await StorageService.saveUserName(_userName);
    await StorageService.saveUserProfile(_userProfile, uid: currentUser?.uid);
    notifyListeners();
  }

  /// Updates reactive UserProfile across app and persists with user-level isolation
  Future<void> updateUserProfile(UserProfile profile) async {
    _userProfile = profile;
    _userName = profile.name;
    final currentUser = AuthService.instance.currentUser;
    await StorageService.saveUserProfile(profile, uid: currentUser?.uid);
    await StorageService.saveUserName(_userName);
    notifyListeners();
  }

  /// Loads profile for specified authenticated user or guest default
  Future<void> loadProfileForUser(User? user) async {
    if (user != null) {
      _userProfile = await StorageService.getUserProfile(
        uid: user.uid,
        authUser: user,
      );
      _userName = _userProfile.name;
      _favorites = await StorageService.getFavorites(uid: user.uid);
      _playlists = await StorageService.getPlaylists(uid: user.uid);
      _recentlyPlayed = await StorageService.getRecentlyPlayed(uid: user.uid);
    } else {
      _userProfile = await StorageService.getUserProfile();
      _userName = _userProfile.name;
      _favorites = await StorageService.getFavorites();
      _playlists = await StorageService.getPlaylists();
      _recentlyPlayed = await StorageService.getRecentlyPlayed();
    }
    notifyListeners();
  }

  /// Securely sign out: stops active playback, resets active queue & current track,
  /// resets user session state, and notifies listeners without destroying shared services.
  Future<void> logout() async {
    try {
      await _player.stop();
    } catch (_) {}
    try {
      await AuthService.instance.signOut();
    } catch (_) {}
    _playbackState = PlaybackState.idle;
    _position = Duration.zero;
    _currentSong = null;
    _queue = [];
    _currentIndex = 0;
    _favorites = [];
    _playlists = [];
    _recentlyPlayed = [];
    _userName = '';
    _userProfile = const UserProfile.empty();
    notifyListeners();
  }

  // --- PLAYBACK ENGINE ACTIONS ---

  /// Play selected song with optional queue replacement and target index
  Future<void> playSong(Song song, {List<Song>? queueList, int? index}) async {
    if (queueList != null && queueList.isNotEmpty) {
      _queue = List.from(queueList);
      _currentIndex = index ?? _queue.indexWhere((s) => s.id == song.id);
      if (_currentIndex < 0) _currentIndex = 0;
    } else {
      final existingIdx = _queue.indexWhere((s) => s.id == song.id);
      if (existingIdx >= 0) {
        _currentIndex = existingIdx;
      } else {
        _queue.add(song);
        _currentIndex = _queue.length - 1;
      }
    }

    // Persist queue snapshot
    StorageService.saveQueue(_queue, _currentIndex);

    // If same song is selected and already loaded, resume playback without reload
    if (_currentSong?.id == song.id &&
        _player.processingState != ProcessingState.idle &&
        _player.processingState != ProcessingState.completed) {
      if (!_player.playing) {
        await _player.play();
      }
      notifyListeners();
      return;
    }

    _currentSong = song;
    _addToRecentlyPlayed(song);
    notifyListeners();
    await _loadSong(song, autoPlay: true);
  }

  /// Construct platform AudioSource tagged with MediaItem for Android MediaSession
  AudioSource _buildAudioSource(Song song) {
    String streamUrl = song.streamUrl;
    bool isLocalFile = false;

    if (song.isDownloaded || song.source == MusicSource.local) {
      isLocalFile = true;
    } else {
      final downloadedMatch = DownloadService.downloadedSongs.where(
        (s) => s.id == song.id,
      );
      if (downloadedMatch.isNotEmpty) {
        final localFile = File(downloadedMatch.first.streamUrl);
        if (localFile.existsSync() && localFile.lengthSync() > 0) {
          streamUrl = downloadedMatch.first.streamUrl;
          isLocalFile = true;
        }
      }
    }

    if (!isLocalFile &&
        song.source == MusicSource.audius &&
        (streamUrl.isEmpty || streamUrl.contains('discoveryprovider'))) {
      try {
        final resolvedUrl = AudiusService.getStreamUrl(song.id);
        if (resolvedUrl.isNotEmpty) {
          streamUrl = resolvedUrl;
        }
      } catch (_) {}
    }

    Uri? artUri;
    if (song.artworkUrl.isNotEmpty) {
      artUri = Uri.tryParse(song.artworkUrl);
    }

    final mediaItem = MediaItem(
      id: song.id,
      album: song.album.isNotEmpty ? song.album : 'LIVE IT',
      title: song.title.isNotEmpty ? song.title : 'Untitled Track',
      artist: song.artist.isNotEmpty ? song.artist : 'Azam Khan',
      artUri: artUri,
      duration: song.durationMs > 0
          ? Duration(milliseconds: song.durationMs)
          : null,
    );

    if (isLocalFile ||
        (!streamUrl.startsWith('http') && !streamUrl.startsWith('assets/'))) {
      return AudioSource.file(streamUrl, tag: mediaItem);
    } else if (streamUrl.startsWith('http')) {
      return AudioSource.uri(Uri.parse(streamUrl), tag: mediaItem);
    } else {
      return AudioSource.asset(streamUrl, tag: mediaItem);
    }
  }

  /// Internal audio loading with race condition protection, MediaSession tags, and offline file support
  Future<void> _loadSong(Song song, {bool autoPlay = true}) async {
    final requestId = ++_activeRequestId;
    _playbackError = null;
    _playbackState = PlaybackState.loading;
    notifyListeners();

    try {
      final source = _buildAudioSource(song);

      if (requestId != _activeRequestId) return;

      await _player.setAudioSource(source);

      if (requestId != _activeRequestId) return;

      if (autoPlay) {
        await _player.play();
      } else {
        _playbackState = PlaybackState.paused;
      }
      notifyListeners();
    } catch (e) {
      if (requestId != _activeRequestId) return;
      if (e is PlatformException && e.code == 'abort') {
        // Loading was cancelled by a newer request or stop command
        return;
      }
      _playbackError = 'Error loading track: ${e.toString()}';
      _playbackState = PlaybackState.error;
      notifyListeners();
    }
  }

  // --- PHASE 10 DOWNLOAD ACTIONS ---

  Future<File?> downloadSong(
    Song song, {
    void Function(double)? onProgress,
  }) async {
    final result = await DownloadService.downloadSong(
      song,
      onProgress: onProgress,
    );
    notifyListeners();
    return result;
  }

  Future<void> cancelDownload(String songId) async {
    await DownloadService.cancelDownload(songId);
    notifyListeners();
  }

  Future<bool> deleteDownload(String songId) async {
    if (_currentSong?.id == songId &&
        (_currentSong?.isDownloaded == true ||
            _currentSong?.source == MusicSource.local)) {
      await _player.stop();
      _playbackState = PlaybackState.idle;
    }
    final result = await DownloadService.deleteDownload(songId);
    notifyListeners();
    return result;
  }

  Future<void> clearAllDownloads() async {
    if (_currentSong?.isDownloaded == true ||
        _currentSong?.source == MusicSource.local) {
      await _player.stop();
      _playbackState = PlaybackState.idle;
    }
    await DownloadService.clearAllDownloads();
    notifyListeners();
  }

  Future<void> play() async {
    if (_currentSong != null) {
      if (_player.processingState == ProcessingState.idle ||
          _player.processingState == ProcessingState.completed) {
        await _loadSong(_currentSong!, autoPlay: true);
      } else {
        await _player.play();
      }
    }
  }

  Future<void> resume() async {
    await play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
    _position = Duration.zero;
    _playbackState = PlaybackState.idle;
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await play();
    }
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> nextSong() async {
    if (_queue.isEmpty) return;

    if (_isShuffle && _queue.length > 1) {
      int nextIdx;
      do {
        nextIdx = math.Random().nextInt(_queue.length);
      } while (nextIdx == _currentIndex && _queue.length > 1);
      _currentIndex = nextIdx;
    } else {
      if (_currentIndex < _queue.length - 1) {
        _currentIndex++;
      } else if (_repeatState == RepeatState.all) {
        _currentIndex = 0;
      } else {
        // Reached end of queue without repeat
        await _player.pause();
        await seek(Duration.zero);
        _playbackState = PlaybackState.completed;
        notifyListeners();
        return;
      }
    }

    _currentSong = _queue[_currentIndex];
    _addToRecentlyPlayed(_currentSong!);
    StorageService.saveQueue(_queue, _currentIndex);
    notifyListeners();
    await _loadSong(_currentSong!, autoPlay: true);
  }

  Future<void> previousSong() async {
    if (_queue.isEmpty) return;

    // If track has played more than 3 seconds, seek back to beginning
    if (_position.inSeconds > 3) {
      await seek(Duration.zero);
      if (!_player.playing) {
        await _player.play();
      }
      return;
    }

    if (_currentIndex > 0) {
      _currentIndex--;
    } else if (_repeatState == RepeatState.all) {
      _currentIndex = _queue.length - 1;
    } else {
      await seek(Duration.zero);
      return;
    }

    _currentSong = _queue[_currentIndex];
    _addToRecentlyPlayed(_currentSong!);
    StorageService.saveQueue(_queue, _currentIndex);
    notifyListeners();
    await _loadSong(_currentSong!, autoPlay: true);
  }

  void _handleSongEnd() {
    if (_repeatState == RepeatState.one) {
      seek(Duration.zero);
      _player.play();
    } else if (_repeatState == RepeatState.all) {
      nextSong();
    } else if (_currentIndex < _queue.length - 1) {
      nextSong();
    } else {
      _playbackState = PlaybackState.completed;
      _player.pause();
      seek(Duration.zero);
      notifyListeners();
    }
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    StorageService.saveShuffleState(_isShuffle);
    notifyListeners();
  }

  void setShuffle(bool enabled) {
    _isShuffle = enabled;
    StorageService.saveShuffleState(_isShuffle);
    notifyListeners();
  }

  void toggleRepeat() {
    if (_repeatState == RepeatState.off) {
      _repeatState = RepeatState.all;
    } else if (_repeatState == RepeatState.all) {
      _repeatState = RepeatState.one;
    } else {
      _repeatState = RepeatState.off;
    }
    StorageService.saveRepeatState(_repeatState.name);
    notifyListeners();
  }

  void setRepeatMode(RepeatState mode) {
    _repeatState = mode;
    StorageService.saveRepeatState(_repeatState.name);
    notifyListeners();
  }

  // --- QUEUE MANIPULATION ---

  void addToQueue(Song song) {
    _queue.add(song);
    if (_currentSong == null) {
      _currentSong = song;
      _currentIndex = 0;
    }
    StorageService.saveQueue(_queue, _currentIndex);
    notifyListeners();
  }

  void removeFromQueue(int index) {
    if (index >= 0 && index < _queue.length) {
      _queue.removeAt(index);
      if (_currentIndex == index) {
        if (_queue.isNotEmpty) {
          _currentIndex = _currentIndex % _queue.length;
          _currentSong = _queue[_currentIndex];
          _loadSong(_currentSong!, autoPlay: _player.playing);
        } else {
          _currentSong = null;
          _currentIndex = 0;
          _player.stop();
          _playbackState = PlaybackState.idle;
        }
      } else if (_currentIndex > index) {
        _currentIndex--;
      }
      StorageService.saveQueue(_queue, _currentIndex);
      notifyListeners();
    }
  }

  void reorderQueue(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final item = _queue.removeAt(oldIndex);
    _queue.insert(newIndex, item);
    if (_currentSong != null) {
      _currentIndex = _queue.indexWhere((s) => s.id == _currentSong!.id);
      if (_currentIndex < 0) _currentIndex = 0;
    }
    StorageService.saveQueue(_queue, _currentIndex);
    notifyListeners();
  }

  void clearQueue() {
    _queue.clear();
    _currentIndex = 0;
    _currentSong = null;
    _player.stop();
    _playbackState = PlaybackState.idle;
    StorageService.saveQueue([], 0);
    notifyListeners();
  }

  /// Clear upcoming tracks while keeping current song playing
  void clearUpcoming() {
    if (_currentSong != null) {
      _queue = [_currentSong!];
      _currentIndex = 0;
    } else {
      _queue.clear();
      _currentIndex = 0;
    }
    StorageService.saveQueue(_queue, _currentIndex);
    notifyListeners();
  }

  /// Insert track to play immediately next in queue
  void insertNextInQueue(Song song) {
    if (_queue.isEmpty || _currentSong == null) {
      addToQueue(song);
    } else {
      _queue.insert(_currentIndex + 1, song);
      StorageService.saveQueue(_queue, _currentIndex);
      notifyListeners();
    }
  }

  // --- USER DATA, PLAYLISTS & STORAGE ---

  Future<void> toggleFavorite(Song song) async {
    final index = _favorites.indexWhere((s) => s.id == song.id);
    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(song.copyWith(isFavorite: true));
    }
    final currentUser = AuthService.instance.currentUser;
    await StorageService.saveFavorites(_favorites, uid: currentUser?.uid);
    notifyListeners();
  }

  bool isSongFavorite(String songId) {
    return _favorites.any((s) => s.id == songId);
  }

  void _addToRecentlyPlayed(Song song) {
    _recentlyPlayed.removeWhere((s) => s.id == song.id);
    _recentlyPlayed.insert(0, song);
    if (_recentlyPlayed.length > 50) {
      _recentlyPlayed = _recentlyPlayed.sublist(0, 50);
    }
    final currentUser = AuthService.instance.currentUser;
    StorageService.saveRecentlyPlayed(
      _recentlyPlayed,
      uid: currentUser?.uid,
      limit: 50,
    );
  }

  void removeFromRecentlyPlayed(Song song) {
    _recentlyPlayed.removeWhere((s) => s.id == song.id);
    notifyListeners();
    final currentUser = AuthService.instance.currentUser;
    StorageService.saveRecentlyPlayed(
      _recentlyPlayed,
      uid: currentUser?.uid,
      limit: 50,
    );
  }

  // --- PLAYLIST OPERATIONS ---

  Future<Playlist> createPlaylist(
    String title, {
    String description = '',
  }) async {
    final currentUser = AuthService.instance.currentUser;
    final newPlaylist = Playlist(
      id: 'playlist_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim().isEmpty ? 'My Playlist' : title.trim(),
      description: description.trim(),
      coverUrl:
          'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500',
      userName: _userName,
      userId: currentUser?.uid,
      isUserCreated: true,
      trackCount: 0,
      songs: [],
    );
    _playlists.insert(0, newPlaylist);
    await StorageService.savePlaylists(_playlists, uid: currentUser?.uid);
    notifyListeners();
    return newPlaylist;
  }

  Future<void> deletePlaylist(String playlistId) async {
    _playlists.removeWhere((p) => p.id == playlistId);
    final currentUser = AuthService.instance.currentUser;
    await StorageService.savePlaylists(_playlists, uid: currentUser?.uid);
    notifyListeners();
  }

  Future<void> renamePlaylist(String playlistId, String newTitle) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index >= 0) {
      final old = _playlists[index];
      _playlists[index] = Playlist(
        id: old.id,
        title: newTitle.trim().isEmpty ? old.title : newTitle.trim(),
        description: old.description,
        coverUrl: old.coverUrl,
        userName: old.userName,
        userId: old.userId,
        trackCount: old.trackCount,
        songs: old.songs,
        isUserCreated: old.isUserCreated,
      );
      final currentUser = AuthService.instance.currentUser;
      await StorageService.savePlaylists(_playlists, uid: currentUser?.uid);
      notifyListeners();
    }
  }

  Future<void> addSongToPlaylist(String playlistId, Song song) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index >= 0) {
      final old = _playlists[index];
      if (!old.songs.any((s) => s.id == song.id)) {
        final updatedSongs = List<Song>.from(old.songs)..add(song);
        _playlists[index] = Playlist(
          id: old.id,
          title: old.title,
          description: old.description,
          coverUrl: old.coverUrl,
          userName: old.userName,
          userId: old.userId,
          trackCount: updatedSongs.length,
          songs: updatedSongs,
          isUserCreated: old.isUserCreated,
        );
        final currentUser = AuthService.instance.currentUser;
        await StorageService.savePlaylists(_playlists, uid: currentUser?.uid);
        notifyListeners();
      }
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index >= 0) {
      final old = _playlists[index];
      final updatedSongs = List<Song>.from(old.songs)
        ..removeWhere((s) => s.id == songId);
      _playlists[index] = Playlist(
        id: old.id,
        title: old.title,
        description: old.description,
        coverUrl: old.coverUrl,
        userName: old.userName,
        userId: old.userId,
        trackCount: updatedSongs.length,
        songs: updatedSongs,
        isUserCreated: old.isUserCreated,
      );
      final currentUser = AuthService.instance.currentUser;
      await StorageService.savePlaylists(_playlists, uid: currentUser?.uid);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
