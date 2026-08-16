import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:linkup/presentation/constants/colors.dart';

class FullScreenImageScreen extends StatefulWidget {
  final String imagePath;

  const FullScreenImageScreen({super.key, required this.imagePath});

  @override
  State<FullScreenImageScreen> createState() => _FullScreenImageScreenState();
}

class _FullScreenImageScreenState extends State<FullScreenImageScreen>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();
  late Matrix4 _initialTransform;

  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animationController.addListener(() {
      if (_animation != null) {
        _transformationController.value = _animation!.value;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialTransform = _transformationController.value;
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scrim,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onScrim),
      ),
      body: Center(
        child: InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.8,
          maxScale: 4.0,
          panEnabled: false,
          clipBehavior: Clip.none,
          boundaryMargin: const EdgeInsets.all(double.infinity),
          onInteractionEnd: (details) {
            _animationController.stop();

            if (_transformationController.value != _initialTransform) {
              _animation =
                  Matrix4Tween(
                    begin: _transformationController.value,
                    end: _initialTransform,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeOut,
                    ),
                  );

              _animationController.forward(from: 0.0);
            }
          },
          child: Hero(
            tag: widget.imagePath,
            child: CachedNetworkImage(
              imageUrl: widget.imagePath,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
