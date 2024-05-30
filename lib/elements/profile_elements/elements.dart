import 'package:cached_network_image/cached_network_image.dart';
import 'package:demo/api/api_calls.dart';
import 'package:demo/pages/about_me_edit_page/edit_page.dart';
import 'package:demo/pages/basics_edit_page/edit_gender_page.dart';
import 'package:demo/pages/basics_edit_page/edit_hometown_page.dart';
import 'package:demo/pages/basics_edit_page/edit_stream_page.dart';
import 'package:demo/pages/basics_edit_page/edit_year_page.dart';
import 'package:demo/pages/main_pages/profile_page.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

TextEditingController controller = TextEditingController();


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



class PhotosWidget extends StatefulWidget {
  final dynamic imageData;

  const PhotosWidget({super.key, required this.imageData});

  @override
  _PhotosWidgetState createState() => _PhotosWidgetState();
}

class _PhotosWidgetState extends State<PhotosWidget> {
  Map<String, String?> images = {
    "image0": null,
    "image1": null,
    "image2": null,
    "image3": null,
  };

  Future confirmationPopup(BuildContext context, int index){
    return showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: CupertinoPopupSurface(
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white
              ),
              child: Column(
                children: [
                  CupertinoButton(child: Text("Delete Photo", style: GoogleFonts.poppins(color: Color.fromARGB(255, 218, 37, 24), fontSize: 20),), onPressed: (){
                    setState(() {
                      switch (index) {
                        case 0:
                          for (int x = 0; x < 4; x++){
                            images["image$x"] = images["image${x+1}"];
                          }
                          images["image3"] = null;
                          Navigator.of(context).pop();
                          break;
                        case 1:
                          for (int x = 1; x < 3; x++){
                            images["image$x"] = images["image${x+1}"];
                          }
                          images["image3"] = null;
                          Navigator.of(context).pop();
                          break;
                        case 2:
                          for (int x = 2; x < 3; x++){
                            images["image$x"] = images["image${x+1}"];
                          }
                          images["image3"] = null;
                          Navigator.of(context).pop();
                          break;
                        case 3:
                          for (int x = 3; x < 1; x++){
                            images["image$x"] = images["image${x+1}"];
                          }
                          images["image3"] = null;
                          Navigator.of(context).pop();
                          break;
                        default:
                          break;
                      }
                    });
                  }),
                  CupertinoButton(child: Text("Dismiss", style: GoogleFonts.poppins(color: Colors.black, fontSize: 20),), onPressed: (){
                    Navigator.of(context).pop();
                  }),
                ],
              )),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    initializeImages();
  }

  void initializeImages() async {
    int imageLength = 0; // Length of images Map
    int imageDataLength = 0; // Length of uservalues.imageData

    // Removing null from both and getting an length

    images.forEach((key, value) {
      if (value != null) {
        imageLength++;
      }
    });

    for (dynamic x in widget.imageData){
      if (x != null){
        imageDataLength++;
      }
    }

    // Compare them if they are different then we need to reload them 
    
    if (imageLength != imageDataLength){
      print(images.length);
      await getImagesFromStorage();
    }
  }

Future<void> getImagesFromStorage() async {
  int counter = 0;

  for (dynamic imagePath in widget.imageData) {
    // Some values are null for some reason those get skipped
    if (imagePath == null) continue;

    // Download URL time saved here by not needing to retrieve it everyTime
    String downloadURL = "https://firebasestorage.googleapis.com/v0/b/mujdating.appspot.com/o/UserImages%2F${userValues.uid}%2F$imagePath?alt=media&token";

      setState(() {
        images["image$counter"] = downloadURL;
      });

    counter++;
  }
}
  Future<void> _pickImage(ImageSource source, int imageIndex) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);
    if (pickedImage != null) {
      // setState(() {
      //   switch (imageIndex) {
      //     case 0:
      //       images["image0"] = File(pickedImage.path);
      //       break;
      //     case 1:
      //       if (images["image0"] == null){
      //         images["image0"] = File(pickedImage.path);
      //       }
      //       else{
      //         images["image1"] = File(pickedImage.path);
      //       }
      //       break;
      //     case 2:
      //       if (images["image0"] == null){
      //         images["image0"] = File(pickedImage.path);
      //         break;
      //       }
      //       if (images["image1"] == null){
      //         images["image1"] = File(pickedImage.path);
      //         break;
      //       }
      //       else{
      //         images["image2"] = File(pickedImage.path);
      //         break;
      //       }
      //     case 3:
      //       if (images["image0"] == null){
      //         images["image0"] = File(pickedImage.path);
      //         break;
      //       }
      //       if (images["image1"] == null){
      //         images["image1"] = File(pickedImage.path);
      //         break;
      //       }
      //       if (images["image2"] == null){
      //         images["image2"] = File(pickedImage.path);
      //         break;
      //       }
      //       else{
      //         images["image3"] = File(pickedImage.path);
      //         break;
      //       }
      //     default:
      //       break;
      //   }
      // });
      
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    child: GestureDetector(
                      onTap: () async {
                        if (images["image0"] != null) {
                          confirmationPopup(context, 0);
                        }
                        else{
                          await _pickImage(ImageSource.gallery, 0);
                        }
                      },
                      child: DottedBorder(
                        borderType: BorderType.RRect,
                        color: Color.fromARGB(255, 175, 175, 175),
                        radius: Radius.circular(12),
                        padding: EdgeInsets.all(4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: images["image0"] != null
                                ? CachedNetworkImage(
                                    imageUrl: images["image0"]!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                  )
                                : Icon(Icons.add_rounded, size: 50, color: Colors.white),

                            ),
                          ),
                      )
                      ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 10,
                    child: GestureDetector(
                      onTap: () async {
                        if (images["image1"] != null) {
                          confirmationPopup(context, 1);
                        }
                        else{
                          await _pickImage(ImageSource.gallery, 1);
                        }
                      },
                      child: DottedBorder(
                        borderType: BorderType.RRect,
                        color: Color.fromARGB(255, 175, 175, 175),
                        radius: Radius.circular(12),
                        padding: EdgeInsets.all(4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          child: images["image1"] != null
                            ? CachedNetworkImage(
                              imageUrl: images["image1"]!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                            )
                            : Icon(Icons.add_rounded, size: 50, color: Colors.white,),
                          ),
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
                    child: GestureDetector(
                      onTap: () async {
                        if (images["image2"] != null) {
                          confirmationPopup(context, 2);
                        }
                        else{
                          await _pickImage(ImageSource.gallery, 2);
                        }
                      },
                      child: DottedBorder(
                        borderType: BorderType.RRect,
                        radius: Radius.circular(12),
                        color: Color.fromARGB(255, 175, 175, 175),
                        padding: EdgeInsets.all(4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          child: images["image2"] != null
                            ? CachedNetworkImage(
                              imageUrl: images["image2"]!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                            )
                            : Icon(Icons.add_rounded, size: 50, color: Colors.white,),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 16,
                    child: GestureDetector(
                      onTap: () async {
                        if (images["image3"] != null) {
                          confirmationPopup(context, 3);
                        }
                        else{
                          await _pickImage(ImageSource.gallery, 3);
                        }
                      },
                      child: DottedBorder(
                        borderType: BorderType.RRect,
                        radius: Radius.circular(12),
                        padding: EdgeInsets.all(4),
                        color: Color.fromARGB(255, 175, 175, 175),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          child: images["image3"] != null
                            ? CachedNetworkImage(
                              imageUrl: images["image3"]!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                            )
                            : Icon(Icons.add_rounded, size: 50, color: Colors.white,),
                          ),
                        ),
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
}

Widget aboutMeContainer({String initialValue = '', required VoidCallback onPressed, required VoidCallback onFocusLost}) {
  FocusNode focusNode = FocusNode();
  controller.text = initialValue;
  focusNode.addListener(() {
    if (focusNode.hasFocus) {
      onPressed();
    }
    else{
      onFocusLost();
    }
  });

  return Column(
    children: [
      SingleChildScrollView(
        child: TextField(
          focusNode: focusNode, // Assign focus node to the TextField
          controller: controller,
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
  return Row(
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
  );
}

Widget childrenBuilder1(IconData type, String childText, data) {
  return Row(
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
  );
}

Widget moreAboutMeChildren(BuildContext context, userData) {
  return Column(
    children: [
      GestureDetector(onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => edit_about_me(counter: 1, progressTrackerValue: 40, userData: userData)),
      );
      }, child: childrenBuilder1(Icons.straighten, "Height", userData?["height"] ?? "Add")),
      SizedBox(height: 25),
  
      GestureDetector(onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => edit_about_me(counter: 2, progressTrackerValue: 80, userData: userData)),
      );
      }, child: childrenBuilder1(Icons.wine_bar_rounded, "Drinking", userData?["drinkingStatus"] ?? "Add")),
      SizedBox(height: 25),
  
      GestureDetector(onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => edit_about_me(counter: 4, progressTrackerValue: 120, userData: userData)),
      );
      }, child: childrenBuilder1(Icons.smoking_rooms_rounded, "Smoking", userData?["smokingStatus"] ?? "Add")),
      SizedBox(height: 25),
  
      GestureDetector(onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => edit_about_me(counter: 5, progressTrackerValue: 160, userData: userData)),
      );
      }, child: childrenBuilder1(Icons.search_rounded, "Looking For", userData?["datingStatus"] ?? "Add")),
      SizedBox(height: 25),
  
  
      GestureDetector(onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => edit_about_me(counter: 8, progressTrackerValue: 200, userData: userData)),
      );
      }, child: childrenBuilder1(Icons.synagogue_rounded, "Religion", userData?["religionStatus"] ?? "Add")),
    ],
  );
}

Widget myBasicsChildren(BuildContext context, userData) {
  return Column(
    children: [
      _buildListItem(context, Icons.school_outlined, "Stream", "Stream", Icons.school_outlined, userData?["stream"]?? "Add"),
      SizedBox(height: 25),
      _buildListItem(context, Icons.calendar_month_outlined, "Year", "Year", Icons.calendar_month_outlined, userData?["year"]?? "Add"),
      SizedBox(height: 25),
      _buildListItem(context, Icons.transgender_outlined, "Gender", "Gender", Icons.transgender_outlined, userData?["gender"]?? "Add"),
      SizedBox(height: 25),
      _buildListItem(context, Icons.home_outlined, "Hometown", "Hometown", Icons.home_outlined, userData?["fromPlace"]?? "Add"),
    ],
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
          // MaterialPageRoute(builder: (context) => EditGender()),
        );
      }
    },
    child: childrenBuilder1(icon, label, data),
  );
}
