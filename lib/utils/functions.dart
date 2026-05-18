import 'package:url_launcher/url_launcher.dart';

class Functions {
  static void launchUrl(String url) async {
    await launch(url);
  }

  /// Make a URL-safe slug out of a free-form title.
  ///
  ///   "Volkswagen AI Patent Search"  -> "volkswagen-ai-patent-search"
  ///   "Hetzner k3s Infrastructure"   -> "hetzner-k3s-infrastructure"
  ///   "PostPilot — Social-Media Automation" -> "postpilot-social-media-automation"
  ///   "Binance → German Tax PDF"     -> "binance-german-tax-pdf"
  static String slugify(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  // static Size textSize({
  //   required String text,
  //   required TextStyle? style,
  //   double maxWidth = double.infinity,
  // }) {
  //   final TextPainter textPainter = TextPainter(
  //       text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr)
  //     ..layout(minWidth: 0, maxWidth: maxWidth);
  //   return textPainter.size;
  // }

  // static void navigateToProject({
  //   required BuildContext context,
  //   required List<ProjectItemData> dataSource,
  //   required ProjectItemData currentProject,
  //   required int currentProjectIndex,
  // }) {
  //   ProjectItemData? nextProject;
  //   bool hasNextProject;
  //   if ((currentProjectIndex + 1) > (dataSource.length - 1)) {
  //     hasNextProject = false;
  //   } else {
  //     hasNextProject = true;
  //     nextProject = dataSource[currentProjectIndex + 1];
  //   }
  //   Navigator.of(context).pushNamed(
  //     ProjectDetailPage.projectDetailPageRoute,
  //     arguments: ProjectDetailArguments(
  //       dataSource: dataSource,
  //       currentIndex: currentProjectIndex,
  //       data: currentProject,
  //       nextProject: nextProject,
  //       hasNextProject: hasNextProject,
  //     ),
  //   );
  // }
}
