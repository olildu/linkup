import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:linkup/features/lobby/presentation/bloc/lobby_bloc.dart';
import 'package:linkup/features/likes/presentation/bloc/likes_bloc.dart';
import 'package:linkup/features/discovery/presentation/bloc/matches_bloc.dart';
import 'package:linkup/core/di/injection_container.dart';
import 'package:linkup/features/profile/presentation/bloc/preferences_bloc.dart';
import 'package:linkup/shared_ui/constants/colors.dart';
import 'package:linkup/shared_ui/theme/app_spacing.dart';
import 'package:linkup/features/discovery/presentation/screens/around_you_page.dart';
import 'package:linkup/features/likes/presentation/screens/likes_you_page.dart';
import 'package:linkup/features/discovery/presentation/screens/matched_page.dart';
import 'package:linkup/features/lobby/presentation/screens/meet_at_8_page.dart';
import 'package:linkup/features/profile/presentation/screens/profile_settings_page.dart';
import 'package:linkup/features/connections/presentation/screens/connections_page.dart';
import 'package:linkup/features/profile/presentation/screens/set_preferences_page.dart';
import 'package:linkup/features/discovery/presentation/swipe_limit_alert.dart';

class MatchMakingPage extends StatefulWidget {
  const MatchMakingPage({super.key});

  @override
  State<MatchMakingPage> createState() => _MatchMakingPageState();
}

class _MatchMakingPageState extends State<MatchMakingPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    context.read<LikesBloc>().add(LoadLikesCountEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MatchesBloc, MatchesState>(
      listener: (context, state) async {
        if (state is MatchesLoaded && state.matchUser != null) {
          final matchUser = state.matchUser!;

          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MatchedPage(matchUser: matchUser),
            ),
          );
        }

        if (state is MatchesLoaded &&
            state.limitMessage != null &&
            context.mounted) {
          showSwipeLimitAlert(context);
          context.read<MatchesBloc>().add(ClearLimitMessageEvent());
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.sm.w,
              right: AppSpacing.sm.w,
              top: AppSpacing.xl3.h,
              bottom: AppSpacing.sm.h,
            ),

            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.tune_rounded, size: 28.sp),
                          onPressed: () async {
                            await Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (context) => sl<PreferencesBloc>(),
                                  child: SetPreferencesPage(),
                                ),
                              ),
                            );
                            if (context.mounted) {
                              context.read<MatchesBloc>().add(
                                LoadMatchesEvent(refresh: true),
                              );
                            }
                          },
                        ),

                        BlocBuilder<LikesBloc, LikesState>(
                          builder: (context, state) {
                            final likesCount = state is LikesLoaded
                                ? state.totalCount
                                : 0;
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.auto_awesome_rounded,
                                    color: AppColors.primary,
                                    size: 28.sp,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      CupertinoPageRoute(
                                        builder: (context) =>
                                            const LikesYouPage(),
                                      ),
                                    );
                                  },
                                ),
                                if (likesCount > 0)
                                  Positioned(
                                    right: 4,
                                    top: 4,
                                    child: IgnorePointer(
                                      child: Container(
                                        padding: EdgeInsets.all(AppSpacing.xs),
                                        constraints: BoxConstraints(
                                          minWidth: 16.sp,
                                          minHeight: 16.sp,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          likesCount > 9 ? '9+' : '$likesCount',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onPrimary,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),

                    Text(
                      'linkup',
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.favorite_rounded,
                            color: AppColors.primary,
                            size: 28.sp,
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) => const ConnectionsPage(),
                              ),
                            );
                          },
                        ),

                        IconButton(
                          icon: Icon(Icons.person_rounded, size: 28.sp),
                          onPressed: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) => ProfileSettingsPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 40.h,
                          width: MediaQuery.of(context).size.width - 160.w,
                          child: TabBar(
                            dividerColor: Colors.transparent,
                            labelColor: Theme.of(context).colorScheme.onSurface,
                            unselectedLabelColor: Theme.of(
                              context,
                            ).colorScheme.onSurface,
                            overlayColor: WidgetStateProperty.all(
                              Colors.transparent,
                            ),
                            indicator: UnderlineTabIndicator(
                              borderSide: BorderSide(
                                width: 3.0.w,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              insets: EdgeInsets.symmetric(horizontal: 30.0.w),
                            ),
                            physics: const NeverScrollableScrollPhysics(),
                            tabs: const [
                              Tab(text: 'Around You'),
                              Tab(text: 'meet@8'),
                            ],
                          ),
                        ),
                        Gap(AppSpacing.xl.h),
                        Expanded(
                          child: TabBarView(
                            physics: NeverScrollableScrollPhysics(),
                            children: [
                              Center(child: AroundYouPage()),
                              Center(
                                child: BlocProvider(
                                  create: (context) => LobbyBloc(),
                                  child: MeetAt8Page(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
