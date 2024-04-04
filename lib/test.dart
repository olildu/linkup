import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Call showCupertinoModalPopup within the build method
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () {
            showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) {
                // Calculate the height of the popup surface
                double popupHeight = MediaQuery.of(context).size.height * 0.8;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CupertinoPopupSurface(
                    child: SizedBox(
                      height: popupHeight,
                      child: SingleChildScrollView(
                        child: Container(
                          color: Colors.white,
                          child: Column(
                            children: [
                              Container(
                                height: 700,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD9D9D9),
                                ),
                                child: const Center(
                                  child: Icon(Icons.image, size: 70),
                                ),
                              ),
                              SizedBox(height: 200),
                              Container(
                                height: 700,
                                color: const Color(0xFFD9D9D9),
                                child: const Center(
                                  child: Icon(Icons.image, size: 70),
                                ),
                              ),
                              SizedBox(height: 200),
                              Container(
                                height: 200,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(20),
                                    bottomLeft: Radius.circular(20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
