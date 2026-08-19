// Central mocktail mocks shared across suites. Add mocks here as layers gain
// coverage so every suite pulls from one place.
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:linkup/core/network/custom_http_client.dart';
import 'package:linkup/core/network/token_service.dart';
import 'package:linkup/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:linkup/features/auth/domain/use_cases/complete_profile_use_case.dart';
import 'package:linkup/features/auth/domain/use_cases/delete_account_use_case.dart';
import 'package:linkup/features/auth/domain/use_cases/login_use_case.dart';
import 'package:linkup/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:linkup/features/auth/domain/use_cases/register_use_case.dart';
import 'package:linkup/features/auth/domain/use_cases/reset_password_use_case.dart';
import 'package:linkup/features/auth/domain/use_cases/send_otp_use_case.dart';
import 'package:linkup/features/auth/domain/use_cases/verify_otp_use_case.dart';
import 'package:linkup/features/city_lookup/data/city_lookup_remote_datasource.dart';
import 'package:linkup/features/city_lookup/domain/search_cities_use_case.dart';
import 'package:linkup/features/discovery/domain/load_matches_use_case.dart';
import 'package:linkup/features/discovery/domain/swipe_use_case.dart';
import 'package:linkup/features/profile/domain/get_other_profile_use_case.dart';
import 'package:linkup/features/profile/domain/get_preference_use_case.dart';
import 'package:linkup/features/profile/domain/get_profile_use_case.dart';
import 'package:linkup/features/profile/domain/update_preference_use_case.dart';
import 'package:linkup/features/profile/domain/update_profile_use_case.dart';
import 'package:linkup/features/profile/domain/upload_pfp_from_url_use_case.dart';
import 'package:linkup/features/profile/domain/upload_pfp_use_case.dart';
import 'package:linkup/features/profile/domain/upload_user_media_use_case.dart';
import 'package:linkup/features/connections/data/chat_local_datasource.dart';
import 'package:linkup/features/discovery/data/match_remote_datasource.dart';
import 'package:linkup/features/discovery/data/swipe_remote_datasource.dart';
import 'package:linkup/features/likes/data/likes_remote_datasource.dart';
import 'package:linkup/features/messaging/data/chat_remote_datasource.dart';
import 'package:linkup/features/messaging/data/message_local_datasource.dart';
import 'package:linkup/features/profile/data/media_remote_datasource.dart';
import 'package:linkup/features/profile/data/user_remote_datasource.dart';
import 'package:linkup/features/auth/domain/repositories/auth_repository.dart';
import 'package:linkup/features/connections/domain/block_user_use_case.dart';
import 'package:linkup/features/connections/domain/cache_connections_use_case.dart';
import 'package:linkup/features/connections/domain/get_cached_connections_use_case.dart';
import 'package:linkup/features/connections/domain/get_connections_use_case.dart';
import 'package:linkup/features/connections/domain/report_user_use_case.dart';
import 'package:linkup/features/likes/domain/get_likes_count_use_case.dart';
import 'package:linkup/features/likes/domain/get_received_likes_use_case.dart';
import 'package:linkup/features/likes/domain/like_back_use_case.dart';
import 'package:linkup/features/likes/domain/pass_like_use_case.dart';
import 'package:linkup/features/messaging/domain/cache_message_use_case.dart';
import 'package:linkup/features/messaging/domain/delete_unsent_by_message_id_use_case.dart';
import 'package:linkup/features/messaging/domain/fetch_messages_use_case.dart';
import 'package:linkup/features/messaging/domain/get_cached_messages_use_case.dart';
import 'package:linkup/features/messaging/domain/get_unsent_messages_use_case.dart';
import 'package:linkup/features/messaging/domain/paginate_messages_use_case.dart';
import 'package:linkup/features/messaging/domain/save_unsent_message_use_case.dart';
import 'package:linkup/features/messaging/domain/upload_chat_media_use_case.dart';
import 'package:linkup/features/city_lookup/domain/city_lookup_repository.dart';
import 'package:linkup/features/discovery/domain/match_repository.dart';
import 'package:linkup/features/likes/domain/likes_repository.dart';
import 'package:linkup/features/messaging/domain/chat_repository.dart';
import 'package:linkup/features/profile/domain/media_repository.dart';
import 'package:linkup/features/profile/domain/user_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockCustomHttpClient extends Mock implements CustomHttpClient {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockChatRepository extends Mock implements ChatRepository {}

class MockCityLookupRepository extends Mock implements CityLookupRepository {}

class MockLikesRepository extends Mock implements LikesRepository {}

class MockMatchRepository extends Mock implements MatchRepository {}

class MockMediaRepository extends Mock implements MediaRepository {}

class MockUserRepository extends Mock implements UserRepository {}

// ── Use-case mocks (for bloc tests) ──────────────────────────────────────
class MockGetUnsentMessagesUseCase extends Mock
    implements GetUnsentMessagesUseCase {}

class MockDeleteUnsentByMessageIdUseCase extends Mock
    implements DeleteUnsentByMessageIdUseCase {}

class MockFetchMessagesUseCase extends Mock implements FetchMessagesUseCase {}

class MockGetCachedMessagesUseCase extends Mock
    implements GetCachedMessagesUseCase {}

class MockCacheMessageUseCase extends Mock implements CacheMessageUseCase {}

class MockSaveUnsentMessageUseCase extends Mock
    implements SaveUnsentMessageUseCase {}

class MockUploadChatMediaUseCase extends Mock
    implements UploadChatMediaUseCase {}

class MockPaginateMessagesUseCase extends Mock
    implements PaginateMessagesUseCase {}

class MockGetConnectionsUseCase extends Mock implements GetConnectionsUseCase {}

class MockCacheConnectionsUseCase extends Mock
    implements CacheConnectionsUseCase {}

class MockGetCachedConnectionsUseCase extends Mock
    implements GetCachedConnectionsUseCase {}

class MockBlockUserUseCase extends Mock implements BlockUserUseCase {}

class MockReportUserUseCase extends Mock implements ReportUserUseCase {}

class MockGetReceivedLikesUseCase extends Mock
    implements GetReceivedLikesUseCase {}

class MockGetLikesCountUseCase extends Mock implements GetLikesCountUseCase {}

class MockLikeBackUseCase extends Mock implements LikeBackUseCase {}

class MockPassLikeUseCase extends Mock implements PassLikeUseCase {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockResetPasswordUseCase extends Mock implements ResetPasswordUseCase {}

class MockDeleteAccountUseCase extends Mock implements DeleteAccountUseCase {}

class MockSendOTPUseCase extends Mock implements SendOTPUseCase {}

class MockVerifyOTPUseCase extends Mock implements VerifyOTPUseCase {}

class MockCompleteProfileUseCase extends Mock
    implements CompleteProfileUseCase {}

class MockLoadMatchesUseCase extends Mock implements LoadMatchesUseCase {}

class MockSwipeUseCase extends Mock implements SwipeUseCase {}

class MockGetProfileUseCase extends Mock implements GetProfileUseCase {}

class MockUpdateProfileUseCase extends Mock implements UpdateProfileUseCase {}

class MockUploadUserMediaUseCase extends Mock
    implements UploadUserMediaUseCase {}

class MockUploadPfpUseCase extends Mock implements UploadPfpUseCase {}

class MockUploadPfpFromUrlUseCase extends Mock
    implements UploadPfpFromUrlUseCase {}

class MockGetOtherProfileUseCase extends Mock
    implements GetOtherProfileUseCase {}

class MockGetPreferenceUseCase extends Mock implements GetPreferenceUseCase {}

class MockUpdatePreferenceUseCase extends Mock
    implements UpdatePreferenceUseCase {}

class MockSearchCitiesUseCase extends Mock implements SearchCitiesUseCase {}

// ── Datasource / service mocks (for repository tests) ────────────────────
class MockAuthRemoteDatasource extends Mock implements AuthRemoteDatasource {}

class MockUserRemoteDatasource extends Mock implements UserRemoteDatasource {}

class MockTokenService extends Mock implements TokenService {}

class MockCityLookupRemoteDatasource extends Mock
    implements CityLookupRemoteDatasource {}

class MockMatchRemoteDatasource extends Mock
    implements MatchRemoteDatasource {}

class MockSwipeRemoteDatasource extends Mock
    implements SwipeRemoteDatasource {}

class MockChatLocalDatasource extends Mock implements ChatLocalDatasource {}

class MockChatRemoteDatasource extends Mock implements ChatRemoteDatasource {}

class MockMediaRemoteDatasource extends Mock
    implements MediaRemoteDatasource {}

class MockMessageLocalDatasource extends Mock
    implements MessageLocalDatasource {}

class MockLikesRemoteDatasource extends Mock
    implements LikesRemoteDatasource {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

/// Call once from setUpAll in suites that stub methods taking Uri arguments.
void registerCommonFallbacks() {
  registerFallbackValue(FakeUri());
}
