import 'package:flutter/material.dart';

const ColorScheme colorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xffFF6600),
  onPrimary: Color(0xff000000),
  primaryContainer: Color(0xff297ea0),
  onPrimaryContainer: Color(0xffd9edf5),
  secondary: Color(0xffa1e9df),
  onSecondary: Color(0xff030303),
  secondaryContainer: Color(0xff005049),
  onSecondaryContainer: Color(0xffd0e3e1),
  tertiary: Color(0xffa0e5e5),
  onTertiary: Color(0xff181e1e),
  tertiaryContainer: Color(0xff004f50),
  onTertiaryContainer: Color(0xffd0e2e3),
  error: Color(0xffcf6679),
  onError: Color(0xff1e1214),
  errorContainer: Color(0xffb1384e),
  onErrorContainer: Color(0xfff9dde2),
  outline: Color(0xff959999),
  background: Color(0xff000000),
  onBackground: Color(0xffe3e4e4),
  surface: Color(0xff131516),
  onSurface: Color(0xfff1f1f1),
  surfaceVariant: Color(0xff15191b),
  onSurfaceVariant: Color(0xffe3e3e4),
  inverseSurface: Color(0xfffafcfd),
  onInverseSurface: Color(0xff0e0e0e),
  inversePrimary: Color(0xff355967),
  shadow: Color(0xff000000),
);

class Transaction {
  String? displayLabel;
  String? subaddressLabel;
  String? address;
  String? notes;
  int? fee;
  int confirmations;
  bool isPending = false;
  int? blockheight;
  int? accountIndex;
  String? paymentId;
  num? amount = 0;
  bool isSpend = false;
  int get timeStamp =>
      DateTime.now()
          .subtract(
            Duration(seconds: confirmations * 120),
          )
          .millisecondsSinceEpoch ~/
      1000;
  int? addressIndex;
  bool get isConfirmed => confirmations > maxConfirms;
  String? hash;
  SubAddress? subAddress;
  List<Transfer> transfers = [];

  Transaction({
    this.displayLabel = "displayLabel",
    this.subaddressLabel = "subaddressLabel",
    this.address =
        "addressaddressaddressaddressaddressaddressaddressaddressaddress",
    this.notes = "notes",
    this.fee = 100000000,
    required this.confirmations,
    this.isPending = false,
    this.blockheight = 30003410,
    this.accountIndex = 0,
    this.paymentId = "paymentId",
    this.addressIndex = 0,
    this.hash =
        "hashhashhashhashhashhashhashhashhashhashhashhashhashhashhashhash",
  });
}

class SubAddress {
  int? accountIndex;
  String? address;
  String? squashedAddress;
  int? addressIndex;
  num? totalAmount;
  String? label;
  String? displayLabel;

  SubAddress(
      {this.accountIndex,
      this.address,
      this.squashedAddress,
      this.addressIndex,
      this.label});
}

class Transfer {
  num? amount;
  String? address;
}

const maxConfirms = 10;
