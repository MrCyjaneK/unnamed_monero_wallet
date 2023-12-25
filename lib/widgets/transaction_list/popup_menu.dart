import 'package:anonero/tools/show_alert.dart';
import 'package:flutter/material.dart';

class TxListPopupMenu extends StatelessWidget {
  TxListPopupMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TxListPopupAction>(
      onSelected: (action) => _onSelected(context, action),
      itemBuilder: (context) => _getWidgets(),
    );
  }

  void _onSelected(BuildContext c, TxListPopupAction action) {
    Alert(title: " $action").show(c);
  }

  final enabledActions = [
    TxListPopupAction.resync,
    TxListPopupAction.exportKeyImages,
    TxListPopupAction.importOutputs,
    TxListPopupAction.signTx,
    TxListPopupAction.coinControl
  ];

  List<PopupMenuItem<TxListPopupAction>> _getWidgets() {
    List<PopupMenuItem<TxListPopupAction>> list = [];
    for (var elm in enabledActions) {
      list.add(_getWidget(elm));
    }
    return list;
  }

  PopupMenuItem<TxListPopupAction> _getWidget(TxListPopupAction elm) {
    return switch (elm) {
      TxListPopupAction.resync => const PopupMenuItem<TxListPopupAction>(
          value: TxListPopupAction.resync,
          child: Text('Resync Blockchain'),
        ),
      TxListPopupAction.exportKeyImages =>
        const PopupMenuItem<TxListPopupAction>(
          value: TxListPopupAction.exportKeyImages,
          child: Text('Export Key Images'),
        ),
      TxListPopupAction.exportOutputs => const PopupMenuItem<TxListPopupAction>(
          value: TxListPopupAction.exportOutputs,
          child: Text('Export Outputs'),
        ),
      TxListPopupAction.broadcastTx => const PopupMenuItem<TxListPopupAction>(
          value: TxListPopupAction.broadcastTx,
          child: Text('Broadcast Tx'),
        ),
      TxListPopupAction.signTx => const PopupMenuItem<TxListPopupAction>(
          value: TxListPopupAction.signTx,
          child: Text('Sign Tx'),
        ),
      TxListPopupAction.importOutputs => const PopupMenuItem<TxListPopupAction>(
          value: TxListPopupAction.importOutputs,
          child: Text('Import Outputs'),
        ),
      TxListPopupAction.coinControl => const PopupMenuItem<TxListPopupAction>(
          value: TxListPopupAction.coinControl,
          child: Text('Coin Control'),
        ),
    };
  }
}

enum TxListPopupAction {
  resync,
  exportKeyImages,
  exportOutputs,
  broadcastTx,
  signTx,
  importOutputs,
  coinControl,
}
