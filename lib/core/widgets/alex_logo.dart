import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Official AlexBank brand logo widget with the iconic triple arches
/// (Blue, Green, Orange) and orange border.
class AlexLogo extends StatelessWidget {
  final double size;

  const AlexLogo({
    super.key,
    this.size = 46,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/alexbank_logo.svg',
      width: size,
      height: size,
    );
  }
}
