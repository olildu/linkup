/// Fixed aspect ratios for cropped/displayed media.
abstract final class AppMediaRatios {
  /// Width:height ratio for candidate-card profile photos.
  /// Must match the crop UI's aspect ratio lock and the display widgets.
  static const double candidatePhoto = 4 / 5;
}
