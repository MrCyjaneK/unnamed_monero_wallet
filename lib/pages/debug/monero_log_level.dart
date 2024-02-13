import 'package:xmruw/widgets/long_outlined_button.dart';
import 'package:flutter/material.dart';

int logLevel = 1;

class MoneroLogLevelDebug extends StatefulWidget {
  const MoneroLogLevelDebug({super.key});

  @override
  State<MoneroLogLevelDebug> createState() => _MoneroLogLevelDebugState();

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const MoneroLogLevelDebug();
      },
    ));
  }
}

class _MoneroLogLevelDebugState extends State<MoneroLogLevelDebug> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("monero logs"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            LongOutlinedButton(
              text: 'LogLevel_-1',
              onPressed: () => logLevel = -1,
            ),
            LongOutlinedButton(
              text: 'LogLevel_0',
              onPressed: () => logLevel = 0,
            ),
            LongOutlinedButton(
              text: 'LogLevel_1',
              onPressed: () => logLevel = 1,
            ),
            LongOutlinedButton(
              text: 'LogLevel_2',
              onPressed: () => logLevel = 2,
            ),
            LongOutlinedButton(
              text: 'LogLevel_3',
              onPressed: () => logLevel = 3,
            ),
            LongOutlinedButton(
              text: 'LogLevel_4',
              onPressed: () => logLevel = 4,
            ),
          ],
        ),
      ),
    );
  }
}
