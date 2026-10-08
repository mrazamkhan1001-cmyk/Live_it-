import '../models/song.dart';
import '../models/lyric_line.dart';

/// Service for retrieving and parsing real-time synchronized lyrics
class LyricsService {
  static final Map<String, List<LyricLine>> _cache = {};

  /// Retrieve parsed lyric lines for a given song
  static List<LyricLine> getLyricsForSong(Song song) {
    if (_cache.containsKey(song.id)) {
      return _cache[song.id]!;
    }

    List<LyricLine> lines = [];

    // 1. If song contains explicit lyrics in model
    if (song.lyrics.isNotEmpty) {
      lines = LyricLine.parseList(song.lyrics);
    }

    // 2. If song is a known theme/curated anime track, provide timestamped LRC if model is default
    if (lines.isEmpty ||
        (!lines.any((l) => l.isSynchronized) && _hasCuratedSyncLyrics(song))) {
      final curatedLrc = _getCuratedSyncLyrics(song);
      if (curatedLrc != null) {
        lines = LyricLine.parseLrc(curatedLrc);
      }
    }

    _cache[song.id] = lines;
    return lines;
  }

  /// Check if curated synchronized lyrics are available for anime/live-it signature tracks
  static bool _hasCuratedSyncLyrics(Song song) {
    final title = song.title.toLowerCase();
    return title.contains('uchiha') ||
        title.contains('naruto') ||
        title.contains('shippuden') ||
        title.contains('sharingan') ||
        title.contains('vengeance') ||
        title.contains('susanoo') ||
        title.contains('arcane') ||
        title.contains('amaterasu');
  }

  /// Curated LRC lyrics for signature tracks
  static String? _getCuratedSyncLyrics(Song song) {
    final title = song.title.toLowerCase();

    if (title.contains('uchiha') ||
        title.contains('sharingan') ||
        title.contains('vengeance')) {
      return '''
[00:00.00]LIVE IT — Uchiha Legacy Beats
[00:08.50]Wake up to reality...
[00:15.00]Nothing ever goes as planned in this world.
[00:22.30]The longer you live, the more you realize...
[00:30.00]That the only things that truly exist in this reality are merely pain, suffering, and futility.
[00:39.50]Wherever there is light, there will always be shadows.
[00:48.00]As long as there is a concept of victors, the vanquished will also exist.
[00:58.20]In this world, where there is love, hatred is born.
[01:08.00]Sharingan awakens in the depths of sorrow.
[01:18.50]Mangekyo spinning through the endless night.
[01:29.00]Flame of Amaterasu that never fades away.
[01:40.00]LIVE IT BY AZAM KHAN — The Infinite Tsukuyomi.
''';
    }

    if (title.contains('naruto') || title.contains('shippuden')) {
      return '''
[00:00.00]Naruto Shippuden — Shinobi Beats
[00:10.00]Through the storm and through the rain.
[00:18.50]I will never give up on my ninja way!
[00:27.00]Blue bird soaring high into the clear blue sky.
[00:36.20]Aoi aoi ano sora...
[00:46.00]Tears falling down, but the fire inside burns bright.
[00:56.50]Believe it, the destiny is written in our stride.
[01:07.00]Rasengan swirling in the palm of my hand.
[01:18.00]Protect the bonds that will never break.
[01:30.00]LIVE IT — Konoha Beats Collection.
''';
    }

    return null;
  }
}
