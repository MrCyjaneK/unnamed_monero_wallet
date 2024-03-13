import 'package:flutter/material.dart';
import 'package:offline_market_data/offline_market_data.dart';
import 'package:xmruw/pages/config/pos.dart';
import 'package:xmruw/widgets/labeled_text_input.dart';
import 'package:xmruw/widgets/long_outlined_button.dart';

class ItemPage extends StatefulWidget {
  const ItemPage({super.key, required this.item});
  final Item item;
  static void push(BuildContext context, Item item) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return ItemPage(item: item);
      },
    ));
  }

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  late final nameCtrl = TextEditingController(text: widget.item.itemName);
  late final keyCtrl = TextEditingController(text: widget.item.itemKey);
  late final descriptionCtrl =
      TextEditingController(text: widget.item.itemDescription);
  late final priceCtrl =
      TextEditingController(text: widget.item.itemPrice.toString());
  late final currenctyCtrl =
      TextEditingController(text: widget.item.baseCurrency);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit item"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            LabeledTextInput(label: "Name", ctrl: nameCtrl),
            LabeledTextInput(label: "Key", ctrl: keyCtrl),
            LabeledTextInput(
              label: "Description",
              ctrl: descriptionCtrl,
              minLines: 4,
              maxLines: 4,
            ),
            LabeledTextInput(label: "Price", ctrl: priceCtrl, onEdit: _rebuild),
            LabeledTextInput(
                label: "Currency", ctrl: currenctyCtrl, onEdit: _rebuild),
          ],
        ),
      ),
      bottomNavigationBar: LongOutlinedButton(
        text: "Save",
        onPressed: inputValid() ? _save : null,
      ),
    );
  }

  void _rebuild() {
    setState(() {});
  }

  void _save() {
    Navigator.of(context).pop();
  }

  bool inputValid() {
    final cur = currenctyCtrl.text.toUpperCase();
    return (num.tryParse(priceCtrl.text) != null) &&
        (usdPairs[cur] != null || cur == "USD" || cur == "XMR");
  }
}
