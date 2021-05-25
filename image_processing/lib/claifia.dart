import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Clarifia extends StatefulWidget {
  @override
  _ClarifiaState createState() => _ClarifiaState();
}

class _ClarifiaState extends State<Clarifia> {
  var age = [];
  var gender = [];
  var race = [];
  var result;
  bool isloading = false;
  String status = '';
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ethnicity and Gender Predictor'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              postImage == null
                  ? Container(
                      margin: EdgeInsets.all(10),
                      height: MediaQuery.of(context).size.height / 2,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          border: Border.all(style: BorderStyle.solid)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.linked_camera),
                            onPressed: () => uploadPic(),
                          ),
                          Text("Choose Image")
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(10),
                          height: MediaQuery.of(context).size.height / 2,
                          width: MediaQuery.of(context).size.width,
                          child: Image.file(postImage ?? File(''),
                              fit: BoxFit.cover),
                        ),
                        // SizedBox(height: 10,),
                        InkWell(
                          onTap: () => uploadPic(),
                          child: Container(
                            margin: EdgeInsets.all(30),
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 10),
                            width: MediaQuery.of(context).size.width / 2,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    style: BorderStyle.solid,
                                    color: Colors.blue)),
                            child: Text("Add Picture"),
                          ),
                        )
                      ],
                    ),
              SizedBox(
                height: 20,
              ),
              result != null &&
                      age.length > 0 &&
                      gender.length > 0 &&
                      race.length > 0
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'gender - ${gender[0]} \nrace - ${race[0]}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          background: Paint()..color = Colors.white,
                        ),
                      ),
                    )
                  : isloading
                      ? Container(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              const CircularProgressIndicator(),
                              Text(status),
                            ],
                          ),
                        )
                      : Container()
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () =>uploadPic(),
      //   child: Icon(Icons.image),
      // ),
    );
  }

  File postImage;
  String imgUrl = '';

  Future uploadPic() async {
    setState(() {
      isloading = true;
      status = 'Waiting for image';
    });

    await showDialog(
      context: context,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Pick image from',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.image),
                    title: Text('Gallery'),
                    onTap: () async {
                      print('gallery');
                      Navigator.of(context).pop();
                      var tempImage = await picker.getImage(
                        source: ImageSource.gallery,
                      );
                      setState(() {
                        postImage = File(tempImage?.path ?? '');
                        age = [];
                        gender = [];
                        race = [];
                        status = 'Picked image from gallery';
                      });
                      prepareImageForUpload();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.camera),
                    title: Text('Camera'),
                    onTap: () async {
                      print('camera');
                      Navigator.of(context).pop();

                      var tempImage =
                          await picker.getImage(source: ImageSource.camera);
                      setState(() {
                        status = 'Picked image from camera';
                        postImage = File(tempImage?.path ?? '');
                        age = [];
                        gender = [];
                        race = [];
                      });
                      prepareImageForUpload();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> prepareImageForUpload() async {
    var timeKey = DateTime.now();

    if (postImage != null) {
      final postImageRef = FirebaseStorage.instance.ref().child('Post Images');

      final uploadTask = postImageRef
          .child(timeKey.toString() + '.jpg')
          .putFile(postImage ?? File(''));
      uploadTask.whenComplete(() async {
        print('uploading image');
        setState(() {
          status = 'Uploading image';
        });
        var imageUrl = await (await uploadTask.whenComplete(() => null))
            .ref
            .getDownloadURL();

        imgUrl = imageUrl.toString();

        getResult(imgUrl);
      });
      // return location;
    } else {
      print('image is null');
    }
  }

  Future getResult(String imgpath) async {
    print('getting result');
    setState(() {
      status = 'Evaluating result';
    });
    http.Response response = await http.post(
        Uri.parse(
            'https://api.clarifai.com/v2/models/aaf5004e07954d87ae53b35a6d4fced8/outputs'),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Key aaf5004e07954d87ae53b35a6d4fced8"
        },
        body: json.encode({
          "inputs": [
            {
              "data": {
                "image": {'url': imgUrl}
              }
            }
          ]
        }));
    setState(() {
      status = 'Preparing result to be displayed';
    });
    var resObj = json.decode(response.body);
    print('RESOBJ: ${resObj}');
    var arr = resObj['outputs'][0]['data']['regions'][0]['data']['concepts'];

    arr.forEach((elem) {
      if (elem['vocab_id'] == 'age_appearance') {
        setState(() {
          age.add(elem['name']);
        });
      }
      if (elem['vocab_id'] == 'gender_appearance') {
        setState(() {
          gender.add(elem['name']);
        });
      }
      if (elem['vocab_id'] == 'multicultural_appearance') {
        setState(() {
          race.add(elem['name']);
        });
      }
    });

    print(age[0]);
    print(gender[0]);
    print(race[0]);
    setState(() {
      result = arr;
      isloading = false;
    });
  }
}
