class Artist {
  final String id;
  final String name;
  final String handle;
  final String imageUrl;
  final String? coverUrl;
  final String? bio;
  final String monthlyListeners;
  final int trackCount;
  final bool isVerified;

  Artist({
    required this.id,
    required this.name,
    this.handle = '',
    required this.imageUrl,
    this.coverUrl,
    this.bio,
    required this.monthlyListeners,
    this.trackCount = 0,
    this.isVerified = true,
  });

  factory Artist.fromAudiusJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final name =
        json['name']?.toString() ?? json['handle']?.toString() ?? 'Artist';
    final handle = json['handle']?.toString() ?? '';

    String img = '';
    if (json['profile_picture'] is Map) {
      final p = json['profile_picture'] as Map;
      img =
          p['1000x1000']?.toString() ??
          p['480x480']?.toString() ??
          p['150x150']?.toString() ??
          '';
    }
    if (img.isEmpty) {
      img =
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500';
    }

    String? cover;
    if (json['cover_photo'] is Map) {
      final c = json['cover_photo'] as Map;
      cover = c['2000x']?.toString() ?? c['640x']?.toString();
    }

    final followerCount = (json['follower_count'] as num?)?.toInt() ?? 0;
    final followersFormatted = followerCount > 1000000
        ? '${(followerCount / 1000000).toStringAsFixed(1)}M'
        : followerCount > 1000
        ? '${(followerCount / 1000).toStringAsFixed(1)}K'
        : '$followerCount';

    return Artist(
      id: id,
      name: name,
      handle: handle,
      imageUrl: img,
      coverUrl: cover,
      bio: json['bio']?.toString(),
      monthlyListeners: '$followersFormatted monthly listeners',
      trackCount: (json['track_count'] as num?)?.toInt() ?? 0,
      isVerified: json['is_verified'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'handle': handle,
    'imageUrl': imageUrl,
    'coverUrl': coverUrl,
    'bio': bio,
    'monthlyListeners': monthlyListeners,
    'trackCount': trackCount,
    'isVerified': isVerified,
  };

  factory Artist.fromJson(Map<String, dynamic> json) => Artist(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    handle: json['handle']?.toString() ?? '',
    imageUrl:
        json['imageUrl']?.toString() ??
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500',
    coverUrl: json['coverUrl']?.toString(),
    bio: json['bio']?.toString(),
    monthlyListeners:
        json['monthlyListeners']?.toString() ?? '0 monthly listeners',
    trackCount: (json['trackCount'] as num?)?.toInt() ?? 0,
    isVerified: json['isVerified'] != false,
  );
}
