import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

/// Rebuilt Login Screen matching target screenshot media_1791330347266.png 1:1
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    final name = _emailController.text.trim();
    if (name.isNotEmpty) {
      await Provider.of<AudioPlayerService>(context, listen: false).setUserName(name);
    }
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Stack(
        children: [
          // 1. FULL SCREEN ITACHI ARTWORK WITH CONTROLLED TOP CROP
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.54,
            child: Image.asset(
              'assets/images/itachi_face_bg.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              filterQuality: FilterQuality.high,
            ),
          ),

          // 2. GRADIENT FADE OVERLAY (Smooth transition down to deep black #050505)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.50),
                    const Color(0xFF050505),
                  ],
                  stops: const [0.0, 0.28, 0.44, 0.60],
                ),
              ),
            ),
          ),

          // 3. SUBTLE THIN RED ACCENT BORDER FRAME (#720006)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF720006).withValues(alpha: 0.55),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // 4. MAIN LOGIN CONTENT OVERLAY WITH EXACT TARGET SPACING
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Position LIVE IT right below Itachi's face at ~38% height
                    SizedBox(height: screenHeight * 0.225),

                    // LIVE IT Branding Title with Brush Style Accent
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'LIVE ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.8,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        Text(
                          'IT',
                          style: TextStyle(
                            color: AppColors.brightRed,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.8,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'BY AZAM KHAN',
                      style: TextStyle(
                        color: AppColors.brightRed,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.2,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Welcome Back Title & Subtitle (Left-aligned)
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Back',
                            style: TextStyle(
                              color: AppColors.primaryText,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Music for the ones who understand...',
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Compact Email Input Field (Placeholder: Email)
                    SizedBox(
                      height: 42,
                      child: TextField(
                        controller: _emailController,
                        style: const TextStyle(color: AppColors.primaryText, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
                          prefixIcon: const Icon(Icons.email_outlined, color: AppColors.secondaryText, size: 18),
                          filled: true,
                          fillColor: const Color(0xFF121212).withValues(alpha: 0.90),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12), width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.brightRed, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Compact Password Input Field with Toggle Visibility
                    SizedBox(
                      height: 42,
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: AppColors.primaryText, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
                          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.secondaryText, size: 18),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.secondaryText,
                              size: 18,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: const Color(0xFF121212).withValues(alpha: 0.90),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12), width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.brightRed, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Remember Me & Forgot Password Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: Checkbox(
                                value: _rememberMe,
                                activeColor: AppColors.brightRed,
                                side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                                onChanged: (val) {
                                  setState(() {
                                    _rememberMe = val ?? true;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Remember me',
                              style: TextStyle(color: AppColors.secondaryText, fontSize: 11),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Compact Bright Red Login Button (#FF1018) with Circular Arrow Badge
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brightRed,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                        ),
                        onPressed: _onLogin,
                        child: Row(
                          children: [
                            const Spacer(),
                            const Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // OR CONTINUE WITH Divider
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'OR CONTINUE WITH',
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 3 Social Login Buttons Row (Google, Apple, Discord)
                    Row(
                      children: [
                        Expanded(
                          child: _buildSocialButton(
                            child: const _GoogleLogoIcon(size: 18),
                            onTap: _onLogin,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildSocialButton(
                            child: const Icon(Icons.apple, color: Colors.white, size: 20),
                            onTap: _onLogin,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildSocialButton(
                            child: const _DiscordLogoIcon(size: 20),
                            onTap: _onLogin,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Don't have an account? Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 12,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SignupScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: AppColors.brightRed,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({required Widget child, required VoidCallback onTap}) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFF121212).withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Center(child: child),
        ),
      ),
    );
  }
}

/// Multi-color Google G Logo Painter matching Google Brand guidelines
class _GoogleLogoIcon extends StatelessWidget {
  final double size;
  const _GoogleLogoIcon({this.size = 18});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double radius = size.width / 2;
    final double strokeWidth = size.width * 0.22;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius - strokeWidth / 2);

    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, 3.14 + 0.35, 1.4, false, redPaint);

    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, 1.9, 1.2, false, yellowPaint);

    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, 0.65, 1.3, false, greenPaint);

    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, -0.4, 1.05, false, bluePaint);

    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(cx - strokeWidth * 0.1, cy - strokeWidth / 2, radius * 0.9, strokeWidth),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Official Discord Brand Icon widget (#5865F2)
class _DiscordLogoIcon extends StatelessWidget {
  final double size;
  const _DiscordLogoIcon({this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DiscordLogoPainter(),
      ),
    );
  }
}

class _DiscordLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF5865F2)
      ..style = PaintingStyle.fill;

    final path = Path();
    final double w = size.width;
    final double h = size.height;

    path.moveTo(w * 0.15, h * 0.2);
    path.cubicTo(w * 0.35, h * 0.12, w * 0.65, h * 0.12, w * 0.85, h * 0.2);
    path.cubicTo(w * 0.95, h * 0.4, w * 0.95, h * 0.7, w * 0.85, h * 0.85);
    path.cubicTo(w * 0.68, h * 0.92, w * 0.32, h * 0.92, w * 0.15, h * 0.85);
    path.cubicTo(w * 0.05, h * 0.7, w * 0.05, h * 0.4, w * 0.15, h * 0.2);
    path.close();

    canvas.drawPath(path, paint);

    final eyePaint = Paint()
      ..color = const Color(0xFF0F0F0F)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.36, h * 0.52), width: w * 0.18, height: h * 0.22),
      eyePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.64, h * 0.52), width: w * 0.18, height: h * 0.22),
      eyePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
