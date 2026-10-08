import 'package:flutter/material.dart';

import 'login_screen.dart';

/// Animated Loading Screen for LIVE IT — BY AZAM
/// Features a real 0-100% progress animation over 3 seconds that automatically navigates to LoginScreen.
/// Renders authentic Japanese typography, LIVE IT logo branding, animated glowing progress bar,
/// and a cinematic outer red border programmatically on top of the clean background artwork.
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  static const List<String> _japaneseCharacters = [
    'う',
    'ち',
    'は',
    'イ',
    'タ',
    'チ',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double screenWidth = constraints.maxWidth;
          final double screenHeight = constraints.maxHeight;

          // Responsive dimensions
          final double barWidth = screenWidth * 0.62;
          const double barHeight = 8.0;
          final double barTop = screenHeight * 0.812;
          final double loadingTextTop = screenHeight * 0.842;
          final double logoTop = screenHeight * 0.65;
          final double japaneseTop = screenHeight * 0.14;
          final double japaneseLeft = screenWidth * 0.08;

          return Stack(
            children: [
              // 1. FULL-SCREEN BACKGROUND ARTWORK
              Positioned.fill(
                child: Image.asset(
                  'assets/images/live_it_loading.png',
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),

              // 2. JAPANESE VERTICAL TEXT (LEFT SIDE: う ちは イタチ)
              Positioned(
                top: japaneseTop,
                left: japaneseLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _japaneseCharacters.map((char) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.006,
                      ),
                      child: Text(
                        char,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: (screenHeight * 0.026).clamp(18.0, 24.0),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0,
                          shadows: const [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 6,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // 3. LIVE IT LOGO & "BY AZAM KHAN"
              Positioned(
                top: logoTop,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'LIVE ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: (screenWidth * 0.095).clamp(32.0, 44.0),
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 2.5,
                              shadows: const [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 8,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                          TextSpan(
                            text: 'IT',
                            style: TextStyle(
                              color: const Color(0xFFFF1018),
                              fontSize: (screenWidth * 0.095).clamp(32.0, 44.0),
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 2.5,
                              shadows: const [
                                Shadow(
                                  color: Color(0xFFFF1018),
                                  blurRadius: 18,
                                  offset: Offset(0, 0),
                                ),
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 8,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'BY AZAM KHAN',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: (screenWidth * 0.033).clamp(11.0, 14.0),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        shadows: const [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 6,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 4. ANIMATED PROGRESS BAR (0.0 -> 1.0 with red glow)
              Positioned(
                top: barTop,
                left: (screenWidth - barWidth) / 2,
                width: barWidth,
                height: barHeight,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0x33FFFFFF),
                          width: 0.5,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: _animation.value.clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF1018),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xDDFF1018),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 5. "LOADING..." TEXT
              Positioned(
                top: loadingTextTop,
                left: 0,
                right: 0,
                child: Text(
                  'LOADING...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFFFF1018),
                    fontSize: (screenWidth * 0.028).clamp(10.0, 13.0),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 5.0,
                    shadows: const [
                      Shadow(
                        color: Color(0xAAFF1018),
                        blurRadius: 8,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),

              // 6. SUBTLE OUTER RED ROUNDED BORDER FRAME
              Positioned(
                top: 14,
                left: 14,
                right: 14,
                bottom: 14,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: const Color(0xFFFF1018).withValues(alpha: 0.65),
                        width: 1.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF1018).withValues(alpha: 0.2),
                          blurRadius: 10,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
