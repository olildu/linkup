import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:linkup/elements/chat_elements/elements.dart";
import "package:linkup/pages/main_pages/candidate_page.dart";

class DesktopUI extends StatefulWidget {
  const DesktopUI({super.key});

  @override
  State<DesktopUI> createState() => DesktopUIState();
}

class DesktopUIState extends State<DesktopUI> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // User Chats, Matches and Profile Section
          Expanded(
            flex: 1, 
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: const Border(
                  right: BorderSide(color: Color.fromARGB(255, 44, 44, 44), width: 1),
                  
                )

              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20,),

                  // User profile and name
                  userProfileAndName(),

                  const SizedBox(height: 20,),

                  // Title stating matchQue
                  matchQueTitle(),

                  
                  // Matched users will appear here
                  matchedUsers(),
                  const SizedBox(height: 20,),

                  // Chats Title (The smaller version)
                  chatTitle(),
              
                  // Chat Widgets
                  const SizedBox(height: 5),
                  
                  const ChatDetailsChatPage(),
                ],  
              ),
            )
          ),

          // MatchUser Pages, Profile Detailed Page
          Expanded(
            flex: 4, 
            child: Container(
              padding: const EdgeInsets.all(10),
              color: Theme.of(context).colorScheme.surface,
              child: Center(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: 400,
                  child: const CandidatePage()
                ),
              ),
            )
          ),
        ],
      ),
    );
  }
}

Widget userProfileAndName() {
  return Row(
    children: [
      ClipOval(
        child: Container(
          width: 50,
          height: 50,
          color: Colors.black,
        ),
      ),
      const SizedBox(width: 10),
      Text(
        'Ebi',
        style: 
          GoogleFonts.poppins(fontSize: 18)
      ),
    ],
  );
}
