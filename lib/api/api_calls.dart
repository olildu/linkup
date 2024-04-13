// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';


class userValues{
  static String uid = FirebaseAuth.instance.currentUser!.uid;
  static String ?cookieValue;
  static Map matchUserData = {};  
  static Map matchUserDataNew = {};  
}

class pathAndName {
  static Map pathAndNameData = {};
}

class flagChecker{
  static bool matchQueFetched = false;
}

class ApiCalls {
  static Future<String> fetchCookieDoggie() async {
    try {
      var data = {
        'uid': userValues.uid,
        'type': 'CookieCreation',
      };

      String jsonData = jsonEncode(data);

      var headers = {
        'Content-Type': 'application/json',
      };

      var response = await http.post(
        Uri.parse('https://65b14d8f6e5d33340fe7.appwrite.global/'),
        headers: headers,
        body: jsonData,
      );

      userValues.cookieValue = response.body;
      return response.body;
    } catch (e) {
      return 'Exception occurred: $e';
    }
  }

  static uploadUserData(data) async {
      String jsonData = jsonEncode(data);
      print(jsonData);
      var headers = {
        'Content-Type': 'application/json',
      };

      var response = await http.post(
        Uri.parse('https://65b14d8f6e5d33340fe7.appwrite.global/'),
        headers: headers,
        body: jsonData,
      );
      
      return response.body;
  }

  static uploadUserTagData(data) async {
      String jsonData = jsonEncode(data);
      print(jsonData);
      var headers = {
        'Content-Type': 'application/json',
      };

      var response = await http.post(
        Uri.parse('https://65b14d8f6e5d33340fe7.appwrite.global/'),
        headers: headers,
        body: jsonData,
      );
      
      return response.body;
  }

  static getChatUserData(data) async {
    String jsonData = jsonEncode(data);

    var headers = {
      'Content-Type': 'application/json',
    };

    var response = await http.post(
      Uri.parse('https://65ca1944cb067d7512f6.appwrite.global/'),
      headers: headers,
      body: jsonData,
    );
    userValues.matchUserDataNew[data["chatUID"]] = jsonDecode(jsonDecode(response.body));
    return response.body;
}

  static writeChatContent(data) async {
      String jsonData = jsonEncode(data);

      var headers = {
        'Content-Type': 'application/json',
      };

      var response = await http.post(
        Uri.parse('https://65ca1944cb067d7512f6.appwrite.global/'),
        headers: headers,
        body: jsonData,
      );
      return response.body;
  }

}

class firebaseCalls {
  static Future<void> getImagesFromStorage(key, Map<String, dynamic> matchUserData, Function onComplete) async {
    final storageRef = FirebaseStorage.instance.ref().child("/UserImages/$key/");
    final result = await storageRef.listAll();
    var items = result.items;
    int counter  = 1;
    for (var item in items) {
      String downloadURL = await FirebaseStorage.instance
          .ref()
          .child(item.fullPath)
          .getDownloadURL();
      matchUserData[key]["userImage$counter"] = downloadURL;
      counter++;
    }
    onComplete(); // Call the callback function to notify task completion
  }

  static Future<String> getImagesFromStorageForChats(key, {Map<String, dynamic>? matchUserData, Function? onComplete}) async {
    final storageRef = FirebaseStorage.instance.ref().child("/UserImages/$key/");
    final result = await storageRef.listAll();
    var items = result.items[0];
    String downloadURL = await FirebaseStorage.instance.ref().child(items.fullPath).getDownloadURL();
    print(downloadURL);
    return downloadURL;
  }

  static Future<Map<String, dynamic>?> GetMatchedUsers() async {
    DatabaseReference userMatchRef = FirebaseDatabase.instance.ref('/UserMatchingDetails/${userValues.uid}/MatchUID/');
    
    int tasksCount = 0;

    Completer<Map<String, dynamic>> completer = Completer<Map<String, dynamic>>();

    userMatchRef.onValue.listen((DatabaseEvent event) {
      flagChecker.matchQueFetched = false;
      final data = event.snapshot.value as Map<dynamic, dynamic>?; 
      Map<String, dynamic> matchUserData = {}; // Create a local variable to store data
      
      void checkTasksCompletion() {
        tasksCount--;
        if (tasksCount == 0) {
          flagChecker.matchQueFetched = true;
          completer.complete(matchUserData); 
        }
      }

      data?.forEach((key, value) async {
        matchUserData[key] = {};
        value.forEach((uniqueIDandName, names) {
          pathAndName.pathAndNameData[key] = names.split(",")[1];
          pathAndName.pathAndNameData[key] = names.split(",")[0];
          matchUserData[key]["userName"] = names.split(",")[1];
          matchUserData[key]["uniquePath"] = names.split(",")[0];
        });
        tasksCount++;
        await firebaseCalls.getImagesFromStorage(key, matchUserData, checkTasksCompletion);

      });
    });

    return completer.future;
  }

  static uploadImageStep(){}
}