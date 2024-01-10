import 'package:anonero/const/resource.g.dart';
import 'package:anonero/pages/debug.dart';
import 'package:flutter/material.dart';

class DebugIconFirstRun extends StatelessWidget {
  const DebugIconFirstRun({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Image.asset(R.ASSETS_ANON_LOGO_PNG),
      onDoubleTap: () {
        DebugPage.push(context);
      },
    );
  }
}
