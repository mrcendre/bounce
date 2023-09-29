import 'dart:math';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'size_wrapper.dart';

/// The minimum delay to wait for before triggering [onTap] block.
/// It emphasizes the bounce effect without compromising the animation duration. By applying this delay,
/// the transition time will allow the bounce-back animation to be slightly visible before transition is done.
/// This makes for a better and more put-together overall UX feel.
const _defaultTapDelay = Duration(milliseconds: 150);

/// The default duration for the scale and rotation animations, when enabled.
const _defaultDuration = Duration(milliseconds: 400);

const _defaultLongPressDuration = Duration(milliseconds: 1000);

class Bounce extends StatefulWidget {
  /// The callback fired when the user's finger is lifted from the widget,
  /// providing informations about local and global position.
  final Function()? onTap;

  /// The callback fired when the widget is held for a few seconds.
  final Function()? onLongPress;

  /// The duration for the scale and rotation animations, when enabled.
  final Duration duration;

  /// The minimum delay to wait for before triggering [onTap] block **after the bounce effect is starting to reverse**.
  final Duration tapDelay;

  /// The duration after which, if the user is still pressing, the [onLongPress] callback will be triggered.
  /// Defaults to [defaultLongPressDuration].
  final Duration longPressDuration;

  final HitTestBehavior behavior;

  /// The child to which the bounce effect will be applied
  final Widget child;

  /// Whether the widget should apply the scale effect, in case you want it temporarily disabled.
  final bool scale;

  /// The minimum scale factor applied by the scale effect.
  final double scaleFactor;

  /// Whether the widget should apply a tilt effect.
  final bool tilt;

  /// The maximum angle to which the tilt effect can rotate the widget.
  final double tiltAngle;

  /// The filter quality to use for the [Transform].
  ///
  /// Specifying a null [filterQuality] may result in poor performances and aliased edges.
  final FilterQuality? filterQuality;

  const Bounce(
      {Key? key,
      required this.child,
      this.onTap,
      this.onLongPress,
      this.behavior = HitTestBehavior.deferToChild,
      this.duration = _defaultDuration,
      this.tapDelay = _defaultTapDelay,
      this.longPressDuration = _defaultLongPressDuration,
      this.scale = true,
      this.scaleFactor = 0.95,
      this.tilt = true,
      this.tiltAngle = pi / 10,
      this.filterQuality = FilterQuality.high})
      : super(key: key);

  @override
  BounceState createState() => BounceState();
}

class BounceState extends State<Bounce> with SingleTickerProviderStateMixin {
  Function()? get onTap => widget.onTap;

  Function()? get onLongPress => widget.onLongPress;

  late AnimationController _controller;

  DateTime? _lastTapDownTime;
  DateTime? _lastTapTime;

  Offset? _lastTapLocation;

  Size? lastSize;

  bool isLongPressing = false, isCancelled = false;

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: widget.duration, value: 0);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTapDown: _onTapDown,
      onPanUpdate: _onPointerMove,
      onTapCancel: _onTapCancel,
      onTapUp: _onPointerUp,
      dragStartBehavior: DragStartBehavior.down,
      child: AnimatedBuilder(
          animation: _controller,
          builder: (ctx, child) {
            final transform = Matrix4.identity()..setEntry(3, 2, 0.002);

            if (widget.scale) {
              transform.scale(lerpDouble(1, widget.scaleFactor, _controller.value));
            }

            if (widget.tilt && _lastTapLocation != null && lastSize != null) {
              double x, y, xAngle, yAngle;

              x = _lastTapLocation!.dx / lastSize!.width;
              y = _lastTapLocation!.dy / lastSize!.height;

              xAngle = (x - 0.5) * (-widget.tiltAngle) * _controller.value;
              yAngle = (y - 0.5) * (widget.tiltAngle) * _controller.value;

              transform.rotateX(yAngle);
              transform.rotateY(xAngle);
            }

            return Transform(
                transformHitTests: true,
                transform: transform,
                origin: Offset((lastSize?.width ?? 0) / 2, (lastSize?.height ?? 0) / 2),
                filterQuality: widget.filterQuality,
                child: child);
          },
          child: WidgetSizeWrapper(
              onSizeChange: (newSize) {
                lastSize = newSize;
              },
              child: widget.child)));

  void _onTapDown(TapDownDetails details) {
    isCancelled = false;
    isLongPressing = true;

    /// Start timing
    _lastTapDownTime = DateTime.now();

    _lastTapLocation = details.localPosition;

    /// Fire the animation right away
    _controller.animateTo(1, curve: Curves.easeOutCubic);

    Future.delayed(widget.longPressDuration, () {
      /// If the user is still pressing after the long press duration, trigger the long press callback.
      if (mounted && isLongPressing) {
        _onLongPress();
      }
    });
  }

  void _onTapCancel() {
    isCancelled = true;
    isLongPressing = false;
    _animateBack();
  }

  void _onPointerMove(DragUpdateDetails details) {
    isLongPressing = false;
    if (isCancelled) return;
    if (details.delta.dx.abs() > 1 || details.delta.dy.abs() > 1) {
      _onTapCancel();
    }
  }

  void _onPointerUp(TapUpDetails details) {
    _animateBack();
    isLongPressing = false;

    if (isCancelled) {
      isCancelled = false;
      return;
    }

    if (_lastTapTime != null) {
      final msSinceLastTap = DateTime.now().difference(_lastTapTime!).inMilliseconds;

      /// Debounce for twice the minimum tap delay
      if (msSinceLastTap < widget.tapDelay.inMilliseconds * 2) return;
    }

    _lastTapTime = DateTime.now();

    if (_lastTapTime != null) {
      final msSinceTapDown = DateTime.now().difference(_lastTapDownTime ?? DateTime.now()).inMilliseconds;

      if (msSinceTapDown > widget.tapDelay.inMilliseconds) {
        /// If the minimum delay is ellapsed, immediately trigger the action.
        onTap?.call();
      } else {
        /// Otherwise, wait for the difference between the actually ellapsed time and the minimum delay before
        /// triggering the animation.
        Future.delayed(widget.tapDelay - _lastTapTime!.difference(DateTime.now()), () {
          onTap?.call();
        });
      }
    }
  }

  void _onLongPress() {
    if (isCancelled) {
      isCancelled = false;
      return;
    }

    onLongPress?.call();
  }

  void _animateBack() {
    Future.delayed(widget.tapDelay).then((_) {
      if (mounted) _controller.animateTo(0, curve: Curves.easeOutCubic);
    });
  }
}
