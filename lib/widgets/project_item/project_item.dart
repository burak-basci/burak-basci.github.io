import 'package:flutter/material.dart';

import '../../pages/project_detail/widgets/animated_hero_cover.dart';
import '../../utils/adaptive_layout.dart';
import '../../utils/functions.dart';
import '../../utils/i18n_strings.dart';
import '../../utils/lang.dart';
import '../../utils/values/values.dart';
import '../../utils/values/spaces.dart';
import '../buttons/animated_bubble_button.dart';

/// One architectural / system illustration shown in the `/04 TECHNICAL`
/// section of a project detail page. Combines the asset path with a
/// short caption so each diagram has a 1-sentence explanation underneath.
class TechnicalImage {
  const TechnicalImage({
    required this.path,
    required this.caption,
    this.captionDe,
  });
  final String path;
  final String caption;

  /// Optional German caption. Falls back to [caption] when null.
  final String? captionDe;

  String captionFor(AppLang lang) =>
      lang == AppLang.de ? (captionDe ?? caption) : caption;
}

/// Translated overrides for a [ProjectItemData]. Every field is optional
/// — anything left null falls back to the English value on the parent
/// data class. Stored on the project as
/// `translations: const {'de': ProjectTranslation(title: '…', …)}`.
class ProjectTranslation {
  const ProjectTranslation({
    this.title,
    this.subtitle,
    this.category,
    this.platform,
    this.technologyUsed,
    this.portfolioDescription,
    this.decisions,
    this.learnings,
  });

  final String? title;
  final String? subtitle;
  final String? category;
  final String? platform;
  final String? technologyUsed;
  final String? portfolioDescription;
  final List<String>? decisions;
  final List<String>? learnings;
}

class ProjectItemData {
  ProjectItemData({
    required this.title,
    required this.image,
    required this.coverUrl,
    required this.subtitle,
    required this.portfolioDescription,
    required this.platform,
    required this.primaryColor,
    required this.category,
    this.designer,
    this.projectAssets = const [],
    this.imageSize,
    this.technologyUsed,
    this.isPublic = false,
    this.isOnPlayStore = false,
    this.isLive = false,
    this.gitHubUrl = "",
    this.hasBeenReleased = true,
    this.playStoreUrl = "",
    this.webUrl = "",
    this.navTitleColor = CustomColors.grey600,
    this.navSelectedTitleColor = CustomColors.black,
    this.appLogoColor = CustomColors.black,
    this.screenshots = const <String>[],
    this.decisions = const <String>[],
    this.learnings = const <String>[],
    this.mockupType = 'fullbleed',
    this.coverColorUrl,
    this.technicalImages = const <TechnicalImage>[],
    this.translations = const <String, ProjectTranslation>{},
  });

  final Color primaryColor;
  final Color navTitleColor;
  final Color navSelectedTitleColor;
  final Color appLogoColor;
  final String image;
  final String coverUrl;
  final String category;
  final List<String> projectAssets;
  final String portfolioDescription;
  final double? imageSize;
  final String title;
  final String subtitle;
  final String platform;
  final String? designer;
  final bool isPublic;
  final bool hasBeenReleased;
  final String gitHubUrl;
  final bool isOnPlayStore;
  final String playStoreUrl;
  final bool isLive;
  final String webUrl;
  final String? technologyUsed;
  final List<String> screenshots;
  final List<String> decisions;
  final List<String> learnings;
  final String mockupType;

  /// Optional cinematic / colour cover that crossfades in over [image]
  /// when the home tile is hovered. Null for projects that don't have a
  /// secondary AI-generated cover yet — those tiles just show [image].
  final String? coverColorUrl;

  /// Architectural / technical illustrations for the project, rendered
  /// on the detail page in their own section. Each entry has an asset
  /// path plus a short caption that contextualises the diagram.
  final List<TechnicalImage> technicalImages;

  /// Per-language overrides. Indexed by language code (`'de'`, `…`).
  /// Anything missing falls back to the canonical English fields above.
  final Map<String, ProjectTranslation> translations;

  // ---- Language-aware getters ----
  // Each one returns the German value when in German mode AND a German
  // translation exists; otherwise falls back to English. The same
  // [ProjectTranslation] object can override any subset of fields.

  ProjectTranslation? _t(AppLang lang) =>
      lang == AppLang.de ? translations['de'] : null;

  String titleFor(AppLang lang) => _t(lang)?.title ?? title;
  String subtitleFor(AppLang lang) => _t(lang)?.subtitle ?? subtitle;
  String categoryFor(AppLang lang) => _t(lang)?.category ?? category;
  String platformFor(AppLang lang) => _t(lang)?.platform ?? platform;
  String? technologyFor(AppLang lang) =>
      _t(lang)?.technologyUsed ?? technologyUsed;
  String descriptionFor(AppLang lang) =>
      _t(lang)?.portfolioDescription ?? portfolioDescription;
  List<String> decisionsFor(AppLang lang) =>
      _t(lang)?.decisions ?? decisions;
  List<String> learningsFor(AppLang lang) =>
      _t(lang)?.learnings ?? learnings;

  /// Returns the cover asset path for the active language. The cover
  /// image is now text-less (just background + illustration), so the
  /// same file serves every language — title / subtitle / category are
  /// rendered live by Flutter on top of it. See `tools/gen_covers.py`.
  // ignore: avoid_unused_constructor_parameters
  String coverFor(AppLang lang) => image;

  /// URL-safe slug derived from [title]. Used for per-project URLs
  /// like `/projects/volkswagen-ai-patent-search`.
  String get slug => Functions.slugify(title);
}

class ProjectData extends StatelessWidget {
  const ProjectData({
    required this.projectNumber,
    required this.title,
    required this.subtitle,
    required this.duration,
    this.curve = Curves.ease,
    this.projectNumberStyle,
    this.subtitleStyle,
    this.titleStyle,
    this.indicatorColor = CustomColors.grey550,
    this.indicatorHeight = Sizes.HEIGHT_1,
    this.indicatorWidth = Sizes.WIDTH_150,
    this.indicatorMargin,
    this.leadingMargin,
    Key? key,
  }) : super(key: key);

  final String projectNumber;
  final String title;
  final String subtitle;
  final Color indicatorColor;
  final TextStyle? projectNumberStyle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final double indicatorWidth;
  final double indicatorHeight;
  final EdgeInsetsGeometry? indicatorMargin;
  final EdgeInsetsGeometry? leadingMargin;
  final Duration duration;
  final Curve curve;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: leadingMargin,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AnimatedContainer(
                width: indicatorWidth,
                height: indicatorHeight,
                margin: indicatorMargin,
                color: indicatorColor,
                duration: duration,
                curve: curve,
              ),
              const SpaceW4(),
              Text(
                projectNumber,
                style: projectNumberStyle,
              ),
            ],
          ),
        ),
        const SpaceW24(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: titleStyle),
            const SpaceH16(),
            Text(subtitle, style: subtitleStyle),
          ],
        ),
      ],
    );
  }
}

// For rendering on bigger devices eg. tablets, desktops etc.
const double startWidthOfButton = 54;
const double heightOfButton = startWidthOfButton;
const double targetWidthOfButton = 200;
const double startWidthOfButtonMd = 44;
const double heightOfButtonMd = startWidthOfButtonMd;
const double targetWidthOfButtonMd = 160;

// For rendering on mobile devices
const double startWidthOfButtonSm = 40;
const double targetWidthSm = 160;
const double heightOfButtonSm = startWidthOfButtonSm;

class ProjectItemLarge extends StatefulWidget {
  const ProjectItemLarge({
    required this.projectNumber,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.containerColor,
    this.hoverImageUrl,
    this.project,
    this.lang,
    this.projectItemheight,
    this.subheight,
    this.coloredContainerHeight,
    this.coloredContainerWidth,
    this.buttonTitle = StringConst.VIEW,
    this.backgroundOnHoverColor = CustomColors.primaryColor,
    this.backgroundColor = CustomColors.accentColor2,
    this.projectNumberStyle,
    this.subtitleStyle,
    this.titleStyle,
    this.duration = const Duration(milliseconds: 300),
    this.padding,
    this.onTap,
    Key? key,
  }) : super(key: key);

  /// When supplied, both the main slide-in tile thumbnail AND the
  /// hover crossfade panel render the live Flutter [AnimatedHeroCover]
  /// instead of the static [imageUrl] / [hoverImageUrl] .webp. The
  /// cover is rendered in static (non-ticking) mode on the home grid
  /// so 30 fps animation across all tiles never spins the GPU; the
  /// main hero on the detail page is the only place the cover ticks.
  final ProjectItemData? project;

  /// Active language for the live cover. Required whenever [project]
  /// is non-null; ignored otherwise.
  final AppLang? lang;

  /// signifies the position of the project in the list
  final String projectNumber;

  /// text for the title of project (usually states the project name)
  final String title;

  /// text for the subtitle of project (usually describes the project or states the platform)
  final String subtitle;

  /// url or location for project image or cover
  final String imageUrl;

  /// optional cinematic / colour cover that crossfades in on hover. When
  /// null, hover keeps showing [imageUrl] unchanged.
  final String? hoverImageUrl;

  /// text that shows on the button (defaults to view project)
  final String buttonTitle;

  /// style for the project number (signifies the position of the project in the list)
  final TextStyle? projectNumberStyle;

  /// style for the title
  final TextStyle? titleStyle;

  /// style for the subtitle
  final TextStyle? subtitleStyle;

  /// color of the container under the project item image. mostly contains the primary color used in the project
  final Color containerColor;

  /// initial background color of the project item
  final Color backgroundColor;

  /// background color of the project item when it is hovered on
  final Color backgroundOnHoverColor;
  final Duration duration;

  /// full height of the project item
  final double? projectItemheight;

  /// height of the portion that contains the title, subtitle and button
  final double? subheight;

  /// height of the colored container under the project image cover
  final double? coloredContainerWidth;

  /// width of the colored container under the project image cover
  final double? coloredContainerHeight;

  /// padding for the title & subtitle section of the project item
  final EdgeInsetsGeometry? padding;

  /// callback for when view project is tapped
  final GestureTapCallback? onTap;

  @override
  ProjectItemLargeState createState() => ProjectItemLargeState();
}

class ProjectItemLargeState extends State<ProjectItemLarge> with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  late AnimationController _controller;
  // late Animation<double> _animation;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    super.initState();
  }

  void _mouseEnter(bool hovering) {
    if (hovering) {
      setState(() {
        _isHovering = hovering;
        _controller.forward();
      });
    } else {
      setState(() {
        _isHovering = hovering;
        _controller.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // width of the project item - it takes the entire width of the device
    double projectItemWidth = widthOfScreen(context);
    // height of the overall project item - it defaults to 40% of the height of the device
    double projectItemHeight = widget.projectItemheight ??
        assignHeight(
          context,
          0.4,
        );
    // it defaults to 75% of the height of the full [projectItemHeight]
    double subheight = widget.subheight ?? (3 / 4 * projectItemHeight);
    // defaults to 80% of the height of the [subheight]
    double containerHeight = widget.coloredContainerHeight ?? (subheight * 0.8);
    // defaults to 25% of the width of the screen on large screens
    double containerWidth = widget.coloredContainerWidth ??
        responsiveValue(
      context,
          assignWidth(context, 0.25),
          assignWidth(context, 0.25), // 25%
          medium: assignWidth(context, 0.33), // 33%
          small: assignWidth(context, 0.35), // 30%
        );
    // computes the position of the button, positions the button in the middle
    // of the container using subheight as it's height
    double positionOfButton = (subheight / 2) - startWidthOfButton;
    // computes the position of the colored container, positions the container in the middle
    // of the button
    double positionOfColoredContainer = positionOfButton + (heightOfButton / 2);
    // width of project cover - takes 1/3 of the width of the screen
    double imageWidth = responsiveValue(
      context,
      projectItemWidth / 2.5,
      projectItemWidth / 4,
      medium: projectItemWidth / 3,
      small: projectItemWidth / 2.8,
    );
    Animation<double> animation = Tween<double>(
      begin: responsiveValue(
      context,
        -imageWidth * 2.2,
        -imageWidth * 1.8,
        medium: -imageWidth * 2.2,
      ),
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn))
      ..addListener(() {
        setState(() {});
      });
    double buttonWidth = responsiveValue(
      context,
      startWidthOfButtonMd,
      startWidthOfButton,
      medium: startWidthOfButtonMd,
    );
    double buttonTargetWidth = responsiveValue(
      context,
      targetWidthOfButtonMd,
      targetWidthOfButton,
      medium: targetWidthOfButtonMd,
    );
    TextTheme textTheme = Theme.of(context).textTheme;
    // textStyle for button for viewing project
    TextStyle? buttonStyle = textTheme.bodyLarge?.copyWith(
      color: CustomColors.black,
      fontSize: responsiveValue(
      context,
        Sizes.TEXT_SIZE_14,
        Sizes.TEXT_SIZE_16,
        medium: Sizes.TEXT_SIZE_14,
      ),
      fontWeight: FontWeight.w500,
    );
    // textStyle for the current number or position of project in the list
    TextStyle? defaultNumberStyle = widget.projectNumberStyle ??
        textTheme.titleMedium?.copyWith(
          fontSize: _isHovering ? Sizes.TEXT_SIZE_20 : Sizes.TEXT_SIZE_16,
          color: CustomColors.grey550,
          fontWeight: _isHovering ? FontWeight.w400 : FontWeight.w300,
        );
    // textStyle for the title or name of the project
    TextStyle? defaultTitleStyle = widget.titleStyle ??
        textTheme.titleMedium?.copyWith(
          color: CustomColors.black,
          fontSize: responsiveValue(context, 24, 40, medium: 36, small: 30),
        );
    // textStyle for the subtitle (describing project platform) of the project
    TextStyle? defaultSubtitleStyle = widget.subtitleStyle ??
        textTheme.bodyLarge?.copyWith(
          color: CustomColors.grey700,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: 2.5,
          // fontWeight: FontWeight.w500,
        );
    return MouseRegion(
      onEnter: (e) => _mouseEnter(true),
      onExit: (e) => _mouseEnter(false),
      child: SizedBox(
        height: projectItemHeight,
        width: projectItemWidth,
        child: Stack(
          children: <Widget>[
            Container(
              width: projectItemWidth,
              height: subheight,
              padding: widget.padding ?? EdgeInsets.only(top: subheight / 4),
              color: _isHovering ? widget.backgroundOnHoverColor : widget.backgroundColor,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  // SelectionContainer.disabled removes this subtree from the
                  // surrounding SelectionArea so the cursor stays as
                  // "pointer" (click) instead of flipping to "text" the
                  // moment the user hovers over the title.
                  SelectionContainer.disabled(
                    child: AnimatedOpacity(
                      opacity: _isHovering ? 1.0 : 0.5,
                      duration: widget.duration,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: widget.onTap,
                          child: ProjectData(
                            duration: const Duration(milliseconds: 400),
                            projectNumber: widget.projectNumber,
                            indicatorWidth:
                                _isHovering ? assignWidth(context, 0.18) : assignWidth(context, 0.12),
                            leadingMargin: EdgeInsets.only(
                              top: (defaultTitleStyle!.fontSize! - defaultNumberStyle!.fontSize!) /
                                  2.5, // computes margin dynamically based on the title and defaultNumber Size
                              right: Sizes.MARGIN_8,
                            ),
                            indicatorMargin: EdgeInsets.only(
                              top: defaultNumberStyle.fontSize! / 2.5,
                              right: Sizes.MARGIN_8,
                            ),
                            title: widget.title,
                            subtitle: widget.subtitle,
                            subtitleStyle: defaultSubtitleStyle,
                            titleStyle: defaultTitleStyle,
                            projectNumberStyle: defaultNumberStyle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // The wipe-in panel that lives behind the slide-in thumbnail.
            // Animation is unchanged: width 0 → containerWidth, anchored
            // to the right edge, so the panel grows leftward on hover.
            // [containerColor] stays as the base fill — if the project
            // has a cinematic AI cover, that image is layered on top of
            // the colour at the panel's full final size and revealed by
            // the same clipping animation (right-anchored, so the image
            // emerges from the right edge as the panel widens).
            Positioned(
              top: positionOfColoredContainer,
              right: assignWidth(context, 0.1),
              child: AnimatedContainer(
                width: _isHovering ? containerWidth : 0,
                color: widget.containerColor,
                duration: const Duration(milliseconds: 450),
                height: containerHeight,
                curve: Curves.fastOutSlowIn,
                clipBehavior: Clip.hardEdge,
                // The behind / wipe-in panel always uses the static
                // AI-generated `cover-color.webp` (passed in via
                // [hoverImageUrl]) — that asset is the cinematic
                // "photographic" cover. The angled-above thumbnail
                // below renders the live painted [AnimatedHeroCover];
                // showing two visually distinct treatments at the same
                // time is intentional. If a project has no AI cover,
                // we fall back to nothing (panel stays solid colour).
                child: widget.hoverImageUrl == null
                    ? null
                    : OverflowBox(
                        maxWidth: containerWidth,
                        maxHeight: containerHeight,
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: containerWidth,
                          height: containerHeight,
                          child: Image.asset(
                            widget.hoverImageUrl!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
              ),
            ),
            Positioned(
              right: 0,
              child: Transform(
                origin: Offset(animation.value, 0),
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0095)
                  ..rotateY(0.075),
                // The main slide-in thumbnail also uses the live cover
                // when a [project] is supplied — non-ticking so the
                // entire cascade is just N static custom-painted
                // canvases instead of N animation controllers.
                child: SizedBox(
                  width: imageWidth,
                  height: containerHeight,
                  child: widget.project != null && widget.lang != null
                      ? AnimatedHeroCover(
                          project: widget.project!,
                          lang: widget.lang!,
                          animated: false,
                        )
                      : Image.asset(
                          widget.imageUrl,
                          width: imageWidth,
                          height: containerHeight,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
            Positioned(
              top: positionOfButton, //places button
              right: assignWidth(context, 0.1),
              child: AnimatedBubbleButton(
                duration: widget.duration,
                height: buttonWidth,
                targetWidth: buttonTargetWidth,
                title: Tr.of('btn.view_project').toUpperCase(),
                bubbleColor: CustomColors.grey100,
                titleStyle: buttonStyle,
                imageColor: CustomColors.black,
                onTap: widget.onTap,
              ),
            ),
            // NOTE on the right-edge dead zone:
            // The dead zone CANNOT live inside this widget. On Flutter web,
            // each tile is wrapped on the home page in a `Link` whose
            // implementation (`url_launcher_web`) overlays a transparent
            // HTML `<a>` element via `Positioned.fill` on top of the
            // Link's child. The browser's native click on that anchor
            // bubbles to the global click listener regardless of any
            // GestureDetector painted inside the tile, so an absorber here
            // sits BELOW the anchor in DOM stacking and never wins.
            //
            // The dead-zone absorber is therefore applied at the
            // home_page.dart level, as a sibling of the `Link` inside an
            // outer `Stack`, so it ends up in a higher DOM layer than the
            // platform-view anchor. See `lib/pages/home/home_page.dart`.
          ],
        ),
      ),
    );
  }
}

class ProjectItemSm extends StatefulWidget {
  const ProjectItemSm({
    required this.projectNumber,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.containerColor,
    this.buttonTitle = StringConst.VIEW,
    this.projectNumberStyle,
    this.subtitleStyle,
    this.titleStyle,
    this.coloredContainerHeight,
    this.coloredContainerWidth,
    this.imageWidth,
    this.imageHeight,
    this.duration = const Duration(milliseconds: 350),
    this.onTap,
    Key? key,
  }) : super(key: key);

  final String projectNumber;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String buttonTitle;
  final TextStyle? projectNumberStyle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final Color containerColor;
  final Duration duration;
  final double? imageWidth;
  final double? imageHeight;
  final double? coloredContainerWidth;
  final double? coloredContainerHeight;

  /// callback for when view project is tapped
  final GestureTapCallback? onTap;

  @override
  ProjectItemSmState createState() => ProjectItemSmState();
}

class ProjectItemSmState extends State<ProjectItemSm> with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    super.initState();
  }

  void _mouseEnter(bool hovering) {
    if (hovering) {
      setState(() {
        _isHovering = hovering;
        _controller.forward();
      });
    } else {
      setState(() {
        _isHovering = hovering;
        _controller.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // takes full width of screen
    final double projectItemWidth = widthOfScreen(context);
    // takes 40% of the height of the device
    final double heightOfProjectImageCover = widget.imageHeight ?? assignHeight(context, 0.3);
    // takes 90% of the width of the device
    final double widthOfProjectImageCover = widget.imageWidth ?? assignWidth(context, 0.9);
    // takes 30% of the height of the device
    final double heightOfColoredContainer = widget.coloredContainerHeight ?? assignHeight(context, 0.3);
    // takes 80% of the width of the device
    final double widthOfColoredContainer = widget.coloredContainerWidth ?? assignWidth(context, 0.8);
    // this positions the colored container at the middle of the cover image.
    final double positionOfColoredContainer = heightOfProjectImageCover / 2;
    final TextTheme textTheme = Theme.of(context).textTheme;
    // textStyle for button for viewing project
    final TextStyle? buttonStyle = textTheme.bodyLarge?.copyWith(
      color: CustomColors.black,
      fontSize: Sizes.TEXT_SIZE_14,
      fontWeight: FontWeight.w500,
    );
    // textStyle for the current number or position of project in the list
    final TextStyle? defaultNumberStyle = widget.projectNumberStyle ??
        textTheme.titleMedium?.copyWith(
          fontSize: _isHovering ? Sizes.TEXT_SIZE_18 : Sizes.TEXT_SIZE_16,
          color: CustomColors.grey550,
          fontWeight: _isHovering ? FontWeight.w400 : FontWeight.w300,
        );
    // textStyle for the title or name of the project
    final TextStyle? defaultTitleStyle = widget.titleStyle ??
        textTheme.titleMedium?.copyWith(
          color: CustomColors.black,
          fontSize: 26,
        );
    // textStyle for the subtitle (describing project platform) of the project
    final TextStyle? defaultSubtitleStyle = widget.subtitleStyle ??
        textTheme.bodyLarge?.copyWith(
          color: CustomColors.grey700,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 2.5,
        );

    return MouseRegion(
      onEnter: (e) => _mouseEnter(true),
      onExit: (e) => _mouseEnter(false),
      child: SizedBox(
        width: projectItemWidth,
        child: Column(
          children: <Widget>[
            SizedBox(
              height:
                  heightOfProjectImageCover + (heightOfColoredContainer - positionOfColoredContainer),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: positionOfColoredContainer,
                    child: Container(
                      width: widthOfColoredContainer,
                      color: widget.containerColor,
                      height: heightOfColoredContainer,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0095)
                        ..rotateY(0.085),
                      child: Image.asset(
                        widget.imageUrl,
                        width: widthOfProjectImageCover,
                        height: heightOfProjectImageCover,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SpaceH12(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ProjectData(
                  duration: widget.duration,
                  projectNumber: widget.projectNumber,
                  indicatorWidth: assignWidth(context, 0.12),
                  leadingMargin: EdgeInsets.only(
                    top: (defaultTitleStyle!.fontSize! - defaultNumberStyle!.fontSize!) / 2.5,
                    right: Sizes.MARGIN_8,
                  ),
                  indicatorMargin: EdgeInsets.only(
                    top: defaultNumberStyle.fontSize! / 2.5,
                    right: Sizes.MARGIN_8,
                  ),
                  title: widget.title,
                  subtitle: widget.subtitle,
                  subtitleStyle: defaultSubtitleStyle,
                  titleStyle: defaultTitleStyle,
                  projectNumberStyle: defaultNumberStyle,
                ),
              ],
            ),
            const SpaceH16(),
            Container(
              margin: const EdgeInsets.only(right: 30),
              child: Align(
                alignment: Alignment.centerRight,
                child: AnimatedBubbleButton(
                  duration: widget.duration,
                  height: startWidthOfButtonSm,
                  targetWidth: targetWidthSm,
                  title: Tr.of('btn.view_project').toUpperCase(),
                  bubbleColor: CustomColors.grey100,
                  titleStyle: buttonStyle,
                  imageColor: CustomColors.black,
                  onTap: widget.onTap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
