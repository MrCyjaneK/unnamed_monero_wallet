String formatMonero(num? amt) {
  if (amt == null) {
    return "#.######## XMR";
  }
  return "${(((amt / 1e12 * 1e8)).floor() / 1e8).toStringAsFixed(8)} XMR";
}

String formatMoneroFiat(num? amt, DateTime? date) {
  date ??= DateTime.now();
  if (amt == null) {
    return "#.## ???";
  }
  return "#.## ???";

  // var price = CurrencyDataXMRxUSD().getPrice(date) ?? -1;

  // if (config.fiatCurrency != "USD") {
  //   final p = usdPairs[config.fiatCurrency]?.getPrice(date);
  //   if (p != null) {
  //     price *= p;
  //   }
  // }

  // return "${((((amt / 1e12)) * price)).toStringAsFixed(2)} ${config.fiatCurrency}";
}
