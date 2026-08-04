import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:linkup/data/models/candidate_info_model.dart';
import 'package:linkup/domain/entities/match_candidate_entity.dart';
import 'package:linkup/logic/utils/calculate_age.dart';
import 'package:linkup/logic/utils/ordinal_helper.dart';
import 'package:linkup/presentation/components/candidate_detail_scroll/info_builder.dart';
import 'package:linkup/presentation/components/signup_page/image_builder.dart';
import 'package:linkup/presentation/screens/full_screen_image_page.dart';
import 'package:linkup/presentation/theme/app_media_ratios.dart';
import 'package:linkup/presentation/theme/app_radius.dart';
import 'package:linkup/presentation/theme/app_spacing.dart';

class CandidateDetailBuilder extends StatelessWidget {
  final double availableHeight;
  final MatchCandidateEntity candidate;

  const CandidateDetailBuilder({super.key, required this.availableHeight, required this.candidate});


  @override
  Widget build(BuildContext context) {
    final localCandidate = candidate;
    final candidateInformation = CandidateInfoModel.fromMatchCandidateEntity(localCandidate);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    List<Map> imageRest = localCandidate.photos.sublist(1);

    void showFullScreenImage(String imagePath) {
      Navigator.push(
        context,
        CupertinoPageRoute(builder: (context) => FullScreenImageScreen(imagePath: imagePath)),
      );
    }

    return Column(
      children: [
        // First image card
        Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                Map imagePath = localCandidate.photos[0];
                return ImageBuilder(
                  imageMetaData: imagePath,
                  height: availableHeight,
                  onTap: () {
                    showFullScreenImage(imagePath['url']);
                  },
                );
              },
            ),

            Positioned(
              bottom: 0.h,
              left: 0.w,
              right: 0.w,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md.w,
                  vertical: AppSpacing.md.h,
                ),
                child: Container(
                  width: MediaQuery.sizeOf(context).width - AppSpacing.xl.w,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg.w,
                    vertical: AppSpacing.lg.h,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${localCandidate.username}, ${calculateAge(localCandidate.dob)}',
                        style: textTheme.headlineLarge?.copyWith(color: colorScheme.onSurface),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),

                      Gap(AppSpacing.xs.h),

                      Row(
                        children: [
                          Icon(
                            Icons.school,
                            size: 16.sp,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),

                          Gap(AppSpacing.xs.w),

                          Expanded(
                            child: Text(
                              '${localCandidate.universityMajor} Student',
                              style: textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      Gap(AppSpacing.xs.h),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16.sp,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),

                          Gap(AppSpacing.xs.w),

                          Text(
                            '${getOrdinalSuffix(localCandidate.universityYear)} Year',
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        Gap(AppSpacing.sm.h),

        // About section card
        Container(
          width: MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          padding: EdgeInsets.symmetric(vertical: AppSpacing.lg.h, horizontal: AppSpacing.lg.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'About',
                style: textTheme.headlineMedium?.copyWith(color: colorScheme.onSurface),
              ),
              Gap(AppSpacing.md.h),
              Text(
                localCandidate.about,
                style: textTheme.bodySmall?.copyWith(
                  height: 1.5,
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              Gap(AppSpacing.xl.h),
              Text(
                "${localCandidate.username}'s Info",
                style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
              ),
              Gap(AppSpacing.md.h),

              Wrap(
                spacing: AppSpacing.sm.w,
                runSpacing: AppSpacing.sm.h,
                children: candidateInformation
                    .asIconMap(showLocationInfo: false)
                    .entries
                    .where((entry) => entry.value['value'] != null)
                    .map((entry) {
                      final icon = entry.value['icon'] as IconData;
                      final text = entry.value['value'] as String;
                      return InfoBuilder(text: text, icon: icon);
                    })
                    .toList(),
              ),
            ],
          ),
        ),

        Gap(AppSpacing.sm.h),

        SizedBox(
          height: availableHeight * 0.8 * imageRest.length + 10,
          child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemCount: imageRest.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  ImageBuilder(
                    imageMetaData: imageRest[index],
                    height: availableHeight * 0.8,
                    onTap: () => showFullScreenImage(imageRest[index]['url']),
                  ),
                  Gap(AppSpacing.sm.h),
                ],
              );
            },
          ),
        ),

        Gap(AppSpacing.sm.h),

        // Location information card
        Container(
          width: MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          padding: EdgeInsets.symmetric(vertical: AppSpacing.lg.h, horizontal: AppSpacing.lg.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${localCandidate.username} lives in',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Gap(AppSpacing.xs.h),
              Text(
                localCandidate.currentlyStaying,
                style: textTheme.headlineMedium?.copyWith(color: colorScheme.onSurface),
              ),
              Gap(AppSpacing.md.h),
              InfoBuilder(text: localCandidate.hometown, icon: Icons.location_on),
            ],
          ),
        ),
      ],
    );
  }
}
