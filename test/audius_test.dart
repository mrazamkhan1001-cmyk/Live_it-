import 'package:flutter_test/flutter_test.dart';
import 'package:liveitbyazam/models/song.dart';
import 'package:liveitbyazam/models/artist.dart';
import 'package:liveitbyazam/models/album.dart';
import 'package:liveitbyazam/models/playlist.dart';
import 'package:liveitbyazam/services/audius_service.dart';

void main() {
  group('AudiusCache Tests', () {
    late AudiusCache cache;

    setUp(() {
      cache = AudiusCache();
    });

    test('stores and retrieves cached items', () {
      cache.set('test_key', 'test_value', ttl: const Duration(seconds: 10));
      expect(cache.get<String>('test_key'), equals('test_value'));
    });

    test('returns null for missing key', () {
      expect(cache.get<String>('non_existent'), isNull);
    });

    test('invalidates specified key', () {
      cache.set('key_to_delete', 123);
      expect(cache.get<int>('key_to_delete'), equals(123));
      cache.invalidate('key_to_delete');
      expect(cache.get<int>('key_to_delete'), isNull);
    });

    test('clears all cached entries', () {
      cache.set('k1', 'v1');
      cache.set('k2', 'v2');
      expect(cache.count, equals(2));
      cache.clear();
      expect(cache.count, equals(0));
      expect(cache.get<String>('k1'), isNull);
    });

    test('expires items past TTL', () async {
      cache.set('expiring_key', 'quick', ttl: const Duration(milliseconds: 10));
      expect(cache.get<String>('expiring_key'), equals('quick'));
      await Future.delayed(const Duration(milliseconds: 20));
      expect(cache.get<String>('expiring_key'), isNull);
    });
  });

  group('Song Model & Audius JSON Parsing', () {
    test('parses full Audius track JSON correctly', () {
      final json = {
        'id': 'track_abc_123',
        'title': 'Gurenge Anime Remix',
        'user': {'id': 'user_456', 'name': 'LiSA', 'handle': 'lisa_official'},
        'artwork': {
          '150x150': 'https://audius.co/art/150.jpg',
          '480x480': 'https://audius.co/art/480.jpg',
          '1000x1000': 'https://audius.co/art/1000.jpg',
        },
        'duration': 240,
        'genre': 'Anime Rock',
        'release_date': '2022-05-15',
        'play_count': 95000,
        'downloadable': true,
      };

      const host = 'https://discoveryprovider.audius.co';
      final song = Song.fromAudiusJson(json, host, appName: 'LIVE_IT_TEST');

      expect(song.id, equals('track_abc_123'));
      expect(song.title, equals('Gurenge Anime Remix'));
      expect(song.artist, equals('LiSA'));
      expect(song.artistId, equals('user_456'));
      expect(song.artworkUrl, equals('https://audius.co/art/1000.jpg'));
      expect(song.durationMs, equals(240000));
      expect(song.genre, equals('Anime Rock'));
      expect(song.releaseDate, equals('2022-05-15'));
      expect(song.playCount, equals(95000));
      expect(song.isDownloadable, isTrue);
      expect(song.source, equals(MusicSource.audius));
      expect(
        song.streamUrl,
        equals(
          'https://discoveryprovider.audius.co/v1/tracks/track_abc_123/stream?app_name=LIVE_IT_TEST',
        ),
      );
    });

    test('handles missing or malformed fields with safe fallbacks', () {
      final json = <String, dynamic>{};
      const host = 'https://discoveryprovider.audius.co';
      final song = Song.fromAudiusJson(json, host);

      expect(song.id, equals(''));
      expect(song.title, equals('Untitled Track'));
      expect(song.artist, equals('Audius Artist'));
      expect(song.artistId, isNull);
      expect(song.artworkUrl, equals(Song.defaultArtwork));
      expect(song.durationMs, equals(180000));
      expect(song.source, equals(MusicSource.audius));
    });

    test('JSON serialization roundtrip preserves properties', () {
      final original = Song(
        id: 's_1',
        title: 'Blue Bird',
        artist: 'Ikimonogakari',
        artistId: 'art_1',
        album: 'Naruto Shippuden OST',
        artworkUrl: 'https://images.unsplash.com/photo-1',
        streamUrl: 'https://stream.mp3',
        durationMs: 215000,
        genre: 'J-Pop',
        isFavorite: true,
        isDownloaded: false,
        source: MusicSource.audius,
      );

      final json = original.toJson();
      final reconstructed = Song.fromJson(json);

      expect(reconstructed.id, equals(original.id));
      expect(reconstructed.title, equals(original.title));
      expect(reconstructed.artist, equals(original.artist));
      expect(reconstructed.artistId, equals(original.artistId));
      expect(reconstructed.album, equals(original.album));
      expect(reconstructed.durationMs, equals(original.durationMs));
      expect(reconstructed.isFavorite, isTrue);
      expect(reconstructed.source, equals(MusicSource.audius));
    });
  });

  group('Artist Model Parsing', () {
    test('parses Audius user JSON payload correctly', () {
      final json = {
        'id': 'user_naruto_01',
        'name': 'Uchiha Beats',
        'handle': 'uchihabeats',
        'profile_picture': {'480x480': 'https://audius.co/user/pic.jpg'},
        'cover_photo': {'2000x': 'https://audius.co/user/cover.jpg'},
        'bio': 'Music inspired by the Hidden Leaf',
        'follower_count': 1250000,
        'track_count': 42,
        'is_verified': true,
      };

      final artist = Artist.fromAudiusJson(json);
      expect(artist.id, equals('user_naruto_01'));
      expect(artist.name, equals('Uchiha Beats'));
      expect(artist.handle, equals('uchihabeats'));
      expect(artist.imageUrl, equals('https://audius.co/user/pic.jpg'));
      expect(artist.coverUrl, equals('https://audius.co/user/cover.jpg'));
      expect(artist.bio, equals('Music inspired by the Hidden Leaf'));
      expect(artist.monthlyListeners, equals('1.3M monthly listeners'));
      expect(artist.trackCount, equals(42));
      expect(artist.isVerified, isTrue);
    });
  });

  group('Album & Playlist Model Parsing', () {
    test('parses Audius playlist/album JSON correctly', () {
      final json = {
        'id': 'album_shippuden',
        'playlist_name': 'Akatsuki Anthology',
        'description': 'Dark orchestral electronic beats',
        'user': {'id': 'user_itachi', 'name': 'Itachi Uchiha'},
        'artwork': {'480x480': 'https://audius.co/album/cover.jpg'},
        'track_count': 12,
        'created_at': '2023-10-01T12:00:00.000Z',
      };

      const host = 'https://discoveryprovider.audius.co';
      final album = Album.fromAudiusJson(json, host);

      expect(album.id, equals('album_shippuden'));
      expect(album.title, equals('Akatsuki Anthology'));
      expect(album.artist, equals('Itachi Uchiha'));
      expect(album.coverUrl, equals('https://audius.co/album/cover.jpg'));
      expect(album.year, equals(2023));
      expect(album.trackCount, equals(12));

      final playlist = Playlist.fromAudiusJson(json, host);
      expect(playlist.id, equals('album_shippuden'));
      expect(playlist.title, equals('Akatsuki Anthology'));
      expect(playlist.userName, equals('Itachi Uchiha'));
      expect(playlist.isUserCreated, isFalse);
    });
  });

  group('AudiusClient Configuration & Stream URL Resolution', () {
    test('generates stream URL adhering to Audius v1 specification', () {
      final client = AudiusClient(appName: 'LIVE_IT_TEST');
      final streamUrl = client.getStreamUrl('track_12345');

      expect(streamUrl, contains('/v1/tracks/track_12345/stream'));
      expect(streamUrl, contains('app_name=LIVE_IT_TEST'));
      expect(streamUrl, startsWith('http'));
    });

    test('contains reliable fallback discovery node hosts', () {
      final client = AudiusClient();
      expect(client.candidateHosts.isNotEmpty, isTrue);
      expect(
        client.candidateHosts,
        contains('https://discoveryprovider.audius.co'),
      );
    });
  });

  group('Audius Exception Hierarchy', () {
    test('instantiates and formats custom Audius exceptions', () {
      const netErr = NetworkException('No connection');
      expect(netErr.toString(), equals('No connection'));

      const timeoutErr = TimeoutException('Timeout');
      expect(timeoutErr.toString(), equals('Timeout'));

      const hostErr = HostUnavailableException();
      expect(hostErr.toString(), contains('unreachable'));

      const notFound = NotFoundException();
      expect(notFound.statusCode, equals(404));

      const rateLimit = RateLimitException();
      expect(rateLimit.statusCode, equals(429));
    });
  });
}
