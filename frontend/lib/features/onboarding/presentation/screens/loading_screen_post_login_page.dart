import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:linkup/core/di/injection_container.dart';
import 'package:linkup/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:linkup/core/network/token_service.dart';
import 'package:linkup/features/settings/data/biometric_lock_service.dart';
import 'package:linkup/features/onboarding/presentation/bloc/post_login_bloc.dart';
import 'package:linkup/features/onboarding/presentation/bloc/signup_bloc.dart';
import 'package:linkup/features/auth/presentation/screens/landing_page.dart';
import 'package:linkup/shared_ui/screens/match_making_page.dart';
import 'package:linkup/features/onboarding/presentation/screens/singup_flow_page.dart';
import 'package:linkup/shared_ui/utils/logo_design.dart';
import 'package:linkup/shared_ui/utils/navigate_fade_transistion.dart';

class LoadingScreenPostLogin extends StatefulWidget {
  const LoadingScreenPostLogin({super.key});

  @override
  State<LoadingScreenPostLogin> createState() => _LoadingScreenPostLoginState();
}

class _LoadingScreenPostLoginState extends State<LoadingScreenPostLogin>
    with SingleTickerProviderStateMixin {
  static const String _appLockKey = 'app_lock_enabled';

  late AnimationController _controller;
  late Animation<double> _animation;
  late PostLoginBloc _postLoginBloc;

  final TokenService _tokenServices = sl<TokenService>();
  final BiometricLockService _biometricLockService = BiometricLockService();

  // Tracks whether we should navigate after the animation completes
  _NavigationTarget? _pendingNavigation;
  bool _animationComplete = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // When animation finishes, execute any pending navigation immediately
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationComplete = true;
        _tryNavigate();
      }
    });

    _postLoginBloc = context.read<PostLoginBloc>();
    _controller.forward();
    _tokenCheck();
  }

  Future<void> _tokenCheck() async {
    final bool exists = await _tokenServices.tokenExists();

    if (!exists) {
      // No token — go to landing after animation finishes
      _pendingNavigation = _NavigationTarget.landing;
      _tryNavigate();
      return;
    }

    await _tokenServices.registerUserIdIfExists();
    final prefs = await SharedPreferences.getInstance();
    final bool appLockEnabled = prefs.getBool(_appLockKey) ?? false;

    if (!mounted) return;

    if (appLockEnabled) {
      // Wait for animation to play first, THEN show biometric prompt
      await _controller.forward();
      if (!mounted) return;
      await _authenticateAndContinue();
      return;
    }

    // Normal path: kick off post-login while animation plays in parallel
    _postLoginBloc.add(StartPostLoginEvent());
  }

  Future<void> _authenticateAndContinue() async {
    final bool unlocked = await _biometricLockService.authenticateForUnlock();

    if (!mounted) return;

    if (unlocked) {
      _postLoginBloc.add(StartPostLoginEvent());
    } else {
      // Authentication failed — retry or go to landing
      // Re-show the prompt; if they cancel twice just send to landing
      final bool retry = await _biometricLockService.authenticateForUnlock();
      if (!mounted) return;
      if (retry) {
        _postLoginBloc.add(StartPostLoginEvent());
      } else {
        _pendingNavigation = _NavigationTarget.landing;
        _tryNavigate();
      }
    }
  }

  void _tryNavigate() {
    if (!_animationComplete || _pendingNavigation == null) return;
    if (!mounted) return;

    final target = _pendingNavigation!;
    _pendingNavigation = null;

    switch (target) {
      case _NavigationTarget.landing:
        navigateWithFade(context, const LandingPage(), allowBack: false);
      case _NavigationTarget.matchMaking:
        navigateWithFade(context, const MatchMakingPage(), allowBack: false);
      case _NavigationTarget.signUp:
        navigateWithFade(
          context,
          BlocProvider(
            create: (context) => sl<AuthBloc>(),
            child: BlocProvider(
              create: (context) => SignupBloc(
                uploadPfpUseCase: sl(),
                uploadUserMediaUseCase: sl(),
              ),
              child: const SingupFlowPage(),
            ),
          ),
          allowBack: false,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.width * 0.5;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: BlocListener<PostLoginBloc, PostLoginState>(
        listener: (context, state) async {
          if (state is PostLoginLoaded) {
            _pendingNavigation = state.goToSignUpPage
                ? _NavigationTarget.signUp
                : _NavigationTarget.matchMaking;
            _tryNavigate();
          } else if (state is PostLoginError) {
            _pendingNavigation = _NavigationTarget.landing;
            _tryNavigate();
          }
        },
        child: Center(
          child: SizedBox(
            width: size,
            height: size,
            child: FadeTransition(
              opacity: _animation,
              child: CustomPaint(
                size: Size(size, size),
                painter: DrawingPainter(
                  _animation,
                  isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

enum _NavigationTarget { landing, matchMaking, signUp }
