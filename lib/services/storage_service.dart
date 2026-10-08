import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';
import '../models/playlist.dart';

class StorageService {
  static const String _keyUserName = 'user_name';
  static const String _keyFavorites = 'favorite_songs';
  static const String _keyPlaylists = 'user_playlists';
  static const String _keyRecentlyPlayed = 'recently_played';

  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_keyUserName);
    if (name == null || name == 'Azam' || name == 'Azam Uchiha') return 'Azam Khan';
    return name;
  }

  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, name);
  }

  static Future<List<Song>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyFavorites);
    if (jsonStr == null) return [];
    try {
      final List list = jsonDecode(jsonStr);
      return list.map((s) => Song.fromJson(s)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveFavorites(List<Song> songs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(songs.map((s) => s.toJson()).toList());
    await prefs.setString(_keyFavorites, jsonStr);
  }

  static Future<List<Playlist>> getPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyPlaylists);
    if (jsonStr == null) return _getDefaultPlaylists();
    try {
      final List list = jsonDecode(jsonStr);
      return list.map((p) => Playlist.fromJson(p)).toList();
    } catch (_) {
      return _getDefaultPlaylists();
    }
  }

  static Future<void> savePlaylists(List<Playlist> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(playlists.map((p) => p.toJson()).toList());
    await prefs.setString(_keyPlaylists, jsonStr);
  }

  static List<Playlist> _getDefaultPlaylists() {
    return [];
  }

  static Future<List<Song>> getRecentlyPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyRecentlyPlayed);
    if (jsonStr == null) return [];
    try {
      final List list = jsonDecode(jsonStr);
      return list.map((s) => Song.fromJson(s)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveRecentlyPlayed(List<Song> songs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(songs.map((s) => s.toJson()).toList());
    await prefs.setString(_keyRecentlyPlayed, jsonStr);
  }
}
