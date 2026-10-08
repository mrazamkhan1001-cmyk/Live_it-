import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Cinematic subtle dark shimmer container for loading states
/// Uses a dark pulse from #151515 to #222222 with zero harsh white glare.
class ShimmerContainer extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final BoxShape shape;

  const ShimmerContainer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  const ShimmerContainer.circular({super.key, required double size})
    : width = size,
      height = size,
      borderRadius = null,
      shape = BoxShape.circle;

  @override
  State<ShimmerContainer> createState() => _ShimmerContainerState();
}

class _ShimmerContainerState extends State<ShimmerContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final color = Color.lerp(
          AppColors.shimmerBase,
          AppColors.shimmerHighlight,
          _animation.value,
        );

        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: color,
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.circle
                ? null
                : (widget.borderRadius ?? BorderRadius.circular(8)),
            border: Border.all(
              color: AppColors.divider.withValues(alpha: 0.4),
              width: 0.8,
            ),
          ),
        );
      },
    );
  }
}

/// Standardized Song Row Loading Skeleton
class SongTileSkeleton extends StatelessWidget {
  final bool showLeadingNumber;

  const SongTileSkeleton({super.key, this.showLeadingNumber = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (showLeadingNumber) ...[
            const ShimmerContainer(width: 18, height: 16),
            const SizedBox(width: 14),
          ],
          const ShimmerContainer(width: 48, height: 48),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerContainer(width: double.infinity, height: 14),
                SizedBox(height: 6),
                ShimmerContainer(width: 120, height: 11),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const ShimmerContainer.circular(size: 24),
        ],
      ),
    );
  }
}

/// Standardized Album / Card Loading Skeleton
class CardSkeleton extends StatelessWidget {
  final double width;
  final double height;

  const CardSkeleton({super.key, this.width = 140, this.height = 140});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerContainer(
            width: width,
            height: height,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 8),
          ShimmerContainer(width: width * 0.85, height: 13),
          const SizedBox(height: 4),
          ShimmerContainer(width: width * 0.55, height: 10),
        ],
      ),
    );
  }
}
