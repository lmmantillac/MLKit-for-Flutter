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

  Widget _extractLabels() {

    var futureBuilder = new FutureBuilder(
      future: getLabels(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return new Text('waiting...');
          default:
            if (snapshot.hasError)
              return new Text('Error: ${snapshot.error}');
            else
              return createListView(context, snapshot);
        }
      },
    );

    return futureBuilder;
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    List<Label> values = snapshot.data;
    return new Expanded(
      child:
      new ListView.builder(
      itemCount: values.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
            key: ValueKey(values[index]),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.lightBlue),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: ListTile(
              title: Text(values[index].label),
              trailing: Text(values[index].confidence.toString()),
            )
          )
        );
      },
    )
    );
  }

  Future<List<Label>> getLabels() async{
    var values = new List<Label>();
    if(_imageFile!=null){
      final File imageFile = await _imageFile;
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
      }
      return labels;
    }
    return values;
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
                _extractLabels()
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

