import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Widget appTitle() {
  return Image.asset(
    'assets/logo/welcome_logo.png',
    width: 200,
    height: 100,
  );
}

Widget imagesLoveHands(){
  return Align(
    alignment: Alignment.center,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.rotate(
          angle: -0.2,
          child: Image.asset(
            'lib/images/love.png',
            width: 100,
            height: 100,
          ),
        ),
        const SizedBox(width: 20),
        Transform.translate(
          offset: const Offset(0, 60),
          child: Transform.rotate(
            angle: 0.2,
            child: Image.asset(
              'lib/images/hand.png',
              width: 100,
              height: 100,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget appSlogan(){
  return Align(
    alignment: Alignment.centerLeft,
    child: Text(
      "DATING FOR\nMUJ STUDENTS",
      textAlign: TextAlign.left,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 30,
        shadows: [
          const Shadow(offset: Offset(-1, 1), color: Color(0xFF000000)),
          const Shadow(offset: Offset(-2, 2), color: Color(0xFF000000)),
          const Shadow(offset: Offset(-3, 3), color: Color(0xFF000000)),
          const Shadow(offset: Offset(-4, 4), color: Color(0xFF000000)),
          const Shadow(offset: Offset(-5, 5), color: Color(0xFF000000)),
          const Shadow(offset: Offset(-6, 6), color: Color(0xFF000000)),
          const Shadow(offset: Offset(-7, 7), color: Color(0xFF000000)),
          const Shadow(offset: Offset(-8, 8), color: Color(0xFF000000)),
        ],
      ),
    ),
  );
}

Widget infotext(){
  return Align(
    alignment: Alignment.centerLeft,
    child: Text(
      "Join the campus dating community",
      textAlign: TextAlign.left,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 14,
      ),
    ),
  );
}

Widget joinTodayButton(BuildContext context){
  return GestureDetector(
    onTap: () async {
      final provider = OAuthProvider("microsoft.com");

      if (kIsWeb) {
        try {
          await FirebaseAuth.instance.signInWithRedirect(provider);

        } catch (e) {
          print('Error signing in with redirect: $e');
        }
      } else {
        try {
          await FirebaseAuth.instance.signInWithProvider(provider);

        } catch (e) {
          print('Error signing in with popup: $e');
        }
      }
    },
    child: Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(10),
        width: 180,
        decoration: const BoxDecoration(
          color: Color(0xFFFFC629),
        ),
        child: const Center(
          child: Text(
            "JOIN TODAY",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
      ),
    ),
  );
}

Widget termsAndConditions(){
  return RichText(
    textAlign: TextAlign.center,
    text: const TextSpan(
      style: TextStyle(
        color: Color.fromARGB(255, 223, 223, 223),
        fontSize: 12,
      ),
      children: [
        TextSpan(
          text: "By signing up, you agree to our ",
        ),
        TextSpan(
          text: "Terms and Conditions",
          style: TextStyle(
            decoration: TextDecoration.underline,
          ),
        ),
        TextSpan(
          text: " & ",
        ),
        TextSpan(
          text: "Privacy Policy.",
          style: TextStyle(
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    ),
    );
}