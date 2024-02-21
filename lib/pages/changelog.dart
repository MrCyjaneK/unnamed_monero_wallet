import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xmruw/const/resource.g.dart';

class ChangelogPage extends StatefulWidget {
  const ChangelogPage({super.key});
  static Future<void> push(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const ChangelogPage();
      },
    ));
  }

  @override
  State<ChangelogPage> createState() => _ChangelogPageState();
}

class ChangelogEntry {
  final DateTime date;
  final String hash;
  final String body;
  final String name;
  ChangelogEntry.fromJson(Map<String, dynamic> v)
      : date = DateTime.parse(v["date"].toString()),
        hash = v["hash"] as String,
        body = v["body"] as String,
        name = v["name"] as String;
  Map<String, dynamic> toJson() {
    return {
      "date": date.toIso8601String(),
      "hash": hash,
      "body": body,
      "name": name,
    };
  }
}

class _ChangelogPageState extends State<ChangelogPage> {
  List<ChangelogEntry> list = [];

  @override
  void initState() {
    loadChangelog();
    super.initState();
  }

  void loadChangelog() async {
    final chstr =
        (await rootBundle.loadString(R.ASSETS_CHANGELOG_JSONP)).trim();
    List<ChangelogEntry> tmpList = [];
    final splitStr = chstr.split("\n");
    for (var element in splitStr) {
      tmpList.add(ChangelogEntry.fromJson(json.decode(element)));
    }
    setState(() {
      list = tmpList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Changelog"),
      ),
      body: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(
                "${list[index].date.toLocal().toString().split(" ")[0]} - ${list[index].name}",
                maxLines: 1,
              ),
              subtitle: SelectableText(
                """
Author: ${list[index].name}
${list[index].body.trimRight()}

${list[index].hash}
                  """
                    .trim(),
              ),
            ),
          );
//           return Card(
//             child: ExpansionTile(
//               initiallyExpanded: index == 0,
//               title: Text(
//                 "${list[index].date.toLocal().toString().split(" ")[0]} - ${list[index].name}",
//                 maxLines: 1,
//               ),
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: SizedBox(
//                     width: double.maxFinite,
//                     child: SelectableText("""
// Author: ${list[index].name}
// ${list[index].body}

// ${list[index].hash}
//                   """
//                         .trim()),
//                   ),
//                 ),
//               ],
//             ),
//           );
        },
      ),
    );
  }
}
