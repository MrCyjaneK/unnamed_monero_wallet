class Item {
  Item({
    required this.itemKey,
    required this.itemName,
    required this.itemDescription,
    required this.itemPrice,
    required this.baseCurrency,
  });
  String itemKey;
  String itemName;
  String itemDescription;
  double itemPrice;
  String baseCurrency;
}

final items = [
  Item(
    itemKey: "myitem1",
    itemName: "Something to sell",
    itemDescription: "my description",
    itemPrice: 1.41,
    baseCurrency: "USD",
  ),
  Item(
    itemKey: "myitem1",
    itemName: "Something to sell",
    itemDescription: "my description",
    itemPrice: 5.50,
    baseCurrency: "PLN",
  ),
  Item(
    itemKey: "myitem1",
    itemName: "Something to sell",
    itemDescription: "my description",
    itemPrice: 0.008810417437578193,
    baseCurrency: "XMR",
  ),
];
