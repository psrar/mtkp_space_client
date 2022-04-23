///Used implementation of InteractiveViewer widget from
///pinch_zoom package https://pub.dev/packages/pinch_zoom
///by https://pub.dev/publishers/jelter.net
///
///InteractiveViewer's _kDrag value for inetrtia was changed to zero

import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:mtkp/main.dart' as app_global;

const imageDimensions = Tuple2(774.0, 1080.0);

class NavigatorView extends StatefulWidget {
  const NavigatorView({Key? key}) : super(key: key);

  @override
  State<NavigatorView> createState() => _NavigatorViewState();
}

class _NavigatorViewState extends State<NavigatorView>
    with SingleTickerProviderStateMixin {
  final _transformationController = TransformationController();

  double markerLeft = 10;
  double markerTop = 10;

  late Animation<Matrix4> _animationReset;
  late AnimationController _controllerReset;

  @override
  void initState() {
    super.initState();
    // _transformationController.value = Matrix4.translationValues(
    //     -imageDimensions.item1 *
    //         _transformationController.value.getMaxScaleOnAxis() /
    //         2,
    //     -imageDimensions.item2 *
    //         _transformationController.value.getMaxScaleOnAxis() /
    //         2,
    //     0);
    _controllerReset = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onDoubleTap: () => _animateResetInitialize(),
          child: InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(20),
            child: Stack(children: [
              const Image(
                  image: AssetImage('assets/building_plan/building_plan.jpg')),
              Positioned(
                left: markerLeft,
                top: markerTop,
                child: const Icon(
                  Icons.place_sharp,
                  color: app_global.errorColor,
                  size: 16,
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
    _controllerReset.reset();
    _animationReset = Matrix4Tween(
      begin: _transformationController.value,
      end: Matrix4.identity(),
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
