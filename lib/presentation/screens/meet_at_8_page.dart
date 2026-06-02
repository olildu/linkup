import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:linkup/logic/bloc/lobby/lobby_bloc.dart';
import 'package:linkup/presentation/components/meet_at_8/background_animation.dart';
import 'package:linkup/presentation/constants/colors.dart';
import 'package:linkup/presentation/screens/matched_page.dart';
import 'package:lottie/lottie.dart';

class MeetAt8Page extends StatefulWidget {
  const MeetAt8Page({super.key});

  @override
  State<MeetAt8Page> createState() => _MeetAt8PageState();
}

class _MeetAt8PageState extends State<MeetAt8Page> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  late LobbyBloc _lobbyBloc;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _lobbyBloc = context.read<LobbyBloc>();
    _lobbyBloc.add(ConnectLobbyEvent());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached || state == AppLifecycleState.inactive) {
      _triggerDisconnect("App moved to background");
    } else if (state == AppLifecycleState.resumed) {
      log("App resumed, triggering reconnect.");
      if (!_lobbyBloc.isClosed) {
        _lobbyBloc.add(ConnectLobbyEvent());
      }
    }
  }

  void _triggerDisconnect(String reason) {
    log("Disconnect triggered: $reason");
    if (!_lobbyBloc.isClosed) {
      _lobbyBloc.add(DisconnectLobbyEvent());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _triggerDisconnect("Disposed normally");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: BlocBuilder<LobbyBloc, LobbyState>(
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              if (state is LobbyBefore8) {
                return BackgroundAnimation(
                  animation: _controller,
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.r)),
                    child: Center(
                      child: SizedBox(
                        width: constraints.maxWidth * 0.8,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("A little early, aren't you?", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 26.sp, color: AppColors.whiteTextColor)),
                            Gap(10.h),
                            Text(
                              'Come back at 8 PM',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 26.sp, fontWeight: FontWeight.bold, color: AppColors.whiteTextColor),
                            ),
                            Gap(10.h),
                            Text("That's when everything starts.", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 26.sp, color: AppColors.whiteTextColor)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              } else if (state is LobbyAt8) {
                return Stack(
                  children: [
                    BackgroundAnimation(animation: _controller, blur: true),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 1300),
                      curve: Curves.easeInOut,
                      builder: (context, opacity, _) {
                        return Opacity(
                          opacity: opacity,
                          child: Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.r)),
                            child: Center(
                              child: SizedBox(
                                width: constraints.maxWidth * 0.8,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(child: Lottie.asset('assets/animations/waiting-animation.json', width: 250.w, height: 250.h)),

                                    Text(
                                      "You've made it to the lobby.",
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22.sp, color: AppColors.whiteTextColor),
                                    ),
                                    Gap(10.h),
                                    Text(
                                      'Matching begins at 8:05 PM',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22.sp, fontWeight: FontWeight.bold, color: AppColors.whiteTextColor),
                                    ),
                                    Gap(10.h),
                                    Text(
                                      "Hang tight while everyone gets here.",
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22.sp, color: AppColors.whiteTextColor),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              } else if (state is LobbyNotMatchFound) {
                return Stack(
                  children: [
                    BackgroundAnimation(animation: _controller, blur: true),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 1300),
                      curve: Curves.easeInOut,
                      builder: (context, opacity, _) {
                        return Opacity(
                          opacity: opacity,
                          child: Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.r)),
                            child: Center(
                              child: SizedBox(
                                width: constraints.maxWidth * 0.8,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(child: Lottie.asset('assets/animations/no-match-animation.json', width: double.infinity, height: 200.h)),
                                    Gap(60.h),
                                    Text("No match this time.", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22.sp, color: AppColors.whiteTextColor)),
                                    Gap(10.h),
                                    Text(
                                      "But hey, tomorrow’s another chance!",
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22.sp, fontWeight: FontWeight.bold, color: AppColors.whiteTextColor),
                                    ),
                                    Gap(10.h),
                                    Text(
                                      "Come back at 8 PM sharp. You never know who’s waiting.",
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22.sp, color: AppColors.whiteTextColor),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              } else if (state is LobbyMatchFound) {
                final candidate = state.candidate;
                return Stack(
                  children: [
                    BackgroundAnimation(animation: _controller, blur: true),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 1300),
                      curve: Curves.easeInOut,
                      builder: (context, opacity, _) {
                        return Opacity(opacity: opacity, child: MatchedPage(matchUser: candidate, meet8State: true));
                      },
                    ),
                  ],
                );
              } else {
                return BackgroundAnimation(
                  animation: _controller,
                  child: Center(
                    child: SizedBox(
                      width: constraints.maxWidth * 0.8,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Something went wrong...",
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 24.sp, fontWeight: FontWeight.bold, color: AppColors.whiteTextColor),
                          ),
                          Gap(8.h),
                          Text(
                            "We're having trouble finding your match.\nPlease try again in a moment.",
                            textAlign: TextAlign.left,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18.sp, color: AppColors.whiteTextColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
