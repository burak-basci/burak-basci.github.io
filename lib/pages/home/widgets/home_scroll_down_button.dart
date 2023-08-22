import 'package:flutter/material.dart';

import '../../../../utils/values/values.dart';
import '../../../utils/values/spaces.dart';

class HomeScrollDownButton extends StatelessWidget {
  const HomeScrollDownButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        RotatedBox(
          quarterTurns: 1,
          child: Text(
            StringConst.SCROLL_DOWN.toUpperCase(),
            style: Theme.of(context).textTheme.subtitle1?.copyWith(
                  fontSize: 12,
                  letterSpacing: 1.7,
                ),
          ),
        ),
        const SpaceH16(),
        Image.asset(
          ImagePath.ARROW_DOWN,
          height: 24,
        ),
      ],
    );
  }
}
