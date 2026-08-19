// Canonical entity builders shared across suites. Every builder returns a
// fully-populated instance; override only what a test cares about.
import 'package:linkup/core/entities/matches_connection_entity.dart';
import 'package:linkup/core/enums/message_type_enum.dart';
import 'package:linkup/features/connections/domain/chat_connection_entity.dart';
import 'package:linkup/features/discovery/domain/match_candidate_entity.dart';
import 'package:linkup/features/likes/domain/likes_you_entry_entity.dart';
import 'package:linkup/features/messaging/domain/media_message_entity.dart';
import 'package:linkup/features/messaging/domain/message_entity.dart';
import 'package:linkup/features/profile/domain/user_entity.dart';
import 'package:linkup/features/profile/domain/user_preference_entity.dart';

MessageEntity makeMessage({
  String id = 'msg-1',
  String message = 'hello',
  String? replyID,
  int to = 2,
  int from = 1,
  int chatRoomId = 10,
  bool isSeen = false,
  bool isSent = true,
  DateTime? timestamp,
  MediaMessageEntity? media,
}) => MessageEntity(
  id: id,
  message: message,
  replyID: replyID,
  to: to,
  from_: from,
  chatRoomId: chatRoomId,
  isSeen: isSeen,
  isSent: isSent,
  timestamp: timestamp ?? DateTime(2026, 1, 1, 12),
  media: media,
);

MediaMessageEntity makeMedia({
  String fileKey = 'file-key',
  MessageType mediaType = MessageType.image,
  String blurhashText = 'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
  Map<String, dynamic>? metadata,
}) => MediaMessageEntity(
  fileKey: fileKey,
  mediaType: mediaType,
  blurhashText: blurhashText,
  metadata: metadata ?? const {'width': 100, 'height': 100},
);

MatchCandidateEntity makeCandidate({
  int id = 7,
  String username = 'alice',
  String gender = 'female',
}) => MatchCandidateEntity(
  id: id,
  username: username,
  gender: gender,
  universityId: 1,
  profilePictureMetaData: const <String, dynamic>{'url': 'https://cdn.test/pic.jpg', 'file_key': 'fk-pic', 'blurhash': 'LEHV6nWB2yk8pyo0adR*.7kCMdnj'},
  dob: DateTime(2000, 5, 20),
  universityMajor: 'CS',
  universityYear: 3,
  photos: const [
    <String, dynamic>{
      'url': 'https://cdn.test/a.jpg',
      'file_key': 'fk-a',
      'blurhash': 'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
    },
  ],
  about: 'about me',
  currentlyStaying: 'City A',
  hometown: 'City B',
  height: 170,
  weight: 60,
  religion: 'none',
  smokingInfo: 'never',
  drinkingInfo: 'socially',
  lookingFor: 'friends',
);

UserEntity makeUser({int id = 1, String username = 'me', int universityId = 1}) =>
    UserEntity(
  id: id,
  universityId: universityId,
  username: username,
  gender: 'male',
  profilePicture: const <String, dynamic>{'url': 'https://cdn.test/me.jpg', 'file_key': 'fk-me', 'blurhash': 'LEHV6nWB2yk8pyo0adR*.7kCMdnj'},
  dob: DateTime(1999, 3, 15),
  interestedGender: 'female',
  universityMajor: 'EE',
  universityYear: 4,
  photos: const [
    <String, dynamic>{
      'url': 'https://cdn.test/p1.jpg',
      'file_key': 'fk-p1',
      'blurhash': 'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
    },
  ],
  about: 'hi',
  currentlyStaying: 'City A',
  hometown: 'City C',
  height: 180,
  weight: 75,
  religion: 'none',
  smokingInfo: 'never',
  drinkingInfo: 'never',
  lookingFor: 'relationship',
);

UserPreferenceEntity makePreference() => const UserPreferenceEntity(
  interestedGender: 'female',
  height: 165,
  weight: 55,
  religion: 'none',
  drinkingStatus: false,
  smokingStatus: false,
  lookingFor: 'relationship',
  currentlyStaying: 'City A',
);

ChatConnectionEntity makeChatConnection({
  int id = 3,
  int chatRoomId = 10,
  int unseenCounter = 2,
}) => ChatConnectionEntity(
  id: id,
  username: 'bob',
  profilePictureMetaData: const <String, dynamic>{'url': 'https://cdn.test/bob.jpg', 'file_key': 'fk-bob', 'blurhash': 'LEHV6nWB2yk8pyo0adR*.7kCMdnj'},
  chatRoomId: chatRoomId,
  unseenCounter: unseenCounter,
  message: 'last message',
  messageType: MessageType.text,
);

MatchesConnectionEntity makeMatchesConnection({int id = 4}) =>
    MatchesConnectionEntity(
      id: id,
      username: 'carol',
      profilePictureMetaData: const <String, dynamic>{'url': 'https://cdn.test/carol.jpg', 'file_key': 'fk-carol', 'blurhash': 'LEHV6nWB2yk8pyo0adR*.7kCMdnj'},
    );

LikesYouEntryEntity makeLikesEntry({int id = 5, bool revealed = false}) =>
    LikesYouEntryEntity(
      id: id,
      revealed: revealed,
      profile: revealed ? makeCandidate() : null,
      firstPhoto: const <String, dynamic>{
        'url': 'https://cdn.test/blur.jpg',
        'file_key': 'fk-blur',
        'blurhash': 'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
      },
    );
