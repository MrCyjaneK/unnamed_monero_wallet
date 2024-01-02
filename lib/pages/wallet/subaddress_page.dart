import 'package:anonero/pages/wallet/subaddress_details.dart';
import 'package:anonero/tools/format_monero.dart';
import 'package:anonero/tools/monero/subaddress_label.dart';
import 'package:anonero/tools/show_alert.dart';
import 'package:anonero/tools/wallet_ptr.dart';
import 'package:flutter/material.dart';
import 'package:monero/monero.dart';

class SubAddressPage extends StatefulWidget {
  const SubAddressPage({super.key});

  @override
  State<SubAddressPage> createState() => _SubAddressPageState();

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const SubAddressPage();
      },
    ));
  }
}

class _SubAddressPageState extends State<SubAddressPage> {
  int addrCount = MONERO_Wallet_numSubaddresses(walletPtr!, accountIndex: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Subaddresses"),
        actions: [
          IconButton(onPressed: _addSubaddress, icon: const Icon(Icons.add))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: addressList(),
        ),
      ),
    );
  }

  List<Widget> addressList() {
    List<Widget> list = [];
    for (var i = addrCount; i >= 0; i--) {
      list.add(
        SubaddressItem(
            subaddressId: i,
            received: 0,
            label: subaddressLabel(i),
            squashedAddress: MONERO_Wallet_address(
              walletPtr!,
              accountIndex: 0,
              addressIndex: i,
            ),
            rebuildParent: () {
              setState(() {});
            }),
      );
    }
    return list;
  }

  void _addSubaddress() {
    MONERO_Wallet_addSubaddress(walletPtr!, accountIndex: 0);
    setState(() {
      addrCount = MONERO_Wallet_numSubaddresses(walletPtr!, accountIndex: 0);
    });
    final status = MONERO_Wallet_status(walletPtr!);
    if (status != 0) {
      final errorString = MONERO_Wallet_errorString(walletPtr!);
      Alert(title: errorString).show(context);
    }
  }
}

class SubaddressItem extends StatefulWidget {
  final int subaddressId;
  final int received;
  final String squashedAddress;
  final bool shouldSquash;
  final String? label;
  final VoidCallback rebuildParent;
  const SubaddressItem({
    super.key,
    required this.subaddressId,
    required this.received,
    required this.squashedAddress,
    this.shouldSquash = true,
    this.label,
    required this.rebuildParent,
  });

  @override
  State<SubaddressItem> createState() => _SubaddressItemState();
}

class _SubaddressItemState extends State<SubaddressItem> {
  late String label = subaddressLabel(widget.subaddressId);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: !widget.shouldSquash
          ? null
          : () => SubaddressDetailsPage.push(context,
                      subaddressId: widget.subaddressId)
                  .then((value) {
                setState(() {
                  label = subaddressLabel(widget.subaddressId);
                });
                widget.rebuildParent();
              }),
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      title: Row(
        children: [
          Expanded(
            child: Text(
              widget.label ?? label,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          Text(
            formatMonero(widget.received),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
      subtitle: Text(
        squash(widget.squashedAddress),
      ),
    );
  }

  String squash(String s) {
    if (s.length < 10 || !widget.shouldSquash) return s;
    return "${s.substring(0, 5)}...${s.substring(s.length - 5)}";
  }
}
