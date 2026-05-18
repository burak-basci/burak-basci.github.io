import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:get/get.dart';

import 'firebase_options.dart';
import 'pages/home/home_page.dart';
import 'utils/intro_redirect.dart';
import 'utils/lang.dart';
import 'utils/page_transition.dart';
import 'utils/route_observers.dart';
import 'utils/routes.dart';
import 'utils/values/app_theme.dart';
import 'utils/values/values.dart';

// Text
// TODO: Fix Text Background Color
// TODO: Make Text properly Selectable

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Path-style URLs (no '#') so each project page is its own indexable URL
  // in search engines. Google ignores hash fragments — without this, every
  // route is treated as the same page.
  usePathUrlStrategy();

  // Lang controller has to be live before captureDeepLink, because the
  // redirect peeks at the URL prefix to decide which language to start
  // in and to strip `/de` from the stashed deep-link route.
  Get.put<LangController>(LangController(), permanent: true);

  // Any cold load — including direct deep links like /projects/foo — must
  // start on the home page so its intro animation plays once. Stash the
  // requested route here; the home page consumes it after the intro.
  IntroRedirect.captureDeepLink();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const Website());
}

class Website extends StatelessWidget {
  const Website({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: StringConst.appTitle,
      theme: AppTheme.lightThemeData,
      initialRoute: HomePage.homePageRoute,
      onGenerateRoute: RouteConfiguration.onGenerateRoute,
      home: const HomePage(),
      // RouteObserver lets individual pages (notably the home page) get
      // notified via [RouteAware] when they become the top route again
      // after a pop. The home page uses this to restore its ListView's
      // scroll offset *before* the global cover panel uncovers, so the
      // user never sees a visible 0 → previous-offset jump.
      navigatorObservers: <NavigatorObserver>[appRouteObserver],
      // One global cover-panel above the Navigator so every push, pop and
      // replace shares the exact same cover / uncover animation.
      builder: (BuildContext context, Widget? child) {
        return PageTransitionOverlay(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
