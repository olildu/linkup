import 'dart:async';

import 'package:demo/api/api_calls.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseCalls {
  dynamic data;

  Future<void> getUserData() async {
    final ref = FirebaseDatabase.instance.ref().child("/UsersMetaData/${userValues.uid}/UserDetails");
    final snapshot = await ref.get();

    if (snapshot.exists) {
      data = snapshot.value; // Store retrieved data in the data variable
    } else {
      data = null;
    }
  }

  static Future<Map<dynamic, dynamic>> getChatList() async {
    DatabaseReference userMatchRef = FirebaseDatabase.instance.ref('/UserMatchingDetails/${userValues.uid}/ChatUID/');

    StreamController<Map<dynamic, dynamic>> controller = StreamController();

    userMatchRef.onValue.listen((event) {
      Map<dynamic, dynamic>? chatList = event.snapshot.value as Map<dynamic, dynamic>?;

      controller.add(chatList ?? {});
    });

    return controller.stream.first;
  }



}

