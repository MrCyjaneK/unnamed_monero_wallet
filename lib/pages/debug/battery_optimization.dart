
import 'package:anonero/tools/backup_class.dart';
import 'package:anonero/tools/show_alert.dart';
import 'package:anonero/widgets/long_outlined_button.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/material.dart';

class BatteryOptimizationDebug extends StatefulWidget {
  const BatteryOptimizationDebug({super.key});

  @override
  State<BatteryOptimizationDebug> createState() =>
      BatteryOptimizationDebugState();

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const BatteryOptimizationDebug();
      },
    ));
  }
}

class BatteryOptimizationDebugState extends State<BatteryOptimizationDebug> {
  var bd = BackupDetails();

  void _decrypt() async {
    final newBd = await BackupDetails.decrypt(context);
    setState(() {
      bd = newBd;
    });
  }

  void _print(String str) {
    Alert(title: str, cancelable: true).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Battery Optimization"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            LongOutlinedButton(
                text: "Is Auto Start Enabled",
                onPressed: () async {
                  bool? isAutoStartEnabled =
                      await DisableBatteryOptimization.isAutoStartEnabled;
                  _print("Auto start is $isAutoStartEnabled");
                }),
            LongOutlinedButton(
                text: "Is Battery optimization disabled",
                onPressed: () async {
                  bool? isBatteryOptimizationDisabled =
                      await DisableBatteryOptimization
                          .isBatteryOptimizationDisabled;
                  _print(
                      "Battery optimization is $isBatteryOptimizationDisabled");
                }),
            LongOutlinedButton(
                text: "Is Manufacturer Battery optimization disabled",
                onPressed: () async {
                  bool? isManBatteryOptimizationDisabled =
                      await DisableBatteryOptimization
                          .isManufacturerBatteryOptimizationDisabled;
                  _print(
                      "Manufacturer Battery optimization is $isManBatteryOptimizationDisabled");
                }),
            LongOutlinedButton(
                text: "Are All Battery optimizations disabled",
                onPressed: () async {
                  bool? isAllBatteryOptimizationDisabled =
                      await DisableBatteryOptimization
                          .isAllBatteryOptimizationDisabled;
                  _print(
                      "All Battery optimizations are disabled $isAllBatteryOptimizationDisabled ");
                }),
            LongOutlinedButton(
                text: "Enable Auto Start",
                onPressed: () {
                  DisableBatteryOptimization.showEnableAutoStartSettings(
                      "Enable Auto Start",
                      "Follow the steps and enable the auto start of this app");
                }),
            LongOutlinedButton(
                text: "Disable Battery Optimizations",
                onPressed: () {
                  DisableBatteryOptimization
                      .showDisableBatteryOptimizationSettings();
                }),
            LongOutlinedButton(
                text: "Disable Manufacturer Battery Optimizations",
                onPressed: () {
                  DisableBatteryOptimization
                      .showDisableManufacturerBatteryOptimizationSettings(
                    "Your device has additional battery optimization",
                    "Follow the steps and disable the optimizations to allow smooth functioning of this app",
                  );
                }),
            LongOutlinedButton(
                text: "Disable all Optimizations",
                onPressed: () {
                  DisableBatteryOptimization
                      .showDisableAllOptimizationsSettings(
                    "Enable Auto Start",
                    "Follow the steps and enable the auto start of this app",
                    "Your device has additional battery optimization",
                    "Follow the steps and disable the optimizations to allow smooth functioning of this app",
                  );
                })
          ],
        ),
      ),
    );
  }
}
