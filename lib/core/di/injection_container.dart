import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:linkup/core/network/custom_http_client.dart';
import 'package:linkup/core/network/token_service.dart';

import 'package:linkup/data/isar_classes/chats_table.dart';
import 'package:linkup/data/isar_classes/message_table.dart';
import 'package:linkup/data/isar_classes/unsent_messages_table.dart';

import 'package:linkup/data/datasources/local/chat_local_datasource.dart';
import 'package:linkup/data/datasources/local/message_local_datasource.dart';
import 'package:linkup/data/datasources/remote/auth_remote_datasource.dart';
import 'package:linkup/data/datasources/remote/chat_remote_datasource.dart';
import 'package:linkup/data/datasources/remote/city_lookup_remote_datasource.dart';
import 'package:linkup/data/datasources/remote/likes_remote_datasource.dart';
import 'package:linkup/data/datasources/remote/match_remote_datasource.dart';
import 'package:linkup/data/datasources/remote/media_remote_datasource.dart';
import 'package:linkup/data/datasources/remote/swipe_remote_datasource.dart';
import 'package:linkup/data/datasources/remote/user_remote_datasource.dart';

import 'package:linkup/data/repositories/auth_repository_impl.dart';
import 'package:linkup/data/repositories/chat_repository_impl.dart';
import 'package:linkup/data/repositories/city_lookup_repository_impl.dart';
import 'package:linkup/data/repositories/likes_repository_impl.dart';
import 'package:linkup/data/repositories/match_repository_impl.dart';
import 'package:linkup/data/repositories/media_repository_impl.dart';
import 'package:linkup/data/repositories/user_repository_impl.dart';

import 'package:linkup/domain/repositories/auth_repository.dart';
import 'package:linkup/domain/repositories/chat_repository.dart';
import 'package:linkup/domain/repositories/city_lookup_repository.dart';
import 'package:linkup/domain/repositories/likes_repository.dart';
import 'package:linkup/domain/repositories/match_repository.dart';
import 'package:linkup/domain/repositories/media_repository.dart';
import 'package:linkup/domain/repositories/user_repository.dart';

import 'package:linkup/domain/use_cases/auth/complete_profile_use_case.dart';
import 'package:linkup/domain/use_cases/auth/delete_account_use_case.dart';
import 'package:linkup/domain/use_cases/auth/login_use_case.dart';
import 'package:linkup/domain/use_cases/auth/logout_use_case.dart';
import 'package:linkup/domain/use_cases/auth/register_use_case.dart';
import 'package:linkup/domain/use_cases/auth/reset_password_use_case.dart';
import 'package:linkup/domain/use_cases/auth/send_otp_use_case.dart';
import 'package:linkup/domain/use_cases/auth/verify_otp_use_case.dart';

import 'package:linkup/domain/use_cases/chat/cache_message_use_case.dart';
import 'package:linkup/domain/use_cases/chat/delete_unsent_by_message_id_use_case.dart';
import 'package:linkup/domain/use_cases/chat/delete_unsent_message_use_case.dart';
import 'package:linkup/domain/use_cases/chat/fetch_messages_use_case.dart';
import 'package:linkup/domain/use_cases/chat/get_cached_messages_use_case.dart';
import 'package:linkup/domain/use_cases/chat/get_unsent_messages_use_case.dart';
import 'package:linkup/domain/use_cases/chat/paginate_messages_use_case.dart';
import 'package:linkup/domain/use_cases/chat/save_unsent_message_use_case.dart';
import 'package:linkup/domain/use_cases/chat/start_chat_use_case.dart';
import 'package:linkup/domain/use_cases/chat/upload_chat_media_use_case.dart';

import 'package:linkup/domain/use_cases/likes/get_received_likes_use_case.dart';
import 'package:linkup/domain/use_cases/likes/get_unseen_likes_count_use_case.dart';
import 'package:linkup/domain/use_cases/likes/like_back_use_case.dart';
import 'package:linkup/domain/use_cases/likes/pass_like_use_case.dart';

import 'package:linkup/domain/use_cases/match/cache_connections_use_case.dart';
import 'package:linkup/domain/use_cases/match/get_cached_connections_use_case.dart';
import 'package:linkup/domain/use_cases/match/get_connections_use_case.dart';
import 'package:linkup/domain/use_cases/match/load_matches_use_case.dart';
import 'package:linkup/domain/use_cases/match/swipe_use_case.dart';

import 'package:linkup/domain/use_cases/media/upload_pfp_from_url_use_case.dart';
import 'package:linkup/domain/use_cases/media/upload_pfp_use_case.dart';
import 'package:linkup/domain/use_cases/media/upload_user_media_use_case.dart';

import 'package:linkup/domain/use_cases/user/block_user_use_case.dart';
import 'package:linkup/domain/use_cases/user/get_other_profile_use_case.dart';
import 'package:linkup/domain/use_cases/user/get_preference_use_case.dart';
import 'package:linkup/domain/use_cases/user/get_profile_use_case.dart';
import 'package:linkup/domain/use_cases/user/report_user_use_case.dart';
import 'package:linkup/domain/use_cases/user/update_preference_use_case.dart';
import 'package:linkup/domain/use_cases/user/update_profile_use_case.dart';

import 'package:linkup/domain/use_cases/city/search_cities_use_case.dart';

import 'package:linkup/logic/bloc/auth/auth_bloc.dart';
import 'package:linkup/logic/bloc/connections/connections_bloc.dart';
import 'package:linkup/logic/bloc/likes/likes_bloc.dart';
import 'package:linkup/logic/bloc/login/login_bloc.dart';
import 'package:linkup/logic/bloc/matches/matches_bloc.dart';
import 'package:linkup/logic/bloc/otp/otp_bloc.dart';
import 'package:linkup/logic/bloc/profile/others/other_profile_bloc.dart';
import 'package:linkup/logic/bloc/profile/own/preferences_bloc/preferences_bloc.dart';
import 'package:linkup/logic/bloc/profile/own/profile_bloc.dart';
import 'package:linkup/logic/bloc/web_socket/chat_sockets/chat_sockets_bloc.dart';

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
  sl.registerFactory(() => GetUnseenLikesCountUseCase(sl()));
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
      getUnseenLikesCountUseCase: sl(),
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
