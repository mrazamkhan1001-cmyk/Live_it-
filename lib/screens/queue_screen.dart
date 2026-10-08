import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';

class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key});

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  int _selectedTab = 1; // 0: Now Playing, 1: Up Next

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (context, audio, child) {
        final queue = audio.queue;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Queue'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),

                // Top Segmented Filter Toggle Pills matching Mockup #11
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: AppColors.divider, width: 1),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTab = 0;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _selectedTab == 0 ? AppColors.brightRed : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Now Playing',
                              style: TextStyle(
                                color: _selectedTab == 0 ? Colors.white : AppColors.secondaryText,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTab = 1;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _selectedTab == 1 ? AppColors.brightRed : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Up Next',
                              style: TextStyle(
                                color: _selectedTab == 1 ? Colors.white : AppColors.secondaryText,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Queue Content
                Expanded(
                  child: queue.isEmpty
                      ? const Center(
                          child: Text('Queue is empty', style: TextStyle(color: AppColors.secondaryText)),
                        )
                      : ReorderableListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: queue.length,
                          onReorder: (oldIndex, newIndex) {
                            audio.reorderQueue(oldIndex, newIndex);
                          },
                          itemBuilder: (context, index) {
                            final song = queue[index];
                            final isCurrent = audio.currentSong?.id == song.id;

                            return Container(
                              key: ValueKey(song.id + index.toString()),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: isCurrent ? AppColors.darkRed.withValues(alpha: 0.3) : AppColors.card,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isCurrent ? AppColors.brightRed : AppColors.divider,
                                  width: 1,
                                ),
                              ),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    song.artworkUrl,
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 44,
                                      height: 44,
                                      color: AppColors.card,
                                      child: const Icon(Icons.music_note, color: AppColors.brightRed),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  song.title,
                                  style: TextStyle(
                                    color: isCurrent ? AppColors.brightRed : AppColors.primaryText,
                                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  song.artist,
                                  style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: const Icon(Icons.drag_handle, color: AppColors.secondaryText),
                                onTap: () => audio.playSong(song, index: index),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
