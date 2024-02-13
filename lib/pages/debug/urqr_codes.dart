import 'dart:convert';
import 'dart:typed_data';

import 'package:xmruw/widgets/labeled_text_input.dart';
import 'package:xmruw/widgets/long_outlined_button.dart';
import 'package:xmruw/widgets/urqr.dart';
import 'package:bytewords/bytewords.dart';
import 'package:flutter/material.dart';

class URQRCodeDebug extends StatefulWidget {
  const URQRCodeDebug({super.key});

  @override
  State<URQRCodeDebug> createState() => _URQRCodeDebugState();

  static void push(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const URQRCodeDebug();
      },
    ));
  }
}

class _URQRCodeDebugState extends State<URQRCodeDebug> {
  final textCtrl = TextEditingController(text: """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris iaculis diam id nibh malesuada, non aliquam diam aliquet. Praesent luctus tincidunt dui vitae pharetra. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Donec eu metus vitae mauris fringilla ullamcorper. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus pretium ultrices turpis id porttitor. Nullam fringilla massa fermentum lacus elementum scelerisque non dictum magna. Etiam pharetra sed lacus et interdum. Nullam gravida orci sed sapien fermentum, in iaculis erat pretium. Donec ut vulputate velit.
Nunc sed sollicitudin nunc. Curabitur vitae aliquam nisi. Ut elementum tellus quis nibh efficitur pretium. Proin semper at turpis nec pharetra. In lacus urna, posuere maximus tempus eget, gravida eu enim. Morbi vestibulum sodales nunc ut egestas. Nam non ligula nulla. Phasellus consectetur leo quam, ac sollicitudin nibh pharetra quis. Nunc eleifend eget nisi vel sagittis. Aenean ex ex, convallis at placerat vel, venenatis nec lacus. Donec quis viverra nunc. Praesent viverra suscipit justo nec feugiat. Donec finibus tincidunt arcu quis fermentum. Sed lacinia ex ac arcu gravida, sed lacinia felis imperdiet. Duis consequat a libero id malesuada.
Donec sodales augue vel dui dictum euismod id eu nisi. In molestie lacus quis vehicula efficitur. Sed ut hendrerit lorem. Sed ipsum dolor, feugiat ac ex eget, scelerisque mollis orci. Duis aliquam sit amet nunc sed vulputate. Praesent placerat mi sed nunc scelerisque fringilla. Aenean viverra lorem lacus, a consequat quam ultricies sed. Quisque leo turpis, aliquam ac felis nec, vestibulum condimentum arcu. Maecenas vitae volutpat quam. Praesent at ultrices turpis. Cras mauris urna, euismod condimentum orci tristique, convallis vestibulum lacus. Sed luctus, libero sed dapibus posuere, dui purus tristique nulla, in lobortis nulla ex vitae neque. Donec at velit ullamcorper, condimentum nisi tristique, blandit velit. Nunc facilisis, mauris id consectetur venenatis, ligula diam consectetur lorem, faucibus placerat diam nibh vitae neque.
Donec tristique augue vel tellus euismod ornare. Nam odio eros, tincidunt eget justo id, pharetra hendrerit mauris. Integer porttitor, turpis in ornare tristique, odio nisl feugiat erat, in scelerisque neque ex vel enim. Vestibulum tincidunt pellentesque neque sed condimentum. Vivamus et libero tortor. Integer luctus convallis tellus, at sagittis eros. Cras vel turpis sit amet turpis scelerisque varius ut a velit. Quisque id arcu vitae odio malesuada consequat id pretium elit. Nam ornare vehicula magna vitae dapibus. Donec posuere vel erat ac ornare. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Mauris fermentum diam a ultricies mollis. Nam ac feugiat metus. In eu sem mi.
Phasellus blandit iaculis urna sed efficitur. Donec metus leo, eleifend et ultrices vel, rhoncus egestas risus. Aenean et rutrum dui, id tempus sapien. Integer eu neque velit. Cras sodales, leo sed varius vehicula, odio tellus tempor arcu, id facilisis tellus est consequat erat. Suspendisse nec dolor sit amet tellus maximus accumsan et at urna. Aenean suscipit non justo auctor ornare. Maecenas quis condimentum leo. Nunc tincidunt neque sit amet rhoncus accumsan. Duis semper mi pulvinar, faucibus risus a, faucibus massa. In id sapien mi. Mauris ultricies faucibus felis nec interdum. Mauris nec molestie arcu. Pellentesque eleifend ipsum consequat, rutrum sem ut, tempor libero. 
""");

  Uint8List? data;

  void _generate() {
    setState(() {
      data = utf8.encode(textCtrl.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("URQR Code"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (data == null) LabeledTextInput(label: "Text", ctrl: textCtrl),
            if (data == null)
              LongOutlinedButton(text: "Generate", onPressed: _generate),
            if (data != null) URQR(frames: uint8ListToURQR(data!, 'debug')),
          ],
        ),
      ),
    );
  }
}
