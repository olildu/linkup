import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linkup/data/enums/message_type_enum.dart';
import 'package:linkup/data/http_services/common_http_services/common_http_services.dart';
import 'package:linkup/data/http_services/user_http_services/user_http_services.dart';
import 'package:linkup/data/models/candidate_info_model.dart';
import 'package:linkup/data/models/update_metadata_model.dart';
import 'package:linkup/data/models/user_model.dart';
import 'package:linkup/data/token/token_services.dart';
import 'package:linkup/logic/bloc/profile/own/profile_bloc.dart';
import 'package:linkup/logic/bloc/signup/signup_bloc.dart';
import 'package:linkup/presentation/components/common/image_picker_builder.dart';
import 'package:linkup/presentation/components/common/text_field_builder.dart';
import 'package:linkup/presentation/components/common/title_sub_builder.dart';
import 'package:linkup/presentation/components/signup_page/button_builder.dart';
import 'package:linkup/presentation/constants/colors.dart';
import 'package:linkup/presentation/screens/loading_screen_post_login_page.dart';
import 'package:linkup/presentation/screens/singup_flow_page.dart';
import 'package:linkup/presentation/utils/show_error_toast.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  bool aboutMeChanged = false;
  late String aboutMeContent;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _handleImageChange(List<dynamic> selectedImages, bool changePfp) async {
    setState(() {
      _updating = true;
    });

    List<Map> finalImages = [];

    for (var item in selectedImages) {
      if (item is XFile) {
        final uploaded = await CommonHttpServices().uploadMediaUser(file: File(item.path), mediaType: MessageType.image);
        finalImages.add(uploaded['metadata']);
      } else {
        finalImages.add(item);
      }
    }

    Map? pfpMetadata;
    if (changePfp) {
      final firstImage = finalImages.isNotEmpty ? finalImages.first : null;
      if (firstImage != null && firstImage['url'] != null) {
        pfpMetadata = await CommonHttpServices().uploadProfilePictureFromUrl(imageUrl: firstImage['url']);
      }
    }

    context.read<ProfileBloc>().add(
      ProfileUpdateEvent(
        userUpdatedModel: UpdateMetadataModel(photos: finalImages, profilePicture: pfpMetadata?['profile_metadata']),
      ),
    );

    setState(() {
      _updating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(
          'Profile Settings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Theme.of(context).colorScheme.onSurface, size: 20.sp),
          onPressed: () {
            if (_updating) {
              showToast(context: context, message: "Please wait until the upload is complete.");
              return;
            }
            Navigator.pop(context);
          },
        ),
      ),

      body: PopScope(
        canPop: !_updating,
        onPopInvokedWithResult: (bool didPop, _) {
          if (!didPop && _updating) {
            showToast(context: context, message: "Please wait until the upload is complete.");
          }
        },
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                if (state is ProfileError) {
                  return Center(
                    child: Text(
                      'Error loading profile settings',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16.sp, color: Theme.of(context).colorScheme.error),
                    ),
                  );
                } else if (state is ProfileLoaded) {
                  final UserModel user = state.user;
                  final candidateInformation = CandidateInfoModel.fromUserModel(user);
                  aboutMeContent = user.about!;

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BuildTitleSubtitle(title: 'Profile Picture', subtitle: 'Choose a profile picture'),
                        Gap(20.h),
                        ImagePickerBuilder(maxImages: 6, onImagesChanged: _handleImageChange, onSignUp: false, initialImages: user.photos!),

                        Gap(20.h),
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
                                    borderRadius: BorderRadius.all(Radius.circular(10.r)),
                                    borderSide: BorderSide(color: AppColors.notSelected),
                                  ),
                                  onChanged: (value) {
                                    internalSetState(() {
                                      aboutMeChanged = value.trim().isNotEmpty;
                                      aboutMeContent = value;
                                    });
                                  },
                                ),

                                if (aboutMeChanged) ...[
                                  Gap(20.h),

                                  ButtonBuilder(
                                    text: "Save",
                                    width: 70.w,
                                    isFullWidth: false,
                                    borderRadius: 10.r,
                                    padding: EdgeInsets.zero,
                                    height: 50.h,
                                    onPressed: () {
                                      FocusScope.of(context).unfocus();
                                      context.read<ProfileBloc>().add(ProfileUpdateEvent(userUpdatedModel: UpdateMetadataModel(about: aboutMeContent)));
                                      setState(() {
                                        aboutMeChanged = false;
                                      });
                                    },
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                        Gap(20.h),

                        BuildTitleSubtitle(title: 'Your Information', subtitle: 'Select or update your information'),
                        Gap(20.h),
                        Column(
                          children: candidateInformation.asIconMap(showGender: false).entries.map((entry) {
                            final icon = entry.value['icon'] as IconData;
                            final value = entry.value['value'];
                            final title = entry.value['title'] as String;
                            final index = entry.value['index'] as int;

                            return _buildOptions(icon, title, value, index, candidateInformation);
                          }).toList(),
                        ),

                        Gap(20.h),

                        Row(
                          children: [
                            Expanded(
                              child: _buildStrongOption(
                                textColor: AppColors.primary,
                                title: "Logout",
                                onTap: () async {
                                  await TokenServices().clearTokens();
                                  Navigator.of(context).pushAndRemoveUntil(CupertinoPageRoute(builder: (context) => const LoadingScreenPostLogin()), (Route<dynamic> route) => false);
                                },
                              ),
                            ),
                            Gap(10.w),
                            Expanded(
                              child: // Inside _buildStrongOption for "Delete Account"
                              _buildStrongOption(
                                textColor: Theme.of(context).colorScheme.error,
                                title: "Delete Account",
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text("Delete Account?", style: Theme.of(context).textTheme.titleLarge),
                                      content: Text("This action cannot be undone. You will lose all your matches and chats.", style: Theme.of(context).textTheme.bodyMedium),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text("Cancel", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context); // Close dialog
                                            try {
                                              await UserHttpServices().deleteAccount();
                                              await TokenServices().clearTokens();
                                              if (context.mounted) {
                                                Navigator.of(context).pushAndRemoveUntil(CupertinoPageRoute(builder: (context) => const LoadingScreenPostLogin()), (Route<dynamic> route) => false);
                                              }
                                            } catch (e) {
                                              showToast(context: context, message: "Failed to delete account");
                                            }
                                          },
                                          child: Text("Delete", style: AppTextStyles.destructive(context)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        Gap(20.h),
                      ],
                    ),
                  );
                } else {
                  return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptions(IconData icon, String title, String? data, int index, dynamic optionsData) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => SignupBloc(isSigningUp: false),
              child: SingupFlowPage(initialIndex: index, initialData: optionsData.toJson()),
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 30.h),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: Theme.of(context).colorScheme.onSurface),
            Gap(10.w),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
            ),
            const Spacer(),
            Text(data ?? "None", style: AppTextStyles.subtitle(context)?.copyWith(fontSize: 14.sp)),

            Gap(10.w),

            Icon(Icons.arrow_forward_ios_rounded, size: 20.sp, color: AppColors.notSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildStrongOption({required String title, required Color textColor, Function? onTap}) {
    return ButtonBuilder(
      text: title,
      onPressed: () {
        if (onTap != null) {
          onTap();
        }
      },
      backgroundColor: const Color.fromARGB(255, 35, 35, 35),
      textColor: textColor,
      isFullWidth: true,
      borderRadius: 50.r,
      height: 40.h,
    );
  }
}
