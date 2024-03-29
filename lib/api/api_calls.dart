import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class userValues{
  static String uid = FirebaseAuth.instance.currentUser!.uid;
  static String ?cookieValue;
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
    try {
      String jsonData = jsonEncode(data);

      var headers = {
        'Content-Type': 'application/json',
      };

      var response = await http.post(
        Uri.parse('https://65b14d8f6e5d33340fe7.appwrite.global/'),
        headers: headers,
        body: jsonData,
      );
      
      print(response.body);
      return response.body;
    } catch (e) {
      // Return the exception message
      return 'Exception occurred: $e';
    }
  }

static GetMatchedUsers() async {
  DatabaseReference userMatchRef = FirebaseDatabase.instance.ref('/UserMatchingDetails/${userValues.uid}/MatchUID/');
  userMatchRef.onValue.listen((DatabaseEvent event) {
    final data = event.snapshot.value as Map<dynamic, dynamic>?; 
    data?.forEach((key, value) async {
      print(key);

      final storageRef = FirebaseStorage.instance.ref();
      final imageUrl = await storageRef.child("/UserImages/QCIG6YCw9HcpLyf5jYHc1yewq6k1/imageIK9dbCof").getDownloadURL();
    });
  });
}

}
