import 'package:flutter/material.dart';

class ChicletCard extends StatelessWidget {
  final Widget child;
  final Color color;
  final double depth;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;

  const ChicletCard({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.depth = 6,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: borderRadius,
                border: Border.all(
                  color: Colors.grey.shade300
                )
              ),
              child: Container(
                margin: EdgeInsets.only(bottom: depth),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: borderRadius,
                ),
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }
}
