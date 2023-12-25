String formatMonero(num? amt) {
  if (amt == null) {
    return "#.########";
  }
  if (amt == 0) {
    return "0";
  }
  return (((amt / 1e12 * 1e8)).floor() / 1e8).toStringAsFixed(8);
}
