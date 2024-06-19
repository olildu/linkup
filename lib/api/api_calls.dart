// ignore_for_file: non_constant_identifier_names, await_only_futures

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserValues extends ChangeNotifier{
  // Essential tokens for current user
  static String uid = FirebaseAuth.instance.currentUser!.uid;
  static String ?cookieValue;
  static late String ?fCMToken; // We store fCMToken here so that we can call after getting key
  static List userImageURLs = [];
  static bool darkTheme = true; // This bool is gonna keep the track of the theme
  static bool snoozeEnabled = false; // This bool will track if snoozeMode is on or off
  static bool limitReached = false; // This bool will keep track if the user has finished his like quota
  static bool didFunctionRun = false;
  
  // Values for candidatePage
  static int userVisited = 0;
  static int counterCandidatesAvailable = 0;
  
  // Values for matchUsers in chatPage
  static Map <String, dynamic> matchUserData = {}; // Map for MatchedUsers used in popUpMenu to see the full details of the user
  static Map<String, dynamic> matchedUsers = {}; // UserData for matchedUsers in chatPage 
  
  // Values for current UserData
  static Map userData = {}; // Current UserDetails will be store here (Change always listening in here)
  static List userImageData = List.empty(growable: true); // Current UserImageDetails here

  // Values for chatUserData in chatPage
  static Map chatUserImages = {};
  static Map<String, dynamic> chatUsers = {}; // UserData for matchedUsers in chatPage 

  // Values that keep track of userChats
  static bool shouldLoad = true; // Keeps track of shouldLoad when user sends a message and accordingly (Avoid message coming twice in the UI)

  // Values that keep track of usersNotification
  static Map <String, dynamic> notificationHandlers = {
    "allowNotification" : true, // Initially set to true as it loads to candidate page on start
    "currentMatchUID" : null
  };
  static int notificationCount = 0;

  static List<String> usersNotificationCounter = [];


  static bool goToMainPage = false;
  static List<dynamic> userMatchCandidates = []; 

  static List<Map<String, dynamic>> matchUserDetails = [];
}

class ApiCalls {
  static Future<String> fetchCookieDoggie(bool newUser) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (newUser == false){
        FirebaseCalls().fetchUserData();
      }
      else{
        await prefs.remove('cookieValue');
      }

      String? localCookieValue = prefs.getString('cookieValue');

      // If already cookie is there in localStorage just return that
      if (localCookieValue != null){
        UserValues.cookieValue = localCookieValue;
        
        // Upload to server 
        ApiCalls.uploadfCMToken(UserValues.fCMToken);
        return localCookieValue;
      }

      var data = {
        'uid': UserValues.uid,
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

      UserValues.cookieValue = response.body;

      // Save cookie to localStorage to avoid fetching cookie repeatedly
      await prefs.setString('cookieValue', response.body);
      
      // Upload to server 
      ApiCalls.uploadfCMToken(UserValues.fCMToken);
      
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
      "key" : UserValues.cookieValue,
      "uid" : UserValues.uid,
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
    
    UserValues.matchUserData[data["chatUID"]] = jsonDecode(jsonDecode(response.body));

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
      "uid": UserValues.uid,
      "key": UserValues.cookieValue,
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
      UserValues.snoozeEnabled = true;
      return [];
    }

    // If none of the users timeStamp has crossed the required 18 hours then show message "Out of likes"
    if (response.body == '{"likesOver":true}' || response.body == '[]') {
      // Return response.body as a List<Map<String, dynamic>>
      UserValues.limitReached = true;
      return [];
    }

    List<dynamic> jsonList = jsonDecode(response.body);

    // Convert each element of jsonList to Map<String, dynamic>
    List<Map<String, dynamic>> matchCandidates = jsonList.map((e) => e as Map<String, dynamic>).toList();

    UserValues.userMatchCandidates = matchCandidates;
    UserValues.snoozeEnabled = false;

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
      "uid": UserValues.uid,
      "key": UserValues.cookieValue,
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

    UserValues.snoozeEnabled = true;

    return response.body;
  }

  static disableSnoozeMode() async{
    Map<String, dynamic> data = {
      "uid": UserValues.uid,
      "key": UserValues.cookieValue,
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

    UserValues.snoozeEnabled = false;

    return response.body;
  }
}

class FirebaseCalls with ChangeNotifier {
  
  static Future<void> getImagesFromStorage(key, Map<String, dynamic> matchUserData) async {
    final storageRef = FirebaseStorage.instance.ref().child("/UserImages/$key/");
    final result = await storageRef.listAll();
    var items = result.items;
    int counter  = 1;
    for (var item in items) {
      String downloadURL = "https://firebasestorage.googleapis.com/v0/b/mujdating.appspot.com/o/UserImages%2F$key%2F${item.name}?alt=media&token";
      matchUserData[key]["userImage$counter"] = downloadURL;
      counter++;
    }
  }

  // Function for getting pfp of chatUsers in chatPage
  static Future<String> getImagesFromStorageForChats(key) async {
    // Check if there is image in Map     
    if (UserValues.chatUserImages[key] == null){
      // If not get downloadURLs 
      final storageRef = FirebaseStorage.instance.ref().child("/UserImages/$key/");
      final result = await storageRef.listAll();
      var item = result.items[0];
      String downloadURL = "https://firebasestorage.googleapis.com/v0/b/mujdating.appspot.com/o/UserImages%2F$key%2F${item.name}?alt=media&token";
      
      // Finally save the downloadURL
      UserValues.chatUserImages[key] = downloadURL;
    }

    // Return the saved downloadURL
    return UserValues.chatUserImages[key];
  }

  // Function for getting all the matched users and then appending them to the map UserValues.matchUserData 
  static getMatchedUsers() async {
    DatabaseReference userMatchRef = FirebaseDatabase.instance.ref('/UserMatchingDetails/${UserValues.uid}/MatchUID/');

    var event = await userMatchRef.once();

    final data = await event.snapshot.value as Map<dynamic, dynamic>?; 
    Map<String, dynamic> localMatchUserData = {}; // Create a local variable to store data

    data?.forEach((key, value) async {
      // Create empty map for storing them locally in this function
      localMatchUserData[key] = {}; // Key is uid of user
      
      localMatchUserData[key]["userName"] = value["matchName"];   //   Path and name are 
      localMatchUserData[key]["uniquePath"] = value["uniquePath"]; //         saved as (Path, Name)
      
      await FirebaseCalls.getImagesFromStorage(key, localMatchUserData);
    });

    UserValues.matchedUsers = localMatchUserData;
    return localMatchUserData;
  }

  static getChatUsers() async {
    final chatUserRef = FirebaseDatabase.instance.ref('/UserMatchingDetails/${UserValues.uid}/ChatUID/');

    var event = await chatUserRef.once();

    final data = await event.snapshot.value as Map<dynamic, dynamic>?; 
    Map<String, dynamic> localMatchUserData = {}; // Create a local variable to store data

    data?.forEach((key, value) async {
      // Create empty map for storing them locally in this function
      localMatchUserData[key] = {}; // Key is uid of user

      localMatchUserData[key]["uniquePath"] = value["uniquePath"]; 
      localMatchUserData[key]["userName"] = value["matchName"];  
      localMatchUserData[key]["imageLink"] = value["imageName"]; 

      UserValues.chatUserImages[key] = localMatchUserData[key]["imageLink"];
      
    });

    UserValues.chatUsers = localMatchUserData;
    return localMatchUserData;
  }

  static updateImageValuesinDatabase(Map data) async { // Change or add name to database when imageUploaded for hashing
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('/UsersMetaData/${UserValues.uid}/ImageDetails').get();

    List imageNamesList = data.values.toList();
    List fileNamesList = data.keys.toList();

    if (snapshot.exists) {
      List imageNames = snapshot.value as List;
      await uploadImage(File(fileNamesList[0]), imageNamesList[0]);
      await ref.child('/UsersMetaData/${UserValues.uid}/ImageDetails').update({imageNames.length.toString() : imageNamesList[0]});
    }
    else{
      for (int x = 0; x < imageNamesList.length; x++){
        await uploadImage(fileNamesList[x], imageNamesList[x]);
        ref.child('/UsersMetaData/${UserValues.uid}/ImageDetails').update({x.toString() : imageNamesList[x]});
      }
    }
  }

  static uploadImage(File imageFile, String imageName) async {
    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child("/UserImages/${UserValues.uid}/$imageName");
    await imageRef.putFile(imageFile);  
  }

  static Future<String> getCandidateImages(String uid, String imageName) async {
    try {
      String userImageURL = "https://firebasestorage.googleapis.com/v0/b/mujdating.appspot.com/o/UserImages%2F$uid%2F$imageName?alt=media&token";
      return userImageURL;
    } catch (e) { // Temporary solution because I was lazy to load some users images
      return ''; // Return an empty string as a default value
    }
  }

  Future<void> fetchUserData() async{
    final ref = FirebaseDatabase.instance.ref().child("/UsersMetaData/${UserValues.uid}/");
    
    final snapshot = await ref.once();
    final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

    UserValues.userData = data?["UserDetails"];
    UserValues.userImageData = data?["ImageDetails"] as List;

    UserValues.matchedUsers = await FirebaseCalls.getMatchedUsers();
    UserValues.chatUsers = await FirebaseCalls.getChatUsers();
  }

  // Instance for Firebase Messaging

  // Intialization of notifications
  Future<void> initNotifications() async {
    final FBMessaging = FirebaseMessaging.instance;
    
    // Request permission from user
    await FBMessaging.requestPermission();

    // Fetch FCM Token
    UserValues.fCMToken = await FBMessaging.getToken();
  }
}