// Mocktail mocks for every bloc/cubit that screens read from context.
// Use [stubBloc] to give a mock a fixed state (and optionally a stream of
// follow-up states) before pumping the widget under test.
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:linkup/core/cubits/connectivity/connectivity_cubit_cubit.dart';
import 'package:linkup/core/cubits/theme/theme_cubit.dart';
import 'package:linkup/core/utils/data_validator_provider.dart';
import 'package:linkup/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:linkup/features/auth/presentation/bloc/login_bloc.dart';
import 'package:linkup/features/auth/presentation/bloc/otp_bloc.dart';
import 'package:linkup/features/connections/presentation/bloc/connections_bloc.dart';
import 'package:linkup/features/connections/presentation/bloc/connections_socket_bloc.dart';
import 'package:linkup/features/discovery/presentation/bloc/matches_bloc.dart';
import 'package:linkup/features/likes/presentation/bloc/likes_bloc.dart';
import 'package:linkup/features/lobby/presentation/bloc/lobby_bloc.dart';
import 'package:linkup/features/messaging/presentation/bloc/chat_sockets_bloc.dart';
import 'package:linkup/features/messaging/presentation/bloc/chats_bloc.dart';
import 'package:linkup/features/messaging/presentation/bloc/web_socket_bloc.dart';
import 'package:linkup/features/onboarding/presentation/bloc/post_login_bloc.dart';
import 'package:linkup/features/onboarding/presentation/bloc/signup_bloc.dart';
import 'package:linkup/features/profile/presentation/bloc/camera_bloc.dart';
import 'package:linkup/features/profile/presentation/bloc/other_profile_bloc.dart';
import 'package:linkup/features/profile/presentation/bloc/preferences_bloc.dart';
import 'package:linkup/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:linkup/features/settings/presentation/app_lock_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

class MockLoginBloc extends Mock implements LoginBloc {}

class MockOtpBloc extends Mock implements OtpBloc {}

class MockMatchesBloc extends Mock implements MatchesBloc {}

class MockLikesBloc extends Mock implements LikesBloc {}

class MockConnectionsBloc extends Mock implements ConnectionsBloc {}

class MockConnectionsSocketBloc extends Mock implements ConnectionsSocketBloc {}

class MockChatsBloc extends Mock implements ChatsBloc {}

class MockChatSocketsBloc extends Mock implements ChatSocketsBloc {}

class MockWebSocketBloc extends Mock implements WebSocketBloc {}

class MockProfileBloc extends Mock implements ProfileBloc {}

class MockOtherProfileBloc extends Mock implements OtherProfileBloc {}

class MockPreferencesBloc extends Mock implements PreferencesBloc {}

class MockSignupBloc extends Mock implements SignupBloc {}

class MockPostLoginBloc extends Mock implements PostLoginBloc {}

class MockLobbyBloc extends Mock implements LobbyBloc {}

class MockCameraBloc extends Mock implements CameraBloc {}

class MockThemeCubit extends Mock implements ThemeCubit {}

class MockConnectivityCubit extends Mock implements ConnectivityCubit {}

class MockAppLockCubit extends Mock implements AppLockCubit {}

/// Stubs state/stream/close/add on a mocked bloc. Returns the controller so
/// the test can push follow-up states; pushed states also update [state].
StreamController<S> stubBloc<S>(BlocBase<S> bloc, S initialState) {
  final controller = StreamController<S>.broadcast();
  S current = initialState;
  controller.stream.listen((s) => current = s);
  when(() => bloc.state).thenAnswer((_) => current);
  when(() => bloc.stream).thenAnswer((_) => controller.stream);
  when(() => bloc.close()).thenAnswer((_) async {});
  return controller;
}

/// Fallback-value events so `verify(() => bloc.add(any()))` works.
void registerBlocEventFallbacks() {
  registerFallbackValue(AuthLoginRequested(email: '', password: ''));
  registerFallbackValue(LoginSubmitted(email: '', password: ''));
  registerFallbackValue(SendOTPEvent(email: ''));
  registerFallbackValue(LoadMatchesEvent());
  registerFallbackValue(LoadLikesCountEvent());
  registerFallbackValue(LoadConnectionsEvent());
  registerFallbackValue(LoadConnectionSocketsEvent());
  registerFallbackValue(StartChatsEvent());
  registerFallbackValue(LoadChatSocketsEvent());
  registerFallbackValue(LoadWebSockEvent());
  registerFallbackValue(ProfileLoadEvent());
  registerFallbackValue(LoadOtherProfileEvent(0));
  registerFallbackValue(PreferencesLoadEvent());
  registerFallbackValue(SignupNext());
  registerFallbackValue(StartPostLoginEvent());
  registerFallbackValue(ConnectLobbyEvent());
  registerFallbackValue(CameraInitEvent());
  registerFallbackValue(ThemeMode.dark);
}

/// A real ChangeNotifier provider value for screens using Provider.of.
DataValidatorProvider makeDataValidator({bool allowNext = false}) {
  final p = DataValidatorProvider();
  if (allowNext) p.allowDisallow(true);
  return p;
}
