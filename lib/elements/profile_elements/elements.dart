// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:demo/pages/about_me_edit_page/edit_page.dart';
import 'package:demo/pages/basics_edit_page/edit_gender_page.dart';
import 'package:demo/pages/basics_edit_page/edit_hometown_page.dart';
import 'package:demo/pages/basics_edit_page/edit_stream_page.dart';
import 'package:demo/pages/basics_edit_page/edit_year_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

Widget titleAndSubtitle(String title, String subTitle, {Color? titleColor, Color? subTitleColor}) {
  Color defaultSubtitleColor = Color(0xFF6C6C6C);
  if (subTitleColor != null){
    defaultSubtitleColor = subTitleColor;
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 20,
          color: titleColor,
        ),
      ),
      SizedBox(height: 10,),
      Text(
        subTitle,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: defaultSubtitleColor,
        ),
      ),
    ],
  );
}

Widget photos() {
  String ImagePath;
  return SizedBox(
    height: 450,
    child: FractionallySizedBox(
      heightFactor: 1,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(Icons.photo, size: 50),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 10,
                  child: GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final pickedImage =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (pickedImage != null) {
                        ImagePath = pickedImage.path;
                        print('Image picked from gallery: ${pickedImage.path}');
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(10),

                      ),
                      child: Center(
                        child: Icon(Icons.add_rounded,
                            size: 50, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(Icons.add_rounded,
                          size: 50, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(Icons.add_rounded,
                          size: 50, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget aboutMeContainer({String initialValue = '', required VoidCallback onPressed}) {
  TextEditingController _controller = TextEditingController(text: initialValue);
  return Column(
    children: [
      SingleChildScrollView(
        child: TextField(
          onTap: onPressed,
          controller: _controller,
          maxLines: 3,
          keyboardType: TextInputType.multiline,
          maxLength: 300,
          style: GoogleFonts.poppins(),
          decoration: InputDecoration(
            hintText: 'Something about you....',
            hintStyle: GoogleFonts.poppins(color: Color(0xFFC5C5C5)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: const Color.fromARGB(255, 35, 35, 35),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color(0xFFC5C5C5)),
            ),
          ),
        ),
      ),
    ],
  );
}

Widget childrenBuilder(IconData type, String childText) {
  return Container(
    child: Row(
      children: [
        Icon(
          type,
          size: 27,
        ),
        SizedBox(width: 14),
        Text(
          childText,
          style: GoogleFonts.poppins(
            fontSize: 16,
          ),
        ),
        Spacer(),
        Text(
          "Add",
          style: GoogleFonts.poppins(
            fontSize: 16,
          ),
        ),
        Icon(
          Icons.chevron_right_rounded,
          size: 30,
        ),
      ],
    ),
  );
}

Widget childrenBuilder1(IconData type, String childText, data) {
  return Container(
    child: Row(
      children: [
        Icon(
          type,
          size: 27,
        ),
        SizedBox(width: 14),
        Text(
          childText,
          style: GoogleFonts.poppins(
            fontSize: 16,
          ),
        ),
        Spacer(),
        Text(
          data.toString(),
          style: GoogleFonts.poppins(
            fontSize: 16,
          ),
        ),
        Icon(
          Icons.chevron_right_rounded,
          size: 30,
        ),
      ],
    ),
  );
}

Widget moreAboutMeChildren(BuildContext context, userData) {
  return Container(
    child: Column(
      children: [
        GestureDetector(onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => edit_about_me(counter: 1, progressTrackerValue: 40,)),
        );
        }, child: childrenBuilder1(Icons.straighten, "Height", userData?["height"] ?? "Add")),
        SizedBox(height: 25),

        GestureDetector(onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => edit_about_me(counter: 2, progressTrackerValue: 80)),
        );
        }, child: childrenBuilder1(Icons.wine_bar_rounded, "Drinking", userData?["drinkingStatus"] ?? "Add")),
        SizedBox(height: 25),

        GestureDetector(onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => edit_about_me(counter: 4, progressTrackerValue: 120)),
        );
        }, child: childrenBuilder1(Icons.smoking_rooms_rounded, "Smoking", userData?["smokingStatus"] ?? "Add")),
        SizedBox(height: 25),

        GestureDetector(onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => edit_about_me(counter: 5, progressTrackerValue: 160)),
        );
        }, child: childrenBuilder1(Icons.search_rounded, "Looking For", userData?["datingStatus"] ?? "Add")),
        SizedBox(height: 25),


        GestureDetector(onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => edit_about_me(counter: 8, progressTrackerValue: 200)),
        );
        }, child: childrenBuilder1(Icons.synagogue_rounded, "Religion", userData?["religionStatus"] ?? "Add")),
      ],
    ),
  );
}

Widget myBasicsChildren(BuildContext context, userData) {
  return Container(
    child: Column(
      children: [
        _buildListItem(context, Icons.school_outlined, "Stream", "Stream", Icons.school_outlined, userData?["stream"]?? "Add"),
        SizedBox(height: 25),
        _buildListItem(context, Icons.calendar_month_outlined, "Year", "Year", Icons.calendar_month_outlined, userData?["year"]?? "Add"),
        SizedBox(height: 25),
        _buildListItem(context, Icons.transgender_outlined, "Gender", "Gender", Icons.transgender_outlined, userData?["gender"]?? "Add"),
        SizedBox(height: 25),
        _buildListItem(context, Icons.home_outlined, "Hometown", "Hometown", Icons.home_outlined, userData?["fromPlace"]?? "Add"),
      ],
    ),
  );
}

Widget _buildListItem(BuildContext context, IconData icon, String label, String title, IconData type, data) {
  return GestureDetector(
    onTap: () {
      if (title == "Stream") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditStream(title: title, type: type, data: data, )),
        );
      }
      if (title == "Year") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditYear(title: title, type: type, data: data.toString(),)),
        );
      }
      if (title == "Hometown") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditHometown(title: title, type: type, data: data)),
        );
      }
      if (title == "Gender") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditGender(title: title, type: type, data: data)),
        );
      }
    },
    child: childrenBuilder1(icon, label, data),
  );
}
