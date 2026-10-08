import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';

import 'services/audio_service.dart';
import 'theme/app_theme.dart';
import 'screens/loading_screen.dart';

import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await StorageService.init();
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.azam.liveit.channel.audio',
      androidNotificationChannelName: 'LIVE IT Audio Playback',
      androidNotificationOngoing: true,
      androidNotificationIcon: 'mipmap/ic_launcher',
    );
  } catch (_) {
    // Fallback gracefully in testing or unsupported platforms
  }
  runApp(const LiveItApp());
}

class LiveItApp extends StatelessWidget {
  const LiveItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AudioPlayerService>(
      create: (_) => AudioPlayerService(),
      child: MaterialApp(
        title: 'LIVE IT — BY AZAM KHAN',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const LoadingScreen(),
      ),
    );
  }
}
