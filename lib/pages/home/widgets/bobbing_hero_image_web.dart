import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';

/// Web implementation: the hero illustration bobs via a CSS keyframe
/// animation on a plain `<img>` inside an [HtmlElementView].
///
/// WHY: a Flutter-side `repeat(reverse: true)` keeps the engine
/// producing frames forever, and CanvasKit presents the ENTIRE canvas
/// (transferToImageBitmap) on every produced frame no matter how small
/// the dirty region is — profiled at 93% of CPU and the cause of the
/// sub-1-fps home page on machines without GPU-accelerated WebGL2.
/// A CSS animation runs on the browser's compositor thread instead:
/// the Flutter surface stays completely static while the image floats,
/// so the idle page presents zero frames — the animation is kept, the
/// cost is gone.
bool _factoryRegistered = false;
const String _viewType = 'home-hero-bobbing-image';

Widget buildBobbingHeroImage({required String assetPath}) {
  if (!_factoryRegistered) {
    _factoryRegistered = true;
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      if (html.document.getElementById('hero-bob-keyframes') == null) {
        html.document.head!.append(
          html.StyleElement()
            ..id = 'hero-bob-keyframes'
            ..innerText = '@keyframes heroBob {'
                'from { transform: translateY(5%); }'
                'to   { transform: translateY(-5%); }'
                '}',
        );
      }
      // Flutter web serves bundle assets under "assets/<asset-path>".
      final html.ImageElement img = html.ImageElement()
        ..src = 'assets/$assetPath'
        ..alt = ''
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..style.animation = 'heroBob 2500ms ease-in-out infinite alternate';
      return html.DivElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.overflow = 'visible'
        // Decorative: never intercept pointer/wheel events — scrolling
        // over the illustration must keep reaching the Flutter surface.
        ..style.pointerEvents = 'none'
        ..append(img);
    });
  }
  return const HtmlElementView(viewType: _viewType);
}
