import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/audio_service.dart';
import 'theme/app_theme.dart';
import 'screens/library_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        home: const LibraryScreen(),
      ),
    );
  }
}
