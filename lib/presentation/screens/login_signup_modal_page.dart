import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:linkup/core/di/injection_container.dart';
import 'package:linkup/logic/bloc/auth/auth_bloc.dart';
import 'package:linkup/logic/bloc/otp/otp_bloc.dart';
import 'package:linkup/presentation/screens/login_page.dart';
import 'package:linkup/presentation/constants/colors.dart';
import 'package:linkup/presentation/screens/signup_page.dart';
import 'package:linkup/presentation/theme/app_radius.dart';
import 'package:linkup/presentation/theme/app_spacing.dart';

class LoginSignupPage extends StatefulWidget {
  final Function(int) onTabChange;
  const LoginSignupPage({super.key, required this.onTabChange});

  @override
  State<LoginSignupPage> createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_detectTabChange);
  }

  void _detectTabChange() {
    widget.onTabChange(_tabController.index);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Container(
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: AppColors.tabBarTrack,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    padding: EdgeInsets.all(3.sp),
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.onSurface.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    labelColor: colorScheme.onSurface,
                    unselectedLabelColor: AppColors.notSelected,
                    labelStyle: Theme.of(context).textTheme.titleMedium,
                    unselectedLabelStyle: Theme.of(
                      context,
                    ).textTheme.titleMedium,
                    tabs: const [
                      Tab(text: 'Log In'),
                      Tab(text: 'Sign Up'),
                    ],
                  ),
                ),
              ),

              Gap(AppSpacing.xl3.h),

              Expanded(
                child: BlocProvider(
                  create: (context) => sl<AuthBloc>(),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      const LoginPage(),
                      BlocProvider(
                        create: (context) => sl<OtpBloc>(),
                        child: SignUpPage(
                          tabHeightChange: (i) => widget.onTabChange(i),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
