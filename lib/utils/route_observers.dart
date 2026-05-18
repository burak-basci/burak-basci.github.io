import 'package:flutter/material.dart';

/// App-wide [RouteObserver] used by pages that want to react to navigator
/// lifecycle events (push / pop / didPopNext) via the [RouteAware] mixin.
///
/// Wired into [GetMaterialApp.navigatorObservers] in `main.dart`. The home
/// page subscribes here so it can restore its ListView scroll offset the
/// moment it becomes the top route again after a project-detail pop —
/// fixing the "page jumps to old position during uncover" issue where
/// PageStorage alone wasn't restoring the offset before the first paint.
final RouteObserver<PageRoute<dynamic>> appRouteObserver =
    RouteObserver<PageRoute<dynamic>>();
