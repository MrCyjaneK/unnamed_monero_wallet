import 'package:flutter/material.dart';
import 'package:offline_market_data/offline_market_data.dart';
import 'package:xmruw/pages/config/pos.dart';
import 'package:xmruw/pages/pos/item_page.dart';
import 'package:xmruw/tools/format_monero.dart';

class ItemsCataloguePage extends StatelessWidget {
  const ItemsCataloguePage({super.key});
  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const ItemsCataloguePage();
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Items"),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final priceXmr = getPriceIn("XMR", item.itemPrice, item.baseCurrency);
          return Card(
            child: ListTile(
              onTap: () {
                ItemPage.push(context, item);
              },
              title: Text(item.itemName),
              subtitle: Text(
                "${item.itemPrice} ${item.baseCurrency} ; ${formatMonero((priceXmr ?? 0) * 1e12)} ; ${formatMoneroFiat((priceXmr ?? 0) * 1e12, null)}",
              ),
            ),
          );
        },
      ),
      floatingActionButton: const FloatingActionButton.extended(
        onPressed: null,
        label: Text("Add item"),
        icon: Icon(Icons.add),
      ),
    );
  }
}

double? getPriceIn(String target, double amount, String source) {
  target = target.toUpperCase();
  source = source.toUpperCase();
  if (target == source) return amount;
  if (source == "USD" && target == "XMR") {
    return amount / CurrencyDataXMRxUSD().getPrice(null)!;
  }
  if (source == "XMR" && target == "USD") {
    return amount * CurrencyDataXMRxUSD().getPrice(null)!;
  }
  for (var k in usdPairs.keys) {
    if (k == source) {
      final usdAmt = amount / usdPairs[k]!.getPrice(null)!;
      return usdAmt / CurrencyDataXMRxUSD().getPrice(null)!;
    }
  }
  return null;
}
