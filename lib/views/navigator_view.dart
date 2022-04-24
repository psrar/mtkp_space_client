///Used implementation of InteractiveViewer widget from
///pinch_zoom package https://pub.dev/packages/pinch_zoom
///by https://pub.dev/publishers/jelter.net
///
///InteractiveViewer's _kDrag value for inertia was changed to zero

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:mtkp/main.dart' as app_global;

const imageDimensions = Tuple2(774.0, 1080.0);
const double markerSize = 32;
const double markerLeftOffset = -markerSize / 2;
const double markerTopOffset = -markerSize / 1.05;

class NavigatorView extends StatefulWidget {
  const NavigatorView({Key? key, String cabName = ''}) : super(key: key);

  @override
  State<NavigatorView> createState() => _NavigatorViewState();
}

class _NavigatorViewState extends State<NavigatorView>
    with SingleTickerProviderStateMixin {
  final _transformationController = TransformationController();

  late double oldMarkerLeft;
  late double oldMarkerTop;
  late double newMarkerLeft;
  late double newMarkerTop;

  late double realWidth;
  late double realHeight;
  late double zoomOriginX;
  late double zoomOriginY;

  late double scaling;

  late Animation<Matrix4> _animationReset;
  late AnimationController _controllerReset;

  @override
  void initState() {
    super.initState();

    _controllerReset = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
//445, 330
    realWidth = MediaQuery.of(context).size.width;
    realHeight = realWidth * imageDimensions.item2 / imageDimensions.item1;
  }

  @override
  Widget build(BuildContext context) {
    oldMarkerLeft = realWidth + markerLeftOffset;
    oldMarkerTop = realHeight + markerTopOffset;
    newMarkerLeft = (445 + markerLeftOffset);
    newMarkerTop = (380 + markerTopOffset);
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: GestureDetector(
            onDoubleTap: () => _animateResetInitialize(),
            child: InteractiveViewer(
              minScale: 1,
              constrained: false,
              child: Stack(children: [
                const Image(
                    image:
                        AssetImage('assets/building_plan/building_plan.jpg')),
                Positioned(
                  left: oldMarkerLeft,
                  top: oldMarkerTop,
                  child: const Icon(
                    Icons.place_sharp,
                    color: app_global.errorColor,
                    size: markerSize,
                  ),
                ),
                Positioned(
                  left: newMarkerLeft,
                  top: newMarkerTop,
                  child: const Icon(
                    Icons.place_sharp,
                    color: app_global.primaryColor,
                    size: markerSize,
                  ),
                ),
              ]),
              onInteractionStart: (_) {
                if (_controllerReset.status == AnimationStatus.forward) {
                  _animateResetStop();
                }
              },
              // onInteractionEnd: (_) => _animateResetInitialize(),
              transformationController: _transformationController,
            ),
          ),
        ),
        Expanded(child: Container())
      ],
    );
  }

  @override
  void dispose() {
    _controllerReset.dispose();
    super.dispose();
  }

  /// Go back to static state after resetting has ended
  void _onAnimateReset() {
    _transformationController.value = _animationReset.value;
    if (!_controllerReset.isAnimating) {
      _animationReset.removeListener(_onAnimateReset);
      _animationReset = Matrix4Tween().animate(_controllerReset);
      _controllerReset.reset();
    }
  }

  /// Start resetting the animation
  void _animateResetInitialize() {
    var t = _transformationController.value.clone();

    var lx = min(oldMarkerLeft, newMarkerLeft);
    var hx = max(oldMarkerLeft, newMarkerLeft);

    var ly = min(oldMarkerTop, newMarkerTop);
    var hy = max(oldMarkerTop, newMarkerTop);

    zoomOriginX = _transformationController.toScene(Offset.zero).dx -
        hx +
        (hx - lx) / 2 +
        markerLeftOffset;
    zoomOriginY = _transformationController.toScene(Offset.zero).dy -
        hy +
        (hy - ly) / 2 +
        markerTopOffset;

    hx -= lx;
    hy -= ly;
    scaling = hx > hy ? realWidth / hx / 1.6 : realHeight / hy / 1.6;

//Sets zoom origins in center and scales
    t.translate(zoomOriginX, zoomOriginY);
    var dx = t.getTranslation().x / t.getMaxScaleOnAxis();
    var dy = t.getTranslation().y / t.getMaxScaleOnAxis();
    t.scale(scaling / t.getMaxScaleOnAxis());
    dx -= t.getTranslation().x / t.getMaxScaleOnAxis() -
        realWidth / 2 / t.getMaxScaleOnAxis();
    dy -= t.getTranslation().y / t.getMaxScaleOnAxis() -
        realHeight / 2.5 / t.getMaxScaleOnAxis();
    t.translate(dx, dy);

    _controllerReset.reset();
    _animationReset = Matrix4Tween(
      begin: _transformationController.value,
      end: t,
    ).animate(
        CurvedAnimation(parent: _controllerReset, curve: Curves.easeOutExpo));
    _animationReset.addListener(_onAnimateReset);
    _controllerReset.forward();
  }

  /// Stop the reset animation
  void _animateResetStop() {
    _controllerReset.stop();
    _animationReset.removeListener(_onAnimateReset);
    _animationReset = Matrix4Tween().animate(_controllerReset);
    _controllerReset.reset();
  }
}
