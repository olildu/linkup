import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:linkup/domain/entities/match_candidate_entity.dart';
import 'package:linkup/logic/bloc/matches/matches_bloc.dart';
import 'package:linkup/presentation/components/candidate_detail_scroll/candidate_detail_builder.dart';
import 'package:linkup/presentation/constants/colors.dart';
import 'package:linkup/presentation/theme/app_spacing.dart';
import 'package:linkup/presentation/utils/swipe_limit_alert.dart';

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
            List<MatchCandidateEntity> candidates = state.matches;
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
              onSwipe: (previousIndex, currentIndex, direction) async {
                if (direction == CardSwiperDirection.right && state.swipesRemaining == 0) {
                  showSwipeLimitAlert(context);
                  return false;
                }

                context.read<MatchesBloc>().add(SwipeProfileEvent(likedId: candidates[previousIndex].id, direction: direction, previousIndex: previousIndex));

                scrollController.jumpTo(0);
                return true;
              },
              cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).colorScheme.surface,
                        Theme.of(context).colorScheme.surface,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: CandidateDetailBuilder(key: PageStorageKey('candidate_${candidates[index].id}'), candidate: candidates[index]),
                  ),
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
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100.sp, color: AppColors.whiteText),
          Gap(AppSpacing.xl3.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppColors.whiteText),
          ),
          Gap(AppSpacing.xl3.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.whiteText.withValues(alpha: 0.9)),
          ),
          Gap(AppSpacing.xl5.h),
        ],
      ),
    );
  }
}
