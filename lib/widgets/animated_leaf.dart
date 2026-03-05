import 'package:flutter/material.dart';
import 'dart:math';

class AnimatedLeaf extends StatefulWidget {
  final double finalTop;
  final double? left;
  final double? right;
  final double size;
  final double delay;
  final bool landsOnLeft;

  const AnimatedLeaf({
    super.key,
    required this.finalTop,
    this.left,
    this.right,
    required this.size,
    this.delay = 0.0,
    required this.landsOnLeft,
  });

  @override
  State<AnimatedLeaf> createState() => _AnimatedLeafState();
}

class _AnimatedLeafState extends State<AnimatedLeaf>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.2, curve: Curves.easeIn),
      ),
    );

    Future.delayed(Duration(milliseconds: (widget.delay * 1000).toInt()), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.finalTop,
      left: widget.left,
      right: widget.right,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          double t = _controller.value;
          double pathEase = Curves.easeOutCubic.transform(t);
          double startX = widget.landsOnLeft ? -250.0 : -450.0;
          double startY = -200.0;
          double mainX = startX * (1 - pathEase);
          double mainY = startY * (1 - pathEase);
          double dampening = (1 - t);
          double loopRadius = 50.0 * dampening;
          double loopX = -sin(t * pi * 4) * loopRadius;
          double loopY = -cos(t * pi * 4) * loopRadius;
          double swayX = sin(t * pi * 2) * 40.0 * dampening;
          double rotation = (t * pi * 4) + (sin(t * pi * 6) * 0.8 * dampening);

          return Transform.translate(
            offset: Offset(mainX + loopX + swayX, mainY + loopY),
            child: Transform.rotate(
              angle: rotation,
              child: Opacity(opacity: _opacityAnimation.value, child: child),
            ),
          );
        },
        child: Icon(
          Icons.eco,
          color: const Color(0xFF8CC63F),
          size: widget.size,
        ),
      ),
    );
  }
}
