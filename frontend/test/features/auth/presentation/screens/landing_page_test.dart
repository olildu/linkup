import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:linkup/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:linkup/features/auth/presentation/bloc/otp_bloc.dart';
import 'package:linkup/features/auth/presentation/screens/landing_page.dart';
import 'package:linkup/features/auth/presentation/screens/login_signup_modal_page.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  setUp(() async {
    final sl = GetIt.instance;
    await sl.reset();
    sl.registerFactory<AuthBloc>(() => AuthBloc(
          loginUseCase: MockLoginUseCase(),
          logoutUseCase: MockLogoutUseCase(),
          registerUseCase: MockRegisterUseCase(),
          resetPasswordUseCase: MockResetPasswordUseCase(),
          deleteAccountUseCase: MockDeleteAccountUseCase(),
        ));
    sl.registerFactory<OtpBloc>(() => OtpBloc(
          sendOTPUseCase: MockSendOTPUseCase(),
          verifyOTPUseCase: MockVerifyOTPUseCase(),
        ));
  });

  testWidgets('renders the hero copy and CTA', (tester) async {
    await tester.pumpWidget(buildTestWidget(const LandingPage()));
    expect(find.textContaining('linkup with your crowd'), findsOneWidget);
    expect(find.text('Continue with MUJ ID'), findsOneWidget);
    expect(find.textContaining('Terms of Service'), findsOneWidget);
  });

  testWidgets('CTA opens the login/signup modal with both tabs',
      (tester) async {
    await tester.pumpWidget(buildTestWidget(const LandingPage()));
    await tester.tap(find.text('Continue with MUJ ID'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginSignupPage), findsOneWidget);
    expect(find.text('Log In'), findsWidgets);
    expect(find.text('Sign Up'), findsWidgets);
  });
}
