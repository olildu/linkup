import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:linkup/api/api_calls.dart';
import 'package:linkup/api/common_functions.dart';
import 'package:linkup/pages/about_me_edit_page/edit_page.dart';
import 'package:linkup/pages/basics_edit_page/edit_gender_page.dart';
import 'package:linkup/pages/basics_edit_page/edit_hometown_page.dart';
import 'package:linkup/pages/basics_edit_page/edit_stream_page.dart';
import 'package:linkup/pages/basics_edit_page/edit_year_page.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linkup/ImageHashing/decode.dart';
import 'package:octo_image/octo_image.dart';

TextEditingController controller = TextEditingController();
List<dynamic> userImages = [];
List<dynamic> userImagesHash = [];

Widget titleAndSubtitle(String title, String subTitle, {Color? titleColor, Color? subTitleColor}) {
  Color defaultSubtitleColor = const Color(0xFF6C6C6C);
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
      const SizedBox(height: 10,),
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

Widget _loadImage(dynamic imagePath, int index) {
  // Load Image Using OctoImage and Use blurhash to transistion
  return OctoImage(
    image: CachedNetworkImageProvider(imagePath),
    placeholderBuilder: OctoBlurHashFix.placeHolder(userImagesHash[index]),
    fit: BoxFit.cover,
  );
}

Map<String, dynamic> images = {
  "image0": null,
  "image1": null,
  "image2": null,
  "image3": null,
};

class PhotosWidget extends StatefulWidget {
  const PhotosWidget({super.key});

  @override
  PhotosWidgetState createState() => PhotosWidgetState();
}

class PhotosWidgetState extends State<PhotosWidget> {    

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void deleteImagefromStorage(String filePath) async{
    Reference storageReference = FirebaseStorage.instance.ref().child("/UserImages/${UserValues.uid}/$filePath");
    storageReference.delete();
  }

  void remapValuesDB() async{
    var storageReference = FirebaseDatabase.instance.ref().child("/UsersMetaData/${UserValues.uid}/ImageDetails");

    Map<String, String> dataToUpdate = {};

    for(int x = 0; x < userImages.length; x++){
      dataToUpdate[x.toString()] = userImages[x];
    }

    storageReference.set(dataToUpdate.cast<String, Object?>());
  }

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
                  CupertinoButton(child: Text("Delete Photo", style: GoogleFonts.poppins(color: const Color.fromARGB(255, 218, 37, 24), fontSize: 20),), onPressed: (){
                    setState(() {
                      for (int i = index; i < 4 - index; i++) {
                        images["image$i"] = images["image${i + 1}"];
                      }
                      // Set the last image slot to null
                      images["image3"] = null;
                      deleteImagefromStorage(userImages[index]);

                      userImages.removeAt(index);
                      remapValuesDB();

                      Navigator.of(context).pop();
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

  Future<void> fetchUserData() async{

    final imageDetailsref = FirebaseDatabase.instance.ref().child("/UsersMetaData/${UserValues.uid}/ImageDetails");

    imageDetailsref.onChildAdded.listen((event) { // Listen for child elements added also this will load every time profile page is visited
      dynamic imageData = event.snapshot.value; // Ready the data for seperating as imageName and imageHash

      if (!userImages.contains(imageData["imageName"])) {
        setState(() async{
          userImages.add(imageData["imageName"]); // Add names to list so that getImagesFromStorage() can loop through this and get downloadURL
          userImagesHash.add(imageData["imageHash"]); // Add imageHashes so that the blurHash can work on images
          await getImagesFromStorage(); // Get downloadURLs by looping userImages
        });
      }
    });
  }

  Future<void> getImagesFromStorage() async {
    int counter = 0;

    for (dynamic imagePath in userImages) {
      // Download URL time saved here by not needing to retrieve it everyTime
      String downloadURL = "https://firebasestorage.googleapis.com/v0/b/mujdating.appspot.com/o/UserImages%2F${UserValues.uid}%2F$imagePath?alt=media&token";
      setState(() {
        images["image$counter"] = downloadURL;
      });
      counter++;
    }
  }

  Future<void> _pickImage(ImageSource source, int imageIndex) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source, imageQuality: 50);

    if (pickedImage != null) {
      setState(() {
        // Find the first available slot for the new image
        for (int i = 0; i < 4; i++) {
          if (images["image$i"] == null) {
            images["image$i"] = File(pickedImage.path);
            break;
          }
        }
      });

      Map<String, String> data = {};
      String md5Hash = await CommonFunction().returnmd5Hash(File(pickedImage.path));
      data[pickedImage.path] = md5Hash;

      await FirebaseCalls.updateImageValuesinDatabase(data);
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
                        color: const Color.fromARGB(255, 175, 175, 175),
                        radius: const Radius.circular(12),
                        padding: const EdgeInsets.all(4),
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
                                ? _loadImage(images["image0"]!, 0)
                                : const Icon(Icons.add_rounded, size: 50, color: Colors.white),
                            ),
                          ),
                      )
                      ),
                  ),
                  const SizedBox(width: 10),
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
                        color: const Color.fromARGB(255, 175, 175, 175),
                        radius: const Radius.circular(12),
                        padding: const EdgeInsets.all(4),
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
                            ? _loadImage(images["image1"]!, 1)
                            : const Icon(Icons.add_rounded, size: 50, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
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
                        radius: const Radius.circular(12),
                        color: const Color.fromARGB(255, 175, 175, 175),
                        padding: const EdgeInsets.all(4),
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
                            ? _loadImage(images["image2"]!, 2)
                            : const Icon(Icons.add_rounded, size: 50, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
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
                        radius: const Radius.circular(12),
                        padding: const EdgeInsets.all(4),
                        color: const Color.fromARGB(255, 175, 175, 175),
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
                            ? _loadImage(images["image3"]!, 3)
                            : const Icon(Icons.add_rounded, size: 50, color: Colors.white),
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
            hintStyle: GoogleFonts.poppins(color: const Color(0xFFC5C5C5)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 35, 35, 35),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFC5C5C5)),
            ),
          ),
        ),
      
      ),
    ],
  );
}

Widget childrenBuilder1(IconData type, String childText, data) {
  return Container(
    color: Colors.transparent,
    child: Row(
      children: [
        Icon(
          type,
          size: 27,
        ),
        const SizedBox(width: 14),
        Text(
          childText,
          style: GoogleFonts.poppins(
            fontSize: 16,
          ),
        ),
        const Spacer(),
        Text(
          data.toString(),
          style: GoogleFonts.poppins(
            fontSize: 16,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1, // You can adjust this value to allow more lines if needed
        ),
        const Icon(
          Icons.chevron_right_rounded,
          size: 30,
        ),
      ],
    ),
  );
}

Widget moreAboutMeChildren(BuildContext context, Map userData) {
  return Column(
    children: [
      GestureDetector(onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EditAboutMe(counter: 1, progressTrackerValue: 40, userData: userData)),
      );
      }, child: childrenBuilder1(Icons.straighten, "Height", userData["height"] ?? "Add")),
      const SizedBox(height: 25),
  
      GestureDetector(onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EditAboutMe(counter: 2, progressTrackerValue: 80, userData: userData)),
      );
      }, child: childrenBuilder1(Icons.wine_bar_rounded, "Drinking", userData["drinkingStatus"] ?? "Add")),
      const SizedBox(height: 25),
  
      GestureDetector(onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EditAboutMe(counter: 4, progressTrackerValue: 120, userData: userData)),
      );
      }, child: childrenBuilder1(Icons.smoking_rooms_rounded, "Smoking", userData["smokingStatus"] ?? "Add")),
      const SizedBox(height: 25),
  
      GestureDetector(onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EditAboutMe(counter: 5, progressTrackerValue: 160, userData: userData)),
      );
      }, child: childrenBuilder1(Icons.search_rounded, "Looking For", userData["datingStatus"] ?? "Add")),
      const SizedBox(height: 25),
  
  
      GestureDetector(onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EditAboutMe(counter: 8, progressTrackerValue: 200, userData: userData)),
      );
      }, child: childrenBuilder1(Icons.synagogue_rounded, "Religion", userData["religionStatus"] ?? "Add")),
    ],
  );
}

Widget myBasicsChildren(BuildContext context, userData) {
  return Column(
    children: [
      _buildListItem(context, Icons.school_outlined, "Stream", "Stream", Icons.school_outlined, userData?["stream"]?? "Add"),
      const SizedBox(height: 25),
      _buildListItem(context, Icons.calendar_month_outlined, "Year", "Year", Icons.calendar_month_outlined, userData?["year"]?? "Add"),
      const SizedBox(height: 25),
      _buildListItem(context, Icons.transgender_outlined, "Gender", "Gender", Icons.transgender_outlined, userData?["gender"]?? "Add"),
      const SizedBox(height: 25),
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
        print(data);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditGender(title: title, type: type, data: data)),
        );
      }
    },
    child: childrenBuilder1(icon, label, data),
  );
}
