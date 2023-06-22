//import 'dart:html';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
//import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'presenter.dart';
//import 'main.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:open_filex/open_filex.dart';
//import 'package:file/local.dart';
//import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'shared_variables.dart';
//import 'package:open_file/open_file.dart';
//import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
//import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:pdf/widgets.dart' as pw;
//import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
//import 'package:native_pdf_renderer/native_pdf_renderer.dart' as pdflib;
import 'package:pdf_render/pdf_render.dart' as pdflib;

//import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
String filepath = 'files/$chosenFile';
bool _isLoading = true;
//pdflib.PdfDocument? document = null;
int initialPage = 0;
String pathing = "";
late PDFViewController _pdfController;
int? _totalPages = 0;
int _currentPage = 0;
int? _currentPage1 = 0;
late File file1 = File('');
int currentSlideNumber = 1;

class AudiencePage extends StatefulWidget {
  //final File files;
  //AudiencePage({required this.files});
  @override
  _AudiencePageState createState() => _AudiencePageState();
}

class _AudiencePageState extends State<AudiencePage> {
  @override
  final Future<FirebaseApp> _fApp = Firebase.initializeApp();
  String current_slide = "";
  late String pdfUrl = "";

  final FirebaseStorage _storage = FirebaseStorage.instance;

  DatabaseReference _slideref = FirebaseDatabase.instance
      .ref()
      .child('slide_nummer')
      .child('keyToUpdate');

  Future<String> getDownloadUrl(String filePath) async {
    String downloadUrl = await _storage.ref().child(filePath).getDownloadURL();
    return downloadUrl;
  }

  Future<File> downloadFile(String pdfUrl, String filename) async {
    Reference ref = FirebaseStorage.instance.refFromURL(pdfUrl);

    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;

    File new_file = File('$tempPath/$filename.pdf');

    await ref.writeToFile(new_file);

    return new_file;
  }

  void loadDocument() async {
    String url = await getDownloadUrl(filepath);
    pdfUrl = url;
    file1 = await downloadFile(url, chosenFile);

    //final bytes = await file.readAsBytes();

    //final pdf = await pdflib.PdfDocument.openFile(file1.path);

    //setState(() {
    //document = pdf;
    //});
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    loadDocument();
    _slideref.onValue.listen((event) {
      final dynamic value = event.snapshot.value;
      if (value != null && value is Map<dynamic, dynamic>) {
        final dynamic keyToUpdate = value['keyToUpdate'];
        if (keyToUpdate != null && keyToUpdate is int) {
          setState(() {
            _currentPage = keyToUpdate;
            _pdfController.setPage(_currentPage);
          });
        }
      }
    });
  }
  /*void openPDF() async {
    // Specify the path of the existing PDF file
    // String filePath = '/path/to/your/pdf/file.pdf';
    String url = await getDownloadUrl(filepath);
    pdfUrl = url;
    File file = await downloadFile(url, chosenFile);
    // Load the PDF document
    final document = pdflib.PdfDocument.openFile(file.path);
    pathing = file.path;

    // Get a reference to the numeric value stored in the Firebase Realtime Database
    final databaseReference = FirebaseDatabase.instance
        .ref()
        .child('slide_nummer')
        .child('keyToUpdate');

    // Navigate to the PDF viewer screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyPDFViewer(
          document: document,
          databaseReference: databaseReference,
        ),
      ),
    );
  }*/

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(chosenFile),
      ),
      body: FutureBuilder(
        future: _fApp,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong with Firebase');
          } else if (snapshot.connectionState == ConnectionState.done) {
            return content();
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
/*
  Widget content() {
    DatabaseReference slideNumberRef = FirebaseDatabase.instance
        .ref()
        .child('slide_number')
        .child('KeyToUpdate');

    int currentSlideNumber = 1;

    void listenToSlideNumberChanges() {
      slideNumberRef.onValue.listen((event) {
        final dataSnapshot = event.snapshot;
        if (dataSnapshot.value != null) {
          final newSlideNumber = dataSnapshot.value as int;
          setState(() {
            currentSlideNumber = newSlideNumber;
          });
          // _pdfController?.setPage(currentSlideNumber);
          return newSlideNumber;
        }
      });
    }

    return Column(
      children: [
        Expanded(
          child: PdfViewer.openFile(
            file.path,
            params: PdfViewerParams(
              pageNumber: currentSlideNumber,
              scrollDirection: Axis.horizontal,
              onViewerControllerInitialized: (PDFViewController c) {
                _pdfController = c;
                _pdfController.getPageCount();
                listenToSlideNumberChanges(); // Start listening to slide number changes
              },
            ),
          ),
        ),
      ],
    );
  }*/

  Widget content() {
    return Column(
      children: [
        Expanded(
          child: PDFView(
            filePath: file1.path,
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
                _currentPage1 = page;
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
                  //change_slide_number(_currentPage);
                }
              },
              icon: Icon(Icons.arrow_back),
            ),
            IconButton(
              onPressed: () {
                if (_pdfController != null &&
                    _currentPage! < _totalPages! - 1) {
                  _pdfController.setPage(_currentPage! + 1);
                  //change_slide_number(_currentPage);
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
/*class MyPDFViewer extends StatelessWidget {
  final PDFDocument document;

  MyPDFViewer(this.document);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: Center(child: PDFViewer(document: document)),
    );
  }
}*/

/*class MyPDFViewer extends StatefulWidget {
  final PDFDocument document;
  final DatabaseReference databaseReference;

  MyPDFViewer({required this.document, required this.databaseReference});

  @override
  _MyPDFViewerState createState() => _MyPDFViewerState();
}

class _MyPDFViewerState extends State<MyPDFViewer> {
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    widget.databaseReference.onValue.listen((event) {
      setState(() {
        currentPage = event.snapshot.value as int;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: pdflib.PdfDocument.openFile(pathing)
      ),
    );
  }
}*/
