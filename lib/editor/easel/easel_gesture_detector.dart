import 'package:flutter/material.dart';

typedef void StrokeStartCallback(Offset position);
typedef void StrokeUpdateCallback(Offset position);

class EaselGestureDetector extends StatefulWidget {
  EaselGestureDetector({
    Key key,
    this.child,
    this.onStrokeStart,
    this.onStrokeUpdate,
    this.onStrokeEnd,
    this.onStrokeCancel,
    this.onScaleStart,
    this.onScaleUpdate,
  }) : super(key: key);

  final Widget child;
  final GestureDragStartCallback onStrokeStart;
  final GestureDragUpdateCallback onStrokeUpdate;
  final VoidCallback onStrokeEnd;
  final VoidCallback onStrokeCancel;
  final GestureScaleStartCallback onScaleStart;
  final GestureScaleUpdateCallback onScaleUpdate;

  @override
  _EaselGestureDetectorState createState() => _EaselGestureDetectorState();
}

class _EaselGestureDetectorState extends State<EaselGestureDetector> {
  int _prevPointersOnScreen = 0;
  int _pointersOnScreen = 0;
  Offset _lastContactPoint;
  bool _startedStroke = false;
  bool _veryQuickStroke = false;

  void changePointerOnScreenBy(int count) {
    _prevPointersOnScreen = _pointersOnScreen;
    _pointersOnScreen = _pointersOnScreen + count;

    if (_pointersOnScreen == 0 && _startedStroke) {
      widget.onStrokeEnd?.call();
      _startedStroke = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (e) => changePointerOnScreenBy(1),
      onPointerUp: (e) => changePointerOnScreenBy(-1),
      onPointerCancel: (e) => changePointerOnScreenBy(-1),
      child: GestureDetector(
        onScaleStart: (ScaleStartDetails details) {
          _lastContactPoint = details.focalPoint;

          if (_pointersOnScreen == 1) {
            _onSinglePointerStart(details);
          } else {
            widget.onScaleStart?.call(details);
          }
        },
        onScaleUpdate: (ScaleUpdateDetails details) {
          if (_pointersOnScreen == 1) {
            _onSinglePointerMove(details);
          } else {
            if (_veryQuickStroke) {
              _veryQuickStroke = false;
              widget.onStrokeCancel?.call();
              _startedStroke = false;
            }

            widget.onScaleUpdate?.call(details);
          }
        },
        child: widget.child,
      ),
    );
  }

  void _onSinglePointerStart(ScaleStartDetails details) {
    if (_prevPointersOnScreen != 0) return;

    _veryQuickStroke = true;

    Future.delayed(Duration(milliseconds: 200), () {
      _veryQuickStroke = false;
    });

    widget.onStrokeStart?.call(DragStartDetails(
      globalPosition: details.focalPoint,
      localPosition: details.localFocalPoint,
    ));

    _startedStroke = true;
  }

  void _onSinglePointerMove(ScaleUpdateDetails details) {
    if (_prevPointersOnScreen != 0) return;

    final currentContactPoint = details.focalPoint;
    final dragUpdateDetails = DragUpdateDetails(
      delta: currentContactPoint - _lastContactPoint,
      globalPosition: currentContactPoint,
      localPosition: details.localFocalPoint,
    );

    _lastContactPoint = details.focalPoint;

    widget.onStrokeUpdate?.call(dragUpdateDetails);
  }
}