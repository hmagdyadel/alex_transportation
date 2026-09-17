import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// App-wide custom rotating loading indicator featuring the AlexBank Transit logo.
class CustomLoadingIndicator extends StatefulWidget {
  final double size;

  const CustomLoadingIndicator({
    super.key,
    this.size = 64,
  });

  @override
  State<CustomLoadingIndicator> createState() => _CustomLoadingIndicatorState();
}

class _CustomLoadingIndicatorState extends State<CustomLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RotationTransition(
        turns: _controller,
        child: SvgPicture.asset(
          'assets/icons/alexbank_green_logo.svg',
          width: widget.size,
          height: widget.size,
        ),
      ),
    );
  }
}
