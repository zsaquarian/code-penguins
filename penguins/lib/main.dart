import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:penguins/admin_page.dart';
import 'package:penguins/scanner.dart';

final isAdmin = false;

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  final ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: Color.fromRGBO(0xFB, 0xFF, 0xE4, 1));

  runApp(
    MaterialApp(
      theme: ThemeData.from(colorScheme: colorScheme),
      home: isAdmin ? AdminScreen() : TakePictureScreen(
        camera: firstCamera,
      ),
    ),
  );
}

// A screen that allows users to take a picture using a given camera.
