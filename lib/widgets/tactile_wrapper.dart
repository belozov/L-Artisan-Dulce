import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wraps any child with a scale-down + haptic tap animation.
class TactileWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;

  const TactileWrapper({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.97,
  });

  @override
  State<TactileWrapper> createState() => _TactileWrapperState();
}

class _TactileWrapperState extends State<TactileWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _controller.reverse();
    HapticFeedback.lightImpact();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
