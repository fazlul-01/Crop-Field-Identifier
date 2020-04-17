import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),

    ));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List _outputs;
  File _image;
  bool _loading = false;


  @override
  void initState() {
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Field Identification App'),
      ),
      body: ListView(children: <Widget>[
        _loading
            ? Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              )
            : Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _image == null ? Container() : Image.file(_image),
                    SizedBox(
                      height: 20,
                    ),
                    _outputs != null &&
                            (_outputs[0]['confidence'] * 100).roundToDouble() >=
                                99.0
                        ? Column(
                            children: <Widget>[
                              Text(
                                "${_outputs[0]['label'].substring(2)}\nConfidence:${(_outputs[0]['confidence'] * 100).roundToDouble()}%",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 30.0,
                                  background: Paint()..color = Colors.white,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: _outputs[0]['label'].substring(2) == 'wheat'
                                    ? Text(
                                        'Wheat is a grass widely cultivated for its seed, a cereal grain which is a worldwide staple food. The many species of wheat together make up the genus Triticum; the most widely grown is common wheat.\n\nScientific name: Triticum\nFamily: Poaceae\nOrder: Poales\nKingdom: Plantae\nRank: Genus\nHigher classification: Triticinae\n\nTypes: Common Wheat, Spelt, Durum, Einkorn wheat, Emmer',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 20.0,
                                        ),
                                      )
                                    : Text(
                                        'Sugarcane, or sugar cane, or simply cane, are several species of tall perennial true grasses of the genus Saccharum, tribe Andropogoneae, used for sugar production. The plant is two to six metres tall. It has stout, jointed, fibrous stalks that are rich in sucrose, which accumulates in the stalk internodes.\n\nScientific name: Saccharum officinarum\nHigher classification: Saccharum\nRank: Species\n\n',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 20.0,
                                        ),
                                      ),
                              )
                            ],
                          )
                        : Container(
                            child: Text(
                              'Not Recognised',
                              style: TextStyle(fontSize: 20.0),
                            ),
                          )
                  ],
                ),
              ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        child: Icon(Icons.image),
      ),
    );
  }

  pickImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = image;
    });
    classifyImage(image);
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _loading = false;
      _outputs = output;
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
}
