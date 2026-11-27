import 'package:flutter/material.dart';

/// A short picture at the top of a screen. Decorative only, so screen readers skip it.
class HeaderImage extends StatelessWidget {
  const HeaderImage(this.asset, {super.key});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        child: Image.asset(
          asset,
          height: 150,
          width: double.infinity,
          fit: BoxFit.cover,
          excludeFromSemantics: true,
        ),
      ),
    );
  }
}
