/// Model representing an individual lyric line with timestamp synchronization metadata
class LyricLine {
  final Duration startTime;
  final Duration? endTime;
  final String text;
  final bool isSynchronized;

  const LyricLine({
    required this.startTime,
    this.endTime,
    required this.text,
    this.isSynchronized = true,
  });

  /// Parse an LRC-formatted string or multiline text into an ordered list of LyricLine objects
  static List<LyricLine> parseLrc(String lrcContent) {
    final trimmed = lrcContent.trim();
    if (trimmed.isEmpty) return [];

    final lines = trimmed.split('\n');
    final List<LyricLine> parsedLines = [];
    final timeTagRegExp = RegExp(r'\[(\d{1,2}):(\d{2})(?:\.(\d{1,3}))?\]');

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      // Ignore ID tags like [ti:Title], [ar:Artist], [al:Album], [by:Creator], [length:03:45]
      if (RegExp(r'^\[[a-zA-Z]+:.*\]$').hasMatch(line)) {
        continue;
      }

      final matches = timeTagRegExp.allMatches(line).toList();
      if (matches.isNotEmpty) {
        // Text is everything after stripping the time tags
        final text = line.replaceAll(timeTagRegExp, '').trim();
        if (text.isEmpty) continue;

        for (final match in matches) {
          final minutes = int.tryParse(match.group(1) ?? '0') ?? 0;
          final seconds = int.tryParse(match.group(2) ?? '0') ?? 0;
          final millisStr = match.group(3) ?? '0';
          int millis = 0;
          if (millisStr.length == 1) {
            millis = (int.tryParse(millisStr) ?? 0) * 100;
          } else if (millisStr.length == 2) {
            millis = (int.tryParse(millisStr) ?? 0) * 10;
          } else if (millisStr.length >= 3) {
            millis = int.tryParse(millisStr.substring(0, 3)) ?? 0;
          }

          final start = Duration(
            minutes: minutes,
            seconds: seconds,
            milliseconds: millis,
          );
          parsedLines.add(
            LyricLine(startTime: start, text: text, isSynchronized: true),
          );
        }
      } else {
        // Plain text line without timestamp
        parsedLines.add(
          LyricLine(
            startTime: Duration.zero,
            text: line,
            isSynchronized: false,
          ),
        );
      }
    }

    // If synchronized timestamps exist, sort by startTime and calculate endTimes
    final hasSync = parsedLines.any((l) => l.isSynchronized);
    if (hasSync) {
      final syncLines = parsedLines.where((l) => l.isSynchronized).toList();
      syncLines.sort((a, b) => a.startTime.compareTo(b.startTime));

      final List<LyricLine> resultWithEndTimes = [];
      for (int i = 0; i < syncLines.length; i++) {
        final current = syncLines[i];
        final nextStart = i < syncLines.length - 1
            ? syncLines[i + 1].startTime
            : null;
        resultWithEndTimes.add(
          LyricLine(
            startTime: current.startTime,
            endTime: nextStart,
            text: current.text,
            isSynchronized: true,
          ),
        );
      }
      return resultWithEndTimes;
    }

    return parsedLines;
  }

  /// Parse a list of string lyrics (which may be LRC tagged or plain lines)
  static List<LyricLine> parseList(List<String> rawLines) {
    if (rawLines.isEmpty) return [];
    final joined = rawLines.join('\n');
    return parseLrc(joined);
  }

  /// Locate the active lyric index for a given playback position
  static int findActiveIndex(List<LyricLine> lines, Duration position) {
    if (lines.isEmpty) return -1;
    final hasSync = lines.any((l) => l.isSynchronized);
    if (!hasSync) return -1;

    int activeIndex = -1;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].isSynchronized) {
        if (lines[i].startTime <= position) {
          activeIndex = i;
        } else {
          break;
        }
      }
    }
    return activeIndex;
  }
}
