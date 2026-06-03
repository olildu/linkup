import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:linkup/logic/bloc/auth/auth_bloc.dart';
import 'package:linkup/presentation/components/common/menu_tile_builder.dart';
import 'package:linkup/presentation/components/signup_page/button_builder.dart';
import 'package:linkup/presentation/components/common/confirmation_dialog_builder.dart';
import 'package:linkup/data/services/biometric_lock_service.dart';
import 'package:linkup/presentation/constants/colors.dart';
import 'package:linkup/presentation/theme/app_radius.dart';
import 'package:linkup/presentation/theme/app_spacing.dart';
import 'package:linkup/presentation/screens/loading_screen_post_login_page.dart';
import 'package:linkup/presentation/utils/show_error_toast.dart';
import 'package:linkup/logic/cubit/app_lock/app_lock_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const String _termsUrl = 'https://linkup.olildu.dpdns.org/terms';
  static const String _privacyUrl = 'https://linkup.olildu.dpdns.org/privacy';
  static const String _supportEmail = 'ebinsanthosh06@gmail.com';
  static final BiometricLockService _biometricLockService = BiometricLockService();

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
      _openExternal(context, Uri.parse('mailto:$_supportEmail?subject=linkup%20Support'));

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthBloc>().logout();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        CupertinoPageRoute(builder: (context) => const LoadingScreenPostLogin()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    // Use the shared confirmation dialog; perform deletion in onConfirm.
    // Show with a strong blur to emphasize the dialog
    ConfirmationDialogBuilder.show<void>(
      context,
      ConfirmationDialogBuilder(
        icon: Icons.delete_outline,
        title: 'Delete Account?',
        message:
            'This action cannot be undone. You will lose your matches, chats, and profile data.',
        confirmText: 'Delete',
        cancelText: 'Cancel',
        iconColor: Theme.of(context).colorScheme.error,
        iconBackgroundColor: Theme.of(context).colorScheme.error.withValues(alpha: 0.12),
        confirmBackgroundColor: Theme.of(context).colorScheme.error,
        confirmTextColor: Theme.of(context).colorScheme.onError,
        verticalButtons: true,
        primaryOnTop: true,
        onConfirm: () {
          final authBloc = context.read<AuthBloc>();
          Future.microtask(() async {
            try {
              await authBloc.deleteAccount();
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
          });
        },
        onCancel: () {},
      ),
      blurSigma: 20.0,
    );
  }

  Future<void> _showAppLockUnavailableDialog(BuildContext context) async {
    ConfirmationDialogBuilder.show<void>(
      context,
      ConfirmationDialogBuilder(
        icon: Icons.info_outline_rounded,
        title: 'App Lock Unavailable',
        message: 'Set up a device lock or biometrics first to enable App Lock.',
        cancelText: 'Okay',
        iconColor: Theme.of(context).colorScheme.primary,
        iconBackgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        confirmBackgroundColor: Theme.of(context).colorScheme.primary,
        confirmTextColor: Theme.of(context).colorScheme.onPrimary,
        cancelTextColor: Theme.of(context).colorScheme.onSurface,
        verticalButtons: true,
        primaryOnTop: true,
        onConfirm: () {},
        onCancel: () {},
      ),
      blurSigma: 20.0,
    );
  }

  Widget _sectionTitle(BuildContext context, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
        ),
        Gap(AppSpacing.xs.h),
        Text(subtitle, style: AppTextStyles.subtitle(context)),
      ],
    );
  }

  Widget _dangerAction(BuildContext context, {required String title, required VoidCallback onTap}) {
    return ButtonBuilder(
      text: title,
      onPressed: onTap,
      isDestructive: true,
    );
  }

  Future<void> _toggleAppLock(BuildContext context, bool enabled) async {
    final AppLockCubit appLockCubit = context.read<AppLockCubit>();

    if (enabled) {
      await appLockCubit.setEnabled(false);
      return;
    }

    final bool canUseAppLock = await _biometricLockService.canUseAppLock();

    if (!context.mounted) {
      return;
    }

    if (!canUseAppLock) {
      await _showAppLockUnavailableDialog(context);
      return;
    }

    await appLockCubit.setEnabled(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl.w, vertical: AppSpacing.lg.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(context, 'Account', 'Secure actions for your profile and session'),
              Gap(AppSpacing.md.h),
              MenuTileBuilder(
                icon: Icons.logout_rounded,
                title: 'Logout',
                onTap: () => _logout(context),
                showBorder: true,
                filledBackground: true,
                borderColor: AppColors.notSelected.withValues(alpha: 0.22),
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w, vertical: AppSpacing.md.h),
                borderRadius: AppRadius.md,
                iconSize: 20.sp,
                arrowSize: 16.sp,
              ),
              Gap(AppSpacing.md.h),
              _dangerAction(context, title: 'Delete Account', onTap: () => _deleteAccount(context)),
              Gap(AppSpacing.xl2.h),
              _sectionTitle(
                context,
                'App Security',
                'Protect the app with biometrics or device passcode',
              ),
              Gap(AppSpacing.md.h),
              BlocBuilder<AppLockCubit, bool>(
                builder: (context, enabled) {
                  return MenuTileBuilder(
                    icon: Icons.fingerprint_rounded,
                    title: 'App Lock',
                    trailingWidget: SizedBox(
                      width: 42,
                      child: Transform.scale(
                        scale: 0.75,
                        alignment: Alignment.centerRight,
                        child: CupertinoSwitch(
                          value: enabled,
                          activeTrackColor: AppColors.primary,
                          onChanged: (_) => _toggleAppLock(context, enabled),
                        ),
                      ),
                    ),
                    onTap: () => _toggleAppLock(context, enabled),
                    showArrow: false,
                    showBorder: true,
                    filledBackground: true,
                    borderColor: AppColors.notSelected.withValues(alpha: 0.22),
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w, vertical: AppSpacing.md.h),
                    borderRadius: AppRadius.md,
                    iconSize: 20.sp,
                  );
                },
              ),
              Gap(AppSpacing.xl2.h),
              _sectionTitle(
                context,
                'Privacy & Legal',
                'Pages users should always be able to find',
              ),
              Gap(AppSpacing.md.h),
              MenuTileBuilder(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () => _openPrivacy(context),
                showBorder: true,
                filledBackground: true,
                borderColor: AppColors.notSelected.withValues(alpha: 0.22),
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w, vertical: AppSpacing.md.h),
                borderRadius: AppRadius.md,
                iconSize: 20.sp,
                arrowSize: 16.sp,
              ),
              Gap(AppSpacing.md.h),
              MenuTileBuilder(
                icon: Icons.description_outlined,
                title: 'Terms & Conditions',
                onTap: () => _openTerms(context),
                showBorder: true,
                filledBackground: true,
                borderColor: AppColors.notSelected.withValues(alpha: 0.22),
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w, vertical: AppSpacing.md.h),
                borderRadius: AppRadius.md,
                iconSize: 20.sp,
                arrowSize: 16.sp,
              ),
              Gap(AppSpacing.xl2.h),
              _sectionTitle(context, 'Support', 'Ways to get help or share feedback'),
              Gap(AppSpacing.md.h),
              MenuTileBuilder(
                icon: Icons.mail_outline_rounded,
                title: 'Contact Support',
                onTap: () => _contactSupport(context),
                showBorder: true,
                filledBackground: true,
                borderColor: AppColors.notSelected.withValues(alpha: 0.22),
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w, vertical: AppSpacing.md.h),
                borderRadius: AppRadius.md,
                iconSize: 20.sp,
                arrowSize: 16.sp,
              ),
              Gap(AppSpacing.xl2.h),
            ],
          ),
        ),
      ),
    );
  }
}
