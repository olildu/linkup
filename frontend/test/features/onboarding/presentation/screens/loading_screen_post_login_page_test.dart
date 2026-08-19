import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:linkup/core/network/token_service.dart';
import 'package:linkup/features/auth/presentation/screens/landing_page.dart';
import 'package:linkup/features/onboarding/presentation/bloc/post_login_bloc.dart';
import 'package:linkup/features/onboarding/presentation/screens/loading_screen_post_login_page.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/mock_blocs.dart';
import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  setUpAll(registerBlocEventFallbacks);

  late MockTokenService tokenService;
  late MockPostLoginBloc postLoginBloc;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    tokenService = MockTokenService();
    postLoginBloc = MockPostLoginBloc();
    when(() => postLoginBloc.add(any())).thenReturn(null);
    stubBloc<PostLoginState>(postLoginBloc, PostLoginInitial());
    final sl = GetIt.instance;
    await sl.reset();
    sl.registerSingleton<TokenService>(tokenService);
  });

  Future<void> pumpPage(WidgetTester tester) async {
    usePhoneSurface(tester);
    await tester.pumpWidget(buildTestWidgetWithBlocs(
      const LoadingScreenPostLogin(),
      providers: [BlocProvider<PostLoginBloc>.value(value: postLoginBloc)],
    ));
  }

  testWidgets('without tokens navigates to the landing page after the '
      'animation', (tester) async {
    when(() => tokenService.tokenExists()).thenAnswer((_) async => false);
    await pumpPage(tester);

    await tester.pump(const Duration(seconds: 2)); // logo animation
    await tester.pump(const Duration(milliseconds: 600)); // fade navigation
    await tester.pumpAndSettle();

    expect(find.byType(LandingPage), findsOneWidget);
  });

  testWidgets('with tokens (no app lock) starts the post-login flow',
      (tester) async {
    when(() => tokenService.tokenExists()).thenAnswer((_) async => true);
    when(() => tokenService.registerUserIdIfExists()).thenAnswer((_) async {});
    await pumpPage(tester);
    await tester.pump(const Duration(milliseconds: 100));

    final events = verify(() => postLoginBloc.add(captureAny())).captured;
    expect(events.whereType<StartPostLoginEvent>(), hasLength(1));
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('PostLoginError sends the user back to landing', (tester) async {
    when(() => tokenService.tokenExists()).thenAnswer((_) async => true);
    when(() => tokenService.registerUserIdIfExists()).thenAnswer((_) async {});
    final controller =
        stubBloc<PostLoginState>(postLoginBloc, PostLoginInitial());
    await pumpPage(tester);
    await tester.pump(const Duration(milliseconds: 100));

    controller.add(PostLoginError());
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.byType(LandingPage), findsOneWidget);
  });
}
