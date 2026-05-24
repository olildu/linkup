import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:linkup/data/enums/message_type_enum.dart';
import 'package:linkup/data/models/chats_connection_model.dart';
import 'package:linkup/data/models/matches_connection_model.dart';
import 'package:linkup/logic/bloc/chats/chats_bloc.dart';
import 'package:linkup/logic/bloc/connections/connections_bloc.dart';
import 'package:linkup/presentation/constants/colors.dart';
import 'package:linkup/presentation/screens/chat_page.dart';
import 'package:linkup/presentation/screens/user_profile_bottom_sheet.dart';
import 'package:linkup/presentation/utils/blurhash_util.dart';
import 'package:octo_image/octo_image.dart';

class ConnectionsPage extends StatefulWidget {
  const ConnectionsPage({super.key});

  @override
  State<ConnectionsPage> createState() => _YourPeoplePageState();
}

class _YourPeoplePageState extends State<ConnectionsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ConnectionsBloc>().add(ReloadChatConnectionsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(
          'Connections',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Theme.of(context).colorScheme.onSurface, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<ConnectionsBloc, ConnectionsState>(
                builder: (context, state) {
                  if (state is ConnectionsLoaded && state.matches.isNotEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitleSubtitle('Your Matches', 'See your matches and connect with them'),

                        Gap(15.h),

                        SizedBox(
                          height: 80.h,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: state.matches.length,
                            cacheExtent: 20,
                            itemBuilder: (context, index) {
                              return _buildAvatar(candidate: state.matches[index]);
                            },
                          ),
                        ),

                        Gap(15.h),
                      ],
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),

              _buildTitleSubtitle('Your Chats', 'See your chats and connect with them'),

              Expanded(
                child: BlocBuilder<ConnectionsBloc, ConnectionsState>(
                  builder: (context, state) {
                    if (state is ConnectionsLoaded) {
                      return ListView.builder(
                        itemCount: state.chats.length,
                        padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 10.h),
                        itemBuilder: (context, index) {
                          return _buildChatTile(candidate: state.chats[index]);
                        },
                      );
                    } else {
                      return Center(
                        child: Text(
                          'No chats available',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16.sp, color: Theme.of(context).colorScheme.onSurface),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar({required MatchesConnectionModel candidate, double diameter = 70.0}) {
    return GestureDetector(
      onTap: () {
        log('Tapped on ${candidate.username}\'s avatar');
        showBottomSheetUserProfile(context: context, userId: candidate.id);
      },
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: ClipOval(
          child: OctoImage(
            image: CachedNetworkImageProvider(candidate.profilePictureMetaData['url']),
            placeholderBuilder: blurHash(candidate.profilePictureMetaData['blurhash']).placeholderBuilder,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildChatTile({required ChatsConnectionModel candidate}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5.h),
      child: ListTile(
        onTap: () {
          log('Tapped on chat with ${candidate.username}');
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => ChatsBloc(
                  currentChatUserId: candidate.id,
                  currentUserId: GetIt.instance<int>(instanceName: 'user_id'),
                  chatRoomId: candidate.chatRoomId,
                  isar: GetIt.instance<Isar>(),
                )..add(StartChatsEvent()),
                child: ChatPage(
                  currentChatUserId: candidate.id,
                  currentUserId: GetIt.instance<int>(instanceName: 'user_id'),
                  userName: candidate.username,
                  userImageMetaData: candidate.profilePictureMetaData,
                  chatRoomId: candidate.chatRoomId,
                ),
              ),
            ),
          );
        },
        contentPadding: EdgeInsets.zero,
        leading: ClipOval(
          child: OctoImage(
            image: CachedNetworkImageProvider(candidate.profilePictureMetaData['url']),
            placeholderBuilder: blurHash(candidate.profilePictureMetaData['blurhash']).placeholderBuilder,
            fit: BoxFit.cover,
            width: 50.r,
            height: 50.r,
          ),
        ),

        title: Text(
          candidate.username,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
        ),
        subtitle: _buildMessageSubtitle(candidate),
        trailing: candidate.unseenCounter > 0
            ? Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: Text(
                  candidate.unseenCounter > 9 ? '9+' : candidate.unseenCounter.toString(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 12.sp, color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildMessageSubtitle(ChatsConnectionModel candidate) {
    if (candidate.messageType == MessageType.image) {
      return Row(
        children: [
          Icon(Icons.image, size: 16.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
          SizedBox(width: 6.w),
          Text(
            'Image',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
          ),
        ],
      );
    } else {
      if (candidate.message != null && candidate.message!.isNotEmpty) {
        return Text(
          candidate.message!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
        );
      } else {
        return Text(
          'No messages yet',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontStyle: FontStyle.italic),
        );
      }
    }
  }

  Widget _buildTitleSubtitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
        ),

        Gap(10.h),

        Text(subtitle, style: AppTextStyles.subtitle(context)?.copyWith(fontSize: 14.sp)),
      ],
    );
  }
}
