import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'presenter.dart';
import 'main.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class AudiencePage extends StatefulWidget {
  @override
  _AudiencePageState createState() => _AudiencePageState();
}

class _AudiencePageState extends State<AudiencePage> {
  final Future<FirebaseApp> _fApp = Firebase.initializeApp();
  String current_slide = "";
  late PDFViewController _pdfController;
  String pdfPath =
      '/Interner Speicher/Download/Einsatzbriefing_qxaYjmFzWTCQC7JS6oYiUA1q.pdf';
  String filePath =
      "C:\\Users\\hayda\\Desktop\\MIS App test\\mis_app_test\\lib\\Project description v26032023-1.pdf";
  int? pages = 0;
  bool isReady = true;
  late File file = File(filePath);

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Audience Page')),
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
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: PDFView(
              filePath: pdfPath,
              onViewCreated: (PDFViewController pdfController) {
                _pdfController = pdfController;
                _pdfController.getPageCount().then((count) {
                  setState(() {
                    pages = count;
                  });
                });
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AudiencePage(),
                ),
              );
            },
            child: Text('Open PDF'),
          ),
        ],
      ),
    );
  }
}
