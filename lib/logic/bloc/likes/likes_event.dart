part of 'likes_bloc.dart';

@immutable
sealed class LikesEvent {}

class LoadUnseenCountEvent extends LikesEvent {}

class LoadReceivedLikesEvent extends LikesEvent {
  final bool refresh;

  LoadReceivedLikesEvent({this.refresh = false});
}

class LikeBackEvent extends LikesEvent {
  final int likerId;

  LikeBackEvent({required this.likerId});
}

class PassLikeEvent extends LikesEvent {
  final int likerId;

  PassLikeEvent({required this.likerId});
}

class ClearLikesMatchUserEvent extends LikesEvent {}
