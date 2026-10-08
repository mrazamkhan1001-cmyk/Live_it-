import 'song.dart';

class Playlist {
  final String id;
  final String title;
  final String description;
  final String coverUrl;
  final String? userName;
  final String? userId;
  final int trackCount;
  final List<Song> songs;
  final bool isUserCreated;

  Playlist({
    required this.id,
    required this.title,
    required this.description,
    required this.coverUrl,
    this.userName,
    this.userId,
    this.trackCount = 0,
    this.songs = const [],
    this.isUserCreated = false,
  });

  factory Playlist.fromAudiusJson(
    Map<String, dynamic> json,
    String host, {
    String appName = 'LIVE_IT_AZAM',
    List<Song> tracks = const [],
  }) {
    final id = json['id']?.toString() ?? '';
    final title = json['playlist_name']?.toString() ?? 'Audius Playlist';
    final description = json['description']?.toString() ?? '';
    final user = json['user'] is Map
        ? json['user'] as Map<String, dynamic>
        : null;
    final userName =
        user?['name']?.toString() ??
        user?['handle']?.toString() ??
        'Audius Curator';
    final userId = user?['id']?.toString();

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

    return Playlist(
      id: id,
      title: title,
      description: description,
      coverUrl: cover,
      userName: userName,
      userId: userId,
      trackCount: trackCount,
      songs: tracks,
      isUserCreated: false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'coverUrl': coverUrl,
    'userName': userName,
    'userId': userId,
    'trackCount': trackCount,
    'songs': songs.map((s) => s.toJson()).toList(),
    'isUserCreated': isUserCreated,
  };

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
    id: json['id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    description: json['description']?.toString() ?? '',
    coverUrl:
        json['coverUrl']?.toString() ??
        'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500',
    userName: json['userName']?.toString(),
    userId: json['userId']?.toString(),
    trackCount: (json['trackCount'] as num?)?.toInt() ?? 0,
    songs:
        (json['songs'] as List?)?.map((s) => Song.fromJson(s)).toList() ?? [],
    isUserCreated: json['isUserCreated'] == true,
  );
}
