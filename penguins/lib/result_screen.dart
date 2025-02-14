import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  final int sustainabilityScore;
  final String sustainabilityDescription;
  final int ethicsScore;
  final String ethicsDescription;
  final String name;

  const ResultsScreen({
    super.key,
    this.sustainabilityScore = -1,
    this.sustainabilityDescription = "",
    this.ethicsScore = -1,
    this.ethicsDescription = "",
    this.name = ""
  });

  @override
  Widget build(BuildContext context) {
    var descriptionStyle = TextStyle(color: Colors.white, fontSize: 15);
    var scoreStyle = TextStyle(color: Colors.white, fontSize: 50);
    return
    Scaffold(
    appBar: AppBar(title: Text( "Results for ${name.trim()}" )),
    body:
    GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      padding: const EdgeInsets.all(25),
      mainAxisSpacing: 10,
          children: [
            Center(child: Text(sustainabilityScore.toString(), style: scoreStyle)),
            Center(child: Text(sustainabilityDescription, style: descriptionStyle)),
            Center(child: Text(ethicsScore.toString(), style: scoreStyle)),
            Center(child: Text(ethicsDescription, style: descriptionStyle)),
        ])
    );
  }
}
