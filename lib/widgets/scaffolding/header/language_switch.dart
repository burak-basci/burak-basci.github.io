import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/i18n_strings.dart';
import '../../../utils/lang.dart';
import '../../../utils/page_transition.dart';
import '../../../utils/values/values.dart';

/// `EN / DE` pill in the top navigation. A single dark "thumb" slides
/// between the two labels — clicking the inactive one drives the
/// global [PageTransition.switchLanguage] (cover → language change →
/// uncover).
///
/// The thumb's position is driven by [_visualLang], a piece of *local*
/// state that flips the instant the user clicks. That decoupling is
/// deliberate:
///   * Clicking immediately starts the 320 ms slide animation — the
///     user sees the choice confirm before the cover panel hides the
///     nav.
///   * [LangController.setLang] (the actual content language swap)
///     fires later, while the cover panel is fully over the screen.
///     The page rebuilds invisibly and uncovers in the new language.
///   * On a URL-driven language change (refresh on `/de/...`, deep
///     link), the widget reconciles [_visualLang] with
///     [LangController.lang] on rebuild, so the thumb sits on the
///     correct side from the very first frame.
class LanguageSwitch extends StatefulWidget {
  const LanguageSwitch({super.key});

  // Layout constants — kept tight so the pill nests neatly into the
  // existing top-nav baseline.
  static const double _height = 30;
  static const double _radius = 18;
  static const double _itemWidth = 42;
  static const double _outerPad = 3;

  @override
  State<LanguageSwitch> createState() => _LanguageSwitchState();
}

class _LanguageSwitchState extends State<LanguageSwitch> {
  late AppLang _visualLang;

  @override
  void initState() {
    super.initState();
    _visualLang = LangController.to.lang;
  }

  void _onTap(AppLang target) {
    if (_visualLang == target) return;
    // 1) Flip the visual thumb immediately — the AnimatedAlign will
    //    interpolate from the current side to the new one over 320 ms.
    //    This happens *before* the cover panel hides the nav, so the
    //    user sees the slide confirm their click.
    setState(() => _visualLang = target);
    // 2) Kick off the real switch (cover → setLang → push → uncover).
    //    The content language swap happens with the cover over the
    //    screen, so no partial-translation flash is visible.
    PageTransition.switchLanguage(context, target);
  }

  @override
  Widget build(BuildContext context) {
    // [_visualLang] is the single source of truth for the thumb side.
    // It's seeded from [LangController.lang] in [initState] (which
    // handles the URL-driven case — a refresh on `/de/...` builds a
    // new widget with the correct initial side) and only mutated by
    // user clicks, so the thumb glide is never overwritten by a build
    // that runs between click and the deferred [setLang] call.
    final bool isDe = _visualLang == AppLang.de;

    return SelectionContainer.disabled(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Tooltip(
          message: isDe
              ? Tr.of('lang.switch_to_en')
              : Tr.of('lang.switch_to_de'),
          waitDuration: const Duration(milliseconds: 400),
          child: Container(
            height: LanguageSwitch._height,
            padding: const EdgeInsets.all(LanguageSwitch._outerPad),
            decoration: BoxDecoration(
              color: CustomColors.grey100,
              borderRadius: BorderRadius.circular(LanguageSwitch._radius),
            ),
            // Tight-size the Stack so AnimatedPositioned has a known
            // box to interpolate against. The previous AnimatedAlign
            // layout shrink-wrapped to its child (42 px wide) and so
            // had zero slide room — that's why the thumb never moved.
            child: SizedBox(
              width: LanguageSwitch._itemWidth * 2,
              height:
                  LanguageSwitch._height - LanguageSwitch._outerPad * 2,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  // The sliding dark thumb. AnimatedPositioned tweens
                  // `left` between 0 and _itemWidth so the slide is a
                  // pure pixel motion — no alignment math, no Stack
                  // sizing fragility.
                  AnimatedPositioned(
                    left: isDe ? LanguageSwitch._itemWidth : 0,
                    top: 0,
                    width: LanguageSwitch._itemWidth,
                    height: LanguageSwitch._height -
                        LanguageSwitch._outerPad * 2,
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    child: Container(
                      decoration: BoxDecoration(
                        color: CustomColors.black,
                        borderRadius: BorderRadius.circular(
                            LanguageSwitch._radius -
                                LanguageSwitch._outerPad),
                      ),
                    ),
                  ),
                  // The two labels sit on top of the thumb. The active
                  // label fades to white over the dark thumb, the
                  // inactive one stays grey on the pill background.
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _LangLabel(
                        label: 'EN',
                        active: !isDe,
                        onTap: isDe ? () => _onTap(AppLang.en) : null,
                      ),
                      _LangLabel(
                        label: 'DE',
                        active: isDe,
                        onTap: isDe ? null : () => _onTap(AppLang.de),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LangLabel extends StatelessWidget {
  const _LangLabel({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: active ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: LanguageSwitch._itemWidth,
          height: LanguageSwitch._height - LanguageSwitch._outerPad * 2,
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 240),
              style: TextStyle(
                color: active ? Colors.white : CustomColors.grey700,
                fontFamily: StringConst.INTER,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.6,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}
