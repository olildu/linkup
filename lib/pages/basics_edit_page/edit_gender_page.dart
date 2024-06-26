// ignore_for_file: prefer_const_constructors

import 'package:linkup/api/api_calls.dart';
import 'package:linkup/elements/profile_elements/elements.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditGender extends StatefulWidget {
  final String title;
  final IconData type;
  final String data;

  const EditGender({
    super.key,
    required this.title,
    required this.type,
    required this.data,
  });

  @override
  State<EditGender> createState() => EditGenderState();
}

class GenderBuilder extends StatelessWidget {
  final String gender;
  final int index;
  final bool isSelected;
  final Function(int) onTap;

  const GenderBuilder({
    super.key,
    required this.gender,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Text(
              gender,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                fontSize: 20,
              ),
            ),
            const Spacer(),
            isSelected
                ? Icon(
                    Icons.radio_button_checked,
                  )
                : Icon(
                    Icons.radio_button_unchecked_rounded,
                  ),
          ],
        ),
      ),
    );
  }
}

class EditGenderState extends State<EditGender> {
  List<bool> isSelected = [false, false, false];

  @override
  void initState() {
    super.initState();
    initialValueSetter();
  }

  void initialValueSetter(){
    switch (widget.data){
      case "Female":
        tapThen(0);
        break;
      case "Male":
        tapThen(1);
        break;
      case "Others":
        tapThen(2);
        break;
    }
  }

  void tapThen(int index) {
    setState(() {
      for (int i = 0; i < isSelected.length; i++) {
        isSelected[i] = i == index;
      }
    });
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleAndSubtitle("Choose your ${widget.title.toLowerCase()}", "Select your ${widget.title.toLowerCase()}"),
            const SizedBox(height: 30),
            SizedBox(
              height: 400,
              child: Column(
                children: [
                  GenderBuilder(
                    gender: "Female",
                    index: 0,
                    isSelected: isSelected[0],
                    onTap: tapThen,
                  ),
                  SizedBox(height: 20),
                  GenderBuilder(
                    gender: "Male",
                    index: 1,
                    isSelected: isSelected[1],
                    onTap: tapThen,
                  ),
                  SizedBox(height: 20),
                  GenderBuilder(
                    gender: "Others",
                    index: 2,
                    isSelected: isSelected[2],
                    onTap: tapThen,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// class EditGender extends StatefulWidget {
//   const EditGender({super.key});

//   @override
//   State<EditGender> createState() => _EditGenderState();
// }

// class _EditGenderState extends State<EditGender> {
//   List <bool> _selections = List.generate(3, (_) => false);

//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle(
//         statusBarColor: Theme.of(context).colorScheme.surface,
//         statusBarIconBrightness: UserValues.darkTheme ? Brightness.light : Brightness.dark,
//         systemNavigationBarColor: Theme.of(context).colorScheme.surface,
//       ),
//       child: Scaffold(
//         backgroundColor: Theme.of(context).colorScheme.surface,
//         appBar: AppBar(
//           title: Text("Edit Gender"),
//           // title: Text(widget.title),
//           centerTitle: true,
//           leading: GestureDetector(
//             onTap: () {
//               Navigator.of(context).pop();
//             },
//             child: const Icon(Icons.arrow_back_ios_new_rounded),
//           ),
//           actions: <Widget>[
//             IconButton(
//               icon: const Icon(Icons.search),
//               onPressed: () {
//                 // showSearch(context: context, delegate: CustomSearchDelegate());
//               },
//             ),
//           ],
//         ),
//         body: Center(
//           child: ToggleButtons(
//             direction: Axis.vertical,
//             isSelected: _selections,
//             onPressed: (int index){
//               setState(() {
//                 for (int i = 0; i < _selections.length; i++) {
//                   _selections[i] = i == index;
//                 }
//               });
//             },
//             children:  [
//               Container(
//                 padding: EdgeInsets.all(8),
//                 child: Text("Women", style: GoogleFonts.poppins(fontSize: 20),)
//               ),
//               Text("Men"),
//               Text("Others"),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
