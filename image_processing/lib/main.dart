import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'DetailScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomeScreen(),
  ));
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, String>> list = [
    {
      'title': 'Text Scanner',
      'image': 'assets/img1.jpg',
      'description': 'Dialog string',
    },
    {
      'title': 'Label Scanner',
      'image': 'assets/img1.jpg',
      'description': 'Dialog string',
    },
    {
      'title': 'Face Detection',
      'image': 'assets/img1.jpg',
      'description': 'Dialog string',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Processing using AI'),
      ),
      body: ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            return Card(
              child: Column(
                children: [
                  SizedBox(
                    height: 180.0,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(list[index]['image'],
                              fit: BoxFit.cover),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: Colors.blueAccent,
                            padding: const EdgeInsets.all(16),
                            child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${list[index]['title']}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(color: Colors.white),
                                )),
                          ),
                        )
                      ],
                    ),
                  ),
                  ButtonBar(
                    alignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: () {
                            showDetailsDialog(context,
                                title: list[index]['title'],
                                description: list[index]['description']);
                          },
                          child: Text('Details')),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailScreen('${list[index]['title']}'),
                              ),
                            );
                          },
                          child: Text('Open'))
                    ],
                  )
                ],
              ),
            );
          }),
    );
  }

  void showDetailsDialog(BuildContext context,
      {@required String title, @required String description}) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text('$title'),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('$description'),
            ),
          ],
        );
      },
    );
  }
}
