class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String artworkUrl;
  final String streamUrl;
  final int durationMs;
  final bool isFavorite;
  final bool isDownloaded;
  final List<String> lyrics;
  final bool isDownloadable;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.artworkUrl,
    required this.streamUrl,
    required this.durationMs,
    this.isFavorite = false,
    this.isDownloaded = false,
    this.lyrics = const [],
    this.isDownloadable = true,
  });

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? artworkUrl,
    String? streamUrl,
    int? durationMs,
    bool? isFavorite,
    bool? isDownloaded,
    List<String>? lyrics,
    bool? isDownloadable,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      streamUrl: streamUrl ?? this.streamUrl,
      durationMs: durationMs ?? this.durationMs,
      isFavorite: isFavorite ?? this.isFavorite,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      lyrics: lyrics ?? this.lyrics,
      isDownloadable: isDownloadable ?? this.isDownloadable,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'album': album,
        'artworkUrl': artworkUrl,
        'streamUrl': streamUrl,
        'durationMs': durationMs,
        'isFavorite': isFavorite,
        'isDownloaded': isDownloaded,
        'lyrics': lyrics,
        'isDownloadable': isDownloadable,
      };

  factory Song.fromJson(Map<String, dynamic> json) => Song(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        artist: json['artist'] ?? '',
        album: json['album'] ?? '',
        artworkUrl: json['artworkUrl'] ?? '',
        streamUrl: json['streamUrl'] ?? '',
        durationMs: json['durationMs'] ?? 0,
        isFavorite: json['isFavorite'] ?? false,
        isDownloaded: json['isDownloaded'] ?? false,
        lyrics: (json['lyrics'] as List?)?.cast<String>() ?? const [],
        isDownloadable: json['isDownloadable'] ?? true,
      );
}
