import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/song.dart';

class DownloadService {
  static final Map<String, double> _downloadProgress = {};

  static double getProgress(String songId) => _downloadProgress[songId] ?? 0.0;

  static Future<File?> downloadSong(Song song, Function(double) onProgress) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/${song.id}.mp3';
      final file = File(filePath);

      if (await file.exists()) {
        onProgress(1.0);
        return file;
      }

      final request = http.Request('GET', Uri.parse(song.streamUrl));
      final response = await http.Client().send(request);
      final total = response.contentLength ?? 0;
      int downloaded = 0;

      final bytes = <int>[];
      response.stream.listen(
        (chunk) {
          bytes.addAll(chunk);
          downloaded += chunk.length;
          if (total > 0) {
            final p = downloaded / total;
            _downloadProgress[song.id] = p;
            onProgress(p);
          }
        },
        onDone: () async {
          await file.writeAsBytes(bytes);
          _downloadProgress[song.id] = 1.0;
          onProgress(1.0);
        },
        onError: (e) {
          _downloadProgress.remove(song.id);
        },
        cancelOnError: true,
      );

      return file;
    } catch (_) {
      return null;
    }
  }
}
