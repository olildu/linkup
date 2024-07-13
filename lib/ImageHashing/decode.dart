import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:linkup/UI/pages/loadingAnimation/loadingAnimation.dart';
import 'package:octo_image/octo_image.dart';

class OctoBlurHashFix {
  static OctoPlaceholderBuilder placeHolder(String hash, double size, {BoxFit? fit}) {
    return (context) => Stack(
      children: [
        SizedBox.expand(
          child: Image(
            image: BlurHashImage(hash),
            fit: fit ?? BoxFit.cover,
          ),
        ),
        // Container(width: 100, height: 100, color: Colors.black,),
        StaggeredDotsWave(color: Colors.white, size: size),

      ],
    );
  }

  static OctoErrorBuilder error(
      String hash, {
        BoxFit? fit,
        double? size,
        Text? message,
        IconData? icon,
        Color? iconColor,
        double? iconSize,
      }) {
    return OctoError.placeholderWithErrorIcon(
      placeHolder(hash, size!, fit: fit),
      message: message,
      icon: icon,
      iconColor: iconColor,
      iconSize: iconSize,
    );
  }
}