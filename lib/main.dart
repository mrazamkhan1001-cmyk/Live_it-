import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'services/audio_service.dart';
import 'theme/app_theme.dart';
import 'screens/loading_screen.dart';

import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Defensive, non-blocking startup: ensure runApp is always reached promptly
  try {
    await StorageService.init().timeout(
      const Duration(seconds: 2),
      onTimeout: () {
        debugPrint('StorageService.init timed out, continuing startup.');
      },
    );
  } catch (e) {
    debugPrint('StorageService.init error: $e');
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(
      const Duration(seconds: 3),
      onTimeout: () {
        debugPrint('Firebase.initializeApp timed out, continuing startup.');
        return Firebase.app();
      },
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.azam.liveit.channel.audio',
      androidNotificationChannelName: 'LIVE IT Audio Playback',
      androidNotificationOngoing: true,
      androidNotificationIcon: 'mipmap/ic_launcher',
    ).timeout(
      const Duration(seconds: 3),
      onTimeout: () {
        debugPrint('JustAudioBackground.init timed out, continuing startup.');
      },
    );
  } catch (e) {
    debugPrint('JustAudioBackground notice: $e');
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
