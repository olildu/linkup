import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:linkup/features/settings/data/biometric_lock_service.dart';
import 'package:linkup/features/settings/presentation/app_lock_cubit.dart';
import 'package:linkup/features/settings/presentation/settings_page.dart';
import 'package:linkup/shared_ui/components/common/confirmation_dialog_builder.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mock_blocs.dart';
import '../../../helpers/test_helper.dart';

class MockBiometricLockService extends Mock implements BiometricLockService {}

void main() {
  setUpAll(registerBlocEventFallbacks);

  late MockAuthBloc authBloc;
  late MockAppLockCubit appLockCubit;
  late MockBiometricLockService biometrics;

  setUp(() {
    authBloc = MockAuthBloc();
    appLockCubit = MockAppLockCubit();
    biometrics = MockBiometricLockService();
    stubBloc<AuthState>(authBloc, AuthInitial());
    stubBloc<bool>(appLockCubit, false);
    when(() => appLockCubit.setEnabled(any())).thenAnswer((_) async {});
    SettingsPage.biometricLockService = biometrics;
  });

  tearDown(() {
    SettingsPage.biometricLockService = BiometricLockService();
  });

  Future<void> pumpPage(WidgetTester tester) async {
    usePhoneSurface(tester);
    ignoreOverflowErrors();
    await tester.pumpWidget(buildTestWidgetWithBlocs(
      const SettingsPage(),
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<AppLockCubit>.value(value: appLockCubit),
      ],
    ));
    await tester.pump();
  }

  testWidgets('renders the settings tiles', (tester) async {
    await pumpPage(tester);
    expect(find.text('Logout'), findsOneWidget);
    expect(find.text('Delete Account'), findsOneWidget);
    expect(find.text('App Lock'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Terms & Conditions'), findsOneWidget);
    expect(find.text('Contact Support'), findsOneWidget);
  });

  testWidgets('toggling app lock when biometrics work enables the cubit',
      (tester) async {
    when(() => biometrics.canUseAppLock()).thenAnswer((_) async => true);
    await pumpPage(tester);

    await tester.tap(find.byType(CupertinoSwitch));
    await tester.pump();

    verify(() => appLockCubit.setEnabled(true)).called(1);
  });

  testWidgets('toggling app lock without biometrics shows the unavailable '
      'dialog', (tester) async {
    when(() => biometrics.canUseAppLock()).thenAnswer((_) async => false);
    await pumpPage(tester);

    await tester.tap(find.byType(CupertinoSwitch));
    await tester.pumpAndSettle();

    expect(find.text('APP LOCK UNAVAILABLE'), findsOneWidget);
    verifyNever(() => appLockCubit.setEnabled(any()));
  });

  testWidgets('delete account opens the confirmation dialog', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();
    expect(find.byType(ConfirmationDialogBuilder), findsOneWidget);
    expect(find.text('DELETE ACCOUNT?'), findsOneWidget);
    await tester.tap(find.text('CANCEL'));
    await tester.pumpAndSettle();
  });
}
