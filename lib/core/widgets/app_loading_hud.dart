import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'package:alex_transportation/core/widgets/custom_loading_indicator.dart';

/// Modal progress wrapper using [CustomLoadingIndicator] and darkened overlay.
///
/// Use this across all views when performing asynchronous operations to block
/// interaction and present the brand loading indicator.
class AppLoadingHUD extends StatelessWidget {
  final bool inAsyncCall;
  final Widget child;
  final Color color;
  final double opacity;
  final double indicatorSize;

  const AppLoadingHUD({
    super.key,
    required this.inAsyncCall,
    required this.child,
    this.color = Colors.black,
    this.opacity = 0.5,
    this.indicatorSize = 64,
  });

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: inAsyncCall,
      progressIndicator: CustomLoadingIndicator(size: indicatorSize),
      color: color,
      opacity: opacity,
      child: child,
    );
  }
}
