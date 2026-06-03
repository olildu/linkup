import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:linkup/data/enums/otp_subject_enum.dart';
import 'package:linkup/logic/bloc/auth/auth_bloc.dart';
import 'package:linkup/logic/bloc/otp/otp_bloc.dart';
import 'package:linkup/presentation/components/common/text_widget_builder.dart';
import 'package:linkup/presentation/components/login/text_input_field.dart';
import 'package:linkup/presentation/components/login/otp_input_field.dart';
import 'package:linkup/presentation/components/signup_page/button_builder.dart';
import 'package:linkup/presentation/constants/colors.dart';
import 'package:linkup/presentation/theme/app_radius.dart';
import 'package:linkup/presentation/theme/app_spacing.dart';
import 'package:linkup/presentation/utils/show_error_toast.dart';

class ForgotPasswordModalPage extends StatefulWidget {
  final Function(String) tabHeightChange;
  final String filledEmail;

  const ForgotPasswordModalPage({super.key, required this.tabHeightChange, required this.filledEmail});

  @override
  State<ForgotPasswordModalPage> createState() => _ForgotPasswordModalPageState();
}

class _ForgotPasswordModalPageState extends State<ForgotPasswordModalPage> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _emailHash = "";
  bool _isEmailValid = false;
  bool _isPasswordMatched = false;

  // Password requirement states
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _hasMinLength = false;

  // Obscure toggle same as Signup
  bool _hidePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateFields);
    _passwordController.addListener(_validateFields);
    _confirmPasswordController.addListener(_validateFields);
    _otpController.addListener(_validateFields);

    _emailController.text = widget.filledEmail;
    _validateFields();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateFields() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    _isEmailValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

    setState(() {
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      _hasMinLength = password.length >= 8;

      _isPasswordMatched = password.isNotEmpty && password == confirmPassword && _hasUppercase && _hasLowercase && _hasNumber && _hasSpecialChar && _hasMinLength;
    });
  }

  // Toggle method same as Signup
  void _hideUnhidePassword() {
    setState(() {
      _hidePassword = !_hidePassword;
    });
  }

  void _safeTabHeightChange(String tab) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.tabHeightChange(tab);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl2.w, vertical: AppSpacing.lg.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(AppSpacing.sm.h),
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      child: Icon(Icons.arrow_back_ios_new_rounded, size: 20.sp, color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                  Gap(AppSpacing.sm.w),
                  Text(
                    "Forgot Password?",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                  ),
                ],
              ),
              Gap(AppSpacing.xl2.h),
              Expanded(
                child: MultiBlocListener(
                  listeners: [
                    BlocListener<OtpBloc, OtpState>(
                      listener: (context, state) {
                        if (state is OtpSent) _safeTabHeightChange("otp-entry");
                        if (state is OtpVerified) {
                          _emailHash = state.emailHash;
                          _safeTabHeightChange("password-entry");
                        }
                        if (state is OtpFailure) showToast(context: context, message: state.message);
                      },
                    ),
                    BlocListener<AuthBloc, AuthState>(
                      listener: (context, state) {
                        if (state is AuthAuthenticated) Navigator.pop(context, true);
                        if (state is AuthFailure) showToast(context: context, message: state.message);
                      },
                    ),
                  ],
                  child: BlocBuilder<OtpBloc, OtpState>(
                    builder: (context, otpState) {
                      if (otpState is OtpVerified) {
                        return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) => _buildPasswordEntry(authState));
                      } else if (otpState is OtpSent) {
                        return _buildOtpVerification(otpState);
                      } else {
                        return _buildEmailEntry(otpState);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailEntry(OtpState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [TextInputField(label: 'Email', hintText: 'Enter your registered email', controller: _emailController, hasError: state is OtpFailure)],
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
                    child: ButtonBuilder(
                      text: 'Send OTP',
                      onPressed: () => context.read<OtpBloc>().add(SendOTPEvent(email: _emailController.text.trim())),
                      isLoading: state is OtpLoading,
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

  Widget _buildOtpVerification(OtpState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [OtpInputField(label: 'OTP Code', hintText: '••••••', controller: _otpController, hasError: state is OtpFailure)],
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
                    child: ButtonBuilder(
                      text: 'Verify OTP',
                      onPressed: () =>
                          context.read<OtpBloc>().add(VerifyOTPEvent(otp: int.parse(_otpController.text.trim()), email: _emailController.text.trim(), subject: EmailOTPSubject.forgotPassword)),
                      isLoading: state is OtpLoading,
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

  Widget _buildPasswordEntry(AuthState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
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
                        label: 'New Password',
                        hintText: 'Enter your new password',
                        obscureText: _hidePassword,
                        controller: _passwordController,
                        hasError: state is AuthFailure,
                        toggleObscure: () => _hideUnhidePassword(),
                      ),
                      Gap(AppSpacing.sm.h),
                      TextInputField(
                        label: 'Confirm New Password',
                        hintText: 'Re-enter your new password',
                        obscureText: _hidePassword,
                        controller: _confirmPasswordController,
                        hasError: state is AuthFailure,
                        toggleObscure: () => _hideUnhidePassword(),
                      ),
                      Gap(AppSpacing.xl.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRequirementItem("At least 8 characters", _hasMinLength),
                            _buildRequirementItem("One uppercase letter", _hasUppercase),
                            _buildRequirementItem("One lowercase letter", _hasLowercase),
                            _buildRequirementItem("One number", _hasNumber),
                            _buildRequirementItem("One special character (!@#\$%^&*(),.:{}|<>)", _hasSpecialChar),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
                    child: ButtonBuilder(
                      text: 'Change Password',
                      onPressed: () => context.read<AuthBloc>().add(AuthResetPasswordRequested(emailHash: _emailHash, password: _passwordController.text.trim())),
                      isLoading: state is AuthLoading,
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
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xxs.h),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            color: isMet ? AppColors.success : AppColors.whiteGreyTextColor,
            size: 16.sp,
          ),
          Gap(AppSpacing.sm.w),
          Expanded(
            child: CustomTextWidget(
              text,
              fontSize: 13,
              color: isMet ? AppColors.success : AppColors.whiteGreyTextColor,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}
