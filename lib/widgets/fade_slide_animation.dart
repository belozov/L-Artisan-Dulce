import 'package:flutter/material.dart';

class FadeSlideAnimation extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration? duration;

  const FadeSlideAnimation({
    super.key,
    required this.child,
    this.index = 0,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration ?? Duration(milliseconds: 300 + index * 60),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
