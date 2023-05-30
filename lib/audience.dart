//import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

//import 'presenter.dart';
//import 'main.dart';
import 'package:flutter/material.dart';

class AudiencePage extends StatefulWidget {
  @override
  _AudiencePageState createState() => _AudiencePageState();
}

class _AudiencePageState extends State<AudiencePage> {
  final Future<FirebaseApp> _fApp = Firebase.initializeApp();
  String current_slide = "";

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
    DatabaseReference _slideref =
        FirebaseDatabase.instance.ref().child('slide_nummer');

    _slideref.onValue.listen(
      (event) {
        setState(() {
          current_slide = event.snapshot.value.toString();
        });
      },
    );
    return Container(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Center(
          child: Text(
        "Aktuelle Foliennummer : $current_slide",
        style: TextStyle(fontSize: 20),
      )),
    ]));
  }
}
