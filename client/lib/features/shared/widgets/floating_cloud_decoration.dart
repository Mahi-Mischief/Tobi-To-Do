import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FloatingCloudDecoration extends StatelessWidget {
  const FloatingCloudDecoration({
    super.key,
    required this.asset,
    required this.opacity,
    this.top,
    this.left,
    this.right,
    this.bottom,
    this.width,
  });

  final String asset;
  final double opacity;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Opacity(
        opacity: opacity,
        child: SvgPicture.asset(
          asset,
          width: width,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
