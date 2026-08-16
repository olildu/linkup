import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:linkup/data/models/chat_models/message_model.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:vibration/vibration.dart';

class SwipeWrapper extends StatefulWidget {
  final Function onSwipe;
  final Message payload;
  final Widget child;

  const SwipeWrapper({
    super.key,
    required this.child,
    required this.payload,
    required this.onSwipe,
  });

  @override
  State<SwipeWrapper> createState() => _SwipeWrapperState();
}

class _SwipeWrapperState extends State<SwipeWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late bool isSentByMe;

  late double _dragExtent = 0.0;
  final double _triggerThreshold = 80;

  @override
  void initState() {
    super.initState();
    isSentByMe =
        widget.payload.from_ == GetIt.instance<int>(instanceName: 'user_id');
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      if (isSentByMe) {
        _dragExtent -= details.primaryDelta!;
      } else {
        _dragExtent += details.primaryDelta!;
      }
    });
  }

  Future<void> _handleDragEnd(DragEndDetails details) async {
    if (_dragExtent > _triggerThreshold) {
      widget.onSwipe();
    }
    // Vibrate
    if (await Vibration.hasVibrator()) {
      if (await Vibration.hasCustomVibrationsSupport()) {
        Vibration.vibrate(duration: 20);
      } else {
        Vibration.vibrate();
        await Future.delayed(Duration(milliseconds: 20));
        Vibration.vibrate();
      }
    }
    _controller.reverse();
    setState(() => _dragExtent = 0);
  }

  @override
  Widget build(BuildContext context) {
    final double offSet = _dragExtent.clamp(0, _triggerThreshold);
    final double slideAmount = isSentByMe ? -offSet : offSet;

    return Stack(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      clipBehavior: Clip.none,
      children: [
        if (_dragExtent > 10)
          Positioned(
            bottom: 0,
            child: Opacity(
              opacity: (slideAmount.abs() / _triggerThreshold).clamp(0.0, 1.0),
              child: Container(
                width: 36.r,
                height: 36.r,
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(70, 194, 194, 194),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Symbols.reply,
                  color: const Color.fromARGB(255, 255, 255, 255),
                  size: 16.r,
                ),
              ),
            ),
          ),

        GestureDetector(
          onHorizontalDragUpdate: _handleDragUpdate,
          onHorizontalDragEnd: _handleDragEnd,
          child: Transform.translate(
            offset: Offset(slideAmount, 0),
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
