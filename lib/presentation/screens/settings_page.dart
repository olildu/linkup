import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:linkup/data/http_services/user_http_services/user_http_services.dart';
import 'package:linkup/data/token/token_services.dart';
import 'package:linkup/presentation/components/common/menu_tile_builder.dart';
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

  Future<void> _contactSupport(BuildContext context) =>
      _openExternal(context, Uri.parse('mailto:$_supportEmail?subject=Linkup%20Support'));

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
        Text(subtitle, style: AppTextStyles.subtitle(context)?.copyWith(fontSize: 13.sp)),
      ],
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
              _sectionTitle(context, 'Account', 'Secure actions for your profile and session'),
              Gap(12.h),
              MenuTileBuilder(
                icon: Icons.logout_rounded,
                title: 'Logout',
                onTap: () => _logout(context),
                showBorder: true,
                filledBackground: true,
                borderColor: AppColors.notSelected.withValues(alpha: 0.22),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                borderRadius: 18.r,
                iconSize: 20.sp,
                arrowSize: 16.sp,
              ),
              Gap(12.h),
              _dangerAction(context, title: 'Delete Account', onTap: () => _deleteAccount(context)),
              Gap(22.h),
              _sectionTitle(
                context,
                'Privacy & Legal',
                'Pages users should always be able to find',
              ),
              Gap(12.h),
              MenuTileBuilder(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () => _openPrivacy(context),
                showBorder: true,
                filledBackground: true,
                borderColor: AppColors.notSelected.withValues(alpha: 0.22),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                borderRadius: 18.r,
                iconSize: 20.sp,
                arrowSize: 16.sp,
              ),
              Gap(12.h),
              MenuTileBuilder(
                icon: Icons.description_outlined,
                title: 'Terms & Conditions',
                onTap: () => _openTerms(context),
                showBorder: true,
                filledBackground: true,
                borderColor: AppColors.notSelected.withValues(alpha: 0.22),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                borderRadius: 18.r,
                iconSize: 20.sp,
                arrowSize: 16.sp,
              ),
              Gap(22.h),
              _sectionTitle(context, 'Support', 'Ways to get help or share feedback'),
              Gap(12.h),
              MenuTileBuilder(
                icon: Icons.mail_outline_rounded,
                title: 'Contact Support',
                onTap: () => _contactSupport(context),
                showBorder: true,
                filledBackground: true,
                borderColor: AppColors.notSelected.withValues(alpha: 0.22),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                borderRadius: 18.r,
                iconSize: 20.sp,
                arrowSize: 16.sp,
              ),
              Gap(22.h),
            ],
          ),
        ),
      ),
    );
  }
}
