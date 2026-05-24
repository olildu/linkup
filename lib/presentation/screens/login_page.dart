import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart'; // Added for kDebugMode
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:linkup/data/common_services/validation_utils.dart';
import 'package:linkup/logic/bloc/auth/auth_bloc.dart';
import 'package:linkup/logic/bloc/otp/otp_bloc.dart';
import 'package:linkup/presentation/constants/colors.dart';
import 'package:linkup/presentation/components/login/text_input_field.dart';
import 'package:linkup/presentation/components/signup_page/button_builder.dart';
import 'package:linkup/presentation/screens/forgot_password_modal_page.dart';
import 'package:linkup/presentation/screens/loading_screen_post_login_page.dart';
import 'package:linkup/presentation/utils/show_error_toast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  bool _isFormValid = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _validate() {
    setState(() {
      _isFormValid = ValidationUtils.validateEmail(_emailController.text) && ValidationUtils.validatePassword(_passwordController.text, isLogin: true);
    });
  }

  // Restored: Forgot Password Popup Logic
  void _showForgotPopup() {
    double modalHeight = 0.35;
    final authBloc = context.read<AuthBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void onTabChange(String value) {
              double newHeight;
              switch (value) {
                case "email-entry":
                case "otp-entry":
                  newHeight = 0.35;
                  break;
                case "password-entry":
                  newHeight = 0.65;
                  break;
                default:
                  newHeight = 0.35;
              }
              setModalState(() => modalHeight = newHeight);
            }

            return ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                height: (MediaQuery.of(context).size.height * modalHeight) + MediaQuery.of(context).viewInsets.bottom,
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider(create: (context) => OtpBloc()),
                    BlocProvider.value(value: authBloc), // Pass existing AuthBloc
                  ],
                  child: ForgotPasswordModalPage(tabHeightChange: onTabChange, filledEmail: _emailController.text),
                ),
              ),
            );
          },
        );
      },
    ).then((value) async {
      if (value is bool && value) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.of(context).push(CupertinoPageRoute(builder: (context) => const LoadingScreenPostLogin()));
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();

    // Restored: Default Credentials for Debug Mode
    if (kDebugMode) {
      _emailController.text = 'ebinsanthosh06@gmail.com';
      _passwordController.text = 'OOMBmyrefc!12';
    }

    _validate();
    _emailController.addListener(_validate);
    _passwordController.addListener(_validate);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) Navigator.of(context).pop(true);
        if (state is AuthFailure) showToast(context: context, message: state.message);
      },
      builder: (context, state) {
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
                      // Top Section: Inputs & Forgot Password
                      Column(
                        children: [
                          TextInputField(label: 'Email', hintText: 'Enter your email', controller: _emailController, hasError: state is AuthFailure),
                          Gap(24.h),
                          TextInputField(
                            label: 'Password',
                            hintText: '••••••••',
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            hasError: state is AuthFailure,
                            toggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          Gap(16.h),
                          // Restored: Forgot Password Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: _showForgotPopup,
                                child: Text(
                                  'Forgot Password ?',
                                  style: AppTextStyles.link(context)?.copyWith(fontSize: 14.sp),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Bottom Section: Action Button
                      Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: ButtonBuilder(
                          width: double.infinity,
                          text: 'Log In',
                          onPressed: () {
                            context.read<AuthBloc>().add(AuthLoginRequested(email: _emailController.text.trim(), password: _passwordController.text));
                          },
                          isEnabled: _isFormValid && state is! AuthLoading,
                          isLoading: state is AuthLoading,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
