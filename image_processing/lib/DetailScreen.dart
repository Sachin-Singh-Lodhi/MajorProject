import 'dart:io';
import 'dart:async';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DetailScreen extends StatefulWidget {
  final String selectedItem;

  const DetailScreen(this.selectedItem);
  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  File pickedImage;
  var imageFile;

  var result = '';

  bool isImageLoaded = false;
  bool isFaceDetected = false;

  List<Rect> rect = [];

  getImageFrom(ImageSource source) async {
    var tempStore = await ImagePicker().getImage(source: source);

    imageFile = await tempStore?.readAsBytes();
    imageFile = await decodeImageFromList(imageFile);

    setState(() {
      pickedImage = File(tempStore?.path ?? '');
      isImageLoaded = true;
      isFaceDetected = false;

      imageFile = imageFile;
    });
  }

  readTextfromanImage() async {
    result = '';
    FirebaseVisionImage myImage = FirebaseVisionImage.fromFile(pickedImage);
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(myImage);

    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement word in line.elements) {
          setState(() {
            result = result + ' ' + word.text;
          });
        }
      }
    }
  }

  decodeBarCode() async {
    result = '';
    FirebaseVisionImage myImage = FirebaseVisionImage.fromFile(pickedImage);
    BarcodeDetector barcodeDetector = FirebaseVision.instance.barcodeDetector();
    List barCodes = await barcodeDetector.detectInImage(myImage);

    for (Barcode readableCode in barCodes) {
      setState(() {
        result = readableCode.displayValue;
      });
    }
  }

  Future labelsread() async {
    result = '';
    FirebaseVisionImage myImage = FirebaseVisionImage.fromFile(pickedImage);
    ImageLabeler labeler = FirebaseVision.instance.imageLabeler();
    List labels = await labeler.processImage(myImage);

    for (ImageLabel label in labels) {
      final String text = label.text;
      final double confidence = label.confidence;
      setState(() {
        result = result + ' ' + '$text     $confidence' + '\n';
      });
    }
  }

  Future detectFace() async {
    result = '';
    FirebaseVisionImage myImage = FirebaseVisionImage.fromFile(pickedImage);
    FaceDetector faceDetector = FirebaseVision.instance.faceDetector();
    List<Face> faces = await faceDetector.processImage(myImage);

    if (rect.length > 0) {
      rect = [];
    }

    for (Face face in faces) {
      rect.add(face.boundingBox);
    }

    setState(() {
      isFaceDetected = true;
    });
  }

  void detectMLFeature(String selectedFeature) {
    switch (selectedFeature) {
      case 'Text Scanner':
        readTextfromanImage();
        break;
      case 'Barcode Scanner':
        decodeBarCode();
        break;
      case 'Label Scanner':
        labelsread();
        break;
      case 'Face Detection':
        detectFace();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    //selectedItem = ModalRoute.of(context).settings.arguments.toString();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedItem),
        actions: [
          ElevatedButton(
            onPressed: () {
              pickImage();
            },
            child: Icon(
              Icons.add_a_photo,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            isImageLoaded && !isFaceDetected
                ? Center(
                    child: Container(
                      height: 250.0,
                      width: 250.0,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: FileImage(pickedImage ?? File('')),
                              fit: BoxFit.cover)),
                    ),
                  )
                : isImageLoaded && isFaceDetected
                    ? Center(
                        child: Container(
                          child: FittedBox(
                            child: SizedBox(
                              width: imageFile.width.toDouble(),
                              height: imageFile.height.toDouble(),
                              child: CustomPaint(
                                painter: FacePainter(
                                    rect: rect, imageFile: imageFile),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('$result'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          detectMLFeature(widget.selectedItem);
        },
        child: Icon(Icons.check),
      ),
    );
  }

  void pickImage() async {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text('Select image from'),
          children: [
            ListTile(
              title: Text('Camera'),
              onTap: () {
                getImageFrom(ImageSource.camera);
              },
            ),
            ListTile(
              title: Text('Gallery'),
              onTap: () {
                getImageFrom(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }
}

class FacePainter extends CustomPainter {
  List<Rect> rect;
  var imageFile;

  FacePainter({@required this.rect, @required this.imageFile});

  @override
  void paint(Canvas canvas, Size size) {
    if (imageFile != null) {
      canvas.drawImage(imageFile, Offset.zero, Paint());
    }

    List<Rect> list = rect ?? [];
    for (Rect rectange in list) {
      canvas.drawRect(
        rectange,
        Paint()
          ..color = Colors.teal
          ..strokeWidth = 6.0
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    throw UnimplementedError();
  }
}
