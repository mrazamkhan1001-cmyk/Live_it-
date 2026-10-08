import 'song.dart';

class Album {
  final String id;
  final String title;
  final String artist;
  final String? artistId;
  final String coverUrl;
  final int year;
  final String? description;
  final int trackCount;
  final List<Song> songs;

  Album({
    required this.id,
    required this.title,
    required this.artist,
    this.artistId,
    required this.coverUrl,
    required this.year,
    this.description,
    this.trackCount = 0,
    this.songs = const [],
  });

  factory Album.fromAudiusJson(
    Map<String, dynamic> json,
    String host, {
    String appName = 'LIVE_IT_AZAM',
    List<Song> tracks = const [],
  }) {
    final id = json['id']?.toString() ?? '';
    final title =
        json['playlist_name']?.toString() ??
        json['title']?.toString() ??
        'Audius Album';
    final user = json['user'] is Map
        ? json['user'] as Map<String, dynamic>
        : null;
    final artist =
        user?['name']?.toString() ??
        user?['handle']?.toString() ??
        'Audius Artist';
    final artistId = user?['id']?.toString();

    String cover = '';
    if (json['artwork'] is Map) {
      final a = json['artwork'] as Map;
      cover =
          a['1000x1000']?.toString() ??
          a['480x480']?.toString() ??
          a['150x150']?.toString() ??
          '';
    }
    if (cover.isEmpty) {
      cover =
          'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500';
    }

    final trackCount = (json['track_count'] as num?)?.toInt() ?? tracks.length;
    int year = DateTime.now().year;
    if (json['created_at'] != null) {
      try {
        year = DateTime.parse(json['created_at'].toString()).year;
      } catch (_) {}
    }

    return Album(
      id: id,
      title: title,
      artist: artist,
      artistId: artistId,
      coverUrl: cover,
      year: year,
      description: json['description']?.toString(),
      trackCount: trackCount,
      songs: tracks,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'artist': artist,
    'artistId': artistId,
    'coverUrl': coverUrl,
    'year': year,
    'description': description,
    'trackCount': trackCount,
    'songs': songs.map((s) => s.toJson()).toList(),
  };

  factory Album.fromJson(Map<String, dynamic> json) => Album(
    id: json['id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    artist: json['artist']?.toString() ?? '',
    artistId: json['artistId']?.toString(),
    coverUrl:
        json['coverUrl']?.toString() ??
        'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500',
    year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
    description: json['description']?.toString(),
    trackCount: (json['trackCount'] as num?)?.toInt() ?? 0,
    songs:
        (json['songs'] as List?)?.map((s) => Song.fromJson(s)).toList() ?? [],
  );
}
