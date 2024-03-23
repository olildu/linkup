import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:demo/elements/candidate_details_elements/elements.dart';

class CandidatePage extends StatefulWidget {
  const CandidatePage({super.key});

  @override
  State<CandidatePage> createState() => _CandidatePageState();
}

class _CandidatePageState extends State<CandidatePage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ClipRRect( 
          borderRadius: BorderRadius.circular(10),
          child: CardSwiper(
              padding: EdgeInsets.zero,
              cardsCount: 2,
              backCardOffset: const Offset(0, 0),
              allowedSwipeDirection: const AllowedSwipeDirection.only(right: true, left: true),
              onSwipe: (previousIndex, currentIndex, direction) {
                _scrollController.jumpTo(0.0);
                return true;
              },
              cardBuilder: (context, index, x, y) {
                return CandidateDetailsContainer(scrollController: _scrollController);
              },
            ),
        ),
    ));
  }
}
