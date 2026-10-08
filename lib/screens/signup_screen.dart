import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import 'main_shell_screen.dart';
import 'login_screen.dart';

/// Rebuilt SignupScreen matching CREATE ACCOUNT reference screenshot
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController(
    text: 'Azam Khan',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'azam.khan@gmail.com',
  );
  final TextEditingController _usernameController = TextEditingController(
    text: 'azam_khan',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: 'uchiha123',
  );
  final TextEditingController _confirmPasswordController =
      TextEditingController(text: 'uchiha123');

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _onSignup() async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      await Provider.of<AudioPlayerService>(
        context,
        listen: false,
      ).setUserName(name);
    }
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShellScreen()),
      );
    }
  }

  void _onGoogleLogin() async {
    await Provider.of<AudioPlayerService>(
      context,
      listen: false,
    ).setUserName('Azam Khan');
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShellScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER ARTWORK (Approved LIVE IT Red Moon Itachi Artwork)
            Stack(
              children: [
                SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/live_it_loading.png',
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                // Dark Gradient overlay fading into #050505
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.2),
                          AppColors.background.withValues(alpha: 0.8),
                          AppColors.background,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // Top Back Button
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, top: 8),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),

            // 2. SIGNUP BODY CONTENT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Join the community of music lovers.',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. INPUT FIELDS
                  _buildInputField(
                    controller: _nameController,
                    hintText: 'Full Name',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 12),

                  _buildInputField(
                    controller: _emailController,
                    hintText: 'Email address',
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 12),

                  _buildInputField(
                    controller: _usernameController,
                    hintText: 'Username',
                    icon: Icons.alternate_email,
                  ),
                  const SizedBox(height: 12),

                  _buildPasswordField(
                    controller: _passwordController,
                    hintText: 'Password',
                    obscure: _obscurePassword,
                    onToggle: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  const SizedBox(height: 12),

                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm Password',
                    obscure: _obscureConfirmPassword,
                    onToggle: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. CREATE ACCOUNT RED BUTTON (#FF1018)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _onSignup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brightRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 4,
                        shadowColor: AppColors.redGlow,
                      ),
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 5. SOCIAL LOGIN (Google Only)
                  const Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.divider)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR CONTINUE WITH',
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: AppColors.divider)),
                    ],
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _onGoogleLogin,
                      icon: Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg',
                        height: 20,
                        width: 20,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.g_mobiledata,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      label: const Text(
                        'Continue with Google',
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.card,
                        side: const BorderSide(
                          color: AppColors.divider,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 6. LOGIN LINK
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          } else {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: AppColors.brightRed,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: AppColors.primaryText, fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: AppColors.secondaryText,
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: AppColors.secondaryText, size: 20),
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.brightRed, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: AppColors.primaryText, fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: AppColors.secondaryText,
          fontSize: 14,
        ),
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: AppColors.secondaryText,
          size: 20,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.secondaryText,
            size: 20,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.brightRed, width: 1.5),
        ),
      ),
    );
  }
}
