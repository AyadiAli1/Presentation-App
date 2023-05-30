import 'dart:io';
import 'presenter.dart';
import 'package:flutter/material.dart';
import 'audience.dart';

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
                              builder: (context) => PresenterPage()),
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
                              builder: (context) => AudiencePage()),
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
