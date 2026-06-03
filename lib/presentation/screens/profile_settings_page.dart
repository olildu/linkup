import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:linkup/core/di/injection_container.dart';
import 'package:linkup/data/models/candidate_info_model.dart';
import 'package:linkup/data/models/update_metadata_model.dart';
import 'package:linkup/domain/entities/user_entity.dart';
import 'package:linkup/logic/bloc/auth/auth_bloc.dart';
import 'package:linkup/logic/bloc/profile/own/profile_bloc.dart';
import 'package:linkup/logic/bloc/signup/signup_bloc.dart';
import 'package:linkup/presentation/components/common/image_picker_builder.dart';
import 'package:linkup/presentation/components/common/menu_tile_builder.dart';
import 'package:linkup/presentation/components/common/text_field_builder.dart';
import 'package:linkup/presentation/components/common/title_sub_builder.dart';
import 'package:linkup/presentation/components/common/upload_progress_overlay_builder.dart';
import 'package:linkup/presentation/components/signup_page/button_builder.dart';
import 'package:linkup/presentation/constants/colors.dart';
import 'package:linkup/presentation/theme/app_radius.dart';
import 'package:linkup/presentation/theme/app_spacing.dart';
import 'package:linkup/presentation/screens/singup_flow_page.dart';
import 'package:linkup/presentation/screens/settings_page.dart';
import 'package:linkup/presentation/screens/user_profile_bottom_sheet.dart';
import 'package:linkup/presentation/utils/show_error_toast.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  bool aboutMeChanged = false;
  late String aboutMeContent;
  UserEntity? cachedUser;

  @override
  void initState() {
    super.initState();
  }

  void _openProfilePreview(UserEntity user) {
    final int currentUserId = GetIt.I<int>(instanceName: 'user_id');
    showBottomSheetUserProfile(context: context, userId: currentUserId, showChatButton: false);
  }

  void _openEditFlow(int index, dynamic optionsData) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => sl<AuthBloc>(),
          child: BlocProvider(
            create: (context) => SignupBloc(uploadPfpUseCase: sl(), uploadUserMediaUseCase: sl(), isSigningUp: false),
            child: SingupFlowPage(initialIndex: index, initialData: optionsData.toJson()),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProfileBloc>().state;
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(
          'Profile Settings',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.onSurface,
            size: 20.sp,
          ),
          onPressed: () {
            if (state is ProfileUpdating) {
              showToast(context: context, message: "Please wait until the upload is complete.");
              return;
            }
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_rounded,
              color: Theme.of(context).colorScheme.onSurface,
              size: 22.sp,
            ),
            onPressed: () {
              if (state is ProfileUpdating) {
                showToast(context: context, message: "Please wait until the upload is complete.");
                return;
              }

              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) =>
                      BlocProvider(create: (context) => sl<AuthBloc>(), child: const SettingsPage()),
                ),
              );
            },
          ),
        ],
      ),

      body: PopScope(
        canPop: state is! ProfileUpdating,
        onPopInvokedWithResult: (bool didPop, _) {
          if (!didPop && state is ProfileUpdating) {
            showToast(context: context, message: "Please wait until the upload is complete.");
          }
        },
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl.w, vertical: AppSpacing.xl.h),
            child: Builder(
              builder: (context) {
                if (state is ProfileError) {
                  return Center(
                    child: Text(
                      'Error loading profile settings',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error),
                    ),
                  );
                } else if (state is ProfileLoaded || state is ProfileUpdating) {
                  if (state is ProfileLoaded) {
                    cachedUser = state.user;
                  }
                  final UserEntity user = cachedUser!;
                  final candidateInformation = CandidateInfoModel.fromUserEntity(user);
                  aboutMeContent = user.about!;

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BuildTitleSubtitle(
                          title: 'Profile Picture',
                          subtitle: 'Choose a profile picture',
                        ),
                        Gap(20.h),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            IgnorePointer(
                              ignoring: state is ProfileUpdating,
                              child: Opacity(
                                opacity: state is ProfileUpdating ? 0.4 : 1,
                                child: ImagePickerBuilder(
                                  maxImages: 6,
                                  onImagesChanged: (selectedImages, changePfp) {
                                    context.read<ProfileBloc>().add(
                                      ProfileImagesUpdatedEvent(
                                        selectedImages: selectedImages,
                                        changePfp: changePfp,
                                      ),
                                    );
                                  },
                                  onSignUp: false,
                                  initialImages: user.photos!,
                                ),
                              ),
                            ),

                            if (state is ProfileUpdating)
                              Builder(
                                builder: (_) {
                                  final uploadingState = state;

                                  return Positioned(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                                      child: UploadProgressOverlayBuilder(
                                        current: uploadingState.current,
                                        total: uploadingState.total,
                                        message: uploadingState.message,
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),

                        Gap(20.h),

                        MenuTileBuilder(
                          icon: Icons.remove_red_eye_sharp,
                          title: "Preview Profile",
                          onTap: () => _openProfilePreview(user),
                          showBorder: true,
                          filledBackground: true,
                          borderColor: AppColors.notSelected.withValues(alpha: 0.22),
                          margin: EdgeInsets.only(bottom: 20.h),
                          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w, vertical: AppSpacing.md.h),
                          borderRadius: AppRadius.md,
                          iconSize: 20.sp,
                          arrowSize: 20.sp,
                        ),

                        BuildTitleSubtitle(title: 'About Me', subtitle: 'Tell us about yourself'),
                        Gap(20.h),
                        StatefulBuilder(
                          builder: (context, internalSetState) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                TextFieldBuilder(
                                  hintText: 'Write something about yourself',
                                  initialValue: aboutMeContent,
                                  maxLines: 3,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
                                    borderSide: BorderSide(color: AppColors.notSelected),
                                  ),
                                  onChanged: (value) {
                                    internalSetState(() {
                                      aboutMeChanged = value.trim() != user.about?.trim();
                                      aboutMeContent = value;
                                    });
                                  },
                                ),

                                if (aboutMeChanged) ...[
                                  Gap(20.h),

                                  SizedBox(
                                    width: 70.w,
                                    child: ButtonBuilder(
                                      text: "Save",
                                      onPressed: () {
                                        FocusScope.of(context).unfocus();
                                        context.read<ProfileBloc>().add(
                                          ProfileUpdateEvent(
                                            userUpdatedModel: UpdateMetadataModel(
                                              about: aboutMeContent,
                                            ),
                                          ),
                                        );
                                        setState(() {
                                          aboutMeChanged = false;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                        Gap(20.h),

                        BuildTitleSubtitle(
                          title: 'Your Information',
                          subtitle: 'Select or update your information',
                        ),
                        Gap(20.h),
                        Column(
                          children: candidateInformation.asIconMap(showGender: false).entries.map((
                            entry,
                          ) {
                            final icon = entry.value['icon'] as IconData;
                            final value = entry.value['value'];
                            final title = entry.value['title'] as String;
                            final index = entry.value['index'] as int;

                            return MenuTileBuilder(
                              icon: icon,
                              title: title,
                              trailingText: value?.toString(),
                              onTap: () => _openEditFlow(index, candidateInformation),
                              showBorder: false,
                              filledBackground: false,
                              padding: EdgeInsets.zero,
                              margin: EdgeInsets.only(bottom: 30.h),
                              iconSize: 20.sp,
                              arrowSize: 20.sp,
                            );
                          }).toList(),
                        ),

                        Gap(20.h),
                      ],
                    ),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
