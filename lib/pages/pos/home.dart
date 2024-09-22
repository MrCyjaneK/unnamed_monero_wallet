import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:xmruw/legacy.dart';
import 'package:xmruw/pages/pin_screen.dart';
import 'package:xmruw/pages/wallet/transaction_list.dart';
import 'package:xmruw/tools/monero/account_index.dart';
import 'package:xmruw/tools/show_alert.dart';
import 'package:xmruw/tools/wallet_ptr.dart';
import 'package:xmruw/widgets/numerical_keyboard.dart';
import 'package:monero/monero.dart' as monero;
import 'package:xmruw/widgets/transaction_list/transaction_item.dart';

class PoSHomePage extends StatefulWidget {
  const PoSHomePage({super.key});

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const PoSHomePage();
      },
    ));
  }

  @override
  State<PoSHomePage> createState() => _PoSHomePageState();
}

class _PoSHomePageState extends State<PoSHomePage> {
  PinInput pin = PinInput();
  late final tCtrl = TextEditingController(text: pin.value);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PoS"),
      ),
      body: Column(
        children: [
          // _printInputCircles(),
          TextField(
            obscureText: false,
            style: const TextStyle(fontSize: 48),
            controller: tCtrl,
            decoration: null,
            textAlign: TextAlign.center,
            onChanged: (value) {
              setState(() {
                pin.value = value;
              });
              _rebuild();
            },
          ),
          NumericalKeyboard(
              pin: pin,
              rebuild: _rebuild,
              showConfirm: _showConfirm,
              nextPage: _showConfirm() ? _confirm : null,
              showComma: true),
        ],
      ),
      bottomNavigationBar: _lastTransaction(),
    );
  }

  Widget _lastTransaction() {
    monero.TransactionHistory_refresh(txHistoryPtr);
    final transactionCount = monero.TransactionHistory_count(txHistoryPtr);
    if (transactionCount == 0) return const Text("No transactions...");
    final txInfo = monero.TransactionHistory_transaction(txHistoryPtr,
        index: transactionCount - 1);
    final tx = Transaction(txInfo: txInfo);
    return SafeArea(
      child: SizedBox(height: 100, child: TransactionItem(transaction: tx)),
    );
  }

  void _rebuild() {
    setState(() {
      tCtrl.text = pin.value;
    });
  }

  void _confirm() async {
    final index = monero.Wallet_numSubaddresses(walletPtr!,
        accountIndex: globalAccountIndex);
    final address = monero.Wallet_address(walletPtr!,
        accountIndex: globalAccountIndex, addressIndex: index);
    await Alert(
        singleBody: SizedBox(
      width: double.maxFinite,
      height: 350,
      child: QrImageView(
        gapless: true,
        dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square, color: Colors.white),
        eyeStyle:
            const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.white),
        data: "monero:$address?tx_amount=${pin.value}",
        version: QrVersions.auto,
        //size: 280.0,
      ),
    )).show(context);
  }

  bool _showConfirm() {
    return num.tryParse(pin.value) != null;
  }
}
