import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:linkup/presentation/constants/colors.dart';
import 'package:linkup/presentation/components/signup_page/button_builder.dart';
import 'package:linkup/presentation/theme/app_spacing.dart';
import 'package:linkup/presentation/components/signup_page/page_title_builder_component.dart';
import 'package:linkup/presentation/screens/loading_screen_post_login_page.dart';
import 'package:linkup/presentation/screens/login_signup_modal_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  void showLoginPopup() {
    double modalHeight = 0.55;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (context) {
        return Theme(
          data: AppTheme.lightTheme,
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  height: (MediaQuery.of(context).size.height * modalHeight) + MediaQuery.of(context).viewInsets.bottom,
                  child: LoginSignupPage(
                    onTabChange: (int tabIndex) {
                      double newHeight;

                      switch (tabIndex) {
                        case 0:
                          newHeight = 0.55;
                          break;
                        case 1:
                          newHeight = 0.37;
                          break;
                        case 2:
                          newHeight = 0.65;
                          break;
                        default:
                          newHeight = 0.5;
                      }

                      setModalState(() {
                        modalHeight = newHeight;
                      });
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    ).then((value) async {
      if (value is bool && value) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) => const LoadingScreenPostLogin()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/landing_page_image.jpg', width: 400.w, height: 400.h, fit: BoxFit.cover),
          ),

          Padding(
            padding: EdgeInsets.only(top: AppSpacing.xl4.h, left: AppSpacing.xl.w, right: AppSpacing.xl.w, bottom: AppSpacing.xl.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                PageTitle(inputText: "More than just classmates", highlightWord: "classmates", fontSize: 23, textColor: AppColors.whiteText),

                Spacer(),

                Text(
                  'linkup with your crowd',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.whiteText),
                ),

                Gap(20.h),

                ButtonBuilder(
                  text: "Continue with MUJ ID",
                  onPressed: () {
                    showLoginPopup();
                  },
                ),

                Gap(20.h),

                Center(
                  child: Text(
                    'By continuing, you agree to our Terms of Service and Privacy Policy.',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.whiteText.withValues(alpha: 0.7)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
