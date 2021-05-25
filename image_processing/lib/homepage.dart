import 'package:flutter/material.dart';
import 'package:image_processing/ObjectRecognitionScreen.dart';
import 'package:image_processing/SentimentAnalysisScreen.dart';
import 'FacialRecognitionScreen.dart';

class Homepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        title: Text('Image Processing'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              NavCard(
                imgUrl: 'assets/img1.jpg',
                imgTitle: 'Facial Recognition',
                imgDesc: 'Predict the demographics related to that person',
                navigationFunction: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => FacialRecognitionScreen()));
                },
              ),
              NavCard(
                imgUrl: 'assets/img1.jpg',
                imgTitle: 'Sentiment Recognition',
                imgDesc: 'Predict the sentiments of the person from text',
                navigationFunction: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => SentimentAnalysisScreen()));
                },
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              NavCard(
                imgUrl: 'assets/img1.jpg',
                imgTitle: 'Object Recognition',
                imgDesc: 'Predict the objects shown in the image',
                navigationFunction: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ObjectRecognitionScreen()));
                },
              ),
              NavCard(
                imgUrl: 'assets/img1.jpg',
                imgTitle: 'About Project',
                imgDesc: 'Know all about the project implementation',
                navigationFunction: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => FacialRecognitionScreen()));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NavCard extends StatelessWidget {
  final String imgUrl;
  final String imgDesc;
  final String imgTitle;
  final Function navigationFunction;
  const NavCard({
    this.imgUrl,
    this.imgTitle,
    this.imgDesc,
    this.navigationFunction,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          print('You clicked $imgTitle');
          navigationFunction?.call();
        },
        child: Container(
          height: 290,
          color: Colors.transparent,
          padding: EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Card(
            color: Colors.red,
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    '$imgTitle',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: 16.0, left: 16.0, right: 16.0, top: 2.0),
                  child: Text(
                    '$imgDesc',
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.6), fontSize: 16.0),
                  ),
                ),
                Image.asset('$imgUrl'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
