import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:penguins/environment.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  AdminScreenState createState() => AdminScreenState();
}

class AdminScreenState extends State<AdminScreen> {
  var suggestions = [];

  var companyName;
  var sustainabilityScore;
  var sustainabilityDescription;
  var ethicsScore;
  var ethicsDescription;
  var categories;

  var category;
  var alternatives;
  var bestAlternatives;

  @override
  void initState() {
    super.initState();

    fetchSuggestions();
  }

  void fetchSuggestions() async {
    var serverURL = Environment.serverUrl;
    var response = await http.get(
      Uri.parse("$serverURL/getSuggestions"),
    );

    setState(() {
      suggestions = jsonDecode(response.body);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(title: Text("Admin")),
    body: Padding(padding: EdgeInsets.only(left: 20, right: 20), child:
      ListView(children: [
        Text("Top Suggestions", style: TextStyle(fontSize: 40)),
        Column(children:
          suggestions.map((item) => Text("${item['name']}: ${item['number']}", style: TextStyle(fontSize: 25))).toList()
        ),
        Text("Add Company", style: TextStyle(fontSize: 40)),
        SizedBox(height: 275, child: GridView.count(childAspectRatio: 2, crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, children: [
          TextField(decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Company Name"), onChanged: (value) {
            setState(() {
              companyName = value;
            });
          }),
          TextField(decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Categories"), onChanged: (value) {
            setState(() {
              categories = value;
            });
          }),
          TextField(decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Sustainability Score"), keyboardType: TextInputType.number, onChanged: (value) {
            setState(() {
              sustainabilityScore = value;
            });
          }),
          TextField(decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Sustainability Description"), onChanged: (value) {
            setState(() {
              sustainabilityDescription = value;
            });
          }),
          TextField(decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Ethics Score"), keyboardType: TextInputType.number, onChanged: (value) {
            setState(() {
              ethicsScore = value;
            });
          }),
          TextField(decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Ethics Description"), onChanged: (value) {
            setState(() {
              ethicsDescription = value;
            });
          }),
        ])
        ),
        SizedBox(width: 200, height: 50, child: ElevatedButton(onPressed: () async {
          var serverURL = Environment.serverUrl;
          var response = await http.post(
          Uri.parse("$serverURL/addCompany"),
            headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{'name': companyName, 'categories': categories, 'sustainability_score': sustainabilityScore, 'sustainability_description': sustainabilityDescription, 'ethics_score': ethicsScore, 'ethics_description': ethicsDescription}),
    );

          const snackBar = SnackBar(content: Text('Company added'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }, child: const Text("Submit"))
        ),
        Text("Add Alternative", style: TextStyle(fontSize: 40)),
        SizedBox(height: 175, child: GridView.count(childAspectRatio: 2, crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, children: [
          TextField(decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Category"), onChanged: (value) {
            setState(() {
              category = value;
            });
          }),
          TextField(decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Alternative Companies"), onChanged: (value) {
            setState(() {
              alternatives = value;
            });
          }),
          TextField(decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Best Alternatives"), onChanged: (value) {
            setState(() {
              bestAlternatives = value;
            });
          }),
          ])
        ),
        SizedBox(width: 250, height: 50, child: ElevatedButton(onPressed: () async {
          var serverURL = Environment.serverUrl;
          var response = await http.post(
          Uri.parse("$serverURL/addAlternative"),
            headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{'category': category, 'alternatives': alternatives, 'best_alternatives': bestAlternatives}),
    );

          const snackBar = SnackBar(content: Text('Alternative added'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }, child: const Text("Submit"))
        ),
      ])
    )
    );
  }
}
