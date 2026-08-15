import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:linkup/domain/entities/likes_you_entry_entity.dart';
import 'package:linkup/logic/bloc/likes/likes_bloc.dart';
import 'package:linkup/presentation/components/candidate_detail_scroll/candidate_detail_builder.dart';
import 'package:linkup/presentation/constants/colors.dart';
import 'package:linkup/presentation/screens/matched_page.dart';
import 'package:linkup/presentation/theme/app_radius.dart';
import 'package:linkup/presentation/theme/app_spacing.dart';
import 'package:linkup/presentation/utils/blurhash_util.dart';
import 'package:octo_image/octo_image.dart';

class LikesYouPage extends StatefulWidget {
  const LikesYouPage({super.key});

  @override
  State<LikesYouPage> createState() => _LikesYouPageState();
}

class _LikesYouPageState extends State<LikesYouPage> with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    context.read<LikesBloc>().add(LoadReceivedLikesEvent(refresh: true));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LikesBloc, LikesState>(
      listener: (context, state) async {
        if (state is LikesLoaded && state.matchUser != null) {
          final matchUser = state.matchUser!;
          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => MatchedPage(matchUser: matchUser)));
          if (context.mounted) {
            context.read<LikesBloc>().add(ClearLikesMatchUserEvent());
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          title: Text(
            'Likes You',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Theme.of(context).colorScheme.onSurface,
              size: 20.sp,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<LikesBloc, LikesState>(
            builder: (context, state) {
              if (state is LikesError) {
                return _buildEmptyState(
                  context,
                  title: 'Something went wrong',
                  subtitle: 'Please try again in a moment.',
                );
              }

              if (state is! LikesLoaded ||
                  (state.loadingEntries && state.entries.isEmpty)) {
                return _buildLoadingGrid(context);
              }

              if (state.entries.isEmpty && state.totalCount == 0 && !state.loadingEntries) {
                return _buildEmptyState(
                  context,
                  title: 'No likes yet',
                  subtitle: 'When someone likes you, they\'ll show up here.',
                );
              }

              return GridView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl.w,
                  vertical: AppSpacing.md.h,
                ),
                itemCount: state.entries.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.md.w,
                  crossAxisSpacing: AppSpacing.md.w,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) => _buildEntryCard(context, state.entries[index]),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingGrid(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl.w, vertical: AppSpacing.md.h),
      itemCount: 6,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md.w,
        crossAxisSpacing: AppSpacing.md.w,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) => _ShimmerCard(animation: _shimmerController),
    );
  }

  Widget _buildEntryCard(BuildContext context, LikesYouEntryEntity entry) {
    final imageMeta = entry.revealed ? entry.profile!.photos.first : entry.firstPhoto;
    final url = imageMeta?['url'] as String?;
    final fileKey = imageMeta?['file_key'] as String?;
    final blurhash = imageMeta?['blurhash'] as String?;

    return GestureDetector(
      onTap: () => entry.revealed ? _showRevealedProfileSheet(context, entry) : () {},
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (url != null)
              _EntryImage(url: url, fileKey: fileKey, blurhash: blurhash, blurred: !entry.revealed)
            else
              Container(color: Theme.of(context).colorScheme.surfaceContainerHighest),
            if (!entry.revealed) ...[
              Container(color: Colors.black.withValues(alpha: 0.15)),
              Center(
                child: Icon(Icons.favorite_rounded, color: AppColors.whiteText, size: 32.sp),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showRevealedProfileSheet(BuildContext context, LikesYouEntryEntity entry) {
    final likesBloc = context.read<LikesBloc>();
    final height = MediaQuery.of(context).size.height * 0.8;
    final availableHeight = height - 100.h;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.8,
          expand: false,
          builder: (sheetContext, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(sheetContext).scaffoldBackgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
              ),
              child: Column(
                children: [
                  Gap(AppSpacing.sm.h),
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Theme.of(sheetContext).colorScheme.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: CandidateDetailBuilder(
                        availableHeight: availableHeight,
                        candidate: entry.profile!,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(AppSpacing.xl.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              likesBloc.add(PassLikeEvent(likerId: entry.id));
                              Navigator.pop(sheetContext);
                            },
                            child: const Text('Pass'),
                          ),
                        ),
                        Gap(AppSpacing.md.w),
                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                            onPressed: () {
                              likesBloc.add(LikeBackEvent(likerId: entry.id));
                              Navigator.pop(sheetContext);
                            },
                            child: const Text('Like back'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, {required String title, required String subtitle}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_border_rounded, size: 72.sp, color: AppColors.primary),
          Gap(AppSpacing.lg.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
          Gap(AppSpacing.sm.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl2.w),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryImage extends StatelessWidget {
  final String url;
  final String? fileKey;
  final String? blurhash;
  final bool blurred;

  const _EntryImage({required this.url, this.fileKey, this.blurhash, required this.blurred});

  @override
  Widget build(BuildContext context) {
    final image = OctoImage(
      image: CachedNetworkImageProvider(url, cacheKey: fileKey),
      placeholderBuilder: blurhash != null ? blurHash(blurhash!).placeholderBuilder : null,
      fit: BoxFit.cover,
    );

    if (!blurred) return image;
    return ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18), child: image);
  }
}

class _ShimmerCard extends StatelessWidget {
  final Animation<double> animation;

  const _ShimmerCard({required this.animation});

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlightColor = Theme.of(context).colorScheme.surface;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: baseColor),
          Center(
            child: Icon(
              Icons.favorite_rounded,
              color: AppColors.primary.withValues(alpha: 0.15),
              size: 32.sp,
            ),
          ),
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return ShaderMask(
                blendMode: BlendMode.srcATop,
                shaderCallback: (bounds) {
                  final dx = lerpDouble(-bounds.width, bounds.width, animation.value)!;
                  return LinearGradient(
                    colors: [baseColor.withValues(alpha: 0), highlightColor, baseColor.withValues(alpha: 0)],
                    stops: const [0.35, 0.5, 0.65],
                  ).createShader(Rect.fromLTWH(dx, 0, bounds.width, bounds.height));
                },
                child: Container(color: baseColor.withValues(alpha: 0.4)),
              );
            },
          ),
        ],
      ),
    );
  }
}
