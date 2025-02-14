import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:penguins/environment.dart';
import 'package:http/http.dart' as http;

class ResultsScreen extends StatefulWidget {
  final int sustainabilityScore;
  final String sustainabilityDescription;
  final int ethicsScore;
  final String ethicsDescription;
  final String name;
  final List<String> categories;

  const ResultsScreen({
    super.key,
    required this.sustainabilityScore,
    required this.sustainabilityDescription,
    required this.ethicsScore,
    required this.ethicsDescription,
    required this.name,
    required this.categories
  });


  @override
  ResultsScreenState createState() => ResultsScreenState();
}

class ResultsScreenState extends State<ResultsScreen> {
  var category = "";
  var alternatives = [];
  var bestAlternatives = [];

  void fetchAlternatives() async {
    var serverURL = Environment.serverUrl;
    var response = await http.post(
      Uri.parse("$serverURL/alternatives"),
headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
        body: category == "" ? jsonEncode(<String, String>{'company': widget.name.trim().toLowerCase()}) : jsonEncode(<String, String>{'category': category}),
    );

    var data = jsonDecode(response.body);
    print(response.body);
    setState(() {
      bestAlternatives = data['best_alternatives'] ?? [];
      alternatives = data['alternatives'] ?? [];
    });
  }

  @override
  void initState() {
    super.initState();

    fetchAlternatives();
  }

  @override
  Widget build(BuildContext context) {
    var descriptionStyle = TextStyle(fontSize: 15);
    var scoreStyle = TextStyle(fontSize: 40);
    return
    Scaffold(
    appBar: AppBar(title: Text( "Results for ${widget.name.trim()}" )),
    body:
    Container(padding: const EdgeInsets.all(20), child:
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Sustainability", style: TextStyle(fontSize: 50)),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(spacing: 20, children: [
              CircleAvatar(radius: 40, child:
              Text(widget.sustainabilityScore.toString(), style: scoreStyle),
              ),
              Expanded(child: Text(widget.sustainabilityDescription, style: descriptionStyle)),
            ]),
          ),
          LinearProgressIndicator(value: widget.sustainabilityScore / 100, backgroundColor: Colors.red, color: Colors.green),
          Text("Ethics", style: TextStyle(fontSize: 50)),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(spacing: 20, children: [
              CircleAvatar(radius: 40, child:
              Text(widget.ethicsScore.toString(), style: scoreStyle),
              ),
              Expanded(child: Text(widget.ethicsDescription, style: descriptionStyle)),
            ]),
          ),
          LinearProgressIndicator(value: widget.ethicsScore / 100, backgroundColor: Colors.red, color: Colors.green),
          Text("Alternatives", style: TextStyle(fontSize: 50)),
          DropdownMenu(dropdownMenuEntries: widget.categories.map((item) => DropdownMenuEntry(value: item, label: item)).toList(), onSelected: (item) {
            setState(() {
              category = item!;
            });
            fetchAlternatives();
          }),
          Column(children: bestAlternatives.map((item) => Text("- $item", style: TextStyle(fontSize: 25, color: Colors.green))).toList()),
          Column(children: alternatives.map((item) => Text("- $item", style: TextStyle(fontSize: 25))).toList()),
        ]
      )
    )
    );
  }
}
