import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:linkup/data/http_services/user_http_services/user_http_services.dart';
import 'package:linkup/data/token/token_services.dart';
import 'package:linkup/presentation/components/signup_page/button_builder.dart';
import 'package:linkup/presentation/constants/colors.dart';
import 'package:linkup/presentation/screens/loading_screen_post_login_page.dart';
import 'package:linkup/presentation/utils/show_error_toast.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const String _termsUrl = 'https://linkup.olildu.dpdns.org/terms';
  static const String _privacyUrl = 'https://linkup.olildu.dpdns.org/privacy';
  static const String _supportEmail = 'ebinsanthosh06@gmail.com';
  static const String _appVersion = '1.0.0+7';

  Future<void> _openExternal(BuildContext context, Uri uri) async {
    try {
      final bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        showToast(context: context, message: 'Could not open this link.');
      }
    } catch (_) {
      if (context.mounted) {
        showToast(context: context, message: 'Could not open this link.');
      }
    }
  }

  Future<void> _openPrivacy(BuildContext context) => _openExternal(context, Uri.parse(_privacyUrl));

  Future<void> _openTerms(BuildContext context) => _openExternal(context, Uri.parse(_termsUrl));

  Future<void> _contactSupport(BuildContext context) => _openExternal(
    context,
    Uri.parse('mailto:$_supportEmail?subject=Linkup%20Support'),
  );

  Future<void> _logout(BuildContext context) async {
    await TokenServices().clearTokens();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        CupertinoPageRoute(builder: (context) => const LoadingScreenPostLogin()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete Account?', style: Theme.of(dialogContext).textTheme.titleLarge),
        content: Text(
          'This action cannot be undone. You will lose your matches, chats, and profile data.',
          style: Theme.of(dialogContext).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancel',
              style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                color: Theme.of(dialogContext).colorScheme.onSurface,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Delete', style: AppTextStyles.destructive(dialogContext)),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await UserHttpServices().deleteAccount();
      await TokenServices().clearTokens();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (context) => const LoadingScreenPostLogin()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (_) {
      if (context.mounted) {
        showToast(context: context, message: 'Failed to delete account');
      }
    }
  }

  Widget _sectionTitle(BuildContext context, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Gap(4.h),
        Text(
          subtitle,
          style: AppTextStyles.subtitle(context)?.copyWith(fontSize: 13.sp),
        ),
      ],
    );
  }

  Widget _tile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: AppColors.notSelected.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: (iconColor ?? Theme.of(context).colorScheme.primary).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor ?? Theme.of(context).colorScheme.primary, size: 20.sp),
              ),
              Gap(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: titleColor ?? Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      Gap(2.h),
                      Text(
                        subtitle,
                        style: AppTextStyles.subtitle(context)?.copyWith(fontSize: 12.sp),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16.sp, color: AppColors.notSelected),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dangerAction(BuildContext context, {required String title, required VoidCallback onTap}) {
    return ButtonBuilder(
      text: title,
      onPressed: onTap,
      backgroundColor: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
      textColor: Theme.of(context).colorScheme.error,
      borderRadius: 18.r,
      height: 54.h,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.16),
                      Theme.of(context).colorScheme.surface,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: AppColors.notSelected.withValues(alpha: 0.16)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Keep your account in control',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Gap(8.h),
                    Text(
                      'Manage legal pages, support, and account actions from one place.',
                      style: AppTextStyles.subtitle(context)?.copyWith(fontSize: 13.sp),
                    ),
                  ],
                ),
              ),
              Gap(22.h),
              _sectionTitle(context, 'Account', 'Secure actions for your profile and session'),
              Gap(12.h),
              _tile(
                context: context,
                icon: Icons.logout_rounded,
                title: 'Logout',
                subtitle: 'End your current session on this device',
                iconColor: AppColors.primary,
                onTap: () => _logout(context),
              ),
              Gap(12.h),
              _dangerAction(
                context,
                title: 'Delete Account',
                onTap: () => _deleteAccount(context),
              ),
              Gap(22.h),
              _sectionTitle(context, 'Privacy & Legal', 'Pages users should always be able to find'),
              Gap(12.h),
              _tile(
                context: context,
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'How we collect, use, and protect data',
                onTap: () => _openPrivacy(context),
              ),
              Gap(12.h),
              _tile(
                context: context,
                icon: Icons.description_outlined,
                title: 'Terms & Conditions',
                subtitle: 'Rules for using Linkup',
                onTap: () => _openTerms(context),
              ),
              Gap(22.h),
              _sectionTitle(context, 'Support', 'Ways to get help or share feedback'),
              Gap(12.h),
              _tile(
                context: context,
                icon: Icons.mail_outline_rounded,
                title: 'Contact Support',
                subtitle: 'Email us if something is broken or unclear',
                onTap: () => _contactSupport(context),
              ),
              Gap(22.h),
              _sectionTitle(context, 'About', 'Basic app information'),
              Gap(12.h),
              _tile(
                context: context,
                icon: Icons.info_outline_rounded,
                title: 'App Version',
                subtitle: _appVersion,
                onTap: () {},
              ),
              Gap(24.h),
            ],
          ),
        ),
      ),
    );
  }
}
