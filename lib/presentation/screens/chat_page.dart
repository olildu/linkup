import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:linkup/data/data_parser/common/check_contains_emoji.dart';
import 'package:linkup/data/enums/message_type_enum.dart';
import 'package:linkup/data/models/chat_models/message_group_model.dart';
import 'package:linkup/data/models/chat_models/message_model.dart';
import 'package:linkup/data/models/live_chat_data_model.dart';
import 'package:linkup/data/models/reply_model.dart';
import 'package:linkup/logic/bloc/chats/chats_bloc.dart';
import 'package:linkup/logic/bloc/connections/connections_bloc.dart';
import 'package:linkup/presentation/components/chat_page/calculate_border_shape.dart';
import 'package:linkup/presentation/components/common/confirmation_dialog_builder.dart';
import 'package:linkup/presentation/components/chat_page/message_input_area.dart';
import 'package:linkup/presentation/components/chat_page/minor_event_widgets.dart';
import 'package:linkup/presentation/components/chat_page/message_renderer.dart';
import 'package:linkup/presentation/components/chat_page/sending_animation.dart';
import 'package:linkup/presentation/components/chat_page/swipe_wrapper.dart';
import 'package:linkup/presentation/constants/colors.dart';
import 'package:linkup/presentation/theme/app_radius.dart';
import 'package:linkup/presentation/theme/app_spacing.dart';
import 'package:linkup/presentation/screens/user_profile_bottom_sheet.dart';
import 'package:linkup/presentation/utils/blurhash_util.dart';
import 'package:linkup/presentation/utils/scaffold_message_display.dart';
import 'package:octo_image/octo_image.dart';
import 'package:uuid/v4.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ChatPage extends StatefulWidget {
  final int currentChatUserId;
  final int currentUserId;
  final String userName;
  final Map userImageMetaData;
  final int chatRoomId;

  const ChatPage({
    super.key,
    required this.currentChatUserId,
    required this.currentUserId,
    required this.userName,
    required this.userImageMetaData,
    required this.chatRoomId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  static const int _messageGroupTimeThresholdMinutes = 1;

  bool _isTyping = false;
  bool _initalSeenMarked = false;
  bool _isSocketConnected = false;

  ReplyModel? _replyPayload;

  final GlobalKey<AnimatedListState> _animatedListKey = GlobalKey<AnimatedListState>();
  List<Message> _currentMessages = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });

    _messageController.addListener(_handleTypingChange);
    _scrollController.addListener(_handlePagination);
  }

  @override
  void dispose() {
    _messageController.removeListener(_handleTypingChange);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handlePagination() {
    if (_scrollController.position.atEdge) {
      bool isTop = _scrollController.position.pixels == 0;
      if (!isTop) {
        final String lastMessageID = _currentMessages.first.id;
        final DateTime lastMessageTimeStamp = _currentMessages.first.timestamp;

        log('Paginating with lastMessageID: $lastMessageID');
        context.read<ChatsBloc>().add(
          PaginateAddMessagesEvent(
            chatRoomId: widget.chatRoomId,
            lastMessageID: lastMessageID,
            lastMessageTimeStamp: lastMessageTimeStamp,
          ),
        );
      }
    }
  }

  void _handleTypingChange() {
    final isTypingNow = _messageController.text.trim().isNotEmpty;

    if (mounted) {
      setState(() => _isTyping = isTypingNow);
    }

    if (mounted && isTypingNow) {
      context.read<ChatsBloc>().add(SendTypingEvent(currentChatUserId: widget.currentChatUserId));
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      final newMessage = Message(
        id: UuidV4().generate(),
        message: _messageController.text.trim(),
        to: widget.currentChatUserId,
        from_: widget.currentUserId,
        timestamp: DateTime.now(),
        chatRoomId: widget.chatRoomId,
        replyID: _replyPayload?.messageID,
      );

      log("Message ${newMessage.toJson()}");

      context.read<ChatsBloc>().add((SendMessageEvent(message: newMessage)));
      _messageController.clear();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });

      _replyPayload = null;

      LiveChatDataModel liveChatData = LiveChatDataModel(
        from_: widget.currentUserId,
        chatRoomId: widget.chatRoomId,
        message: _isSocketConnected ? "Sent just now" : "Sending...",
        unseenCounterIncBy: 0,
        messageType: MessageType.text,
      );

      context.read<ConnectionsBloc>().add(ReloadChatConnectionsEvent(liveChatData: liveChatData));
    }
  }

  MessageGroupModel _calculateMessageGroupInfo({
    required int messageIndex,
    required List<Message> messages,
  }) {
    final message = messages[messageIndex];

    int groupStart = messageIndex;
    while (groupStart > 0) {
      final prevMessage = messages[groupStart - 1];
      if (prevMessage.from_ != message.from_ ||
          message.timestamp.difference(prevMessage.timestamp).inMinutes >=
              _messageGroupTimeThresholdMinutes) {
        break;
      }
      groupStart--;
    }

    int groupEnd = messageIndex;
    while (groupEnd < messages.length - 1) {
      final nextMessage = messages[groupEnd + 1];
      if (nextMessage.from_ != message.from_ ||
          nextMessage.timestamp.difference(message.timestamp).inMinutes >=
              _messageGroupTimeThresholdMinutes) {
        break;
      }
      groupEnd++;
    }

    final groupSize = groupEnd - groupStart + 1;
    final positionInGroup = messageIndex - groupStart;
    final isFirstInGroup = messageIndex == groupStart;
    final isLastInGroup = messageIndex == groupEnd;
    final isOnlyMessageInGroup = groupSize == 1;

    final prevMessageEmoji = messageIndex > 0
        ? containsOnlyEmojis(messages[messageIndex - 1].message)
        : false;

    final nextMessageEmoji = messageIndex < messages.length - 1
        ? containsOnlyEmojis(messages[messageIndex + 1].message)
        : false;

    return MessageGroupModel(
      isFirstInGroup: isFirstInGroup,
      isLastInGroup: isLastInGroup,
      isOnlyMessageInGroup: isOnlyMessageInGroup,
      groupSize: groupSize,
      positionInGroup: positionInGroup,
      nextMessageEmoji: nextMessageEmoji,
      prevMessageEmoji: prevMessageEmoji,
    );
  }

  Widget _buildMessageItem({
    required Message message,
    required BuildContext context,
    required int messageIndex,
    required List<Message> messages,
  }) {
    final bool isSentByMe = message.from_ == widget.currentUserId;
    final isOnlyEmoji = containsOnlyEmojis(message.message);

    final MessageGroupModel groupInfo = _calculateMessageGroupInfo(
      messageIndex: messageIndex,
      messages: messages,
    );

    final alignment = isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final containsReply = message.replyID != null ? true : false;

    final color = isOnlyEmoji
        ? Colors.transparent
        : isSentByMe
        ? AppColors.primary
        : Theme.of(context).colorScheme.surfaceContainerHighest;

    BorderRadius messageBorderRadius = getBorderRadius(
      groupInfo: groupInfo,
      isSentByMe: isSentByMe,
      isOnlyEmoji: isOnlyEmoji,
      containsReply: containsReply,
    );

    return Container(
      margin: EdgeInsets.only(top: groupInfo.isFirstInGroup ? AppSpacing.sm.h : AppSpacing.xxs.h, bottom: AppSpacing.xxs.h),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Row(
            mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isSentByMe && (groupInfo.isLastInGroup || groupInfo.isOnlyMessageInGroup)) ...[
                Padding(
                  padding: EdgeInsets.only(right: AppSpacing.md.w, bottom: AppSpacing.xxs.h),
                  child: ClipOval(
                    child: OctoImage(
                      image: CachedNetworkImageProvider(widget.userImageMetaData["url"]),
                      placeholderBuilder: blurHash(
                        widget.userImageMetaData["blurhash"],
                      ).placeholderBuilder,
                      errorBuilder: OctoError.icon(color: Theme.of(context).colorScheme.error),
                      fit: BoxFit.cover,
                      width: 30.r,
                      height: 30.r,
                    ),
                  ),
                ),
              ] else if (!isSentByMe) ...[
                Padding(
                  padding: EdgeInsets.only(right: AppSpacing.md.w, bottom: AppSpacing.xxs.h),
                  child: SizedBox(width: 30.r, height: 30.r),
                ),
              ],
              VisibilityDetector(
                key: Key(message.id.toString()),
                onVisibilityChanged: (info) {
                  if (!isSentByMe && !message.isSeen) {
                    final int lastIndex = messages.length - 1;
                    final int seenIndex = messages.indexWhere((m) => m.id == message.id);
                    final int seenDiff = lastIndex - seenIndex;

                    context.read<ChatsBloc>().add(MarkMessageAsSeenEvent(messageId: message.id));

                    if (_initalSeenMarked) {
                      context.read<ConnectionsBloc>().add(
                        MarkMessagesSeenEvent(
                          chatRoomId: widget.chatRoomId,
                          decrementCounterTo: seenDiff,
                        ),
                      );
                    }
                  }
                },
                child: SwipeWrapper(
                  payload: message,
                  onSwipe: () => _replyPayloadSetter(
                    ReplyModel(
                      messageID: message.id,
                      message: message.message,
                      userName: message.from_ == GetIt.instance<int>(instanceName: 'user_id')
                          ? "yourself"
                          : widget.userName,
                    ),
                  ),
                  child: Builder(
                    builder: (context) {
                      return MessageRenderer(
                        message: message,
                        messages: messages,
                        isSentByMe: isSentByMe,
                        messageBorderRadius: messageBorderRadius,
                        color: color,
                        isOnlyEmoji: isOnlyEmoji,
                      );
                    },
                  ),
                ),
              ),
              if (!message.isSent) SendingAnimation(),
            ],
          ),
        ],
      ),
    );
  }

  void _handleMedia(File imageFile) {
    context.read<ChatsBloc>().add(
      UploadMediaChatEvent(mediaType: MessageType.image, file: imageFile),
    );
  }

  void _replyPayloadSetter(ReplyModel? payload) {
    setState(() {
      _replyPayload = payload;
    });
  }

  void _showBlockConfirmation() {
    ConfirmationDialogBuilder.show<void>(
      context,
      blurSigma: 20.0,
      ConfirmationDialogBuilder(
        icon: Icons.block_rounded,
        title: 'Block User?',
        message:
            'Are you sure you want to block ${widget.userName}?\n\nThis conversation will be deleted and they will no longer be able to contact you.',
        confirmText: 'Block',
        cancelText: 'Cancel',
        onConfirm: _onBlockConfirmed,
        iconColor: Theme.of(context).colorScheme.error,
        iconBackgroundColor: Theme.of(context).colorScheme.error.withValues(alpha: 0.12),
        cancelTextColor: Theme.of(context).colorScheme.onSurface,
        verticalButtons: true,
        primaryOnTop: true,
      ),
    );
  }

  // ADD THIS FUNCTION
  void _onBlockConfirmed() {
    // 1. Trigger the Bloc Event
    context.read<ConnectionsBloc>().add(
      BlockUserEvent(userIdToBlock: widget.currentChatUserId, chatRoomId: widget.chatRoomId),
    );

    // 2. Navigate back to connections page immediately
    Navigator.pop(context);

    // 3. Show feedback
    showScaffoldMessage(context: context, message: "User blocked successfully");
  }

  void _showReportDialog() {
    ConfirmationDialogBuilder.show<void>(
      context,
      blurSigma: 20.0,
      ConfirmationDialogBuilder(
        icon: Icons.flag_outlined,
        title: 'Report User',
        message: null,
        cancelText: 'Cancel',
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ],
        iconColor: Theme.of(context).colorScheme.error,
        iconBackgroundColor: Theme.of(context).colorScheme.error.withValues(alpha: 0.12),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildReportOption(context, 'Inappropriate messages'),
            _buildReportOption(context, 'Inappropriate photos'),
            _buildReportOption(context, 'Spam or Scam'),
            _buildReportOption(context, 'Harassment'),
            _buildReportOption(context, 'Other'),
          ],
        ),
      ),
    );
  }

  // 2. Helper widget for report options
  Widget _buildReportOption(BuildContext ctx, String reason) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
      child: Material(
        color: Theme.of(ctx).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          onTap: () {
            Navigator.pop(ctx); // Close dialog
            _onReportConfirmed(reason);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w, vertical: AppSpacing.md.h),
            child: Row(
              children: [
                Icon(Icons.flag_outlined, size: 18.sp, color: Theme.of(ctx).colorScheme.error),
                Gap(AppSpacing.md.w),
                Expanded(
                  child: Text(
                    reason,
                    style: Theme.of(ctx).textTheme.bodyLarge,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18.sp,
                  color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 3. Logic to trigger the Bloc event
  void _onReportConfirmed(String reason) {
    context.read<ConnectionsBloc>().add(
      ReportUserEvent(userIdToReport: widget.currentChatUserId, reason: reason),
    );

    showScaffoldMessage(
      context: context,
      message: "User reported. Thank you for making linkup safer.",
    );
  }

  @override
  Widget build(BuildContext context) {
    final pageBackgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        title: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            showBottomSheetUserProfile(
              context: context,
              userId: widget.currentChatUserId,
              showChatButton: false,
            );
          },
          child: Row(
            children: [
              ClipOval(
                child: OctoImage(
                  image: CachedNetworkImageProvider(widget.userImageMetaData['url']),
                  placeholderBuilder: blurHash(
                    widget.userImageMetaData['blurhash'],
                  ).placeholderBuilder,
                  fit: BoxFit.cover,
                  width: 30.r,
                  height: 30.r,
                ),
              ),
              Gap(AppSpacing.sm.w),
              Text(
                widget.userName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
              ),
            ],
          ),
        ),
        backgroundColor: pageBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.onSurface,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        // --- ADD THIS ACTIONS BLOCK ---
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurface),
            onSelected: (value) {
              if (value == 'block') {
                _showBlockConfirmation();
              } else if (value == 'report') {
                _showReportDialog(); // Trigger report flow
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'report',
                  child: Row(
                    children: [
                      Icon(
                        Icons.flag_outlined,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 20.sp,
                      ),
                      Gap(AppSpacing.sm.w),
                      Text(
                        'Report User',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'block',
                  child: Row(
                    children: [
                      Icon(Icons.block, color: Theme.of(context).colorScheme.error, size: 20.sp),
                      Gap(AppSpacing.sm.w),
                      Text(
                        'Block User',
                        style: AppTextStyles.destructive(context),
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
        // -------------------------------
      ),
      body: BlocConsumer<ChatsBloc, ChatsState>(
        listener: (context, state) {
          if (state is ChatsLoaded) {
            if (state.messages.length > _currentMessages.length) {
              final int newItemsCount = state.messages.length - _currentMessages.length;
              for (int i = 0; i < newItemsCount; i++) {
                _animatedListKey.currentState?.insertItem(
                  0,
                  duration: const Duration(milliseconds: 300),
                );
              }
            }
            _currentMessages = List.from(state.messages);
          }
        },
        builder: (context, state) {
          if (state is ChatsLoading) {
            return Center(
              child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
            );
          } else if (state is ChatsError) {
            return Center(
              child: Text(
                'Error loading messages',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            );
          } else if (state is ChatsLoaded) {
            if (_currentMessages.isEmpty && state.messages.isNotEmpty) {
              _currentMessages = List.from(state.messages);
            }
            if (!_initalSeenMarked) {
              context.read<ConnectionsBloc>().add(
                MarkMessagesSeenEvent(chatRoomId: widget.chatRoomId, decrementCounterTo: 0),
              );
              _initalSeenMarked = true;
            }

            _isSocketConnected = state.isSocketConnected;

            const int topWidgetCount = 1;
            final int totalItemCount = _currentMessages.length + 2 + topWidgetCount;

            return Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm.w),
                    child: AnimatedList(
                      key: _animatedListKey,
                      controller: _scrollController,
                      reverse: true,
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm.h),
                      initialItemCount: totalItemCount,
                      itemBuilder: (context, index, animation) {
                        // Index 0: Typing Indicator
                        if (index == 0) {
                          if (state.isTyping) {
                            return FadeTransition(
                              opacity: animation,
                              child: buildTypingIndicator(
                                context: context,
                                imageMetaData: widget.userImageMetaData,
                                userName: widget.userName,
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }

                        // Index 1: Seen Indicator
                        if (index == 1) {
                          if (state.messages.isNotEmpty &&
                              state.messages.last.from_ == widget.currentUserId &&
                              (state.otherUserSeenMsg || state.messages.last.isSeen)) {
                            return FadeTransition(
                              opacity: animation,
                              child: Padding(
                                padding: EdgeInsets.only(top: AppSpacing.xs.h),
                                child: buildSeenIndicator(),
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }

                        // Loading indicator for paginated
                        if (index == totalItemCount - 1 && state.isFetchingPaginatedMessages) {
                          return Center(
                            child: Container(
                              width: 20.w,
                              height: 20.h,
                              margin: EdgeInsets.symmetric(vertical: AppSpacing.sm.h),
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            ),
                          );
                        }

                        // --- CHAT MESSAGES ---
                        final chronologicalIndex =
                            _currentMessages.length - (index - (2 + topWidgetCount)) - 1;

                        if (chronologicalIndex < 0 ||
                            chronologicalIndex >= _currentMessages.length) {
                          return const SizedBox.shrink();
                        }

                        final message = _currentMessages[chronologicalIndex];

                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.5),
                            end: Offset.zero,
                          ).animate(animation),
                          child: _buildMessageItem(
                            message: message,
                            context: context,
                            messageIndex: chronologicalIndex,
                            messages: _currentMessages,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                MessageInputArea(
                  messageController: _messageController,
                  isTyping: _isTyping,
                  replyPayload: _replyPayload,
                  sendMessage: _sendMessage,
                  handleMedia: _handleMedia,
                  removeReplyPayload: () => _replyPayloadSetter(null),
                  userImageMetaData: widget.userImageMetaData,
                ),
              ],
            );
          } else {
            return Center(
              child: Text(
                'No messages yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
            );
          }
        },
      ),
    );
  }
}
