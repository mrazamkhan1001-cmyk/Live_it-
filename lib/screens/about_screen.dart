import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('About LIVE IT'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Sharingan Glow Logo Badge
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.brightRed, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.redGlow,
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.music_note,
                  color: AppColors.brightRed,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'LIVE IT',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'BY AZAM KHAN',
                style: TextStyle(
                  color: AppColors.brightRed,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.darkRed.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.brightRed, width: 1),
                ),
                child: const Text(
                  'Version 2.0.0',
                  style: TextStyle(color: AppColors.primaryText, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                '"YOU ARE ALREADY UNDER MY GENJUTSU."',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Details Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider, width: 1),
                ),
                child: Column(
                  children: [
                    const ListTile(
                      dense: true,
                      leading: Icon(Icons.api, color: AppColors.brightRed),
                      title: Text('Music Provider', style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
                      subtitle: Text('Audius Decentralized Music API', style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                    const Divider(color: AppColors.divider),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.gavel, color: AppColors.brightRed),
                      title: const Text('Terms of Service', style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600, fontSize: 14)),
                      trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.secondaryText, size: 14),
                      onTap: () {},
                    ),
                    const Divider(color: AppColors.divider),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.brightRed),
                      title: const Text('Privacy Policy', style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600, fontSize: 14)),
                      trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.secondaryText, size: 14),
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const Spacer(),
              const Text(
                '© 2026 LIVE IT — BY AZAM KHAN. All Rights Reserved.',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
