import 'package:burak_basci_website/pages/privacy_policy/privacy_policy_page.dart';
import 'package:flutter/material.dart';

import '../pages/about/about_page.dart';
import '../pages/contact/contact_page.dart';
import '../pages/experience/experience_page.dart';
import '../pages/home/home_page.dart';
import '../pages/project_detail/project_detail_page.dart';
import 'lang.dart';

typedef PathWidgetBuilder = Widget Function(BuildContext, String? /*Map<String, String>*/);

class Path {
  const Path(this.pattern, this.builder);

  /// A RegEx string for route matching.
  final String pattern;

  /// The builder for the associated pattern route. The first argument is the
  /// [BuildContext] and the second argument is any RegEx matches if such are
  /// included inside of the pattern. See example:
  ///
  /// ```dart
  /// Path(
  ///   'r'^/demo/(?<slug>[\w-]+)$',
  ///   (context, matches) => Page(argument: matches['slug']),
  /// )
  /// ```
  final PathWidgetBuilder builder;
}

class RouteConfiguration {
  /// List of [Path] to for route matching. When a named route is pushed with
  /// [Navigator.pushNamed], the route name is matched with the [Path.pattern]
  /// in the list below. As soon as there is a match, the associated builder
  /// will be returned. This means that the paths higher up in the list will
  /// take priority.
  static List<Path> paths = <Path>[
    Path(
      HomePage.homePageRoute,
      (context, matches) => const HomePage(),
    ),

    // Friendly alias so a direct visit to `/home` (or `/index`,
    // `/index.html`) still lands on the home page instead of falling
    // through to onUnknownRoute. The intro-redirect layer also
    // normalises these URLs back to `/` at startup.
    Path(
      r'^/(home|index|index\.html)$',
      (context, matches) => const HomePage(),
    ),

    // Path(
    //   r'^' + WorksPage.worksPageRoute,
    //   (context, matches) => const WorksPage(),
    // ),

    Path(
      AboutPage.aboutPageRoute,
      (context, matches) => const AboutPage(),
    ),

    Path(
      ExperiencePage.experiencePageRoute,
      (context, matches) => const ExperiencePage(),
    ),

    Path(
      ContactPage.contactPageRoute,
      (context, matches) => const ContactPage(),
    ),

    Path(
      PrivacyPolicyPage.privacyPolicyPageRoute,
      (context, matches) => const PrivacyPolicyPage(),
    ),

    // Per-project URLs: /projects/<slug>
    Path(
      r'^/projects/([\w-]+)$',
      (context, slug) => ProjectDetailPage(slug: slug),
    ),
    // Back-compat: the old /project-detail route still works and
    // uses the index argument as before.
    Path(
      ProjectDetailPage.projectDetailPageRoute,
      (context, matches) => const ProjectDetailPage(),
    ),

    // Path(
    //   r'^' + CertificationPage.certificationPageRoute,
    //   (context, matches) => const CertificationPage(),
    // ),
  ];

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // Pull the language out of the URL and strip the `/de` prefix
    // before matching against the route table. The remaining `name`
    // is the logical route, identical for both languages.
    final String rawName = settings.name ?? '/';
    final AppLang detected = LangController.detect(rawName);
    LangController.to.setLang(detected);
    final String logicalName = LangController.stripLangPrefix(rawName);

    for (Path path in paths) {
      final regExpPattern = RegExp(path.pattern);
      if (regExpPattern.hasMatch(logicalName)) {
        final firstMatch = regExpPattern.firstMatch(logicalName)!;
        final match = (firstMatch.groupCount == 1) ? firstMatch.group(1) : null;
        return NoAnimationMaterialPageRoute<void>(
          builder: (context) => path.builder(context, match),
          settings: settings,
        );
      }
    }
    // If no match is found, [WidgetsApp.onUnknownRoute] handles it.
    return null;
  }

  /// The route generator callback used when the app is navigated to a named
  /// route. Set it on the [MaterialApp.onGenerateRoute] or
  /// [WidgetsApp.onGenerateRoute] to make use of the [paths] for route
  /// matching.
//  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
//    for (final path in paths) {
//      final regExpPattern = RegExp(path.pattern);
//      if (regExpPattern.hasMatch(settings.name)) {
//        final match = regExpPattern.firstMatch(settings.name);
//        var groupNameToMatch = <String, String>{};
//        for (final groupName in match.groupNames) {
//          groupNameToMatch[groupName] = match.namedGroup(groupName);
//        }
//        print(groupNameToMatch);
//        print(path.pattern);
//        if (kIsWeb) {
//          return NoAnimationMaterialPageRoute<void>(
//            builder: (context) => path.builder(context, groupNameToMatch),
//            settings: settings,
//          );
//        }
//
//        return MaterialPageRoute<void>(
//          builder: (context) => path.builder(context, groupNameToMatch),
//          settings: settings,
//        );
//      }
//    }
//    // If no match was found, we let [WidgetsApp.onUnknownRoute] handle it.
//    return null;
//  }
}

class NoAnimationMaterialPageRoute<T> extends MaterialPageRoute<T> {
  NoAnimationMaterialPageRoute({
    required super.builder,
    super.settings,
  });

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
