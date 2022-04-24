///Used implementation of InteractiveViewer widget from
///pinch_zoom package https://pub.dev/packages/pinch_zoom
///by https://pub.dev/publishers/jelter.net
///
///InteractiveViewer's _kDrag value for inertia was changed to zero

import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:mtkp/main.dart' as app_global;

const imageDimensions = Tuple2(774.0, 1080.0);
const double markerSize = 24;
const double markerLeftOffset = -markerSize / 2;
const double markerTopOffset = -markerSize / 1.1;

class NavigatorView extends StatefulWidget {
  const NavigatorView({Key? key}) : super(key: key);

  @override
  State<NavigatorView> createState() => _NavigatorViewState();
}

class _NavigatorViewState extends State<NavigatorView>
    with SingleTickerProviderStateMixin {
  final _transformationController = TransformationController();

  late double markerLeft;
  late double markerTop;

  late double realWidth;
  late double realHeight;
  late double zoomOriginX;
  late double zoomOriginY;

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

    realWidth = MediaQuery.of(context).size.width;
    realHeight = realWidth * imageDimensions.item2 / imageDimensions.item1;
    zoomOriginX = realWidth / 2;
    zoomOriginY = realHeight / 3;
  }

  @override
  Widget build(BuildContext context) {
    markerLeft = 10 + markerLeftOffset;
    markerTop = 10 + markerTopOffset;
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: GestureDetector(
            onDoubleTap: () => _animateResetInitialize(),
            child: InteractiveViewer(
              constrained: false,
              boundaryMargin: const EdgeInsets.all(800),
              child: Stack(children: [
                Image(
                    width: MediaQuery.of(context).size.width,
                    image: const AssetImage(
                        'assets/building_plan/building_plan.jpg')),
                Positioned(
                  left: markerLeft,
                  top: markerTop,
                  child: const Icon(
                    Icons.place_sharp,
                    color: app_global.errorColor,
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
    t.translate(
        -_transformationController.toScene(Offset.zero).dx -
            zoomOriginX / t.getMaxScaleOnAxis(),
        -_transformationController.toScene(Offset.zero).dy -
            zoomOriginY / t.getMaxScaleOnAxis());
    t.scale(1.999);

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
