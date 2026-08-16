import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:linkup/core/network/custom_http_client.dart';
import 'package:linkup/core/network/token_service.dart';

import 'package:linkup/features/connections/data/isar_classes/chats_table.dart';
import 'package:linkup/features/messaging/data/isar_classes/message_table.dart';
import 'package:linkup/features/messaging/data/isar_classes/unsent_messages_table.dart';

import 'package:linkup/features/connections/data/chat_local_datasource.dart';
import 'package:linkup/features/messaging/data/message_local_datasource.dart';
import 'package:linkup/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:linkup/features/messaging/data/chat_remote_datasource.dart';
import 'package:linkup/features/city_lookup/data/city_lookup_remote_datasource.dart';
import 'package:linkup/features/likes/data/likes_remote_datasource.dart';
import 'package:linkup/features/discovery/data/match_remote_datasource.dart';
import 'package:linkup/features/profile/data/media_remote_datasource.dart';
import 'package:linkup/features/discovery/data/swipe_remote_datasource.dart';
import 'package:linkup/features/profile/data/user_remote_datasource.dart';

import 'package:linkup/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:linkup/features/messaging/data/chat_repository_impl.dart';
import 'package:linkup/features/city_lookup/data/city_lookup_repository_impl.dart';
import 'package:linkup/features/likes/data/likes_repository_impl.dart';
import 'package:linkup/features/discovery/data/match_repository_impl.dart';
import 'package:linkup/features/profile/data/media_repository_impl.dart';
import 'package:linkup/features/profile/data/user_repository_impl.dart';

import 'package:linkup/features/auth/domain/repositories/auth_repository.dart';
import 'package:linkup/features/messaging/domain/chat_repository.dart';
import 'package:linkup/features/city_lookup/domain/city_lookup_repository.dart';
import 'package:linkup/features/likes/domain/likes_repository.dart';
import 'package:linkup/features/discovery/domain/match_repository.dart';
import 'package:linkup/features/profile/domain/media_repository.dart';
import 'package:linkup/features/profile/domain/user_repository.dart';

import 'package:linkup/features/auth/domain/use_cases/complete_profile_use_case.dart';
import 'package:linkup/features/auth/domain/use_cases/delete_account_use_case.dart';
import 'package:linkup/features/auth/domain/use_cases/login_use_case.dart';
import 'package:linkup/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:linkup/features/auth/domain/use_cases/register_use_case.dart';
import 'package:linkup/features/auth/domain/use_cases/reset_password_use_case.dart';
import 'package:linkup/features/auth/domain/use_cases/send_otp_use_case.dart';
import 'package:linkup/features/auth/domain/use_cases/verify_otp_use_case.dart';

import 'package:linkup/features/messaging/domain/cache_message_use_case.dart';
import 'package:linkup/features/messaging/domain/delete_unsent_by_message_id_use_case.dart';
import 'package:linkup/features/messaging/domain/delete_unsent_message_use_case.dart';
import 'package:linkup/features/messaging/domain/fetch_messages_use_case.dart';
import 'package:linkup/features/messaging/domain/get_cached_messages_use_case.dart';
import 'package:linkup/features/messaging/domain/get_unsent_messages_use_case.dart';
import 'package:linkup/features/messaging/domain/paginate_messages_use_case.dart';
import 'package:linkup/features/messaging/domain/save_unsent_message_use_case.dart';
import 'package:linkup/features/messaging/domain/start_chat_use_case.dart';
import 'package:linkup/features/messaging/domain/upload_chat_media_use_case.dart';

import 'package:linkup/features/likes/domain/get_likes_count_use_case.dart';
import 'package:linkup/features/likes/domain/get_received_likes_use_case.dart';
import 'package:linkup/features/likes/domain/like_back_use_case.dart';
import 'package:linkup/features/likes/domain/pass_like_use_case.dart';

import 'package:linkup/features/connections/domain/cache_connections_use_case.dart';
import 'package:linkup/features/connections/domain/get_cached_connections_use_case.dart';
import 'package:linkup/features/connections/domain/get_connections_use_case.dart';
import 'package:linkup/features/discovery/domain/load_matches_use_case.dart';
import 'package:linkup/features/discovery/domain/swipe_use_case.dart';

import 'package:linkup/features/profile/domain/upload_pfp_from_url_use_case.dart';
import 'package:linkup/features/profile/domain/upload_pfp_use_case.dart';
import 'package:linkup/features/profile/domain/upload_user_media_use_case.dart';

import 'package:linkup/features/connections/domain/block_user_use_case.dart';
import 'package:linkup/features/profile/domain/get_other_profile_use_case.dart';
import 'package:linkup/features/profile/domain/get_preference_use_case.dart';
import 'package:linkup/features/profile/domain/get_profile_use_case.dart';
import 'package:linkup/features/connections/domain/report_user_use_case.dart';
import 'package:linkup/features/profile/domain/update_preference_use_case.dart';
import 'package:linkup/features/profile/domain/update_profile_use_case.dart';

import 'package:linkup/features/city_lookup/domain/search_cities_use_case.dart';

import 'package:linkup/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:linkup/features/connections/presentation/bloc/connections_bloc.dart';
import 'package:linkup/features/likes/presentation/bloc/likes_bloc.dart';
import 'package:linkup/features/auth/presentation/bloc/login_bloc.dart';
import 'package:linkup/features/discovery/presentation/bloc/matches_bloc.dart';
import 'package:linkup/features/auth/presentation/bloc/otp_bloc.dart';
import 'package:linkup/features/profile/presentation/bloc/other_profile_bloc.dart';
import 'package:linkup/features/profile/presentation/bloc/preferences_bloc.dart';
import 'package:linkup/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:linkup/features/messaging/presentation/bloc/chat_sockets_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── Core ─────────────────────────────────────────────────────────────────

  final storage = const FlutterSecureStorage();
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [MessageTableSchema, ChatsTableSchema, UnsentMessagesTableSchema],
    directory: dir.path,
    inspector: kDebugMode,
  );

  // FlutterSecureStorage must be registered before CustomHttpClient is
  // constructed, because CustomHttpClient reads it from GetIt at init time.
  sl.registerSingleton<FlutterSecureStorage>(storage);
  sl.registerSingleton<CustomHttpClient>(CustomHttpClient());
  sl.registerSingleton<Isar>(isar);
  sl.registerSingleton<TokenService>(TokenService(storage));

  // ── Datasources ───────────────────────────────────────────────────────────

  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasource(sl()),
  );
  sl.registerLazySingleton<UserRemoteDatasource>(
    () => UserRemoteDatasource(sl()),
  );
  sl.registerLazySingleton<ChatRemoteDatasource>(
    () => ChatRemoteDatasource(sl()),
  );
  sl.registerLazySingleton<MatchRemoteDatasource>(
    () => MatchRemoteDatasource(sl()),
  );
  sl.registerLazySingleton<LikesRemoteDatasource>(
    () => LikesRemoteDatasource(sl()),
  );
  sl.registerLazySingleton<SwipeRemoteDatasource>(
    () => SwipeRemoteDatasource(sl()),
  );
  sl.registerLazySingleton<MediaRemoteDatasource>(
    () => MediaRemoteDatasource(sl()),
  );
  sl.registerLazySingleton<CityLookupRemoteDatasource>(
    () => CityLookupRemoteDatasource(sl()),
  );

  sl.registerLazySingleton<MessageLocalDatasource>(
    () => MessageLocalDatasource(sl()),
  );
  sl.registerLazySingleton<ChatLocalDatasource>(
    () => ChatLocalDatasource(sl()),
  );

  // ── Repositories ──────────────────────────────────────────────────────────

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authDatasource: sl(),
      userDatasource: sl(),
      tokenService: sl(),
    ),
  );

  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(sl()));

  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      chatDatasource: sl(),
      mediaDatasource: sl(),
      localDatasource: sl(),
    ),
  );

  sl.registerLazySingleton<MatchRepository>(
    () => MatchRepositoryImpl(
      matchDatasource: sl(),
      swipeDatasource: sl(),
      chatLocalDatasource: sl(),
    ),
  );

  sl.registerLazySingleton<LikesRepository>(
    () => LikesRepositoryImpl(likesDatasource: sl()),
  );

  sl.registerLazySingleton<MediaRepository>(() => MediaRepositoryImpl(sl()));

  sl.registerLazySingleton<CityLookupRepository>(
    () => CityLookupRepositoryImpl(sl()),
  );

  // ── Use cases — auth ──────────────────────────────────────────────────────

  sl.registerFactory(() => LoginUseCase(sl()));
  sl.registerFactory(() => LogoutUseCase(sl()));
  sl.registerFactory(() => RegisterUseCase(sl()));
  sl.registerFactory(() => ResetPasswordUseCase(sl()));
  sl.registerFactory(() => SendOTPUseCase(sl()));
  sl.registerFactory(() => VerifyOTPUseCase(sl()));
  sl.registerFactory(() => CompleteProfileUseCase(sl()));
  sl.registerFactory(() => DeleteAccountUseCase(sl<AuthRepository>()));

  // ── Use cases — user ──────────────────────────────────────────────────────

  sl.registerFactory(() => GetProfileUseCase(sl()));
  sl.registerFactory(() => GetOtherProfileUseCase(sl()));
  sl.registerFactory(() => UpdateProfileUseCase(sl()));
  sl.registerFactory(() => GetPreferenceUseCase(sl()));
  sl.registerFactory(() => UpdatePreferenceUseCase(sl()));
  sl.registerFactory(() => BlockUserUseCase(sl()));
  sl.registerFactory(() => ReportUserUseCase(sl()));

  // ── Use cases — chat ──────────────────────────────────────────────────────

  sl.registerFactory(() => FetchMessagesUseCase(sl()));
  sl.registerFactory(() => PaginateMessagesUseCase(sl()));
  sl.registerFactory(() => GetCachedMessagesUseCase(sl()));
  sl.registerFactory(() => CacheMessageUseCase(sl()));
  sl.registerFactory(() => SaveUnsentMessageUseCase(sl()));
  sl.registerFactory(() => GetUnsentMessagesUseCase(sl()));
  sl.registerFactory(() => DeleteUnsentMessageUseCase(sl()));
  sl.registerFactory(() => DeleteUnsentByMessageIdUseCase(sl()));
  sl.registerFactory(() => StartChatUseCase(sl()));
  sl.registerFactory(() => UploadChatMediaUseCase(sl()));

  // ── Use cases — match ─────────────────────────────────────────────────────

  sl.registerFactory(() => LoadMatchesUseCase(sl()));
  sl.registerFactory(() => SwipeUseCase(sl()));
  sl.registerFactory(() => GetConnectionsUseCase(sl()));
  sl.registerFactory(() => CacheConnectionsUseCase(sl()));
  sl.registerFactory(() => GetCachedConnectionsUseCase(sl()));

  // ── Use cases — likes ─────────────────────────────────────────────────────

  sl.registerFactory(() => GetReceivedLikesUseCase(sl()));
  sl.registerFactory(() => GetLikesCountUseCase(sl()));
  sl.registerFactory(() => LikeBackUseCase(sl()));
  sl.registerFactory(() => PassLikeUseCase(sl()));

  // ── Use cases — media ─────────────────────────────────────────────────────

  sl.registerFactory(() => UploadUserMediaUseCase(sl()));
  sl.registerFactory(() => UploadPfpUseCase(sl()));
  sl.registerFactory(() => UploadPfpFromUrlUseCase(sl()));

  // ── Use cases — city ──────────────────────────────────────────────────────

  sl.registerFactory(() => SearchCitiesUseCase(sl()));

  // ── Blocs (singletons — shared across the widget tree via MultiBlocProvider) ──

  sl.registerLazySingleton<MatchesBloc>(
    () => MatchesBloc(loadMatchesUseCase: sl(), swipeUseCase: sl()),
  );

  sl.registerLazySingleton<ConnectionsBloc>(
    () => ConnectionsBloc(
      getConnectionsUseCase: sl(),
      cacheConnectionsUseCase: sl(),
      getCachedConnectionsUseCase: sl(),
      blockUserUseCase: sl(),
      reportUserUseCase: sl(),
    ),
  );

  sl.registerLazySingleton<LikesBloc>(
    () => LikesBloc(
      getReceivedLikesUseCase: sl(),
      getLikesCountUseCase: sl(),
      likeBackUseCase: sl(),
      passLikeUseCase: sl(),
    ),
  );

  sl.registerLazySingleton<ProfileBloc>(
    () => ProfileBloc(
      getProfileUseCase: sl(),
      updateProfileUseCase: sl(),
      uploadUserMediaUseCase: sl(),
      uploadPfpFromUrlUseCase: sl(),
    ),
  );

  sl.registerLazySingleton<ChatSocketsBloc>(
    () => ChatSocketsBloc(
      getUnsentMessagesUseCase: sl(),
      deleteUnsentByMessageIdUseCase: sl(),
    ),
  );

  // ── Blocs (factories — fresh instance per screen) ─────────────────────────

  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: sl(),
      logoutUseCase: sl(),
      registerUseCase: sl(),
      resetPasswordUseCase: sl(),
      deleteAccountUseCase: sl(),
    ),
  );

  sl.registerFactory<LoginBloc>(() => LoginBloc(loginUseCase: sl()));

  sl.registerFactory<OtpBloc>(
    () => OtpBloc(sendOTPUseCase: sl(), verifyOTPUseCase: sl()),
  );

  sl.registerFactory<PreferencesBloc>(
    () => PreferencesBloc(
      getPreferenceUseCase: sl(),
      updatePreferenceUseCase: sl(),
    ),
  );

  sl.registerFactory<OtherProfileBloc>(
    () => OtherProfileBloc(getOtherProfileUseCase: sl()),
  );
}
