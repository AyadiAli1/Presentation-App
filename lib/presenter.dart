import 'dart:io';
import 'audience.dart';
import 'main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class PresentationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Presentation Page'),
      ),
      body: Center(
        child: Text('You logged in as an audience'),
      ),
    );
  }
}

class PresenterPage extends StatefulWidget {
  @override
  State<PresenterPage> createState() => _PresenterPageState();
}

class _PresenterPageState extends State<PresenterPage> {
  @override
  late Future<File?> file;
  late String chosenFile = '';

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Presenter Page'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    pickFile();
                  },
                  child: Text('Choose a file'),
                ),
                SizedBox(height: 20),
                Text(
                  'You chose: $chosenFile\n',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Start Presentation'),
                ),
              ],
            ),
          ),
          Align(
            alignment: FractionalOffset.bottomLeft,
            child: Container(
              padding: EdgeInsets.only(left: 16.0, right: 16.0),
              child: Text(
                'Support',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          Align(
            alignment: FractionalOffset.bottomRight,
            child: Container(
              padding: EdgeInsets.only(left: 16.0, right: 16.0),
              child: Text(
                'Version 1.0',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['ppt', 'pptx'],
    );
    if (result != null) {
      setState(() {
        chosenFile = result.files.single.name;
        file = Future.value(File(result.files.single.path!));
      });
    }
  }
}