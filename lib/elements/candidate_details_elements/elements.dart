// ignore_for_file: unused_element, prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:demo/elements/candidate_page_elements/elements.dart';
import 'package:flutter/material.dart';

const Color tagColor = Color(0xFF0C192C);

class ProfileImageFullscreen extends StatelessWidget {
  final String imagePath;

  const ProfileImageFullscreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 200.0),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fitWidth,
                  image: CachedNetworkImageProvider(imagePath),
                )
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CandidateDetailsContainer extends StatefulWidget {
  final ScrollController scrollController;
  final Map<String, dynamic> candidateDetails;
  final List userImageList;

  const CandidateDetailsContainer({required this.scrollController, required this.candidateDetails, required this.userImageList});

  @override
  State<CandidateDetailsContainer> createState() => _CandidateDetailsContainerState();
}


class _CandidateDetailsContainerState extends State<CandidateDetailsContainer> {
  late List<dynamic> filteredList;

  @override
  void initState() {
    super.initState();
    List<dynamic> dataList = widget.candidateDetails["ImageDetails"];
    filteredList = dataList.where((element) => element != null).toList();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: widget.scrollController,
          child: Container(
            color: Color(0xFF193046),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Candidate First Image
                buildProfileImage(context, widget.candidateDetails, widget.userImageList[0], constraints.maxHeight),

                // Candidate About Me and Tags
                aboutMeAndTags(candidateDetails: widget.candidateDetails["UserDetails"]),

                // Remaining Candidate Images
                nextImages(context, widget.candidateDetails, constraints.maxHeight, secondImageURL: widget.userImageList[1],),

                if (filteredList.length == 3)
                  nextImages(context, widget.candidateDetails, constraints.maxHeight, thirdImageURL: widget.userImageList[2]),

                if (filteredList.length == 4)
                  nextImages(context, widget.candidateDetails, constraints.maxHeight, thirdImageURL: widget.userImageList[3]),

                // From Candidate Details or Stream Detail
                fromOrStreamDetails(candidateDetails: widget.candidateDetails["UserDetails"]),
              ],
            ),
          ),
        );
      },
    );
  }
}

