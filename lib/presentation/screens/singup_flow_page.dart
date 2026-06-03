import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:linkup/logic/bloc/auth/auth_bloc.dart';
import 'package:linkup/data/data_parser/signup_page/data_parser.dart';
import 'package:linkup/data/models/signup_options_model.dart';
import 'package:linkup/data/services/signup_options_service.dart';
import 'package:linkup/logic/bloc/signup/signup_bloc.dart';
import 'package:linkup/logic/provider/data_validator_provider.dart';
import 'package:linkup/presentation/components/signup_page/animation_handlers.dart';
import 'package:linkup/presentation/components/signup_page/button_builder.dart';
import 'package:linkup/presentation/components/signup_page/progress_bar_component.dart';
import 'package:linkup/presentation/components/common/confirmation_dialog_builder.dart';
import 'package:linkup/presentation/constants/colors.dart';
import 'package:linkup/presentation/constants/singup_page/flow.dart';
import 'package:linkup/presentation/screens/landing_page.dart';
import 'package:linkup/presentation/screens/loading_screen_post_login_page.dart';
import 'package:linkup/presentation/screens/uploading_overlay.dart';
import 'package:linkup/presentation/utils/navigate_fade_transistion.dart';
import 'package:linkup/presentation/utils/show_error_toast.dart';

class SingupFlowPage extends StatefulWidget {
  final int initialIndex;
  final dynamic initialData;

  const SingupFlowPage({super.key, this.initialIndex = -1, this.initialData});

  @override
  State<SingupFlowPage> createState() => _SingupFlowPageState();
}

class _SingupFlowPageState extends State<SingupFlowPage> {
  static const String _logTag = 'SingupFlowPage';

  final SignupOptionsService _signupOptionsService = SignupOptionsService();

  late SignUpPageFlow _signUpPageFlow;
  late DataValidatorProvider _dataValidatorProvider;
  late SignupBloc _signupBloc;
  late bool _isNextButtonEnabled;
  bool _isLoadingSignupOptions = true;

  @override
  void initState() {
    super.initState();
    log(
      'Signup flow initState started. initialIndex: ${widget.initialIndex}, hasInitialData: ${widget.initialData != null}',
      name: _logTag,
    );
    _signupBloc = context.read<SignupBloc>();
    _dataValidatorProvider = Provider.of<DataValidatorProvider>(context, listen: false);
    _isNextButtonEnabled = _dataValidatorProvider.allowNext;
    _dataValidatorProvider.addListener(_dataValidatorListener);
    _loadSignupFlow();
  }

  Future<void> _loadSignupFlow() async {
    try {
      log('Loading signup options before building flow UI.', name: _logTag);
      final signupOptions = await _signupOptionsService.loadSignupOptions();

      if (!mounted) {
        return;
      }

      log(
        'Signup options ready. version: ${signupOptions.version}, programs: ${signupOptions.programs.length}',
        name: _logTag,
      );

      _signUpPageFlow = SignUpPageFlow(
        context,
        signupOptions: signupOptions,
        initialData: widget.initialData as Map<String, dynamic>?,
      );
      _signupBloc.add(
        SignupInit(currentIndex: widget.initialIndex, signUpPageFlow: _signUpPageFlow),
      );

      setState(() {
        _isLoadingSignupOptions = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      log('Unexpected error while loading signup options. Using fallback config.', name: _logTag);
      _signUpPageFlow = SignUpPageFlow(
        context,
        signupOptions: SignupOptionsConfig.fallback(),
        initialData: widget.initialData as Map<String, dynamic>?,
      );
      _signupBloc.add(
        SignupInit(currentIndex: widget.initialIndex, signUpPageFlow: _signUpPageFlow),
      );

      setState(() {
        _isLoadingSignupOptions = false;
      });
    }
  }

  @override
  void dispose() {
    _dataValidatorProvider.removeListener(_dataValidatorListener);
    super.dispose();
  }

  void _dataValidatorListener() {
    if (mounted) {
      setState(() {
        _isNextButtonEnabled = _dataValidatorProvider.allowNext;
      });
    }
  }

  void decideNextButtonState(int currentIndex) {
    final step = _signUpPageFlow.flow[currentIndex];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dataValidatorProvider.allowDisallow(step["showProgressBar"] != null);
    });
  }

  bool _isAutoAdvanceStep(int currentIndex) {
    return _signUpPageFlow.flow[currentIndex]["showProgressBar"] == false;
  }

  Future<void> _logout() async {
    await context.read<AuthBloc>().logout();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      CupertinoPageRoute(builder: (context) => const LandingPage()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _showLogoutConfirmation() async {
    final theme = Theme.of(context);

    ConfirmationDialogBuilder.show<void>(
      context,
      ConfirmationDialogBuilder(
        icon: Icons.logout_rounded,
        title: 'Logout?',
        message: 'Do you want to log out and leave this signup flow?',
        confirmText: 'Logout',
        cancelText: 'Cancel',
        iconColor: theme.colorScheme.primary,
        iconBackgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
        confirmBackgroundColor: theme.colorScheme.primary,
        confirmTextColor: theme.colorScheme.onPrimary,
        verticalButtons: true,
        primaryOnTop: true,
        onConfirm: _logout,
        onCancel: () {},
      ),
      blurSigma: 20.0,
    );
  }

  void _manageFlow(SignupState state) {
    if (state is SingupPhotoUploading) {
      navigateWithFade(
        context,
        const CustomOverlay(
          text: 'Uploading',
          backgroundColor: AppColors.primary,
          textColor: AppColors.whiteText,
        ),
        allowBack: true,
      );
    } else if (state is SingupPhotoUploaded) {
      Navigator.of(context).pop();
    } else if (state is SingupPhotoUploadError) {
      showToast(context: context, message: state.message);
      Navigator.of(context).pop();
    } else if (state is SignupInitial) {
      decideNextButtonState(state.currentIndex);
    } else if (state is SingupUploading) {
      final bool uploadComplete = state.uploadComplete;
      navigateWithFade(
        context,
        CustomOverlay(
          iconOrLoader: uploadComplete
              ? LottieBuilder.asset(
                  'assets/animations/done.json',
                  fit: BoxFit.contain,
                  repeat: false,
                )
              : LottieBuilder.asset(
                  Theme.of(context).brightness == Brightness.dark
                      ? 'assets/animations/upload-dark.json'
                      : 'assets/animations/upload-light.json',
                  fit: BoxFit.contain,
                ),
          iconSize: uploadComplete ? Size(400.w, 400.h) : Size(400.w, 200.h),
          text: uploadComplete ? 'You are all set ' : 'Uploading you to the clouds',
        ),
        allowBack: true,
      );
    } else if (state is SingupUploaded) {
      navigateWithFade(context, const LoadingScreenPostLogin(), allowBack: true);
    } else if (state is UpdateComplete) {
      Navigator.of(context).pop();
    } else if (state is SingupUploadError) {
      showToast(context: context, message: state.message);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingSignupOptions) {
      return Scaffold(
        body: SafeArea(
          child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: BlocConsumer<SignupBloc, SignupState>(
                listener: (context, state) {
                  _manageFlow(state);
                },
                builder: (context, state) {
                  if (state is SignupInitial) {
                    final currentIndex = state.currentIndex;
                    final progressBarIndex = state.progessBarIndex;
                    final bool isNextButtonEnabled =
                        _isAutoAdvanceStep(currentIndex) || _isNextButtonEnabled;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Gap(10.h),
                        widget.initialData == null &&
                                _signUpPageFlow.flow[currentIndex]["showProgressBar"] == null
                            ? ProgressBarComponent(currentIndex: progressBarIndex, totalSteps: 10)
                            : const SizedBox.shrink(),
                        Gap(20.h),
                        Expanded(
                          child: PageTransitionSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return SharedAxisTransition(
                                animation: animation,
                                transitionType: SharedAxisTransitionType.horizontal,
                                child: child,
                              );
                            },
                            child: buildFlowPage(currentIndex),
                          ),
                        ),
                        Gap(20.h),
                        ButtonBuilder(
                          text: state.buttonText,
                          isEnabled: isNextButtonEnabled,
                          onPressed: () {
                            _signupBloc.add(SignupNext());

                            if (widget.initialData != null) {
                              SignUpDataParser.updateData(context);
                            }
                          },
                        ),
                      ],
                    );
                  }

                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            BlocBuilder<SignupBloc, SignupState>(
              builder: (context, state) {
                if (state is! SignupInitial || state.currentIndex <= 0) {
                  return const SizedBox.shrink();
                }

                return Positioned(
                  top: 2.h,
                  left: 4.w,
                  child: Semantics(
                    button: true,
                    label: 'Go back',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(999.r),
                        onTap: () => _signupBloc.add(SignupPrevious()),
                        child: Container(
                          width: 36.r,
                          height: 36.r,
                          decoration: BoxDecoration(
                            color: AppColors.scrim.withValues(alpha: 0.71),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.notSelected),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.arrow_back_rounded,
                              size: 20.sp,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            BlocBuilder<SignupBloc, SignupState>(
              builder: (context, state) {
                if (state is! SignupInitial ||
                    state.currentIndex != 0 ||
                    widget.initialData != null) {
                  return const SizedBox.shrink();
                }

                return Positioned(
                  top: 2.h,
                  right: 4.w,
                  child: Semantics(
                    button: true,
                    label: 'Log out',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(999.r),
                        onTap: _showLogoutConfirmation,
                        child: Container(
                          width: 36.r,
                          height: 36.r,
                          decoration: BoxDecoration(
                            color: AppColors.scrim.withValues(alpha: 0.71),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.notSelected),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.logout_rounded,
                              size: 20.sp,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFlowPage(int index) {
    return KeyedSubtree(
      key: ValueKey(index),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _signUpPageFlow.flow[index]["title"],
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeInOutCubic,
              switchOutCurve: Curves.easeInOutCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: KeyedSubtree(
                key: ValueKey('action_$index'),
                child: _signUpPageFlow.buildAction(index),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
