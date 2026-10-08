enum MusicSource { audius, local, demo }

class Song {
  final String id;
  final String title;
  final String artist;
  final String? artistId;
  final String album;
  final String? albumId;
  final String artworkUrl;
  final String streamUrl;
  final int durationMs;
  final String? genre;
  final String? releaseDate;
  final int? playCount;
  final bool isFavorite;
  final bool isDownloaded;
  final List<String> lyrics;
  final bool isDownloadable;
  final MusicSource source;

  static const String defaultArtwork =
      'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500';

  Song({
    required this.id,
    required this.title,
    required this.artist,
    this.artistId,
    required this.album,
    this.albumId,
    required this.artworkUrl,
    required this.streamUrl,
    required this.durationMs,
    this.genre,
    this.releaseDate,
    this.playCount,
    this.isFavorite = false,
    this.isDownloaded = false,
    this.lyrics = const [],
    this.isDownloadable = true,
    this.source = MusicSource.audius,
  });

  /// Factory constructor to parse real Audius track JSON payload
  factory Song.fromAudiusJson(
    Map<String, dynamic> json,
    String host, {
    String appName = 'LIVE_IT_AZAM',
  }) {
    final trackId = json['id']?.toString() ?? '';
    final title = (json['title']?.toString() ?? 'Untitled Track').trim();

    // User / Artist extraction
    final user = json['user'] is Map
        ? json['user'] as Map<String, dynamic>
        : null;
    final artistName =
        user?['name']?.toString() ??
        user?['handle']?.toString() ??
        'Audius Artist';
    final artistId = user?['id']?.toString();

    // Artwork extraction (1000x1000 -> 480x480 -> 150x150 -> default)
    String artwork = '';
    if (json['artwork'] is Map) {
      final artMap = json['artwork'] as Map;
      artwork =
          artMap['1000x1000']?.toString() ??
          artMap['480x480']?.toString() ??
          artMap['150x150']?.toString() ??
          '';
    }
    if (artwork.isEmpty) {
      artwork = defaultArtwork;
    }

    // Duration extraction (Audius provides seconds)
    final durationSec = (json['duration'] as num?)?.toInt() ?? 180;
    final durationMs = durationSec * 1000;

    // Stream URL
    final streamUrl = '$host/v1/tracks/$trackId/stream?app_name=$appName';

    // Genre & Release Date
    final genre = json['genre']?.toString();
    final releaseDate = json['release_date']?.toString();
    final playCount = (json['play_count'] as num?)?.toInt();
    final isDownloadable = json['downloadable'] == true;

    return Song(
      id: trackId,
      title: title.isNotEmpty ? title : 'Untitled Track',
      artist: artistName.isNotEmpty ? artistName : 'Audius Artist',
      artistId: artistId,
      album: 'Audius Catalog',
      artworkUrl: artwork,
      streamUrl: streamUrl,
      durationMs: durationMs,
      genre: genre,
      releaseDate: releaseDate,
      playCount: playCount,
      isDownloadable: isDownloadable,
      source: MusicSource.audius,
      lyrics: const [
        "Live It by Azam",
        "Streamed seamlessly via Audius Decentralized Network",
        "High-fidelity anime & electronic beats",
      ],
    );
  }

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? artistId,
    String? album,
    String? albumId,
    String? artworkUrl,
    String? streamUrl,
    int? durationMs,
    String? genre,
    String? releaseDate,
    int? playCount,
    bool? isFavorite,
    bool? isDownloaded,
    List<String>? lyrics,
    bool? isDownloadable,
    MusicSource? source,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      artistId: artistId ?? this.artistId,
      album: album ?? this.album,
      albumId: albumId ?? this.albumId,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      streamUrl: streamUrl ?? this.streamUrl,
      durationMs: durationMs ?? this.durationMs,
      genre: genre ?? this.genre,
      releaseDate: releaseDate ?? this.releaseDate,
      playCount: playCount ?? this.playCount,
      isFavorite: isFavorite ?? this.isFavorite,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      lyrics: lyrics ?? this.lyrics,
      isDownloadable: isDownloadable ?? this.isDownloadable,
      source: source ?? this.source,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'artist': artist,
    'artistId': artistId,
    'album': album,
    'albumId': albumId,
    'artworkUrl': artworkUrl,
    'streamUrl': streamUrl,
    'durationMs': durationMs,
    'genre': genre,
    'releaseDate': releaseDate,
    'playCount': playCount,
    'isFavorite': isFavorite,
    'isDownloaded': isDownloaded,
    'lyrics': lyrics,
    'isDownloadable': isDownloadable,
    'source': source.name,
  };

  factory Song.fromJson(Map<String, dynamic> json) {
    MusicSource source = MusicSource.audius;
    if (json['source'] != null) {
      source = MusicSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => MusicSource.audius,
      );
    }

    return Song(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      artist: json['artist']?.toString() ?? '',
      artistId: json['artistId']?.toString(),
      album: json['album']?.toString() ?? '',
      albumId: json['albumId']?.toString(),
      artworkUrl: json['artworkUrl']?.toString() ?? defaultArtwork,
      streamUrl: json['streamUrl']?.toString() ?? '',
      durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
      genre: json['genre']?.toString(),
      releaseDate: json['releaseDate']?.toString(),
      playCount: (json['playCount'] as num?)?.toInt(),
      isFavorite: json['isFavorite'] == true,
      isDownloaded: json['isDownloaded'] == true,
      lyrics:
          (json['lyrics'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      isDownloadable: json['isDownloadable'] != false,
      source: source,
    );
  }
}
