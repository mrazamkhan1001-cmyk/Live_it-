import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';
import '../models/playlist.dart';
import 'audius_service.dart';
import 'storage_service.dart';

enum RepeatState { off, all, one }

class AudioPlayerService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  
  Song? _currentSong;
  List<Song> _queue = [];
  int _currentIndex = 0;
  
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  
  bool _isShuffle = false;
  RepeatState _repeatState = RepeatState.off;
  
  String _userName = 'Azam Khan';
  List<Song> _favorites = [];
  List<Playlist> _playlists = [];
  List<Song> _recentlyPlayed = [];

  AudioPlayerService() {
    _init();
  }

  AudioPlayer get player => _player;
  Song? get currentSong => _currentSong;
  List<Song> get queue => _queue;
  int get currentIndex => _currentIndex;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isShuffle => _isShuffle;
  RepeatState get repeatState => _repeatState;
  
  String get rawUserName => _userName;
  String get uchihaUserName => _userName;
  
  List<Song> get favorites => _favorites;
  List<Playlist> get playlists => _playlists;
  List<Song> get recentlyPlayed => _recentlyPlayed;

  Future<void> _init() async {
    _userName = await StorageService.getUserName();
    if (_userName == 'Azam' || _userName == 'Azam Uchiha') _userName = 'Azam Khan';
    _favorites = await StorageService.getFavorites();
    _playlists = await StorageService.getPlaylists();
    _recentlyPlayed = await StorageService.getRecentlyPlayed();
    
    // Load trending songs as default queue
    final initialSongs = await AudiusService.fetchTrendingTracks();
    if (initialSongs.isNotEmpty) {
      _queue = initialSongs;
      _currentSong = _queue.first;
    }

    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      if (state.processingState == ProcessingState.completed) {
        _handleSongEnd();
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

    if (_currentSong != null) {
      _loadSong(_currentSong!);
    }
  }

  Future<void> setUserName(String name) async {
    _userName = name.replaceAll(' Uchiha', '').trim();
    if (_userName.isEmpty || _userName == 'Azam') _userName = 'Azam Khan';
    await StorageService.saveUserName(_userName);
    notifyListeners();
  }

  Future<void> playSong(Song song, {List<Song>? queueList, int? index}) async {
    if (_currentSong?.id == song.id) {
      if (queueList != null) {
        _queue = List.from(queueList);
        _currentIndex = index ?? _queue.indexWhere((s) => s.id == song.id);
        if (_currentIndex < 0) _currentIndex = 0;
      }
      if (!_isPlaying) {
        await _player.play();
      }
      notifyListeners();
      return;
    }

    if (queueList != null) {
      _queue = List.from(queueList);
      _currentIndex = index ?? _queue.indexWhere((s) => s.id == song.id);
      if (_currentIndex < 0) _currentIndex = 0;
    } else {
      if (!_queue.any((s) => s.id == song.id)) {
        _queue.add(song);
      }
      _currentIndex = _queue.indexWhere((s) => s.id == song.id);
    }
    
    _currentSong = song;
    _addToRecentlyPlayed(song);
    await _loadSong(song);
    await _player.play();
    notifyListeners();
  }

  Future<void> _loadSong(Song song) async {
    try {
      if (song.streamUrl.startsWith('http')) {
        await _player.setUrl(song.streamUrl);
      } else if (song.streamUrl.startsWith('assets/')) {
        await _player.setAsset(song.streamUrl);
      }
    } catch (_) {}
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      if (_currentSong != null) {
        await _player.play();
      }
    }
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> nextSong() async {
    if (_queue.isEmpty) return;
    if (_isShuffle) {
      _currentIndex = (_currentIndex + 1) % _queue.length;
    } else {
      _currentIndex = (_currentIndex + 1) % _queue.length;
    }
    _currentSong = _queue[_currentIndex];
    _addToRecentlyPlayed(_currentSong!);
    await _loadSong(_currentSong!);
    await _player.play();
    notifyListeners();
  }

  Future<void> previousSong() async {
    if (_queue.isEmpty) return;
    if (_position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }
    _currentIndex = (_currentIndex - 1 + _queue.length) % _queue.length;
    _currentSong = _queue[_currentIndex];
    _addToRecentlyPlayed(_currentSong!);
    await _loadSong(_currentSong!);
    await _player.play();
    notifyListeners();
  }

  void _handleSongEnd() {
    if (_repeatState == RepeatState.one) {
      seek(Duration.zero);
      _player.play();
    } else if (_repeatState == RepeatState.all || _currentIndex < _queue.length - 1) {
      nextSong();
    } else {
      _player.pause();
      seek(Duration.zero);
    }
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
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
    notifyListeners();
  }

  Future<void> toggleFavorite(Song song) async {
    final index = _favorites.indexWhere((s) => s.id == song.id);
    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(song.copyWith(isFavorite: true));
    }
    await StorageService.saveFavorites(_favorites);
    notifyListeners();
  }

  bool isSongFavorite(String songId) {
    return _favorites.any((s) => s.id == songId);
  }

  void reorderQueue(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final item = _queue.removeAt(oldIndex);
    _queue.insert(newIndex, item);
    notifyListeners();
  }

  void _addToRecentlyPlayed(Song song) {
    _recentlyPlayed.removeWhere((s) => s.id == song.id);
    _recentlyPlayed.insert(0, song);
    if (_recentlyPlayed.length > 20) {
      _recentlyPlayed = _recentlyPlayed.sublist(0, 20);
    }
    StorageService.saveRecentlyPlayed(_recentlyPlayed);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
