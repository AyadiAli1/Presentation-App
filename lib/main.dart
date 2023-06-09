import 'dart:io';
import 'audience.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:mis_app_test/presenter.dart';
import 'package:path/path.dart' as path;

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Presentation App'),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PresenterPage(),
                          ),
                        );
                      },
                      child: Text('Presenter'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AudiencePage(),
                          ),
                        );
                      },
                      child: Text('Audience'),
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
      },
    );
  }
}

class PresenterPage extends StatefulWidget {
  @override
  State<PresenterPage> createState() => _PresenterPageState();
}

class _PresenterPageState extends State<PresenterPage> {
  late File? selectedFile;
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
                  'You chose: ${chosenFile.isNotEmpty ? chosenFile : 'No file selected'}\n',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedFile != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PresentationPage(file: selectedFile!),
                        ),
                      );
                    } else {
                      // Handle case when no file is selected
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('No File Selected'),
                            content: Text(
                                'Please choose a file before starting the presentation.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
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
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
        chosenFile = path.basename(result.files.single.path!);
      });
    }
  }
}
