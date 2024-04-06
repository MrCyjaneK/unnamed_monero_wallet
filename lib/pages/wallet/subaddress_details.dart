import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monero/monero.dart' as monero;
import 'package:xmruw/pages/wallet/subaddress_page.dart';
import 'package:xmruw/tools/monero/account_index.dart';
import 'package:xmruw/tools/monero/subaddress_label.dart';
import 'package:xmruw/tools/show_alert.dart';
import 'package:xmruw/tools/wallet_ptr.dart';
import 'package:xmruw/widgets/labeled_text_input.dart';
import 'package:xmruw/widgets/qr_code.dart';

class SubaddressDetailsPage extends StatefulWidget {
  const SubaddressDetailsPage({super.key, required this.subaddressId});

  final int subaddressId;

  @override
  State<SubaddressDetailsPage> createState() => _SubaddressDetailsPageState();

  static Future<dynamic> push(BuildContext context,
      {required int subaddressId}) {
    return Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return SubaddressDetailsPage(
          subaddressId: subaddressId,
        );
      },
    ));
  }
}

class _SubaddressDetailsPageState extends State<SubaddressDetailsPage> {
  void _copyAddress() {
    Clipboard.setData(ClipboardData(
        text: monero.Wallet_address(walletPtr!,
            addressIndex: widget.subaddressId)));
  }

  void _showQr(BuildContext c) {
    Alert(
        cancelable: false,
        singleBody: SizedBox(
          width: 512,
          child: Qr(
            data: monero.Wallet_address(walletPtr!,
                addressIndex: widget.subaddressId),
          ),
        )).show(c);
  }

  late final renameCtrl =
      TextEditingController(text: subaddressLabel(widget.subaddressId));

  void _rename(BuildContext c) {
    Alert(
      singleBody: SizedBox(
        width: double.maxFinite,
        child: LabeledTextInput(
          label: "Rename subaddress",
          ctrl: renameCtrl,
        ),
      ),
      cancelable: true,
      callback: () {
        monero.Wallet_setSubaddressLabel(
          walletPtr!,
          accountIndex: globalAccountIndex,
          addressIndex: widget.subaddressId,
          label: renameCtrl.text,
        );
        Navigator.of(c).pop();
        setState(() {
          label = subaddressLabel(widget.subaddressId);
        });
      },
    ).show(c);
  }

  late String label = subaddressLabel(widget.subaddressId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: _copyAddress, icon: const Icon(Icons.copy)),
          IconButton(
            onPressed: () => _rename(context),
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () => _showQr(context),
            icon: const Icon(Icons.qr_code_2_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              SubaddressItem(
                shouldSquash: false,
                subaddressId: widget.subaddressId,
                label: label,
                received: 0,
                squashedAddress: monero.Wallet_address(walletPtr!,
                    addressIndex: widget.subaddressId),
                rebuildParent: () {
                  setState(() {});
                },
              ),
              const SizedBox(
                height: 16,
              ),
              // TransactionItem(transaction: Transaction(confirmations: 532)),
            ],
          ),
        ),
      ),
    );
  }
}
