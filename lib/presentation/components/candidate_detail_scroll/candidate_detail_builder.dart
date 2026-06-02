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

class CandidateDetailBuilder extends StatelessWidget {
  final double availableHeight;
  final MatchCandidateEntity candidate;

  const CandidateDetailBuilder({super.key, required this.availableHeight, required this.candidate});

  @override
  Widget build(BuildContext context) {
    final localCandidate = candidate;
    final candidateInformation = CandidateInfoModel.fromMatchCandidateEntity(localCandidate);

    List<Map> imageRest = localCandidate.photos.sublist(1);

    void showFullScreenImage(String imagePath) {
      Navigator.push(context, CupertinoPageRoute(builder: (context) => FullScreenImageScreen(imagePath: imagePath)));
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
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                child: Container(
                  width: MediaQuery.sizeOf(context).width - 20.w,
                  padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 16.0.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light ? Color.fromARGB(255, 210, 208, 208) : Color.fromARGB(255, 31, 29, 29),
                    borderRadius: BorderRadius.circular(20.0.r),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${localCandidate.username}, ${calculateAge(localCandidate.dob)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),

                      Gap(4.h),

                      Row(
                        children: [
                          Icon(Icons.school, size: 16.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),

                          Gap(6.w),

                          Expanded(
                            child: Text(
                              '${localCandidate.universityMajor} Student',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      Gap(4.h),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),

                          Gap(6.w),

                          Text(
                            '${getOrdinalSuffix(localCandidate.universityYear)} Year',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
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

        Gap(5.h),

        // About section card
        Container(
          width: MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20.r)),
          padding: EdgeInsets.symmetric(vertical: 16.0.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'About',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
              ),
              Gap(12.h),
              Text(
                localCandidate.about,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.sp, height: 1.5, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8)),
              ),
              Gap(20.h),
              Text(
                "${localCandidate.username}'s Info",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
              ),
              Gap(12.h),

              Wrap(
                spacing: 8.0.w,
                runSpacing: 8.0.h,
                children: candidateInformation.asIconMap(showLocationInfo: false).entries.where((entry) => entry.value['value'] != null).map((entry) {
                  final icon = entry.value['icon'] as IconData;
                  final text = entry.value['value'] as String;
                  return InfoBuilder(text: text, icon: icon);
                }).toList(),
              ),
            ],
          ),
        ),

        Gap(5.h),

        SizedBox(
          height: availableHeight * 0.8 * imageRest.length + 10,
          child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemCount: imageRest.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  ImageBuilder(imageMetaData: imageRest[index], height: availableHeight * 0.8, onTap: () => showFullScreenImage(imageRest[index]['url'])),
                  Gap(5.h),
                ],
              );
            },
          ),
        ),

        Gap(5.h),

        // Location information card
        Container(
          width: MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16.0.r)),
          padding: EdgeInsets.symmetric(vertical: 16.0.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${localCandidate.username} lives in',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
              ),
              Gap(4.h),
              Text(
                localCandidate.currentlyStaying,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
              ),
              Gap(12.h),
              InfoBuilder(text: localCandidate.hometown, icon: Icons.location_on),
            ],
          ),
        ),
      ],
    );
  }
}
