import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:math';
import 'dart:io';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'ML Kit Demo',
      home: new MyHomePage(title: 'ML Kit Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<File> _imageFile;

  void _onImageButtonPressed(ImageSource source) {
    setState(() {
      _imageFile = ImagePicker.pickImage(source: source);
    });
  }


  Widget _previewImage() {
    return FutureBuilder<File>(
        future: _imageFile,
        builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            //in this place we start to analize the data

            return Image.file(snapshot.data);
          } else if (snapshot.error != null) {
            return const Text(
              'Error picking image.',
              textAlign: TextAlign.center,
            );
          } else {
            return const Text(
              'You have not yet picked an image.',
              textAlign: TextAlign.center,
            );
          }
        });
  }

  Widget _analizeImage() {
    return FutureBuilder<File>(
        future: _imageFile,
        builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            //in this place we start to analize the data
            faceCheck();
            return Image.file(snapshot.data);
          } else if (snapshot.error != null) {
            return const Text(
              'No se analizo ninguna imagen',
              textAlign: TextAlign.center,
            );
          } else {
            return const Text(
              'No se analizo ninguna imagen',
              textAlign: TextAlign.center,
            );
          }
        });
  }

  Future<String> faceCheck() async{
    print("Paso 1");
    if(_imageFile!=null){
      final File imageFile = await _imageFile;
      print("Paso 2");
      final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(imageFile);
      final LabelDetector labelDetector = FirebaseVision.instance.labelDetector();
      final LabelDetector detector = FirebaseVision.instance.labelDetector(
        LabelDetectorOptions(confidenceThreshold: 0.75),
      );

      final List<Label> labels = await labelDetector.detectInImage(visionImage);
      for (Label label in labels) {
        final String text = label.label;
        final String entityId = label.entityId;
        final double confidence = label.confidence;
        print("Resultados:::" + text);
      }
    }
    return "Bisa";
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(15.0),
          child: Column(
              children: <Widget>[
                _previewImage(),
                _analizeImage()
              ]
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () {
              _onImageButtonPressed(ImageSource.gallery);
            },
            heroTag: 'image0',
            tooltip: 'Pick Image from gallery',
            child: const Icon(Icons.photo_library),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              onPressed: () {
                _onImageButtonPressed(ImageSource.camera);
              },
              heroTag: 'image1',
              tooltip: 'Take a Photo',
              child: const Icon(Icons.camera_alt),
            ),
          ),
        ],
      ),
    );
  }
}

