import 'package:flutter/material.dart';
import 'login_screen.dart';

/// Animated Loading Screen for LIVE IT — BY AZAM
/// Features a real 0-100% progress animation over 3 seconds that automatically navigates to LoginScreen.
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

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
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            ),
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

          // Responsive calculation for exact bar overlay alignment
          final double barWidth = screenWidth * 0.62;
          const double barHeight = 8.0;
          final double barTop = screenHeight * 0.816;

          return Stack(
            children: [
              // Approved Background Artwork Image
              Positioned.fill(
                child: Image.asset(
                  'assets/images/live_it_loading.png',
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),

              // Animated Progress Bar Fill (#FF1018) overlaying the bar area
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
                        color: const Color(0xFF252525),
                        borderRadius: BorderRadius.circular(4),
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
                                  color: Color(0xAAFF1018),
                                  blurRadius: 6,
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
            ],
          );
        },
      ),
    );
  }
}
