import 'package:xmruw/const/resource.g.dart';
import 'package:xmruw/pages/debug.dart';
import 'package:flutter/material.dart';

class DebugIconFirstRun extends StatelessWidget {
  const DebugIconFirstRun({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Image.asset(R.ASSETS_LOGO_PNG),
      onDoubleTap: () {
        DebugPage.push(context);
      },
    );
  }
}
