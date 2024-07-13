import "dart:io";
import 'package:crypto/crypto.dart';
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:linkup/UI/colors/colors.dart";
import "package:linkup/UI/pages/appbar_pages/filters_page.dart";
import "package:linkup/UI/pages/appbar_pages/settings_page.dart";
import "package:linkup/UI/pages/providers/theme_provider.dart";
import "package:provider/provider.dart";
import "package:shared_preferences/shared_preferences.dart";
import "api_calls.dart";

class CommonFunction {
  void manageNotificationHandlers(int index) {
    if (index != 2) {
      UserValues.notificationHandlers["allowNotification"] = true;
      UserValues.notificationHandlers["currentMatchUID"] = null;
    }
    // On chatPage notificationBanner should be displayed
    else {
      UserValues.notificationHandlers["allowNotification"] = false;
      UserValues.notificationHandlers["currentMatchUID"] = null;
    }
  }

  void getDarkThemeValue(BuildContext context) async {
    if (UserValues.didFunctionRun) {
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? localDarkThemeValue = await prefs.getBool('darkTheme');

    if (localDarkThemeValue != null) {
      UserValues.darkTheme = localDarkThemeValue;
      if (localDarkThemeValue == false) {
        Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
      }
      UserValues.didFunctionRun = true;
    }
  }

  void manageUserVisited(int bottomBarIndex) {
    if (bottomBarIndex != 1) {
      for (int x = 0; x < UserValues.userVisited; x++) {
        UserValues.matchUserDetails.removeAt(0);
        UserValues.candidateImageURLs.removeAt(0);
      }
      UserValues.userVisited = 0;
    }
  }

  Future<String> returnmd5Hash(File value) async {
    var bytes = await value.readAsBytes();
    var digest = md5.convert(bytes);
    var imageName = "image${digest.toString()}.jpg";

    return imageName;
  }

  void navigateActionButtons(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Settings()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Filter()),
        );
        break;
    }
  }
}

Widget buildNoInternetWidget(BuildContext context, String width) {
  double offsetMiddle =
      (115 / 392.72727272727275) * MediaQuery.of(context).size.width;
  return Transform.translate(
    offset: Offset(offsetMiddle, 0),
    child: Container(
      padding: const EdgeInsets.all(0),
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
              color: ReuseableColors.primaryColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              'You are offline',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );
}

/*
  Over ride http settings to accept self signed certificates (only ours), 
  1. From getApiKeys we get the SSL Keys
  2. Do all necessary alteractions 
  3. Verify if same 
      - If same then return true
      - Else return false and the program will exit
*/

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        String newCert = cert.pem.replaceAll("\n", "");
        if (UserValues.SSL_CERT == newCert) {
          return true;
        } else {
          return false;
        }
      };
  }
}
