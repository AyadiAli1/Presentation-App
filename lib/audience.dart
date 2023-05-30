import 'dart:io';
import 'presenter.dart';
import 'main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AudiencePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audience Page'),
      ),
      body: Center(
        child: Text('You logged in as an audience'),
      ),
    );
  }
}
