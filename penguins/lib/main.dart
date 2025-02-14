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

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  final ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: Color.fromRGBO(0xFB, 0xFF, 0xE4, 1), primary: Color.fromRGBO(0xA3, 0xD1, 0xC6, 1));

  runApp(
    MaterialApp(
      theme: ThemeData.from(colorScheme: colorScheme),
      home: TakePictureScreen(
        // Pass the appropriate camera to the TakePictureScreen widget.
        camera: firstCamera,
      ),
    ),
  );
}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({super.key, required this.camera});

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final StreamController<String> controller = StreamController<String>(onListen: () => print('LISTENNNNNNN'));

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.high,
    );

    controller.stream.listen((event) async {
      if (company_list.companyList.contains(event.trim().toLowerCase())) {
        final image = await _controller.takePicture();
        if (!context.mounted) return;

        await Navigator.of(context).push(
            MaterialPageRoute(
              builder:
              (context) => DisplayPictureScreen(
                // Pass the automatically generated path to
                // the DisplayPictureScreen widget.
                imagePath: image.path,
                company: event,
                ),
              ),
            );
        }
    });

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
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
    var camera = _controller.value;
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio / camera.aspectRatio;

    // if (scale < 1) scale = 1 / scale;

    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: Column(children: [
        ScalableOCR(
          paintboxCustom: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4.0
            ..color = const Color.fromARGB(153, 102, 160, 241),
          boxLeftOff: 5,
          boxBottomOff: 2.5,
          boxRightOff: 5,
          boxTopOff: 2.5,
          boxHeight: MediaQuery.of(context).size.height / 3,
          getScannedText: (value) {
            // print(value);
            setText(value);
          }),
          StreamBuilder<String>(
                stream: controller.stream,
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  return Text(
                      snapshot.data != null ? snapshot.data! : "");
                },
              ),]
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
          name: widget.company
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
