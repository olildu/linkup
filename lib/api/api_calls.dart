// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class userValues{
  static String uid = FirebaseAuth.instance.currentUser!.uid;
  static String ?cookieValue;
  static Map matchUserData = {};  
  static Map<String, dynamic>? matchedUsers; // UserData for matchedUsers in chatPage 
  static late String ?fCMToken; // We store fCMToken here so that we can call after getting key
  static bool goToMainPage = false;
  static bool snoozeEnabled = false; // This bool will track if snoozeMode is on or off
  static bool limitReached = false; // This bool will keep track if the user has finished his like quota
  static late List<dynamic> userMatchCandidates = []; 
  static Map userData = {}; // Current UserDetails will be store here (Change always listening in here)
  static List userImageData = []; // Current UserImageDetails here
  static List<Map<String, dynamic>> matchUserDetails = [];
  static List userImageURLs = [];
  static int userVisited = 0;
  static bool darkTheme = true; // This bool is gonna keep the track of the theme
}

class pathAndName {
  static Map pathAndNameData = {};
}

class flagChecker{
  static bool matchQueFetched = false;
}

class ApiCalls {
  static Future<String> fetchCookieDoggie() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      firebaseCalls.fetchUserData();

      String? localCookieValue = prefs.getString('cookieValue');

      // If already cookie is there in localStorage just return that
      if (localCookieValue != null){
        userValues.cookieValue = localCookieValue;
        
        // Upload to server 
        ApiCalls.uploadfCMToken(userValues.fCMToken);
        return localCookieValue;
      }

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
      
      // Save cookie to localStorage to avoid fetching cookie repeatedly
      await prefs.setString('cookieValue', response.body);
      
      // Upload to server 
      ApiCalls.uploadfCMToken(userValues.fCMToken);

      return response.body;
  }

  static uploadUserData(data) async {
      String jsonData = jsonEncode(data);
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

  // Function to upload fCMToken to the server just gives the token and key and is stored in /fCMTokens/
  static uploadfCMToken(String ?token) async {
    Map storeTokenData = {
      "key" : userValues.cookieValue,
      "uid" : userValues.uid,
      "token" : token,
      "type" : "storefCMToken"
    };

    String jsonData = jsonEncode(storeTokenData);
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
    userValues.matchUserData[data["chatUID"]] = jsonDecode(jsonDecode(response.body));
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

  static Future<List<Map<String, dynamic>>> getMatchCandidates() async {
    Map<String, dynamic> data = {
      "uid": userValues.uid,
      "key": userValues.cookieValue,
      "gender": "Female",
      'type': 'GetUIDs'
    };
    
    String jsonData = jsonEncode(data);

    var headers = {
      'Content-Type': 'application/json',
    };

    var response = await http.post(
      Uri.parse('https://65d257a08d0655ad974f.appwrite.global/'),
      headers: headers,
      body: jsonData,
    );

    // If user is in snoozeMode then code will handle here
    if (response.body == '{"snoozeEnabled":true}') {
      // Return response.body as a List<Map<String, dynamic>>
      userValues.snoozeEnabled = true;
      return [];
    }


    List<dynamic> jsonList = jsonDecode(response.body);

    // Convert each element of jsonList to Map<String, dynamic>
    List<Map<String, dynamic>> matchCandidates = jsonList.map((e) => e as Map<String, dynamic>).toList();

    userValues.userMatchCandidates = matchCandidates;
    userValues.snoozeEnabled = false;

    return matchCandidates;
  }

  static dislikeMatch(data) async{
    String jsonData = jsonEncode(data);

    var headers = {
      'Content-Type': 'application/json',
    };

    var response = await http.post(
      Uri.parse('https://65d257a08d0655ad974f.appwrite.global/'),
      headers: headers,
      body: jsonData,
    );
    
    return response.body;
  }
  
  /*When getUIDs run also check for future match possibility when swiped right, bring to device check if swipe right is done then show 
match banner */

  static swipeActionsMatch(data) async{
    String jsonData = jsonEncode(data);

    var headers = {
      'Content-Type': 'application/json',
    };

    var response = await http.post(
      Uri.parse('https://65d257a08d0655ad974f.appwrite.global/'),
      headers: headers,
      body: jsonData,
    );
    
    return response.body;
  }

  static enableSnoozeMode() async{
    Map<String, dynamic> data = {
      "uid": userValues.uid,
      "key": userValues.cookieValue,
      'type': 'snoozeUser'
    };
    
    String jsonData = jsonEncode(data);

    var headers = {
      'Content-Type': 'application/json',
    };

    var response = await http.post(
      Uri.parse('https://65d257a08d0655ad974f.appwrite.global/'),
      headers: headers,
      body: jsonData,
    );

    userValues.snoozeEnabled = true;

    return response.body;
  }

  static disableSnoozeMode() async{
    Map<String, dynamic> data = {
      "uid": userValues.uid,
      "key": userValues.cookieValue,
      'type': 'disableSnoozeUser'
    };
    
    String jsonData = jsonEncode(data);

    var headers = {
      'Content-Type': 'application/json',
    };

    var response = await http.post(
      Uri.parse('https://65d257a08d0655ad974f.appwrite.global/'),
      headers: headers,
      body: jsonData,
    );

    userValues.snoozeEnabled = false;

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
      String downloadURL = "https://firebasestorage.googleapis.com/v0/b/mujdating.appspot.com/o/UserImages%2F${key}%2F${item.name}?alt=media&token";
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
    return downloadURL;
  }

  static Future<Map<String, dynamic>?> getMatchedUsers() async {
    DatabaseReference userMatchRef = FirebaseDatabase.instance.ref('/UserMatchingDetails/${userValues.uid}/MatchUID/');
    
    int tasksCount = 0;

    Completer<Map<String, dynamic>> completer = Completer<Map<String, dynamic>>();

    userMatchRef.onValue.listen((DatabaseEvent event) async{
      flagChecker.matchQueFetched = false;
      final data = await event.snapshot.value as Map<dynamic, dynamic>?; 
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

  static updateImageValuesinDatabase(String imageName) async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('/UsersMetaData/${userValues.uid}/ImageDetails').get();
    
    if (snapshot.exists) {
      final dataList = snapshot.value as List<Object?>?;
      final List<Object?> listWithoutNulls = dataList?.where((element) => element != null).toList() ?? [];

    final Map<String, String> uploadData = {
      (listWithoutNulls.length + 1).toString(): imageName
    };

      await ref.child('/UsersMetaData/${userValues.uid}/ImageDetails').update(uploadData);
    }
  }

  static uploadImage(File imageFile) async {
    final storageRef = FirebaseStorage.instance.ref();
    final String imageName = "image${DateTime.now().millisecondsSinceEpoch}.jpg";
    final imageRef = storageRef.child("/UserImages/${userValues.uid}/$imageName");

    await imageRef.putFile(imageFile);
    await updateImageValuesinDatabase(imageName);
  }

  static Future<String> getCandidateImages(String uid, String imageName) async {
    try {
      String userImageURL = "https://firebasestorage.googleapis.com/v0/b/mujdating.appspot.com/o/UserImages%2F$uid%2F$imageName?alt=media&token";
      return userImageURL;
    } catch (e) { // Temporary solution because I was lazy to load some users images
      return ''; // Return an empty string as a default value
    }
  }

  static fetchUserData() async{
    User? user = FirebaseAuth.instance.currentUser;
    final ref = FirebaseDatabase.instance.ref().child("/UsersMetaData/${user?.uid}/");
    
    final snapshot = await ref.once();
    final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

    userValues.userData = data?["UserDetails"];
    userValues.userImageData = data?["ImageDetails"] as List;

    userValues.matchedUsers = await firebaseCalls.getMatchedUsers();

    ref.onValue.listen((event) {
      userValues.userData = (event.snapshot.value as Map<dynamic, dynamic>)["UserDetails"];
      userValues.userImageData = (event.snapshot.value as Map<dynamic, dynamic>)["ImageDetails"];
    },);


  }

  // Instance for Firebase Messaging

  // Intialization of notifications
  Future<void> initNotifications() async {
    final FBMessaging = FirebaseMessaging.instance;
    
    // Request permission from user
    await FBMessaging.requestPermission();

    // Fetch FCM Token
    userValues.fCMToken = await FBMessaging.getToken();

  }
  // Fun
}