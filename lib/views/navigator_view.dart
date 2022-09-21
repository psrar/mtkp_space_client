///Used implementation of InteractiveViewer widget from
///pinch_zoom package https://pub.dev/packages/pinch_zoom
///by https://pub.dev/publishers/jelter.net
///
///InteractiveViewer's _kDrag value for inertia was changed to zero

import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mtkp/models.dart';
import 'package:tuple/tuple.dart';
import 'package:mtkp/main.dart' as app_global;

const imageDimensions = Tuple2(774.0, 1080.0);
const double markerSize = 32;
const double markerLeftOffset = -markerSize / 2;
const double markerTopOffset = -markerSize / 1.05;

const defaultScaling = 1.1;

class NavigatorView extends StatefulWidget {
  final String previousOrSingleClassroom;
  final String nextClassroom;

  const NavigatorView(
      {Key? key, this.previousOrSingleClassroom = '', this.nextClassroom = ''})
      : super(key: key);

  @override
  State<NavigatorView> createState() => _NavigatorViewState();
}

class _NavigatorViewState extends State<NavigatorView>
    with SingleTickerProviderStateMixin {
  final _transformationController = TransformationController();

  late String _previousOrSingleClassroom;
  // late String _nextClassroom;

  double? oldMarkerLeft;
  double? oldMarkerTop;
  double? newMarkerLeft;
  double? newMarkerTop;

  late double realWidth;
  late double realHeight;
  double? zoomOriginX;
  double? zoomOriginY;

  double? scaling;

  late Animation<Matrix4> _animationReset;
  late AnimationController _controllerReset;

  Widget? zeroPointCard;
  Widget? singlePointCard;
  Widget? twoPointsCard;

  late int mode = 0;
  // late PageStorageBucket storage;

  StreamSubscription<dynamic>? _sub;

  @override
  void initState() {
    super.initState();

    // storage = PageStorage.of(context)!;
    // var data = storage.readState(context, identifier: widget.key);
    // if (data == null) {
    _previousOrSingleClassroom = widget.previousOrSingleClassroom;
    // _nextClassroom = widget.nextClassroom;
    // } else {
    //   _previousOrSingleClassroom = data[0];
    //   _nextClassroom = data[1];
    // }

    _controllerReset = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);

    buildInformationCard();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    realWidth = MediaQuery.of(context).size.width;
    realHeight = realWidth * imageDimensions.item2 / imageDimensions.item1;
    _transformationController.value =
        Matrix4.identity().scaled(realWidth / imageDimensions.item1);
    _animateResetInitialize(false);
  }

  @override
  Widget build(BuildContext context) {
    buildInformationCard();

    return Column(
      children: [
        Expanded(
          flex: 4,
          child: InteractiveViewer(
            clipBehavior: Clip.none,
            boundaryMargin: const EdgeInsets.all(200),
            minScale: 0.5,
            constrained: false,
            child: Stack(children: [
              const Image(
                  alignment: Alignment.center,
                  image: AssetImage('assets/building_plan/building_plan.jpg')),
              if (mode == 1)
                Positioned(
                  left: oldMarkerLeft,
                  top: oldMarkerTop,
                  child: const Icon(
                    Icons.place_sharp,
                    color: app_global.errorColor,
                    size: markerSize,
                  ),
                ),
              if (mode == 2)
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
              _sub?.cancel();
              if (_controllerReset.status == AnimationStatus.forward) {
                _animateResetStop();
              }
            },
            onInteractionEnd: (_) => _previousOrSingleClassroom.isEmpty
                ? _startResetTimer(true)
                : _startResetTimer(false),
            transformationController: _transformationController,
          ),
        ),
        Expanded(
            child: Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 69, 69, 69),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18))),
                child: mode == 1
                    ? singlePointCard
                    : mode == 2
                        ? twoPointsCard
                        : zeroPointCard))
      ],
    );
  }

  Future resettingTimer() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  void _startResetTimer(bool fullReset) {
    _sub = resettingTimer()
        .asStream()
        .listen((data) => _animateResetInitialize(fullReset));
  }

  void buildInformationCard() {
    if (_previousOrSingleClassroom.isNotEmpty) {
      var classroom = classrooms[_previousOrSingleClassroom]!;
      oldMarkerLeft = classroom.item1 + markerLeftOffset;
      oldMarkerTop = classroom.item2 + markerTopOffset;

      if (widget.nextClassroom.isEmpty) {
        mode = 1;

        String s;
        s = _previousOrSingleClassroom[0];
        switch (s) {
          case '1':
          case 'Б':
          case 'б':
            s = 'Первый этаж';
            break;
          case '2':
            s = 'Второй этаж';
            break;
          case '3':
            s = 'Третий этаж';
            break;
          case '4':
            s = 'Четвертый этаж';
            break;
          default:
            s = 'Не в здании';
        }

        singlePointCard = Row(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AutoSizeText(s, style: app_global.headerFont),
              Row(
                children: [
                  const Icon(
                    Icons.place_rounded,
                    color: app_global.errorColor,
                    size: 32,
                  ),
                  Text(
                    _previousOrSingleClassroom,
                    style: app_global.headerFont,
                  ),
                ],
              ),
            ],
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                  padding: EdgeInsets.zero,
                  color: app_global.primaryColor,
                  hoverColor: app_global.errorColor,
                  iconSize: 36,
                  onPressed: () {
                    // storage.writeState(context, ['', ''],
                    //     identifier: widget.key);
                    _previousOrSingleClassroom = '';
                    // _nextClassroom = '';
                    _animateResetStop();
                    _animateResetInitialize(true);
                  },
                  icon: const Icon(Icons.cancel)),
            ),
          ),
        ]);
      } else {}
    } else {
      mode = 0;
      zeroPointCard = Center(
        child: AutoSizeText(
          'Нажмите на номер кабинета в расписании, чтобы увидеть его',
          style: app_global.headerFont,
        ),
      );
    }
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
  void _animateResetInitialize(bool fullReset) {
    Matrix4 t;

    if (!fullReset && mode != 0) {
      if (mode == 2) {
        var lx = min(oldMarkerLeft!, newMarkerLeft!);
        var hx = max(oldMarkerLeft!, newMarkerLeft!);

        var ly = min(oldMarkerTop!, newMarkerTop!);
        var hy = max(oldMarkerTop!, newMarkerTop!);

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
      } else if (mode == 1) {
        zoomOriginX = _transformationController.toScene(Offset.zero).dx -
            oldMarkerLeft! +
            markerLeftOffset;
        zoomOriginY = _transformationController.toScene(Offset.zero).dy -
            oldMarkerTop! +
            markerTopOffset;

        scaling = defaultScaling;
      }

      //Sets zoom origins in center and scales
      t = _transformationController.value.clone();
      t.translate(zoomOriginX, zoomOriginY!);
      var dx = t.getTranslation().x / t.getMaxScaleOnAxis();
      var dy = t.getTranslation().y / t.getMaxScaleOnAxis();
      t.scale(scaling! / t.getMaxScaleOnAxis());
      dx -= t.getTranslation().x / t.getMaxScaleOnAxis() -
          realWidth / 2 / t.getMaxScaleOnAxis();
      dy -= t.getTranslation().y / t.getMaxScaleOnAxis() -
          realHeight / 2.4 / t.getMaxScaleOnAxis();
      t.translate(dx, dy);
    } else {
      _previousOrSingleClassroom = '';
      setState(() {
        buildInformationCard();
      });
      t = Matrix4.identity().scaled(realWidth / imageDimensions.item1);
    }

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
