import 'dart:io';
//import 'audience.dart';
//import 'main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PresenterPage extends StatefulWidget {
  @override
  State<PresenterPage> createState() => _PresenterPageState();
}

class _PresenterPageState extends State<PresenterPage> {
  final Future<FirebaseApp> _fApp = Firebase.initializeApp();
  late Future<File?> file;
  late String chosenFile = '';
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Presenter Page')),
      body: FutureBuilder(
        future: _fApp,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('something wrong with Firebase');
          } else if (snapshot.hasData) {
            return content();
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }

  Widget content() {
    return Column(
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
                onPressed: () {
                  change_slide_number(1);
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

class PresentationPage extends StatefulWidget {
  final File file;

  PresentationPage({required this.file});

  @override
  _PresentationPageState createState() => _PresentationPageState();
}

class _PresentationPageState extends State<PresentationPage> {
  final Future<FirebaseApp> _fApp = Firebase.initializeApp();
  late Future<File?> file;
  late PDFViewController _pdfController;
  int? _currentPage = 0;
  int? _totalPages = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Presentation Page'),
      ),
      body: FutureBuilder(
        future: _fApp,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('something wrong with Firebase');
          } else if (snapshot.hasData) {
            return content();
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }

  Widget content() {
    return Column(
      children: [
        Expanded(
          child: PDFView(
            filePath: widget.file.path,
            onViewCreated: (PDFViewController pdfController) {
              _pdfController = pdfController;
              _pdfController.getPageCount().then((count) {
                setState(() {
                  _totalPages = count;
                });
              });
            },
            onPageChanged: (int? page, int? total) {
              setState(() {
                _currentPage = page;
                _totalPages = total;
                change_slide_number(_currentPage);
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                if (_pdfController != null && _currentPage! > 0) {
                  _pdfController.setPage(_currentPage! - 1);
                  change_slide_number(_currentPage);
                }
              },
              icon: Icon(Icons.arrow_back),
            ),
            IconButton(
              onPressed: () {
                if (_pdfController != null &&
                    _currentPage! < _totalPages! - 1) {
                  _pdfController.setPage(_currentPage! + 1);
                  change_slide_number(_currentPage);
                }
              },
              icon: Icon(Icons.arrow_forward),
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            // Navigate back to the main menu
            Navigator.pop(context);
          },
          icon: Icon(Icons.pause),
        ),
      ],
    );
  }
}

// method to change the slide and update the value in the realtime database
void change_slide_number(int? check) async {
  DatabaseReference _slideref = FirebaseDatabase.instance
      .ref()
      .child('slide_nummer')
      .child('keyToUpdate');
  Map<String, dynamic> updateData = {
    'keyToUpdate': check,
  };
  _slideref.update(updateData);
}
