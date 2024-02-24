import 'package:xmruw/helpers/resource.g.dart';
import 'package:flutter/material.dart';

class SetupLogo extends StatelessWidget {
  final String? title;
  final double width;
  final double fontSize;
  const SetupLogo(
      {super.key, required this.title, this.width = 180, this.fontSize = 22});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            R.ASSETS_LOGO_PNG,
            width: width,
          ),
          if (title != null)
            Text(
              title ?? "",
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(fontSize: fontSize, color: Colors.white),
            )
        ],
      ),
    );
  }
}
