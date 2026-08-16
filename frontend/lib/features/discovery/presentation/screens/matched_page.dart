import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:linkup/core/di/injection_container.dart';
import 'package:linkup/core/entities/matches_connection_entity.dart';
import 'package:linkup/features/messaging/domain/start_chat_use_case.dart';
import 'package:linkup/features/messaging/presentation/bloc/chats_bloc.dart';
import 'package:linkup/features/discovery/presentation/bloc/matches_bloc.dart';
import 'package:linkup/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:linkup/features/onboarding/presentation/components/button_builder.dart';
import 'package:linkup/features/onboarding/presentation/components/page_title_builder_component.dart';
import 'package:linkup/shared_ui/theme/app_radius.dart';
import 'package:linkup/shared_ui/theme/app_spacing.dart';
import 'package:linkup/features/messaging/presentation/screens/chat_page.dart';
import 'package:linkup/shared_ui/utils/blurhash_util.dart';
import 'package:octo_image/octo_image.dart';

class MatchedPage extends StatefulWidget {
  final MatchesConnectionEntity matchUser;
  final bool meet8State;

  const MatchedPage({
    super.key,
    required this.matchUser,
    this.meet8State = false,
  });

  @override
  State<MatchedPage> createState() => _MatchedPageState();
}

class _MatchedPageState extends State<MatchedPage> {
  final double _rotationAngle = 0.1;
  final double _imageWidth = 150.w;
  final double _imageHeight = 250.h;
  final double _offset = 40.h;

  late ConfettiController _confettiControllerLeft;
  late ConfettiController _confettiControllerRight;

  @override
  void initState() {
    super.initState();
    _confettiControllerLeft = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _confettiControllerRight = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    Future.delayed(Duration(milliseconds: 300), () async {
      await Haptics.vibrate(HapticsType.success);
      _confettiControllerLeft.play();
      _confettiControllerRight.play();
    });
  }

  @override
  void dispose() {
    _confettiControllerLeft.dispose();
    _confettiControllerRight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: widget.meet8State
          ? null
          : AppBar(
              leading: IconButton(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl.w,
                  vertical: AppSpacing.xl.h,
                ),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 20.sp,
                ),

                onPressed: () {
                  context.read<MatchesBloc>().add(ClearMatchUserEvent());
                  Navigator.pop(context, true);
                },
              ),
            ),

      body: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.xl.w,
          right: AppSpacing.xl.w,
          top: widget.meet8State ? AppSpacing.xl3.h : AppSpacing.xl4.h,
          bottom: AppSpacing.xl5.h,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: _imageBuilder(
                        imageMetaData:
                            (context.read<ProfileBloc>().state as ProfileLoaded)
                                .user
                                .profilePicture!,
                        offsetX: -_offset,
                        angle: -_rotationAngle,
                      ),
                    ),
                    _imageBuilder(
                      imageMetaData: widget.matchUser.profilePictureMetaData,
                      offsetX: _offset,
                      angle: _rotationAngle,
                    ),
                  ],
                ),
                Gap(AppSpacing.xl4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl2.h),
                  child: PageTitle(
                    inputText: widget.meet8State
                        ? "Congratulations!\n${widget.matchUser.username} and you have been matched"
                        : "Congratulations!\n${widget.matchUser.username} and you like each other",
                    highlightWord: widget.matchUser.username,
                  ),
                ),

                if (!widget.meet8State) ...[
                  const Spacer(),
                  ButtonBuilder(
                    text: "Start Messaging",
                    onPressed: () async {
                      final currentUserId =
                          (context.read<ProfileBloc>().state as ProfileLoaded)
                              .user
                              .id;
                      final response = await sl<StartChatUseCase>()(
                        widget.matchUser.id,
                      );

                      if (!context.mounted) return;
                      if (response["success"] == true) {
                        Navigator.of(context).pushReplacement(
                          CupertinoPageRoute(
                            builder: (ctx) => BlocProvider(
                              create: (ctx) => ChatsBloc(
                                currentChatUserId: widget.matchUser.id,
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
                                currentChatUserId: widget.matchUser.id,
                                currentUserId: currentUserId,
                                userName: widget.matchUser.username,
                                userImageMetaData:
                                    widget.matchUser.profilePictureMetaData,
                                chatRoomId: response["chat_room_id"],
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ],
            ),

            _confettiBuilder(
              controller: _confettiControllerLeft,
              alignment: Alignment.centerLeft,
              blastDirection: 0,
            ),

            _confettiBuilder(
              controller: _confettiControllerRight,
              alignment: Alignment.centerRight,
              blastDirection: pi,
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageBuilder({
    required Map imageMetaData,
    required double offsetX,
    required double angle,
  }) {
    final String url = imageMetaData["url"];
    final String? fileKey = imageMetaData["file_key"];
    final String blurhash = imageMetaData["blurhash"];

    return Transform.translate(
      offset: Offset(offsetX, 0),
      child: Transform.rotate(
        angle: angle,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: OctoImage(
            image: CachedNetworkImageProvider(url, cacheKey: fileKey),
            placeholderBuilder: blurHash(blurhash).placeholderBuilder,
            errorBuilder: OctoError.icon(
              color: Theme.of(context).colorScheme.error,
            ),
            fit: BoxFit.cover,
            width: _imageWidth,
            height: _imageHeight,
          ),
        ),
      ),
    );
  }

  Widget _confettiBuilder({
    required ConfettiController controller,
    required Alignment alignment,
    required double blastDirection,
  }) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.07,
      left: alignment == Alignment.centerLeft ? 0 : null,
      right: alignment == Alignment.centerRight ? 0 : null,
      child: ConfettiWidget(
        confettiController: controller,
        blastDirection: blastDirection,
        emissionFrequency: 0.05,
        numberOfParticles: 5,
        maxBlastForce: 20,
        minBlastForce: 10,
        gravity: 0.1,
        particleDrag: 0.05,
        // Intentionally varied rainbow colors — not brand tokens
        colors: const [
          Colors.red,
          Colors.blue,
          Colors.green,
          Colors.orange,
          Colors.purple,
          Colors.yellow,
        ],
      ),
    );
  }
}
