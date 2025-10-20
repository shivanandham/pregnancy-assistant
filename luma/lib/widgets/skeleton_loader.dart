import 'package:flutter/material.dart';

class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.margin,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
        color: Colors.grey[300],
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey[300]!,
                  Colors.grey[100]!,
                  Colors.grey[300]!,
                ],
                stops: [
                  0.0,
                  0.5,
                  1.0,
                ],
                transform: GradientRotation(_animation.value * 3.14159),
              ),
            ),
          );
        },
      ),
    );
  }
}

class TipsSkeletonLoader extends StatelessWidget {
  const TipsSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: PageView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title skeleton
                const SkeletonLoader(
                  width: double.infinity,
                  height: 24,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                const SizedBox(height: 12),
                // Content skeleton
                const SkeletonLoader(
                  width: double.infinity,
                  height: 60,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                const SizedBox(height: 12),
                // Category skeleton
                const SkeletonLoader(
                  width: 100,
                  height: 16,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                const Spacer(),
                // Action button skeleton
                const SkeletonLoader(
                  width: 120,
                  height: 36,
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class MilestonesSkeletonLoader extends StatelessWidget {
  const MilestonesSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon skeleton
                const SkeletonLoader(
                  width: 40,
                  height: 40,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                const SizedBox(height: 8),
                // Title skeleton
                const SkeletonLoader(
                  width: double.infinity,
                  height: 16,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                const SizedBox(height: 4),
                // Description skeleton
                const SkeletonLoader(
                  width: double.infinity,
                  height: 12,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                const SizedBox(height: 4),
                // Date skeleton
                const SkeletonLoader(
                  width: 80,
                  height: 12,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ChecklistSkeletonLoader extends StatelessWidget {
  const ChecklistSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Category header skeleton
          const SkeletonLoader(
            width: 150,
            height: 20,
            borderRadius: BorderRadius.all(Radius.circular(4)),
            margin: EdgeInsets.only(bottom: 12),
          ),
          // Checklist items skeleton
          ...List.generate(4, (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  // Checkbox skeleton
                  const SkeletonLoader(
                    width: 20,
                    height: 20,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    margin: EdgeInsets.only(right: 12),
                  ),
                  // Text skeleton
                  Expanded(
                    child: SkeletonLoader(
                      width: double.infinity,
                      height: 16,
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
