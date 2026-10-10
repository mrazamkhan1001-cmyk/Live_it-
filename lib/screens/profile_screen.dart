import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import 'theme_settings_screen.dart';

/// Redesigned Profile Screen with Full-Screen Cinematic Background and Sasuke Avatar
class ProfileScreen extends StatefulWidget {
  final void Function(int)? onNavigateToTab;

  const ProfileScreen({super.key, this.onNavigateToTab});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggingOut = false;

  Future<void> _showLogoutDialog(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161616),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: AppColors.brightRed.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          title: const Text(
            'Log out?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out of your account?',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 14,
            ),
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brightRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                elevation: 0,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      await _performLogout();
    }
  }

  Future<void> _performLogout() async {
    if (_isLoggingOut) return;
    setState(() {
      _isLoggingOut = true;
    });

    try {
      final audioService =
          Provider.of<AudioPlayerService>(context, listen: false);
      await audioService.logout();

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: AppColors.brightRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (context, audio, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // 1. FULL-SCREEN BACKGROUND ARTWORK (Red Moon + Silhouette + Ravens)
              Positioned.fill(
                child: Image.asset(
                  'assets/images/profile_background.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  filterQuality: FilterQuality.high,
                ),
              ),

              // 2. DARK GRADIENT OVERLAY
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.50),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),

              // 3. MAIN FOREGROUND CONTENT OVER BACKGROUND
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Top Row with Back Button over artwork
                            Padding(
                              padding: const EdgeInsets.only(left: 12, top: 8),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    if (widget.onNavigateToTab != null) {
                                      widget.onNavigateToTab!(0);
                                    } else if (Navigator.of(context).canPop()) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // 4. SASUKE AVATAR POSITIONED NEAR TOP
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  width: 82,
                                  height: 82,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white38,
                                      width: 2,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black54,
                                        blurRadius: 16,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/images/sasuke_profile.jpg',
                                      fit: BoxFit.cover,
                                      filterQuality: FilterQuality.high,
                                    ),
                                  ),
                                ),

                                // Camera Icon Badge
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF151515)
                                        .withValues(alpha: 0.9),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.divider,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.white,
                                    size: 13,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // 5. USER NAME (Azam Khan) + RED VERIFICATION BADGE
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  audio.rawUserName.isNotEmpty
                                      ? audio.rawUserName
                                      : 'Azam Khan',
                                  style: const TextStyle(
                                    color: AppColors.primaryText,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.brightRed,
                                  size: 20,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // 6. USERNAME (@azam_uchiha)
                            const Text(
                              '@azam_uchiha',
                              style: TextStyle(
                                color: AppColors.secondaryText,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // 7. PROFILE BIO ("Music is my genjutsu.")
                            const Text(
                              '"Music is my genjutsu."',
                              style: TextStyle(
                                color: AppColors.secondaryText,
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // 8. PROFILE STATS (Centered 3-column layout)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatColumn('Songs', '523'),
                                Container(
                                  height: 28,
                                  width: 1,
                                  color: Colors.white24,
                                ),
                                _buildStatColumn('Playlists', '12'),
                                Container(
                                  height: 28,
                                  width: 1,
                                  color: Colors.white24,
                                ),
                                _buildStatColumn('Minutes', '2.4K'),
                              ],
                            ),
                            const SizedBox(height: 26),

                            // 9. PROFILE ACTION MENU CARDS
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Column(
                                children: [
                                  _buildMenuCard(
                                    context: context,
                                    icon: Icons.person_outline,
                                    title: 'Edit Profile',
                                    trailing: const Icon(
                                      Icons.chevron_right_rounded,
                                      color: AppColors.secondaryText,
                                      size: 22,
                                    ),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const EditProfileScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 10),

                                  // THEME ROW with small red indicator (#FF1018)
                                  _buildMenuCard(
                                    context: context,
                                    icon: Icons.palette_outlined,
                                    title: 'Theme',
                                    trailing: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: const BoxDecoration(
                                        color: AppColors.brightRed,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const ThemeSettingsScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 10),

                                  _buildMenuCard(
                                    context: context,
                                    icon: Icons.settings_outlined,
                                    title: 'Settings',
                                    trailing: const Icon(
                                      Icons.chevron_right_rounded,
                                      color: AppColors.secondaryText,
                                      size: 22,
                                    ),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const SettingsScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 10),

                                  // LOGOUT BUTTON
                                  _buildMenuCard(
                                    context: context,
                                    icon: Icons.logout_rounded,
                                    iconColor: AppColors.brightRed,
                                    title: 'Logout',
                                    titleColor: AppColors.brightRed,
                                    borderColor: AppColors.brightRed
                                        .withValues(alpha: 0.35),
                                    trailing: _isLoggingOut
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                AppColors.brightRed,
                                              ),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.chevron_right_rounded,
                                            color: AppColors.brightRed,
                                            size: 22,
                                          ),
                                    onTap: _isLoggingOut
                                        ? () {}
                                        : () => _showLogoutDialog(context),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            const Text(
                              'LIVE IT',
                              style: TextStyle(
                                color: AppColors.primaryText,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'BY AZAM KHAN',
                              style: TextStyle(
                                color: AppColors.brightRed,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget trailing,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
    Color titleColor = AppColors.primaryText,
    Color borderColor = Colors.white12,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF151515).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
