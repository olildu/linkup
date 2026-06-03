import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:linkup/core/di/injection_container.dart';
import 'package:linkup/domain/entities/match_candidate_entity.dart';
import 'package:linkup/domain/use_cases/chat/start_chat_use_case.dart';
import 'package:linkup/logic/bloc/chats/chats_bloc.dart';
import 'package:linkup/logic/bloc/profile/others/other_profile_bloc.dart';
import 'package:linkup/logic/bloc/profile/own/profile_bloc.dart';
import 'package:linkup/presentation/components/candidate_detail_scroll/candidate_detail_builder.dart';
import 'package:linkup/presentation/components/signup_page/button_builder.dart';
import 'package:linkup/presentation/screens/chat_page.dart';

void showBottomSheetUserProfile({required BuildContext context, required int userId, bool showChatButton = true}) {
  final parentContext = context;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8, minHeight: MediaQuery.of(context).size.height * 0.8),
    builder: (context) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        child: BlocProvider(
          create: (_) => sl<OtherProfileBloc>()..add(LoadOtherProfileEvent(userId)),
          child: BlocBuilder<OtherProfileBloc, OtherProfileState>(
            builder: (context, state) {
              if (state is OtherProfileLoading) {
                return const SizedBox(
                  height: double.infinity,
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (state is OtherProfileLoaded) {
                return OtherProfileLoadedView(candidate: state.user, showChatButton: showChatButton, parentContext: parentContext);
              } else if (state is OtherProfileError) {
                return SizedBox(
                  height: double.infinity,
                  child: Center(child: Text("Error loading profile", style: Theme.of(context).textTheme.bodyLarge)),
                );
              } else {
                return SizedBox(
                  height: double.infinity,
                  child: Center(child: Text("No data available", style: Theme.of(context).textTheme.bodyLarge)),
                );
              }
            },
          ),
        ),
      );
    },
  );
}

class OtherProfileLoadedView extends StatelessWidget {
  final MatchCandidateEntity candidate;
  final bool showChatButton;
  final BuildContext parentContext;
  const OtherProfileLoadedView({super.key, required this.candidate, required this.parentContext, this.showChatButton = true});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.8;

    final backgroundColor = Theme.of(context).colorScheme.surfaceContainerLow;

    final availableHeight = showChatButton ? height - 60.h - 30.h : height - 25.h;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: CandidateDetailBuilder(availableHeight: availableHeight, candidate: candidate),
              ),
            ),
            if (showChatButton) ...{
              Gap(5.h),
              ButtonBuilder(
                text: "Start Messaging",
                onPressed: () async {
                  final navigator = Navigator.of(parentContext, rootNavigator: true);
                  final currentUserId = (context.read<ProfileBloc>().state as ProfileLoaded).user.id;
                  final response = await sl<StartChatUseCase>()(candidate.id);

                  if (response["success"] == true) {
                    navigator.pop();
                    await Future.delayed(const Duration(milliseconds: 500));

                    navigator.push(
                      CupertinoPageRoute(
                        builder: (ctx) => BlocProvider(
                          create: (ctx) => ChatsBloc(
                            currentChatUserId: candidate.id,
                            currentUserId: currentUserId,
                            chatRoomId: response["chat_room_id"],
                            fetchMessagesUseCase: sl(),
                            getCachedMessagesUseCase: sl(),
                            cacheMessageUseCase: sl(),
                            saveUnsentMessageUseCase: sl(),
                            uploadChatMediaUseCase: sl(),
                            paginateMessagesUseCase: sl(),
                          )..add(StartChatsEvent()),
                          child: ChatPage(
                            currentChatUserId: candidate.id,
                            currentUserId: currentUserId,
                            userName: candidate.username,
                            userImageMetaData: candidate.profilePictureMetaData,
                            chatRoomId: response["chat_room_id"],
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            },
          ],
        ),
      ),
    );
  }
}
