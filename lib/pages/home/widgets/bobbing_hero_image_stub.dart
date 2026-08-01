import 'package:flutter/widgets.dart';

/// Non-web fallback: a static image. The site only ships as a web
/// bundle; this stub exists so the other targets keep compiling.
Widget buildBobbingHeroImage({required String assetPath}) {
  return Image.asset(assetPath, fit: BoxFit.cover);
}
