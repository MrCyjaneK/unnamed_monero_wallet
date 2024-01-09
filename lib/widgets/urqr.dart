import 'dart:async';

import 'package:anonero/widgets/qr_code.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class URQR extends StatefulWidget {
  URQR({super.key, required this.frames});

  List<String> frames;

  @override
  // ignore: library_private_types_in_public_api
  _URQRState createState() => _URQRState();
}

class _URQRState extends State<URQR> {
  Timer? t;
  int frame = 0;
  @override
  void initState() {
    super.initState();
    setState(() {
      t = Timer.periodic(const Duration(milliseconds: 1000 ~/ 3), (timer) {
        _nextFrame();
      });
    });
  }

  void _nextFrame() {
    setState(() {
      frame++;
    });
  }

  @override
  void dispose() {
    t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Qr(data: widget.frames[frame % widget.frames.length]),
        // Text("widget.frames[${frame % widget.frames.length}]"),
        // Text(widget.frames[frame % widget.frames.length]),
      ],
    );
  }
}
