import 'package:flutter/material.dart';

class RadialExpansion extends StatelessWidget {
  RadialExpansion({
    Key? key,
    required this.maxRadius,
    required this.child,
  }): super(key: key);

  final double maxRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      clipBehavior: Clip.hardEdge,
      child: ClipOval(
        child: SizedBox(
          child: child,
          width: maxRadius,
          height: maxRadius,
        ),
      ),
    );
  }
}