import 'package:flutter/material.dart';

class Alert {
  final String? title;
  final Widget? singleBody;
  final List<Widget> body;
  final List<Widget> overrideActions;
  final bool cancelable;
  final VoidCallback? callback;
  final String callbackText;
  final CrossAxisAlignment crossAxisAligment;

  Alert({
    this.title,
    this.singleBody,
    this.body = const [],
    this.overrideActions = const [],
    this.cancelable = false,
    this.callback,
    this.callbackText = "Confirm",
    this.crossAxisAligment = CrossAxisAlignment.center,
  });

  Widget _getContent() {
    if (singleBody != null) return singleBody!;
    if (body.isEmpty) return SelectableText(title ?? "");
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAligment,
      children: body,
    );
  }

  Widget _builder(BuildContext context) {
    return AlertDialog.adaptive(
      content: _getContent(),
      backgroundColor: Colors.black,
      surfaceTintColor: Colors.transparent,
      actions: overrideActions.isEmpty
          ? [
              if (cancelable)
                TextButton(
                  onPressed: () => _cancel(context),
                  child: const Text("Cancel"),
                ),
              if (callback != null)
                TextButton(
                  onPressed: () => callback?.call(),
                  child: Text(callbackText),
                ),
            ]
          : overrideActions,
    );
  }

  void _cancel(BuildContext context) {
    Navigator.of(context).pop();
  }

  Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      builder: _builder,
    );
  }
}

class LongAlertButton extends StatelessWidget {
  final VoidCallback? callback;
  final String text;

  const LongAlertButton({
    super.key,
    this.callback,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextButton(
        onPressed: callback,
        child: Expanded(child: Center(child: Text(text))),
      ),
    );
  }
}

class LongAlertButtonAlt extends StatelessWidget {
  final VoidCallback? callback;
  final String text;

  const LongAlertButtonAlt({
    super.key,
    this.callback,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: callback,
      child: Center(
        child: Text(text),
      ),
    );
  }
}
