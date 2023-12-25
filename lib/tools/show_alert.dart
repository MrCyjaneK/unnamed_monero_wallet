import 'package:flutter/material.dart';

class Alert {
  final String? title;
  final List<Widget> body;
  final List<Widget> overrideActions;
  final bool cancelable;
  final VoidCallback? callback;
  final String callbackText;
  final CrossAxisAlignment crossAxisAligment;
  Alert({
    this.title,
    this.body = const [],
    this.overrideActions = const [],
    this.cancelable = false,
    this.callback,
    this.callbackText = "Confirm",
    this.crossAxisAligment = CrossAxisAlignment.center,
  });

  Widget _getContent() {
    if (body.isEmpty) return SelectableText(title ?? "");
    if (body.length == 1) return body[0];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAligment,
      children: body,
    );
  }

  Widget _builder(BuildContext context) {
    return AlertDialog.adaptive(
      content: _getContent(),
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

  void show(BuildContext context) {
    showDialog(
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
