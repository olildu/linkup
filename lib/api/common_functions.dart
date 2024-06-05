import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:shared_preferences/shared_preferences.dart";
import "../pages/providers/provider.dart";
import "api_calls.dart";

class commonFunction {
  void manageNotificationHandlers(int index){
    if (index != 2){
      userValues.notificationHandlers["allowNotification"] = true;
      userValues.notificationHandlers["currentMatchUID"] = null;
    }
    // On chatPage notificationBanner should be displayed 
    else{
      userValues.notificationHandlers["allowNotification"] = false;
      userValues.notificationHandlers["currentMatchUID"] = null;
    }
    print(userValues.notificationHandlers);
  }

  void getDarkThemeValue(BuildContext context) async{
    if (userValues.didFunctionRun){
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? localDarkThemeValue = await prefs.getBool('darkTheme');

    if (localDarkThemeValue != null){
      userValues.darkTheme = localDarkThemeValue;
      if (localDarkThemeValue == false){
        Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
      }
      userValues.didFunctionRun = true;
    }
  }

  void manageUserVisited(int bottomBarIndex){
    if (bottomBarIndex != 1){
      for (int x = 0; x < userValues.userVisited; x++){
        userValues.matchUserDetails.removeAt(0);
        userValues.userImageURLs.removeAt(0);
      }
      userValues.userVisited = 0;
    }
  }
}