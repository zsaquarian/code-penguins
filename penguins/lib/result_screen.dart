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
    var scoreStyle = TextStyle(color: Colors.white, fontSize: 40);
    return
    Scaffold(
    appBar: AppBar(title: Text( "Results for ${name.trim()}" )),
    body:
    Container(padding: const EdgeInsets.all(20), child:
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Sustainability", style: TextStyle(fontSize: 50)),
          Row(spacing: 20, children: [
            Text(sustainabilityScore.toString(), style: scoreStyle),
            Expanded(child: Text(sustainabilityDescription, style: descriptionStyle)),
          ]),
          LinearProgressIndicator(value: sustainabilityScore / 100, backgroundColor: Colors.red, color: Colors.green),
          Text("Ethics", style: TextStyle(fontSize: 50)),
          Row(spacing: 20,  children: [
            Text(ethicsScore.toString(), style: scoreStyle),
            Expanded(child: Text(ethicsDescription, style: descriptionStyle)),
          ]),
          LinearProgressIndicator(value: ethicsScore / 100, backgroundColor: Colors.red, color: Colors.green),
        ]
      )
    )
    );
  }
}
