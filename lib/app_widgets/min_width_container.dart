import 'package:flutter/material.dart';

class MinWidthContainer extends StatelessWidget {
  final double minWidth;
  final Widget child;

  const MinWidthContainer({
    super.key,
    required this.minWidth,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        constraints: BoxConstraints(minWidth: minWidth),
        child: child,
      ),
    );
  }
}
