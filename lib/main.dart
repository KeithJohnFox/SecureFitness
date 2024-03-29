import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/home.dart';

void main() {
  runApp(MyApp());
  Firestore.instance.settings(timestampsInSnapshotsEnabled: true).then((_) {
    print("Timestamps enabled in snapshots\n");
  }, onError: (_) {
    print("Error enabling timestamps in snapshots\n");
  });
  
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SecureFitness',
      debugShowCheckedModeBanner: false,
      //BACKGROUND COLOR THEME FOR LOGIN
      theme: ThemeData(primaryColor: Colors.deepPurple, accentColor: Colors.teal
      ),
      home: Home(),
    );
  }
}
