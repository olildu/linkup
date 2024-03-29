// ignore_for_file: prefer_const_constructors

import 'package:demo/api/firebase_calls.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  State<Test> createState() => _TestState();

  static data() {}
}

class _TestState extends State<Test> {
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dynamic data = FirebaseCalls().data;
    return Scaffold(
      body: Center(
        child: Text(data["name"]),
      ),
    );
  }
}