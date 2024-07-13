import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:linkup/api/api_calls.dart';
import 'package:linkup/api/common_functions.dart';
import 'package:linkup/UI/pages/about_me_edit_page/edit_page.dart';
import 'package:linkup/UI/pages/basics_edit_page/edit_gender_page.dart';
import 'package:linkup/UI/pages/basics_edit_page/edit_hometown_page.dart';
import 'package:linkup/UI/pages/basics_edit_page/edit_stream_page.dart';
import 'package:linkup/UI/pages/basics_edit_page/edit_year_page.dart';
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
  if (imagePath.runtimeType == String){
    return OctoImage( // Load Image Using OctoImage and Use blurhash to transistion
      image: CachedNetworkImageProvider(imagePath),
      placeholderBuilder: OctoBlurHashFix.placeHolder(userImagesHash[index], 60),
      fit: BoxFit.cover,
    );
  }
  else{
    return Image.file(
      imagePath,
      fit: BoxFit.cover,
    );
  }
}

Map<dynamic, dynamic> images = {
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
    fetchUserImage();
  }

  void deleteImagefromStorage(String filePath) async{
    Reference storageReference = FirebaseStorage.instance.ref().child("/UserImages/${UserValues.uid}/$filePath");
    storageReference.delete();
  }

  void remapValuesDBAfterDeletion() async{
    var storageReference = FirebaseDatabase.instance.ref().child("/UsersMetaData/${UserValues.uid}/ImageDetails");

    Map<String, dynamic> dataToUpdate = {};

    for(int x = 0; x < userImages.length; x++){
      dataToUpdate[x.toString()] = {
        "imageName" : userImages[x],
        "imageHash" : userImagesHash[x]
      };
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
                      
                      // Delete from storage
                      deleteImagefromStorage(userImages[index]);

                      // Remove at indexes 
                      userImages.removeAt(index);
                      userImagesHash.removeAt(index);

                      // Remap values in DataBase
                      remapValuesDBAfterDeletion();

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

  Future<void> fetchUserImage() async{
    final imageDetailsref = FirebaseDatabase.instance.ref().child("/UsersMetaData/${UserValues.uid}/ImageDetails");

    imageDetailsref.onChildAdded.listen((event) { // Listen for child elements added also this will load every time profile page is visited
      dynamic imageData = event.snapshot.value; // Ready the data for seperating as imageName and imageHash

      if (!userImages.contains(imageData["imageName"])) { // Checking if already that image is loaded to prevent same image from loading again
          userImages.add(imageData["imageName"]); // Add names to list so that getImagesFromStorage() can loop through this and get downloadURL
          userImagesHash.add(imageData["imageHash"]); // Add imageHashes so that the blurHash can work on images
          getImagesFromStorage(); // Get downloadURLs by looping userImages
      }
    });
  }

  Future<void> getImagesFromStorage() async {
    int counter = 0;
    for (dynamic imagePath in userImages) {
      // Download URL time saved here by not needing to retrieve it everytime 
      String downloadURL = "https://firebasestorage.googleapis.com/v0/b/mujdating.appspot.com/o/UserImages%2F${UserValues.uid}%2F$imagePath?alt=media&token";
      setState(() {
        images["image$counter"] = downloadURL; // Add to the map
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

      String md5Hash = await CommonFunction().returnmd5Hash(File(pickedImage.path));
      File file = File(pickedImage.path); 
      String imageName = md5Hash;
      int orderNumber = userImages.length;

      await FirebaseCalls.uploadImage(file, imageName); // First uploadImage

      Map dataToUpload = { // Data to pass to the server
        "key": UserValues.cookieValue,
        "uid": UserValues.uid,
        "orderNumber": orderNumber,
        "imageName": imageName,
        "url": "https://firebasestorage.googleapis.com/v0/b/mujdating.appspot.com/o/UserImages%2F${UserValues.uid}%2F$imageName?alt=media&token"
      };

      await ApiCalls.mapValuesHashDatabase(dataToUpload); // Then hash the blurHash and save to the database with hashMappings
    }
  }

  Widget buildImageContainer(BuildContext context, int imageIndex, int flex) {
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: () async {
          if (images["image$imageIndex"] != null) {
            confirmationPopup(context, imageIndex);
          } else {
            await _pickImage(ImageSource.gallery, imageIndex);
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
              child: images["image$imageIndex"] != null
                  ? _loadImage(images["image$imageIndex"]!, imageIndex)
                  : const Icon(Icons.add_rounded, size: 50, color: Colors.white),
            ),
          ),
        ),
      ),
    );
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
                  buildImageContainer(context, 0, 16),
                  const SizedBox(width: 10),
                  buildImageContainer(context, 1, 10),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Row(
                children: [
                  buildImageContainer(context, 2, 10),
                  const SizedBox(width: 10),
                  buildImageContainer(context, 3, 16),
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
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 150),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              data.toString(),
              style: GoogleFonts.poppins(
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditGender(title: title, type: type, data: data)),
        );
      }
    },
    child: childrenBuilder1(icon, label, data),
  );
}
