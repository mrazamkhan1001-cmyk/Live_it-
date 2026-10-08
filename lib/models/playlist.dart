import 'song.dart';

class Playlist {
  final String id;
  final String title;
  final String description;
  final String coverUrl;
  final List<Song> songs;

  Playlist({
    required this.id,
    required this.title,
    required this.description,
    required this.coverUrl,
    this.songs = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'coverUrl': coverUrl,
        'songs': songs.map((s) => s.toJson()).toList(),
      };

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        coverUrl: json['coverUrl'] ?? '',
        songs: (json['songs'] as List?)?.map((s) => Song.fromJson(s)).toList() ?? [],
      );
}
