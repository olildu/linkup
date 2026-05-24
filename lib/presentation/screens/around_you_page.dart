import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:linkup/data/models/match_candidate_model.dart';
import 'package:linkup/logic/bloc/matches/matches_bloc.dart';
import 'package:linkup/presentation/components/candidate_detail_scroll/candidate_detail_builder.dart';
import 'package:linkup/presentation/constants/colors.dart';

class AroundYouPage extends StatefulWidget {
  const AroundYouPage({super.key});

  @override
  State<AroundYouPage> createState() => _AroundYouPageState();
}

class _AroundYouPageState extends State<AroundYouPage> {
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.circular(20.r),
      child: BlocBuilder<MatchesBloc, MatchesState>(
        builder: (context, state) {
          if (state is MatchesLoaded) {
            List<MatchCandidateModel> candidates = state.matches;
            // If there are no candidates, show the empty message instead of
            // building the CardSwiper (the CardSwiper asserts when cardsCount
            // is 0 or when numberOfCardsDisplayed > cardsCount).
            if (candidates.isEmpty) {
              return _buildMessage(icon: Icons.tune_rounded, title: "You’ve seen all nearby profiles", subtitle: "Come back later or adjust your search preferences.");
            }

            final displayCount = candidates.length < 3 ? candidates.length : 3;

            return CardSwiper(
              padding: EdgeInsets.zero,
              numberOfCardsDisplayed: displayCount,
              cardsCount: candidates.length,
              isLoop: false,
              allowedSwipeDirection: AllowedSwipeDirection.symmetric(vertical: false, horizontal: true),
              onSwipe: (previousIndex, currentIndex, direction) {
                context.read<MatchesBloc>().add(SwipeProfileEvent(likedId: candidates[previousIndex].id, direction: direction, previousIndex: previousIndex));

                scrollController.jumpTo(0);
                return true;
              },
              cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    double availableHeight = constraints.maxHeight;
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            if (Theme.of(context).brightness == Brightness.light) ...[
                              Colors.white,
                              const Color.fromARGB(255, 215, 215, 215),
                            ] else ...[
                              Colors.black,
                              const Color.fromARGB(255, 0, 0, 0),
                            ],
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: CandidateDetailBuilder(key: PageStorageKey('candidate_${candidates[index].id}'), availableHeight: availableHeight, candidate: candidates[index]),
                      ),
                    );
                  },
                );
              },
            );
          } else if (state is MatchesError) {
            return _buildMessage(icon: Icons.search_off_rounded, title: "There’s been a glitch in the matrix", subtitle: "Things should be up and running soon. Please try restarting the app.");
          } else if (state is MatchesEmpty) {
            return _buildMessage(icon: Icons.tune_rounded, title: "You’ve seen all nearby profiles", subtitle: "Come back later or adjust your search preferences.");
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildMessage({IconData? icon, required String title, required String subtitle}) {
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100.sp, color: AppColors.whiteTextColor),
          Gap(30.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 30.sp, color: AppColors.whiteTextColor),
          ),
          Gap(30.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.sp, color: AppColors.whiteTextColor.withValues(alpha: 0.9)),
          ),
          Gap(100.h),
        ],
      ),
    );
  }
}
