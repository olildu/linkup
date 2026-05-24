import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:linkup/data/models/reply_model.dart';
import 'package:linkup/logic/bloc/camera/camera_bloc.dart';
import 'package:linkup/presentation/screens/media_picker_page.dart';

class MessageInputArea extends StatelessWidget {
  final TextEditingController messageController;
  final bool isTyping;
  final ReplyModel? replyPayload;

  final Function() sendMessage;
  final Function(File) handleMedia;
  final Function removeReplyPayload;
  final Map userImageMetaData;

  const MessageInputArea({
    super.key,
    required this.messageController,
    required this.isTyping,
    required this.replyPayload,
    required this.removeReplyPayload,
    required this.sendMessage,
    required this.handleMedia,
    required this.userImageMetaData,
  });

  @override
  Widget build(BuildContext context) {
    final double maxWidth = MediaQuery.sizeOf(context).width;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [BoxShadow(offset: const Offset(0, -2), blurRadius: 5, spreadRadius: -1, color: const Color.fromARGB(255, 26, 26, 26).withValues(alpha: 0.08))],
      ),
      child: SafeArea(
        child: Column(
          children: [
            replyPayload != null
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                    width: maxWidth,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outline, width: 2)),
                    ),

                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 5.w),

                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Replying to ${replyPayload?.userName}",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16.sp, fontWeight: FontWeight.w300),
                                    ),
                                    Text(
                                      replyPayload!.message,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.copyWith(fontSize: 14.sp, fontWeight: FontWeight.w300, color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7)),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(
                                width: 36.w,
                                height: 36.h,
                                child: IconButton(
                                  icon: Icon(Icons.close, size: 18.sp, color: Theme.of(context).colorScheme.onSurface),
                                  onPressed: () {
                                    removeReplyPayload();
                                  },
                                  tooltip: 'Close reply',
                                  padding: EdgeInsets.zero,
                                  style: IconButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.outline,
                                    shape: CircleBorder(),
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox.shrink(),

            Padding(
              padding: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 5.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 120.h),
                      child: TextField(
                        controller: messageController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 15.sp, color: Theme.of(context).colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Message...',
                          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.outline,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.r), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.r),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.r),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Gap(8.w),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: isTyping
                        ? Material(
                            key: const ValueKey('send_button'),
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(25.r),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(25.r),
                              onTap: sendMessage,
                              child: Padding(
                                padding: EdgeInsets.all(10.r),
                                child: Icon(Icons.send_rounded, color: Theme.of(context).colorScheme.onPrimary, size: 22.sp),
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(color: Theme.of(context).colorScheme.outline, borderRadius: BorderRadius.circular(50.r)),
                            child: Row(
                              key: const ValueKey('camera_icons'),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Hero(
                                  tag: 'camera-hero',
                                  child: IconButton(
                                    icon: Icon(Icons.camera_alt_outlined, color: Theme.of(context).colorScheme.primary, size: 24.sp),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .push(
                                            PageRouteBuilder(
                                              transitionDuration: Duration(milliseconds: 500),
                                              pageBuilder: (_, __, ___) => BlocProvider(
                                                create: (context) => CameraBloc()..add(CameraInitEvent()),
                                                child: MediaPickerPage(userImageMetaData: userImageMetaData),
                                              ),
                                            ),
                                          )
                                          .then((imageFile) {
                                            if (imageFile is! File) return;
                                            handleMedia(imageFile);
                                          });
                                    },
                                    tooltip: 'Send image/video',
                                    padding: EdgeInsets.all(10.r),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
