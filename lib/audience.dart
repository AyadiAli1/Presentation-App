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
//String chosenFile1 = 'SQN-Mischer_v20';
late String chosenFile1 = '';
String filepath = '';
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
bool _isPDFloaded = true;
List<String> fileList = [];

class AudiencePage extends StatefulWidget {
  @override
  _AudiencePageState createState() => _AudiencePageState();
}

class _AudiencePageState extends State<AudiencePage> {
  final Future<FirebaseApp> _fApp = Firebase.initializeApp();
  String current_slide = "";
  late String pdfUrl = "";

  final FirebaseStorage _storage = FirebaseStorage.instance;

  DatabaseReference _slideref = FirebaseDatabase.instance
      .ref()
      .child('slide_nummer')
      .child('keyToUpdate');

  DatabaseReference _slideref2 =
      FirebaseDatabase.instance.ref().child('presentation_name').child('name');

  DatabaseReference filesRef = FirebaseDatabase.instance.ref().child('files');

  Future<String> getDownloadUrl(String filePath) async {
    _slideref2.onValue.listen((event) {
      final dynamic value = event.snapshot.value;
      if (value != null && value is Map<dynamic, dynamic>) {
        final dynamic valeur = value['name'];
        chosenFile1 = valeur;
      }
    });
    filePath = 'files/$chosenFile1';
    String downloadUrl = await _storage.ref().child(filePath).getDownloadURL();
    return downloadUrl;
  }

  Future<File> downloadFile(String pdfUrl, String filename) async {
    Reference ref = FirebaseStorage.instance.refFromURL(pdfUrl);

    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;

    File new_file = File('$tempPath/$filename');

    await ref.writeToFile(new_file);

    return new_file;
  }

  Future<void> loadDocument() async {
    String url = await getDownloadUrl(filepath);
    pdfUrl = url;
    print(filepath);

    print(chosenFile1);
    file1 = await downloadFile(url, chosenFile1);
  }

  Future<List<String>> getListOfFiles() async {
    try {
      Reference storageRef = FirebaseStorage.instance.ref().child('files');
      ListResult result = await storageRef.listAll();

      // Iterate over each item in the result
      for (var item in result.items) {
        String fileName = item.name;
        fileList.add(fileName);
      }
    } catch (e) {
      print('Error retrieving list of files: $e');
    }

    return fileList;
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

    getListOfFiles().then((files) {
      setState(() {
        fileList = files;
      });
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(chosenFile1),
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

  Widget content() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(
                      title: Text(chosenFile1),
                    ),
                    body: Column(
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
                                // change_slide_number(_currentPage);
                              });
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                if (_pdfController != null &&
                                    _currentPage! > 0) {
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
                    ),
                  ),
                ),
              );
            },
            child: Text(
              'Start last started presentation',
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FileListWidget(pdfFiles: fileList),
                ),
              );
            },
            child: Text(
              'Show available Presentations',
              style: TextStyle(fontSize: 18.0),
            ),
          ),
        ],
      ),
    );
  }
}

class FileListWidget extends StatelessWidget {
  final List<String> pdfFiles;

  FileListWidget({required this.pdfFiles});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Presentations'),
      ),
      body: ListView.builder(
        itemCount: pdfFiles.length,
        itemBuilder: (context, index) {
          String fileName = pdfFiles[index];
          return ListTile(
            title: Text(fileName),
          );
        },
      ),
    );
  }
}
