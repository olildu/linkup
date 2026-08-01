import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:linkup/logic/bloc/lobby/lobby_bloc.dart';
import 'package:linkup/logic/bloc/matches/matches_bloc.dart';
import 'package:linkup/core/di/injection_container.dart';
import 'package:linkup/logic/bloc/profile/own/preferences_bloc/preferences_bloc.dart';
import 'package:linkup/presentation/constants/colors.dart';
import 'package:linkup/presentation/theme/app_spacing.dart';
import 'package:linkup/presentation/screens/around_you_page.dart';
import 'package:linkup/presentation/screens/matched_page.dart';
import 'package:linkup/presentation/screens/meet_at_8_page.dart';
import 'package:linkup/presentation/screens/profile_settings_page.dart';
import 'package:linkup/presentation/screens/connections_page.dart';
import 'package:linkup/presentation/screens/set_preferences_page.dart';
import 'package:linkup/presentation/utils/scaffold_message_display.dart';

class MatchMakingPage extends StatefulWidget {
  const MatchMakingPage({super.key});

  @override
  State<MatchMakingPage> createState() => _MatchMakingPageState();
}

class _MatchMakingPageState extends State<MatchMakingPage> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return BlocListener<MatchesBloc, MatchesState>(
      listener: (context, state) async {
        if (state is MatchesLoaded && state.matchUser != null) {
          final matchUser = state.matchUser!;

          await Navigator.of(context).push(MaterialPageRoute(builder: (_) => MatchedPage(matchUser: matchUser)));
        }

        if (state is MatchesLoaded && state.limitMessage != null && context.mounted) {
          showScaffoldMessage(context: context, message: state.limitMessage!);
          context.read<MatchesBloc>().add(ClearLimitMessageEvent());
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(left: AppSpacing.sm.w, right: AppSpacing.sm.w, top: AppSpacing.xl3.h, bottom: AppSpacing.sm.h),

            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.tune_rounded, size: 28.sp),
                          onPressed: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) => BlocProvider(create: (context) => sl<PreferencesBloc>(), child: SetPreferencesPage()),
                              ),
                            );
                          },
                        ),

                        SizedBox(width: 48.w, height: 48.w),
                      ],
                    ),

                    Text(
                      'linkup',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                    ),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.favorite_rounded, color: AppColors.primary, size: 28.sp),
                          onPressed: () {
                            Navigator.of(context).push(CupertinoPageRoute(builder: (context) => const ConnectionsPage()));
                          },
                        ),

                        IconButton(
                          icon: Icon(Icons.person_rounded, size: 28.sp),
                          onPressed: () {
                            Navigator.of(context).push(CupertinoPageRoute(builder: (context) => ProfileSettingsPage()));
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
                            unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
                            overlayColor: WidgetStateProperty.all(Colors.transparent),
                            indicator: UnderlineTabIndicator(
                              borderSide: BorderSide(width: 3.0.w, color: Theme.of(context).colorScheme.onSurface),
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
                                child: BlocProvider(create: (context) => LobbyBloc(), child: MeetAt8Page()),
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
