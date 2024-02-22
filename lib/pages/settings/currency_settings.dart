import 'package:flutter/material.dart';
import 'package:offline_market_data/offline_market_data.dart';
import 'package:xmruw/pages/config/base.dart';

class CurrencySettingsPage extends StatefulWidget {
  const CurrencySettingsPage({super.key});
  static void push(BuildContext context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) {
        return const CurrencySettingsPage();
      },
    ));
  }

  @override
  State<CurrencySettingsPage> createState() => _CurrencySettingsPageState();
}

class _CurrencySettingsPageState extends State<CurrencySettingsPage> {
  var currency = config.fiatCurrency;
  var currentDate = DateTime.now();

  void _changeDate() async {
    final newDate = await showDatePicker(
      context: context,
      currentDate: currentDate,
      firstDate: DateTime(2014, 4, 18),
      lastDate: DateTime.now(),
    );
    if (newDate == null) return;
    setState(() {
      currentDate = newDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    final keys = usdPairs.keys.toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change currency"),
        actions: [
          IconButton(
            onPressed: _changeDate,
            icon: const Icon(Icons.calendar_month),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: keys.length,
        itemBuilder: (context, index) {
          final key = keys[index];
          final xmrPrice = CurrencyDataXMRxUSD().getPrice(currentDate)!;
          var price = usdPairs[key]?.getPrice(currentDate);
          if (price != null) {
            price *= xmrPrice;
          }
          return _getTile(price, key);
        },
      ),
    );
  }

  Widget _getTile(double? price, String key) {
    return ListTile(
      title: Row(children: [
        Text(key),
        const Spacer(),
        Text(
          (price != null)
              ? "${price.toStringAsFixed(4)} $key/XMR"
              : "[no data]",
        ),
      ]),
      leading: Radio<String>(
        value: key,
        groupValue: currency,
        onChanged: price == null && key != "USD"
            ? null
            : (String? value) {
                setState(() {
                  currency = value!;
                });
                config.fiatCurrency = value!;
                config.save();
              },
      ),
    );
  }
}
