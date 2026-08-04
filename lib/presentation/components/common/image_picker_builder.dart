import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linkup/core/errors/error_message_mapper.dart';
import 'package:linkup/presentation/constants/colors.dart';
import 'package:linkup/presentation/theme/app_media_ratios.dart';
import 'package:linkup/presentation/utils/blurhash_util.dart';
import 'package:linkup/presentation/utils/show_error_toast.dart';
import 'package:octo_image/octo_image.dart';

class ImagePickerBuilder extends StatefulWidget {
  final int maxImages;
  final Function(List<dynamic>, bool changePfp) onImagesChanged;
  final bool allowMultipleSelection;
  final List<Map> initialImages;
  final bool onSignUp;

  const ImagePickerBuilder({
    super.key,
    this.maxImages = 6,
    required this.onImagesChanged,
    this.allowMultipleSelection = true,
    this.initialImages = const [],
    this.onSignUp = true,
  });

  @override
  State<ImagePickerBuilder> createState() => _ImagePickerBuilderState();
}

class _ImagePickerBuilderState extends State<ImagePickerBuilder> {
  final ImagePicker _picker = ImagePicker();
  final List<dynamic> _displayedItems = [];

  @override
  void initState() {
    super.initState();
    _syncDisplayedItems(widget.initialImages);
  }

  @override
  void didUpdateWidget(covariant ImagePickerBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialImages != widget.initialImages) {
      _syncDisplayedItems(widget.initialImages);
    }
  }

  void _syncDisplayedItems(List<Map> initialImages) {
    _displayedItems
      ..clear()
      ..addAll(
        initialImages.length > widget.maxImages
            ? initialImages.sublist(0, widget.maxImages)
            : initialImages,
      );
  }

  Future<XFile?> _cropImage(XFile source) async {
    final CroppedFile? cropped = await ImageCropper().cropImage(
      sourcePath: source.path,
      aspectRatio: const CropAspectRatio(ratioX: 9, ratioY: 16),
      uiSettings: [
        AndroidUiSettings(
          lockAspectRatio: true,
          hideBottomControls: false,
          toolbarTitle: 'Adjust photo',
        ),
        IOSUiSettings(aspectRatioLockEnabled: true, resetAspectRatioEnabled: false, title: 'Adjust photo'),
      ],
    );
    return cropped == null ? null : XFile(cropped.path);
  }

  Future<void> _pickImages() async {
    if (_displayedItems.where((item) => item != null).length >= widget.maxImages) return;

    try {
      final List<XFile> pickedImages = widget.allowMultipleSelection
          ? await _picker.pickMultiImage()
          : [(await _picker.pickImage(source: ImageSource.gallery))].whereType<XFile>().toList();

      if (pickedImages.isEmpty) return;

      final int occupiedSlots = _displayedItems.where((item) => item != null).length;
      final int remainingSlots = widget.maxImages - occupiedSlots;
      if (remainingSlots <= 0) return;

      final newImagesToAdd = pickedImages.where((newlyPickedFile) {
        return !_displayedItems.whereType<XFile>().any(
          (existingXFile) => existingXFile.path == newlyPickedFile.path,
        );
      }).toList();

      final int imagesToAddCount = newImagesToAdd.length > remainingSlots
          ? remainingSlots
          : newImagesToAdd.length;
      if (imagesToAddCount == 0) return;

      final List<XFile> imagesToCrop = newImagesToAdd.sublist(0, imagesToAddCount);
      final List<XFile> croppedImages = [];
      for (final image in imagesToCrop) {
        final XFile? cropped = await _cropImage(image);
        if (cropped != null) croppedImages.add(cropped);
      }

      if (croppedImages.isEmpty || !mounted) return;

      setState(() {
        final emptySlotIndices = _displayedItems
            .asMap()
            .entries
            .where((entry) => entry.value == null)
            .map((entry) => entry.key)
            .toList();
        bool shouldChangePfp = false;

        for (final image in croppedImages) {
          if (emptySlotIndices.isNotEmpty) {
            final targetIndex = emptySlotIndices.removeAt(0);
            _displayedItems[targetIndex] = image;
            shouldChangePfp = shouldChangePfp || targetIndex == 0;
          } else {
            _displayedItems.add(image);
          }
        }

        widget.onImagesChanged(
          _displayedItems.where((item) => item != null).toList(),
          shouldChangePfp,
        );
      });
    } catch (e) {
      if (mounted) {
        showToast(context: context, message: friendlyErrorMessage(e));
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      if (index < _displayedItems.length) {
        _displayedItems[index] = null;
        widget.onImagesChanged(_displayedItems.where((item) => item != null).toList(), false);
      }
    });
  }

  Widget _buildImageContainer(double contentSize, int index) {
    final bool hasImage = index < _displayedItems.length && _displayedItems[index] != null;
    final bool canAddMore = _displayedItems.where((item) => item != null).length < widget.maxImages;
    final bool isAddButton = !hasImage && canAddMore;
    Widget imageDisplayWidget;
    if (hasImage) {
      final item = _displayedItems[index];
      if (item is Map) {
        imageDisplayWidget = OctoImage(
          image: CachedNetworkImageProvider(item["url"]),
          placeholderBuilder: blurHash(item["blurhash"]).placeholderBuilder,
          errorBuilder: OctoError.icon(color: Colors.red),
          fit: BoxFit.cover,
          width: 30.r,
          height: 30.r,
        );
      } else if (item is XFile) {
        imageDisplayWidget = Image.file(File(item.path), fit: BoxFit.cover);
      } else {
        imageDisplayWidget = const SizedBox.shrink();
      }
    } else {
      imageDisplayWidget = Center(
        child: Container(
          padding: EdgeInsets.all((contentSize * 0.08).sp),
          decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          child: Icon(Icons.add_rounded, color: Colors.white, size: (contentSize * 0.2).sp),
        ),
      );
    }

    return GestureDetector(
      onTap: isAddButton ? _pickImages : null,
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: Radius.circular(15.r),
        padding: EdgeInsets.all(1.sp),
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade700
            : Colors.grey.shade400,
        strokeWidth: 1.5,
        dashPattern: const [6, 4],
        child: Container(
          width: contentSize,
          height: contentSize,
          decoration: BoxDecoration(
            color: hasImage
                ? Colors.transparent
                : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: hasImage
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(borderRadius: BorderRadius.circular(15.r), child: imageDisplayWidget),

                    if (_displayedItems.length > 2 || widget.onSignUp)
                      Positioned(
                        top: 5.r,
                        right: 5.r,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: EdgeInsets.all(4.sp),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close, color: Colors.white, size: 14.sp),
                          ),
                        ),
                      ),
                  ],
                )
              : imageDisplayWidget,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double itemGap = 5.sp;
    final double dottedBorderInternalPaddingPerSide = 1.sp;
    const double dottedBorderStrokeWidth = 1.5;

    return LayoutBuilder(
      builder: (context, constraints) {
        double availableWidth = constraints.maxWidth;
        double shellWidthPerItem =
            (2 * dottedBorderInternalPaddingPerSide) + dottedBorderStrokeWidth;
        double totalShellWidthForAllItemsInRow = 3 * shellWidthPerItem;
        double totalGapSpaceInRow = 2 * itemGap;
        double effectiveContentWidthForRow =
            availableWidth - totalShellWidthForAllItemsInRow - totalGapSpaceInRow;
        if (effectiveContentWidthForRow < 0) effectiveContentWidthForRow = 0;

        double smallItemContentWidth = (effectiveContentWidthForRow / 3);
        double largeItemContentWidth = ((2 * smallItemContentWidth) + itemGap);

        return Padding(
          padding: EdgeInsets.symmetric(vertical: itemGap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _buildImageContainer(largeItemContentWidth, 0),
                  Gap(itemGap),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildImageContainer(smallItemContentWidth, 1),
                      Gap(itemGap),
                      _buildImageContainer(smallItemContentWidth, 2),
                    ],
                  ),
                ],
              ),
              Gap(itemGap),
              Row(
                children: [
                  _buildImageContainer(smallItemContentWidth, 3),
                  Gap(itemGap),
                  _buildImageContainer(smallItemContentWidth, 4),
                  if (widget.maxImages > 5) ...[
                    Gap(itemGap),
                    _buildImageContainer(smallItemContentWidth, 5),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
