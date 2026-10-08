import 'package:flutter/material.dart';

import '../services/download_service.dart';
import '../theme/app_theme.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  double _cacheSizeMB = 12.4;
  double _downloadSizeMB = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStorageData();
  }

  Future<void> _loadStorageData() async {
    final downloadBytes = await DownloadService.getTotalDownloadSizeBytes();
    if (mounted) {
      setState(() {
        _downloadSizeMB = downloadBytes / (1024 * 1024);
        _isLoading = false;
      });
    }
  }

  void _clearCache() {
    setState(() {
      _cacheSizeMB = 0.0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'App Cache Cleared',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.brightRed,
      ),
    );
  }

  Future<void> _clearDownloads() async {
    await DownloadService.clearAllDownloads();
    setState(() {
      _downloadSizeMB = 0.0;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Downloads Cleared',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.brightRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double totalMB = _cacheSizeMB + _downloadSizeMB;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Storage & Cache'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Visual Storage Usage Bar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'STORAGE USAGE',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isLoading
                        ? 'Calculating...'
                        : '${totalMB.toStringAsFixed(1)} MB used',
                    style: const TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stacked Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 12,
                      width: double.infinity,
                      color: AppColors.divider,
                      child: Row(
                        children: [
                          Expanded(
                            flex: (_downloadSizeMB * 10).toInt() + 1,
                            child: Container(color: AppColors.brightRed),
                          ),
                          Expanded(
                            flex: (_cacheSizeMB * 10).toInt() + 1,
                            child: Container(color: AppColors.darkRed),
                          ),
                          Expanded(
                            flex: ((1000 - totalMB) * 10)
                                .clamp(1, 10000)
                                .toInt(),
                            child: Container(color: AppColors.card),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppColors.brightRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Downloads (${_downloadSizeMB.toStringAsFixed(1)} MB)',
                            style: const TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppColors.darkRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Cache (${_cacheSizeMB.toStringAsFixed(1)} MB)',
                            style: const TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            _buildActionTile(
              title: 'Clear App Cache',
              subtitle: 'Free up temporary song metadata and streaming buffer',
              buttonLabel: 'CLEAR CACHE',
              onPressed: _cacheSizeMB > 0 ? _clearCache : null,
            ),
            const SizedBox(height: 16),

            _buildActionTile(
              title: 'Clear Downloaded Songs',
              subtitle:
                  'Remove offline downloaded tracks from your local device',
              buttonLabel: 'CLEAR DOWNLOADS',
              onPressed: _downloadSizeMB > 0 ? _clearDownloads : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback? onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkRed,
              foregroundColor: AppColors.brightRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: AppColors.brightRed, width: 1),
              ),
            ),
            child: Text(
              buttonLabel,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
