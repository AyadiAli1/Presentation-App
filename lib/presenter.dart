import 'dart:io';
//import 'audience.dart';
//import 'main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

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

// method to change the slide and update the value in the realtime database
void change_slide_number(int check) async {
  DatabaseReference _slideref = FirebaseDatabase.instance
      .ref()
      .child('slide_nummer')
      .child('keyToUpdate');

  if (check == 1) {
    DataSnapshot snapshot = await _slideref.get();
    dynamic value = snapshot.value;

    int? current_value = int.tryParse(value);
    int? new_value = current_value;
    Map<String, dynamic> updateData = {
      'keyToUpdate': new_value,
    };
    _slideref.update(updateData);
  } else if (check == 3) {
    // when we upload a new presentation, we will go back to the first slide
    _slideref.update(0 as Map<String, Object?>);
  } else if (check == 2) {
    DataSnapshot snapshot = await _slideref.get();
    String current_value_string = snapshot.value.toString();
    int current_value = snapshot.value as int;
    int new_value = current_value--;
    Map<String, dynamic> updateData = {
      'keyToUpdate': new_value,
    };
    _slideref.update(updateData);
  }
}

int convertStringToInt(String value) {
  int intValue = 0;
  for (int i = 0; i < value.length; i++) {
    int digit = value.codeUnitAt(i) - '0'.codeUnitAt(0);
    if (digit >= 0 && digit <= 9) {
      intValue = intValue * 10 + digit;
    } else {
      // Handle invalid input or non-numeric characters
      return 2; // or a default value if desired
    }
  }
  return intValue;
}
