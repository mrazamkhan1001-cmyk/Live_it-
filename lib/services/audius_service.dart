import '../models/song.dart';
import '../models/artist.dart';
import '../models/album.dart';
import '../models/playlist.dart';
import 'audius/audius_client.dart';
import 'audius/audius_cache.dart';

export 'audius/audius_exceptions.dart';
export 'audius/audius_cache.dart';
export 'audius/audius_client.dart';

/// Authoritative Data Service for Audius Decentralized Music Network
class AudiusService {
  static final AudiusClient _client = AudiusClient();
  static final AudiusCache _cache = AudiusCache();

  static AudiusClient get client => _client;
  static AudiusCache get cache => _cache;

  /// Fetch trending tracks from Audius with caching
  static Future<List<Song>> fetchTrendingTracks({
    String? genre,
    String? time,
    int limit = 20,
    int offset = 0,
    bool forceRefresh = false,
  }) async {
    final cacheKey =
        'trending_${genre ?? "all"}_${time ?? "all"}_${limit}_$offset';
    if (!forceRefresh) {
      final cached = _cache.get<List<Song>>(cacheKey);
      if (cached != null) return cached;
    }

    final queryParams = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
      if (genre != null && genre.isNotEmpty) 'genre': genre,
      if (time != null && time.isNotEmpty) 'time': time,
    };

    final response = await _client.request(
      '/v1/tracks/trending',
      queryParameters: queryParams,
    );

    if (response is Map && response['data'] is List) {
      final host = _client.activeHost;
      final tracks = (response['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((t) => Song.fromAudiusJson(t, host, appName: _client.appName))
          .toList();

      _cache.set<List<Song>>(
        cacheKey,
        tracks,
        ttl: AudiusCache.defaultTrendingTtl,
      );
      return tracks;
    }

    return [];
  }

  /// Search tracks on Audius with query and pagination
  static Future<List<Song>> searchTracks(
    String query, {
    int limit = 20,
    int offset = 0,
    bool forceRefresh = false,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return fetchTrendingTracks(
        limit: limit,
        offset: offset,
        forceRefresh: forceRefresh,
      );
    }

    final cacheKey = 'search_${trimmed.toLowerCase()}_${limit}_$offset';
    if (!forceRefresh) {
      final cached = _cache.get<List<Song>>(cacheKey);
      if (cached != null) return cached;
    }

    final queryParams = <String, String>{
      'query': trimmed,
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    final response = await _client.request(
      '/v1/tracks/search',
      queryParameters: queryParams,
    );

    if (response is Map && response['data'] is List) {
      final host = _client.activeHost;
      final tracks = (response['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((t) => Song.fromAudiusJson(t, host, appName: _client.appName))
          .toList();

      _cache.set<List<Song>>(
        cacheKey,
        tracks,
        ttl: AudiusCache.defaultSearchTtl,
      );
      return tracks;
    }

    return [];
  }

  /// Search artists / creators on Audius
  static Future<List<Artist>> searchArtists(
    String query, {
    int limit = 20,
    int offset = 0,
    bool forceRefresh = false,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final cacheKey = 'search_artists_${trimmed.toLowerCase()}_${limit}_$offset';
    if (!forceRefresh) {
      final cached = _cache.get<List<Artist>>(cacheKey);
      if (cached != null) return cached;
    }

    final queryParams = <String, String>{
      'query': trimmed,
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    final response = await _client.request(
      '/v1/users/search',
      queryParameters: queryParams,
    );

    if (response is Map && response['data'] is List) {
      final artists = (response['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((a) => Artist.fromAudiusJson(a))
          .toList();

      _cache.set<List<Artist>>(
        cacheKey,
        artists,
        ttl: AudiusCache.defaultSearchTtl,
      );
      return artists;
    }

    return [];
  }

  /// Search playlists on Audius
  static Future<List<Playlist>> searchPlaylists(
    String query, {
    int limit = 20,
    int offset = 0,
    bool forceRefresh = false,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final cacheKey =
        'search_playlists_${trimmed.toLowerCase()}_${limit}_$offset';
    if (!forceRefresh) {
      final cached = _cache.get<List<Playlist>>(cacheKey);
      if (cached != null) return cached;
    }

    final queryParams = <String, String>{
      'query': trimmed,
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    final response = await _client.request(
      '/v1/playlists/search',
      queryParameters: queryParams,
    );

    if (response is Map && response['data'] is List) {
      final host = _client.activeHost;
      final playlists = (response['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(
            (p) => Playlist.fromAudiusJson(p, host, appName: _client.appName),
          )
          .toList();

      _cache.set<List<Playlist>>(
        cacheKey,
        playlists,
        ttl: AudiusCache.defaultSearchTtl,
      );
      return playlists;
    }

    return [];
  }

  /// Search albums / official releases on Audius
  static Future<List<Album>> searchAlbums(
    String query, {
    int limit = 20,
    int offset = 0,
    bool forceRefresh = false,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final cacheKey = 'search_albums_${trimmed.toLowerCase()}_${limit}_$offset';
    if (!forceRefresh) {
      final cached = _cache.get<List<Album>>(cacheKey);
      if (cached != null) return cached;
    }

    final queryParams = <String, String>{
      'query': trimmed,
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    final response = await _client.request(
      '/v1/playlists/search',
      queryParameters: queryParams,
    );

    if (response is Map && response['data'] is List) {
      final host = _client.activeHost;
      final albums = (response['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((a) => Album.fromAudiusJson(a, host, appName: _client.appName))
          .toList();

      _cache.set<List<Album>>(
        cacheKey,
        albums,
        ttl: AudiusCache.defaultSearchTtl,
      );
      return albums;
    }

    return [];
  }

  /// Get specific track details by track ID
  static Future<Song?> getTrackDetails(
    String trackId, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'track_$trackId';
    if (!forceRefresh) {
      final cached = _cache.get<Song>(cacheKey);
      if (cached != null) return cached;
    }

    final response = await _client.request('/v1/tracks/$trackId');
    if (response is Map && response['data'] is Map<String, dynamic>) {
      final host = _client.activeHost;
      final song = Song.fromAudiusJson(
        response['data'] as Map<String, dynamic>,
        host,
        appName: _client.appName,
      );
      _cache.set<Song>(cacheKey, song, ttl: AudiusCache.defaultDetailsTtl);
      return song;
    }
    return null;
  }

  /// Get direct playable stream URL for a track ID
  static String getStreamUrl(String trackId) {
    return _client.getStreamUrl(trackId);
  }

  /// Get artist details by user ID
  static Future<Artist?> getArtistDetails(
    String artistId, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'artist_$artistId';
    if (!forceRefresh) {
      final cached = _cache.get<Artist>(cacheKey);
      if (cached != null) return cached;
    }

    final response = await _client.request('/v1/users/$artistId');
    if (response is Map && response['data'] is Map<String, dynamic>) {
      final artist = Artist.fromAudiusJson(
        response['data'] as Map<String, dynamic>,
      );
      _cache.set<Artist>(cacheKey, artist, ttl: AudiusCache.defaultDetailsTtl);
      return artist;
    }
    return null;
  }

  /// Get tracks created by an artist
  static Future<List<Song>> getArtistTracks(
    String artistId, {
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'artist_tracks_${artistId}_$limit';
    if (!forceRefresh) {
      final cached = _cache.get<List<Song>>(cacheKey);
      if (cached != null) return cached;
    }

    final response = await _client.request(
      '/v1/users/$artistId/tracks',
      queryParameters: {'limit': limit.toString()},
    );

    if (response is Map && response['data'] is List) {
      final host = _client.activeHost;
      final tracks = (response['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((t) => Song.fromAudiusJson(t, host, appName: _client.appName))
          .toList();

      _cache.set<List<Song>>(
        cacheKey,
        tracks,
        ttl: AudiusCache.defaultDetailsTtl,
      );
      return tracks;
    }
    return [];
  }

  /// Get album and its tracklist
  static Future<Album?> getAlbum(
    String albumId, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'album_$albumId';
    if (!forceRefresh) {
      final cached = _cache.get<Album>(cacheKey);
      if (cached != null) return cached;
    }

    final response = await _client.request('/v1/playlists/$albumId');
    if (response is Map &&
        response['data'] is List &&
        (response['data'] as List).isNotEmpty) {
      final albumData =
          (response['data'] as List).first as Map<String, dynamic>;
      final host = _client.activeHost;

      // Fetch tracks in album
      List<Song> tracks = [];
      try {
        final tracksResponse = await _client.request(
          '/v1/playlists/$albumId/tracks',
        );
        if (tracksResponse is Map && tracksResponse['data'] is List) {
          tracks = (tracksResponse['data'] as List)
              .whereType<Map<String, dynamic>>()
              .map(
                (t) => Song.fromAudiusJson(t, host, appName: _client.appName),
              )
              .toList();
        }
      } catch (_) {}

      final album = Album.fromAudiusJson(
        albumData,
        host,
        appName: _client.appName,
        tracks: tracks,
      );
      _cache.set<Album>(cacheKey, album, ttl: AudiusCache.defaultDetailsTtl);
      return album;
    }
    return null;
  }

  /// Fetch trending playlists on Audius
  static Future<List<Playlist>> getTrendingPlaylists({
    int limit = 10,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'trending_playlists_$limit';
    if (!forceRefresh) {
      final cached = _cache.get<List<Playlist>>(cacheKey);
      if (cached != null) return cached;
    }

    final response = await _client.request(
      '/v1/playlists/trending',
      queryParameters: {'limit': limit.toString()},
    );

    if (response is Map && response['data'] is List) {
      final host = _client.activeHost;
      final playlists = (response['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(
            (p) => Playlist.fromAudiusJson(p, host, appName: _client.appName),
          )
          .toList();

      _cache.set<List<Playlist>>(
        cacheKey,
        playlists,
        ttl: AudiusCache.defaultTrendingTtl,
      );
      return playlists;
    }
    return [];
  }

  /// Get playlist and its track list
  static Future<Playlist?> getPlaylist(
    String playlistId, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'playlist_$playlistId';
    if (!forceRefresh) {
      final cached = _cache.get<Playlist>(cacheKey);
      if (cached != null) return cached;
    }

    final response = await _client.request('/v1/playlists/$playlistId');
    if (response is Map &&
        response['data'] is List &&
        (response['data'] as List).isNotEmpty) {
      final pData = (response['data'] as List).first as Map<String, dynamic>;
      final host = _client.activeHost;

      // Fetch tracks in playlist
      List<Song> tracks = [];
      try {
        final tracksResponse = await _client.request(
          '/v1/playlists/$playlistId/tracks',
        );
        if (tracksResponse is Map && tracksResponse['data'] is List) {
          tracks = (tracksResponse['data'] as List)
              .whereType<Map<String, dynamic>>()
              .map(
                (t) => Song.fromAudiusJson(t, host, appName: _client.appName),
              )
              .toList();
        }
      } catch (_) {}

      final playlist = Playlist.fromAudiusJson(
        pData,
        host,
        appName: _client.appName,
        tracks: tracks,
      );
      _cache.set<Playlist>(
        cacheKey,
        playlist,
        ttl: AudiusCache.defaultDetailsTtl,
      );
      return playlist;
    }
    return null;
  }
}
