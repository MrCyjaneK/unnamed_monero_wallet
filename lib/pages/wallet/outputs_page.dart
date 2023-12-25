import 'package:anonero/tools/format_monero.dart';
import 'package:anonero/widgets/long_outlined_button.dart';
import 'package:flutter/material.dart';

class Output {
  Output({
    required this.amount,
    required this.hash,
  });
  final int amount;
  final String hash;
  bool value = true;
}

class OutputsPage extends StatefulWidget {
  const OutputsPage({super.key});

  @override
  State<OutputsPage> createState() => _OutputsPageState();

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const OutputsPage();
      },
    ));
  }
}

class _OutputsPageState extends State<OutputsPage> {
  List<Output> outs = [
    Output(amount: 539871431413, hash: 'hash'),
    Output(amount: 314134314131, hash: 'hash'),
    Output(amount: 213213131313, hash: 'hash'),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            OutputItem(
              output: outs[0],
              id: 0,
              triggerChange: () {
                setState(() {});
              },
            ),
            OutputItem(
              output: outs[1],
              id: 1,
              triggerChange: () {
                setState(() {});
              },
            ),
            OutputItem(
              output: outs[2],
              id: 2,
              triggerChange: () {
                setState(() {});
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const LongOutlinedButton(text: "Send #.### XMR"),
    );
  }
}

class OutputItem extends StatelessWidget {
  final int id;
  final Output output;
  final VoidCallback triggerChange;
  const OutputItem({
    super.key,
    required this.output,
    required this.id,
    required this.triggerChange,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: output.value,
      onChanged: (bool? value) {
        output.value = value == true;
        triggerChange();
      },
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      title: Row(
        children: [
          Expanded(
            child: Text(
              'OUTPUT #$id',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          Text(
            formatMonero(output.amount),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
      subtitle: Text(
        output.hash,
      ),
    );
  }
}
