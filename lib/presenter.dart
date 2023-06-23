import 'dart:io';
//import 'audience.dart';
//import 'main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:firebase_storage/firebase_storage.dart';
//import 'shared_variables.dart';

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
  //int? _currentPage1 = 0;

  int? _totalPages = 0;

  // DatabaseReference _slideref = FirebaseDatabase.instance
  //   .ref()
  // .child('slide_nummer')
  ////.child('keyToUpdate');

  //void initState() {
  // super.initState();
  //isten for changes
  /* _slideref.onValue.listen((event) {
      final dynamic value = event.snapshot.value;
      if (value != null && value is Map<Object?, Object?>) {
        final dynamic keyToUpdate = value['keyToUpdate'];
        if (keyToUpdate != null && keyToUpdate is int) {
          setState(() {
            _currentPage = keyToUpdate;
            _pdfController.setPage(_currentPage);
          });
        }
      }
    });*/
  //}

  void initState() {
    super.initState();
    _fApp;
  }

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
