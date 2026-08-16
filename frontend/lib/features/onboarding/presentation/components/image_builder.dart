import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linkup/shared_ui/utils/blurhash_util.dart';
import 'package:octo_image/octo_image.dart';

class ImageBuilder extends StatelessWidget {
  final dynamic imageMetaData;
  final bool? darkMode;
  final double? height;
  final double? width;
  final void Function()? onTap;

  const ImageBuilder({
    super.key,
    this.imageMetaData = "assets/images/care.png",
    this.darkMode,
    this.height,
    this.width,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNetwork = imageMetaData is Map<String, dynamic>;

    Widget imageWidget = GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0.r),
        child: isNetwork
            ? OctoImage(
                image: CachedNetworkImageProvider(
                  imageMetaData['url'],
                  cacheKey: imageMetaData['file_key'],
                ),
                placeholderBuilder: blurHash(
                  imageMetaData['blurhash'],
                ).placeholderBuilder,
                fit: BoxFit.cover,
                width: width ?? double.infinity,
                height: height ?? double.infinity,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error),
              )
            : Image.asset(
                imageMetaData,
                height: height ?? double.infinity,
                fit: BoxFit.contain,
                width: width ?? double.infinity,
              ),
      ),
    );

    if (darkMode == true) {
      return ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          -1,
          0,
          0,
          0,
          255,
          0,
          -1,
          0,
          0,
          255,
          0,
          0,
          -1,
          0,
          255,
          0,
          0,
          0,
          1,
          0,
        ]),
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
