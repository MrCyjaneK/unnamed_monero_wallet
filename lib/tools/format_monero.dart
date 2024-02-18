String formatMonero(num? amt) {
  if (amt == null) {
    return "#.########";
  }
  return (((amt / 1e12 * 1e8)).floor() / 1e8).toStringAsFixed(8);
}
