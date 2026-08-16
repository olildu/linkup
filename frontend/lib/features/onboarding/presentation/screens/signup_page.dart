import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:linkup/core/utils/validation_utils.dart';
import 'package:linkup/core/enums/otp_subject_enum.dart';
import 'package:linkup/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:linkup/features/auth/presentation/bloc/otp_bloc.dart';
import 'package:linkup/shared_ui/constants/colors.dart';
import 'package:linkup/shared_ui/components/common/text_widget_builder.dart';
import 'package:linkup/features/auth/presentation/components/otp_input_field.dart';
import 'package:linkup/features/auth/presentation/components/text_input_field.dart';
import 'package:linkup/features/onboarding/presentation/components/button_builder.dart';
import 'package:linkup/shared_ui/utils/show_error_toast.dart';

class SignUpPage extends StatefulWidget {
  final Function(int) tabHeightChange;
  const SignUpPage({super.key, required this.tabHeightChange});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isEmailValid = false;
  bool _isPasswordMatched = false;
  bool _hidePassword = true;
  String _emailHash = "";

  // Password requirement states
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _hasMinLength = false;

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();

  void _validateEmail() {
    final email = _emailController.text.trim();
    final isEmailValid = ValidationUtils.validateEmail(email);
    setState(() {
      _isEmailValid = isEmailValid;
    });
  }

  void _validatePasswords() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      _hasMinLength = password.length >= 8;

      _isPasswordMatched =
          password.isNotEmpty &&
          password == confirmPassword &&
          _hasUppercase &&
          _hasLowercase &&
          _hasNumber &&
          _hasSpecialChar &&
          _hasMinLength;
    });
  }

  void _hideUnhidePassword() {
    setState(() {
      _hidePassword = !_hidePassword;
    });
  }

  @override
  void initState() {
    super.initState();

    if (kDebugMode) {
      _emailController.text = 'ebinsanthosh06@gmail.com';
      _passwordController.text = 'OOMBmyrefc!12';
      _confirmPasswordController.text = 'OOMBmyrefc!12';
      _otpController.text = '123456';
    }

    _validateEmail();
    _validatePasswords();

    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePasswords);
    _confirmPasswordController.addListener(_validatePasswords);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: MultiBlocListener(
        listeners: [
          BlocListener<OtpBloc, OtpState>(
            listener: (context, state) {
              if (state is OtpVerified) {
                _emailHash = state.emailHash;
                widget.tabHeightChange(2);
              }
              if (state is OtpFailure) {
                showToast(context: context, message: state.message);
              }
            },
          ),
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                Navigator.pop(context, true);
              }
              if (state is AuthFailure) {
                showToast(context: context, message: state.message);
              }
            },
          ),
        ],
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: BlocBuilder<OtpBloc, OtpState>(
            builder: (context, otpState) {
              if (otpState is OtpInitial ||
                  otpState is OtpLoading ||
                  otpState is OtpFailure && _emailHash.isEmpty) {
                if (otpState is OtpSent) {
                  return _otpVerification(
                    key: const ValueKey('otpView'),
                    otpState: otpState,
                  );
                }
                return _emailEntry(
                  key: const ValueKey('emailView'),
                  otpState: otpState,
                );
              } else if (otpState is OtpSent) {
                return _otpVerification(
                  key: const ValueKey('otpView'),
                  otpState: otpState,
                );
              } else if (otpState is OtpVerified) {
                return BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    return _passwordEntry(
                      key: const ValueKey('passwordView'),
                      authState: authState,
                    );
                  },
                );
              } else {
                return _emailEntry(
                  key: const ValueKey('emailView'),
                  otpState: otpState,
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _emailEntry({required ValueKey key, required OtpState otpState}) {
    final bool hasError = otpState is OtpFailure;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          key: key,
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      TextInputField(
                        label: 'Email',
                        hintText: 'Enter your MUJ college email',
                        controller: _emailController,
                        hasError: hasError,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                      ),
                      if (hasError)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 8.0.h,
                            horizontal: 5.w,
                          ),
                          child: Text(
                            (otpState).message,
                            style: AppTextStyles.error(
                              context,
                            )?.copyWith(fontSize: 14.sp),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: ButtonBuilder(
                      text: 'Verify with OTP',
                      onPressed: () {
                        context.read<OtpBloc>().add(
                          SendOTPEvent(email: _emailController.text.trim()),
                        );
                      },
                      isLoading: otpState is OtpLoading,
                      isEnabled: _isEmailValid,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _otpVerification({required ValueKey key, required OtpState otpState}) {
    final bool hasError = otpState is OtpFailure;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          key: key,
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OtpInputField(
                        label: 'OTP',
                        hintText: '••••••',
                        controller: _otpController,
                        hasError: hasError,
                      ),
                      if (hasError)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 8.0.h,
                            horizontal: 0.w,
                          ),
                          child: Text(
                            (otpState).message,
                            style: AppTextStyles.error(
                              context,
                            )?.copyWith(fontSize: 14.sp),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: ButtonBuilder(
                      text: 'Submit OTP',
                      onPressed: () {
                        context.read<OtpBloc>().add(
                          VerifyOTPEvent(
                            otp: int.parse(_otpController.text.trim()),
                            email: _emailController.text.trim(),
                            subject: EmailOTPSubject.emailVerification,
                          ),
                        );
                      },
                      isLoading: otpState is OtpLoading,
                      isEnabled: _otpController.text.trim().length == 6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _passwordEntry({required ValueKey key, required AuthState authState}) {
    final bool hasError = authState is AuthFailure;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          key: key,
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextInputField(
                        label: 'Password',
                        hintText: 'Enter your new password',
                        obscureText: _hidePassword,
                        controller: _passwordController,
                        hasError: hasError,
                        toggleObscure: () => _hideUnhidePassword(),
                      ),
                      Gap(10.h),
                      TextInputField(
                        label: 'Confirm Password',
                        hintText: 'Re-enter your new password',
                        controller: _confirmPasswordController,
                        hasError: hasError,
                        obscureText: _hidePassword,
                        toggleObscure: () => _hideUnhidePassword(),
                      ),
                      Gap(20.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRequirementItem(
                              "At least 8 characters",
                              _hasMinLength,
                            ),
                            _buildRequirementItem(
                              "One uppercase letter",
                              _hasUppercase,
                            ),
                            _buildRequirementItem(
                              "One lowercase letter",
                              _hasLowercase,
                            ),
                            _buildRequirementItem("One number", _hasNumber),
                            _buildRequirementItem(
                              "One special character (!@#\$%^&*(),.:{}|<>)",
                              _hasSpecialChar,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: ButtonBuilder(
                      text: 'Save password',
                      onPressed: () {
                        context.read<AuthBloc>().add(
                          AuthRegisterRequested(
                            emailHash: _emailHash,
                            password: _passwordController.text.trim(),
                          ),
                        );
                      },
                      isLoading: authState is AuthLoading,
                      isEnabled: _isPasswordMatched,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            color: isMet ? AppColors.success : AppColors.notSelected,
            size: 16.sp,
          ),
          Gap(8.w),
          Expanded(
            child: CustomTextWidget(
              text,
              fontSize: 13,
              color: isMet ? AppColors.success : AppColors.notSelected,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}
