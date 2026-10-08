import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/mini_player.dart';
import '../widgets/bottom_navigation.dart';
import 'edit_profile_screen.dart';
import 'theme_settings_screen.dart';
import 'settings_screen.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';

/// Redesigned Profile Screen with Full-Screen Cinematic Background and Sasuke Avatar
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentNavIndex = 3; // Profile tab active

  @override
  Widget build(BuildContext context) {
    if (_currentNavIndex == 0) return const HomeScreen();
    if (_currentNavIndex == 1) return const SearchScreen();
    if (_currentNavIndex == 2) return const LibraryScreen();

    return Consumer<AudioPlayerService>(
      builder: (context, audio, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // 1. FULL-SCREEN BACKGROUND ARTWORK (Itachi + Red Moon + Crows)
              Positioned.fill(
                child: Image.asset(
                  'assets/images/itachi_face_bg.png',
                  fit: BoxFit.cover,
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
                                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                                  onPressed: () {
                                    if (Navigator.of(context).canPop()) {
                                      Navigator.of(context).pop();
                                    } else {
                                      setState(() {
                                        _currentNavIndex = 0;
                                      });
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
                                    border: Border.all(color: Colors.white38, width: 2),
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
                                    color: const Color(0xFF151515).withValues(alpha: 0.9),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.divider, width: 1.5),
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
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Azam Khan',
                                  style: TextStyle(
                                    color: AppColors.primaryText,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(
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
                                Container(height: 28, width: 1, color: Colors.white24),
                                _buildStatColumn('Playlists', '12'),
                                Container(height: 28, width: 1, color: Colors.white24),
                                _buildStatColumn('Minutes', '2.4K'),
                              ],
                            ),
                            const SizedBox(height: 26),

                            // 9. PROFILE ACTION MENU CARDS
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: [
                                  _buildMenuCard(
                                    context: context,
                                    icon: Icons.person_outline,
                                    title: 'Edit Profile',
                                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.secondaryText, size: 22),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => const EditProfileScreen()),
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
                                        MaterialPageRoute(builder: (_) => const ThemeSettingsScreen()),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 10),

                                  _buildMenuCard(
                                    context: context,
                                    icon: Icons.settings_outlined,
                                    title: 'Settings',
                                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.secondaryText, size: 22),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                                      );
                                    },
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

                    // Persistent Mini Player (only visible if active song present)
                    const MiniPlayer(),

                    // 10. GLOBAL BOTTOM NAVIGATION (Profile active in LIVE IT red #FF1018)
                    CustomBottomNavigation(
                      currentIndex: _currentNavIndex,
                      onTap: (index) {
                        setState(() {
                          _currentNavIndex = index;
                        });
                      },
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
          style: const TextStyle(
            color: AppColors.secondaryText,
            fontSize: 12,
          ),
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF151515).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12, width: 1),
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
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.primaryText,
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
