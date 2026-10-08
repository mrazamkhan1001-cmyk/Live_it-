import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/song.dart';

class AudiusService {
  /// Audius API Application Name / API Key identifier
  static String apiKey = 'LIVE_IT_AZAM';
  
  static const String _apiHostUrl = 'https://api.audius.co';
  static String? _cachedHost;

  static Future<String> _getHost() async {
    if (_cachedHost != null) return _cachedHost!;
    try {
      final res = await http.get(Uri.parse(_apiHostUrl)).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final hosts = (data['data'] as List).cast<String>();
        if (hosts.isNotEmpty) {
          _cachedHost = hosts.first;
          return _cachedHost!;
        }
      }
    } catch (_) {}
    _cachedHost = 'https://discoveryprovider.audius.co';
    return _cachedHost!;
  }

  static Future<List<Song>> fetchTrendingTracks() async {
    try {
      final host = await _getHost();
      final url = Uri.parse('$host/v1/tracks/trending?app_name=$apiKey');
      final res = await http.get(url).timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final tracksJson = data['data'] as List;
        final songs = tracksJson.map((t) => _parseAudiusTrack(t, host)).toList();
        if (songs.isNotEmpty) return songs;
      }
    } catch (_) {}
    return _getFallbackSampleSongs();
  }

  static Future<List<Song>> searchTracks(String query) async {
    if (query.trim().isEmpty) return fetchTrendingTracks();
    try {
      final host = await _getHost();
      final url = Uri.parse('$host/v1/tracks/search?query=${Uri.encodeComponent(query)}&app_name=$apiKey');
      final res = await http.get(url).timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final tracksJson = data['data'] as List;
        return tracksJson.map((t) => _parseAudiusTrack(t, host)).toList();
      }
    } catch (_) {}
    return _getFallbackSampleSongs().where((s) =>
      s.title.toLowerCase().contains(query.toLowerCase()) ||
      s.artist.toLowerCase().contains(query.toLowerCase()) ||
      s.album.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  static Song _parseAudiusTrack(Map<String, dynamic> t, String host) {
    final trackId = t['id']?.toString() ?? '';
    final title = t['title'] ?? 'Uchiha Vibe';
    final user = t['user'] ?? {};
    final artist = user['name'] ?? user['handle'] ?? 'Uchiha Clan';
    final artwork = t['artwork'] != null ? t['artwork']['480x480'] ?? t['artwork']['150x150'] ?? '' : '';
    final duration = (t['duration'] as num? ?? 196).toInt() * 1000;
    final streamUrl = '$host/v1/tracks/$trackId/stream?app_name=$apiKey';
    final isDownloadable = t['downloadable'] == true;

    return Song(
      id: trackId,
      title: title,
      artist: artist,
      album: 'Uchiha Vibes',
      artworkUrl: artwork.isNotEmpty ? artwork : 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500',
      streamUrl: streamUrl,
      durationMs: duration,
      isDownloadable: isDownloadable,
      lyrics: [
        "I wake up to the sounds",
        "of the silence that allows",
        "For my mind to run",
        "around with my ear up",
        "To the ground I'm searching",
        "to behold the stories",
        "that are told",
        "When my back is to the",
        "world that was smiling",
        "when I turned"
      ],
    );
  }

  static List<Song> _getFallbackSampleSongs() {
    return [
      Song(
        id: 'audius_1',
        title: 'Uchiha Spirit',
        artist: 'Anime Lo-Fi Beats',
        album: 'Uchiha Vibes',
        artworkUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500',
        streamUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        durationMs: 196000,
        isFavorite: false,
        lyrics: [
          "I wake up to the sounds",
          "of the silence that allows",
          "For my mind to run",
          "around with my ear up",
          "To the ground I'm searching"
        ],
      ),
      Song(
        id: 'audius_2',
        title: 'Heat Waves',
        artist: 'Glass Animals',
        album: 'Chill Phase',
        artworkUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=500',
        streamUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        durationMs: 238000,
        isFavorite: false,
        lyrics: [
          "Usually I hate this time of year",
          "Late June, back in heat waves",
          "Roads shimmer in the sunlight",
          "Always thinkin' 'bout you"
        ],
      ),
      Song(
        id: 'audius_3',
        title: 'Shadow Clone',
        artist: 'Naruto Beats',
        album: 'Anime Hits',
        artworkUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500',
        streamUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
        durationMs: 185000,
        isFavorite: false,
        lyrics: [
          "When the days are cold",
          "And the cards all fold"
        ],
      ),
      Song(
        id: 'audius_4',
        title: 'My Ordinary Life',
        artist: 'The Living Tombstone',
        album: 'Uchiha Vibes',
        artworkUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500',
        streamUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
        durationMs: 220000,
        isFavorite: false,
      ),
      Song(
        id: 'audius_5',
        title: 'Sharingans Awakening',
        artist: 'Konoha Chill',
        album: 'Anime Hits',
        artworkUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=500',
        streamUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
        durationMs: 212000,
        isFavorite: false,
      ),
    ];
  }
}
