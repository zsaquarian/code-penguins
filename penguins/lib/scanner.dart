library;
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_scalable_ocr/flutter_scalable_ocr.dart';
import 'package:penguins/environment.dart';
import 'package:penguins/result_screen.dart';

import 'company_list.dart' as company_list;

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({super.key, required this.camera});

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late TextEditingController _controller2;
  final StreamController<String> controller = StreamController<String>(onListen: () => print('LISTENNNNNNN'));
  var triggered = false;
  var companyName = "";

  void fetchCompanies() async {
    var serverURL = Environment.serverUrl;
    var response = await http.get(
      Uri.parse("$serverURL/getAll"),
    );

    var data = jsonDecode(response.body);
    company_list.companyList = data;
    print(data);
  }

  void makeSuggestion() async {
    _controller2.clear();
    var serverURL = Environment.serverUrl;
    var response = await http.post(
      Uri.parse("$serverURL/suggest/$companyName"),
    );
  }

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller2 = TextEditingController();
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.high,
    );

    controller.stream.listen((event) async {
      // if (triggered) return;
      if (!_controller.value.isInitialized) return;
      var matching = event.trim().toLowerCase().split(' ').where((item) => company_list.companyList.contains(item)).toList();
      if (matching.isNotEmpty) {
        final image = await _controller.takePicture();
        if (!context.mounted) return;

        triggered = true;
        // await controller.stream.drain();
        await Navigator.of(context).push(
            MaterialPageRoute(
              builder:
              (context) => DisplayPictureScreen(
                // Pass the automatically generated path to
                // the DisplayPictureScreen widget.
                imagePath: image.path,
                company: matching[0],
                ),
              ),
            ).then((_)  {
              triggered = false;
            });
        }
    });

    _controller.initialize();
    fetchCompanies();
  }

  void setText(value) {
    controller.add(value);
  }


  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: SingleChildScrollView(child:
        Column(children: [
          ScalableOCR(
            paintboxCustom: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.0
              ..color = const Color.fromRGBO(0x1C, 0x1D, 0x29, 1),
            boxLeftOff: 5,
            boxBottomOff: 5,
            boxRightOff: 5,
            boxTopOff: 5,
            boxHeight: MediaQuery.of(context).size.height / 2,
            getScannedText: (value) {
              // print(value);
              setText(value);
            }),
            Text("Not finding your brand?", style: TextStyle(fontSize: 35)),
            Padding(padding: EdgeInsets.only(top: 5, bottom: 5, left: 20, right: 20), child:
              TextField(decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Company name"), controller: _controller2,onChanged: (text) {
                setState(() {
                  companyName = text;
                });
              }),
            ),
            Padding(
              padding: EdgeInsets.only(right: 20),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(onPressed: () {
                  makeSuggestion();
                }, child: Text("Submit suggestion"))
                )
            )
          ])
        )
      );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final String company;
  const DisplayPictureScreen({super.key, required this.imagePath, required this.company});
  @override
  DisplayPictureScreenState createState() => DisplayPictureScreenState();
}

class DisplayPictureScreenState extends State<DisplayPictureScreen> {
  var resJson;

  findCompany() async {
    File image = File(widget.imagePath);
    var serverURL = Environment.serverUrl;
    var company = widget.company.trim().toLowerCase();
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$serverURL/search/$company"),
    );
    print("request: " + request.toString());
    var res = await request.send();
    http.Response response = await http.Response.fromStream(res);
    final data = jsonDecode(response.body);

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
        (context) => ResultsScreen(
          // Pass the automatically generated path to
          // the DisplayPictureScreen widget.
          ethicsScore: data['ethics_score'],
          ethicsDescription: data['ethics_description'],
          sustainabilityScore: data['sustainability_score'],
          sustainabilityDescription: data['sustainability_description'],
          name: widget.company,
          categories: data['categories'].toString().split(",")
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Column(spacing: 20, children: [
        Image.file(File(widget.imagePath), height: MediaQuery.of(context).size.height / 2, width: MediaQuery.of(context).size.width, fit: BoxFit.contain),
        Text("\"${widget.company.trim()}\" has been found!", style: const TextStyle(fontSize: 25)),
        ElevatedButton(
          onPressed: findCompany,
          style: ButtonStyle(fixedSize: WidgetStatePropertyAll<Size>(Size(200, 75))),
          child: Text("Check", style: const TextStyle(fontSize: 35)),
          ),
        ]),
    );
  }
}
