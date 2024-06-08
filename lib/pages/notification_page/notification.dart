import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:linkup/api/api_calls.dart';
import 'package:linkup/pages/chat_sub_pages/chat_details.dart';

FirebaseMessaging messaging = FirebaseMessaging.instance;

class notificationHandlers {
  void setupFirebaseMessaging(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data["type"] == "messageNotification"){
        // Reorder userList in chatPage here
        

        if ((message.data["uidFor"] != userValues.notificationHandlers["currentMatchUID"]) && (userValues.notificationHandlers["allowNotification"])){

          InAppNotification.show(
            child: NotificationBody(
              title: message.notification!.title.toString(),
              userProfileURL: "https://firebasestorage.googleapis.com/v0/b/mujdating.appspot.com/o/UserImages%2F${message.data["uidFor"]}%2F${userValues.chatUsers[message.data["uidFor"]]["imageLink"]}?alt=media&token",
            ),
            context: context,
            duration: Duration(milliseconds: 6000),

            onTap: () {
              String matchUID = message.data["uidFor"];
              String path = userValues.chatUsers[matchUID]["uniquePath"];
              String name = userValues.chatUsers[matchUID]["userName"];
              String downloadURL = "https://firebasestorage.googleapis.com/v0/b/mujdating.appspot.com/o/UserImages%2F${matchUID}%2F${userValues.chatUsers[matchUID]["imageLink"]}?alt=media&token";
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailsPage(path: path, appBarTitle: name, imageUrl: downloadURL, matchUID: matchUID,),
                ),
              );
            }
          );
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      // Handle message tap event
    });
  }
}


class NotificationBody extends StatelessWidget {
  final String title;
  final double minHeight;
  final String userProfileURL;

  NotificationBody({
    Key? key,
    this.title = "",
    this.minHeight = 0.0,
    required this.userProfileURL
  }) : super(key: key);

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
                            imageUrl: userProfileURL,
                            fit: BoxFit.cover,
                            width: 35,
                            placeholder: (context, url) => Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondaryContainer,)),
                            height: 35,
                          ),
                        ),

                        SizedBox(width: 10),
                        
                        // Message from the notification
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.poppins(),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),

                        SizedBox(width: 20), // Adjust space between text and icon if needed
                        
                        // Decoration Icon : (>) 
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.background,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Icon(Icons.chevron_right_rounded),
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
