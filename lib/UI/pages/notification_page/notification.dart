// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:linkup/api/api_calls.dart';
import 'package:linkup/UI/pages/chat_sub_pages/chat_details.dart';
import 'package:shake_flutter/shake_flutter.dart';

FirebaseMessaging messaging = FirebaseMessaging.instance;

class NotificationHandlers {
  Function()? onNotificationReceived;

  void registerCallback(Function() callback) {
    onNotificationReceived = callback;
  }

  void setupFirebaseMessaging(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data["type"] == "messageNotification") {
        String notificationUID = message.data["uidFor"];

        // Check wether on chatPage or wether on the notification recieved user page
        if ((notificationUID != UserValues.notificationHandlers["currentMatchUID"]) && (UserValues.notificationHandlers["allowNotification"])) {

          if (!UserValues.usersNotificationCounter.contains(notificationUID)) { // See if user is there in the list or not then only increment
            // Notification dots to add up here        
            UserValues.notificationCount++; // Increment when notification is received
            UserValues.usersNotificationCounter.add(notificationUID);
            onNotificationReceived!();
          }

          // Show the notification animation
          InAppNotification.show( 
            child: NotificationBody(
              title: message.notification!.title.toString(),
              userProfileURL: "https://firebasestorage.googleapis.com/v0/b/mujdating.appspot.com/o/UserImages%2F${message.data["uidFor"]}%2F${UserValues.chatUsers[message.data["uidFor"]]["imageLink"]}?alt=media&token",
            ),
            context: context,
            duration: const Duration(milliseconds: 3000), // Duration for the animation
            onTap: () {
              String path = UserValues.chatUsers[notificationUID]["uniquePath"];
              String name = UserValues.chatUsers[notificationUID]["userName"];
              String downloadURL = "https://firebasestorage.googleapis.com/v0/b/mujdating.appspot.com/o/UserImages%2F${notificationUID}%2F${UserValues.chatUsers[notificationUID]["imageLink"]}?alt=media&token";

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailsPage(path: path, matchName: name, imageUrl: downloadURL, matchUID: notificationUID),
                ),
              );
            }
          );

          // Call the callback to notify the parent widget
        }
      }
      else{
        Shake.showChatNotification(message.data);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data["type"] == "messageNotification") {
        String notificationUID = message.data["uidFor"];
        
        String path = UserValues.chatUsers[notificationUID]["uniquePath"];
        String name = UserValues.chatUsers[notificationUID]["userName"];
        String downloadURL = "https://firebasestorage.googleapis.com/v0/b/mujdating.appspot.com/o/UserImages%2F$notificationUID%2F${UserValues.chatUsers[notificationUID]["imageLink"]}?alt=media&token";

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailsPage(path: path, matchName: name, imageUrl: downloadURL, matchUID: notificationUID),
          ),
        );
      }
      // Handle message tap event
    });
  }
}

class NotificationBody extends StatelessWidget {
  final String title;
  final double minHeight;
  final String userProfileURL;

  const NotificationBody({
    super.key,
    this.title = "",
    this.minHeight = 0.0,
    required this.userProfileURL
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 12,
                  blurRadius: 16,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // User logo
                        ClipOval(
                          child: CachedNetworkImage(
                            imageUrl:  userProfileURL,
                            fit: BoxFit.cover,
                            width: 35,
                            placeholder: (context, url) => Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondaryContainer,)),
                            height: 35,
                          ),
                        ),

                        const SizedBox(width: 10),
                        
                        // Message from the notification
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.poppins(),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),

                        const SizedBox(width: 20), // Adjust space between text and icon if needed
                        
                        // Decoration Icon : (>) 
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Icon(Icons.chevron_right_rounded),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
