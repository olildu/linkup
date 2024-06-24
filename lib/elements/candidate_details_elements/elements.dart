// ignore_for_file: unused_element, prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:linkup/elements/candidate_page_elements/elements.dart';
import 'package:flutter/material.dart';

const Color tagColor = Color(0xFF0C192C);

class ProfileImageFullscreen extends StatelessWidget {
  final String imagePath;

  const ProfileImageFullscreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: CachedNetworkImageProvider(imagePath),
              )
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
  final List userImageHash;

  const CandidateDetailsContainer({super.key, required this.scrollController, required this.candidateDetails, required this.userImageList, required this.userImageHash});

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
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Candidate First Image
                buildProfileImage(context, widget.candidateDetails, widget.userImageList[0], widget.userImageHash[0],constraints.maxHeight, constraints.maxWidth),

                SizedBox(height: 5,),

                // Candidate About Me and Tags
                aboutMeAndTags(candidateDetails: widget.candidateDetails["UserDetails"], context),

                SizedBox(height: 5,),

                // Remaining Candidate Images
                nextImages(context, widget.candidateDetails, constraints.maxHeight, widget.userImageList[1], widget.userImageHash[1]),

                if (filteredList.length == 3)
                  nextImages(context, widget.candidateDetails, constraints.maxHeight,widget.userImageList[2], widget.userImageHash[2]),

                if (filteredList.length == 4)
                  nextImages(context, widget.candidateDetails, constraints.maxHeight,widget.userImageList[3], widget.userImageHash[3]),

                // From Candidate Details or Stream Detail
              ],
            ),
          ),
        );
      },
    );
  }
}

