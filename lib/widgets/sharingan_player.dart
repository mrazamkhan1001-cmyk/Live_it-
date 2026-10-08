import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../theme/app_theme.dart';

/// Cinematic Sharingan Video Visualizer Widget
/// Features continuous video playback inside a perfect circular mask
/// with a soft atmospheric red energy glow and subtle rotation effect.
class SharinganPlayer extends StatefulWidget {
  final bool isPlaying;
  final double size;

  const SharinganPlayer({
    super.key,
    required this.isPlaying,
    this.size = 260.0,
  });

  @override
  State<SharinganPlayer> createState() => _SharinganPlayerState();
}

class _SharinganPlayerState extends State<SharinganPlayer> with TickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  late AnimationController _pulseController;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    );

    if (widget.isPlaying) {
      _rotationController.repeat();
    }

    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      _controller = VideoPlayerController.asset(
        'assets/video/sharingan_android.mp4',
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      await _controller!.initialize();
      _controller!.setLooping(true);
      _controller!.setVolume(0.0);

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });

        if (widget.isPlaying) {
          _controller!.play();
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant SharinganPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    }

    if (_controller != null && _isInitialized && !_hasError) {
      if (widget.isPlaying && !_controller!.value.isPlaying) {
        _controller!.play();
      } else if (!widget.isPlaying && _controller!.value.isPlaying) {
        _controller!.pause();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double visualizerSize = widget.size;

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _rotationController]),
      builder: (context, child) {
        final beatPulse = widget.isPlaying ? _pulseController.value : 0.0;
        final rotationAngle = _rotationController.value * 2 * math.pi;

        return SizedBox(
          width: visualizerSize + 60,
          height: visualizerSize + 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Atmospheric Soft Red Energy Glow matching Animated Version (Glow Effect)
              CustomPaint(
                size: Size(visualizerSize + 60, visualizerSize + 60),
                painter: _AtmosphericGlowPainter(beatPulse: beatPulse),
              ),

              // Soft Red Energy Shadow Layer
              Container(
                width: visualizerSize,
                height: visualizerSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.glowPrimary.withValues(alpha: 0.5 + (beatPulse * 0.2)),
                      blurRadius: 40 + (beatPulse * 15),
                      spreadRadius: 6 + (beatPulse * 6),
                    ),
                  ],
                ),
              ),

              // Perfect Circular Sharingan Video Visualizer
              Container(
                width: visualizerSize,
                height: visualizerSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.background,
                ),
                child: ClipOval(
                  child: _isInitialized && _controller != null && !_controller!.value.hasError && !_hasError
                      ? Transform.rotate(
                          angle: rotationAngle * 0.15, // Subtle smooth rotation matching reference image
                          child: AspectRatio(
                            aspectRatio: _controller!.value.aspectRatio,
                            child: VideoPlayer(_controller!),
                          ),
                        )
                      : CustomPaint(
                          size: Size(visualizerSize, visualizerSize),
                          painter: _SharinganFallbackPainter(
                            rotationAngle: rotationAngle,
                            beatPulse: beatPulse,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AtmosphericGlowPainter extends CustomPainter {
  final double beatPulse;

  _AtmosphericGlowPainter({required this.beatPulse});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) * (0.92 + (beatPulse * 0.08));

    final paint = Paint()
      ..shader = RadialGradient(
        colors: const [
          Color(0x77D00010),
          Color(0x44B0000A),
          Color(0x1A6D0005),
          Color(0x00050505),
        ],
        stops: const [0.0, 0.4, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _AtmosphericGlowPainter oldDelegate) =>
      oldDelegate.beatPulse != beatPulse;
}

class _SharinganFallbackPainter extends CustomPainter {
  final double rotationAngle;
  final double beatPulse;

  _SharinganFallbackPainter({required this.rotationAngle, required this.beatPulse});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Dark Red Eye Background
    final eyeBgPaint = Paint()..color = const Color(0xFFD00010);
    canvas.drawCircle(center, radius * 0.9, eyeBgPaint);

    // Outer Iris Ring
    final ringPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.06;
    canvas.drawCircle(center, radius * 0.7, ringPaint);
    canvas.drawCircle(center, radius * 0.9, ringPaint);

    // Center Pupil
    final pupilPaint = Paint()..color = Colors.black;
    canvas.drawCircle(center, radius * 0.22 + (beatPulse * 2), pupilPaint);

    // Rotating Tomoe
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);

    final tomoeRadius = radius * 0.55;
    for (int i = 0; i < 3; i++) {
      final angle = (i * 2 * math.pi / 3);
      final tomoeCenter = Offset(tomoeRadius * math.cos(angle), tomoeRadius * math.sin(angle));

      canvas.drawCircle(tomoeCenter, radius * 0.09, pupilPaint);
      
      final path = Path()
        ..addArc(
          Rect.fromCircle(center: tomoeCenter, radius: radius * 0.12),
          angle - 0.5,
          1.8,
        );
      canvas.drawPath(path, ringPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SharinganFallbackPainter oldDelegate) =>
      oldDelegate.rotationAngle != rotationAngle || oldDelegate.beatPulse != beatPulse;
}
