import 'package:flutter/material.dart';
import 'dart:math' as math;

enum CircularStrokeCap { butt, round, square }

extension CircularStrokeCapExtension on CircularStrokeCap {
  StrokeCap get strokeCap {
    switch (this) {
      case CircularStrokeCap.butt:
        return StrokeCap.butt;
      case CircularStrokeCap.round:
        return StrokeCap.round;
      case CircularStrokeCap.square:
        return StrokeCap.square;
    }
  }
}

num radians(num deg) => deg * (math.pi / 180.0);

///inspired by percent_indicator.dart

// ignore: must_be_immutable
class CalorieIndicator extends StatefulWidget {
  ///percentage displayed and radius of indicator
  final double percent;
  final List<double> parts;
  final double radius;

  ///width of progress bar
  final double lineWidth;

  ///background width of progress bar
  final double backgroundWidth;

  ///First color applied to the complete circle
  final Color fillColor;

  ///color of the rest of the circle
  final Color backgroundColor;

  List<Color> get progressColors => _progressColors;
  late List<Color> _progressColors;

  ///want an animation?
  final bool animation;

  ///animation duration in ms
  final int animationDuration;

  ///widget at the top of the circle
  final Widget? header;

  ///widget at the bottom of the circle
  final Widget? footer;

  ///widget inside the circle
  final Widget? center;

  final LinearGradient? linearGradient;

  ///kind of finish to place on the end of lines drawn, values supported: butt, round, square
  final CircularStrokeCap circularStrokeCap;

  ///the angle which the circle will start the progress (in degrees, eg: 0.0, 45.0, 90.0)
  final double startAngle;

  /// set true if you want to animate the linear from the last percent value you set
  final bool animateFromLastPercent;

  /// set false if you don't want to preserve the state of the widget
  final bool addAutomaticKeepAlive;

  /// set true when you want to display the progress in reverse mode
  final bool reverse;

  /// set a circular curve animation type
  final Curve curve;

  /// set true when you want to restart the animation, it restarts only when reaches 1.0 as a value
  /// defaults to false
  final bool restartAnimation;

  /// Callback called when the animation ends (only if `animation` is true)
  final VoidCallback? onAnimationEnd;

  /// Display a widget indicator at the end of the progress. It only works when `animation` is true
  final Widget? widgetIndicator;

  /// Set to true if you want to rotate linear gradient in accordance to the [startAngle].
  final bool rotateLinearGradient;

  CalorieIndicator({
    Key? key,
    this.percent = 0.0,
    required this.parts,
    this.lineWidth = 5.0,
    this.startAngle = 0.0,
    required this.radius,
    this.fillColor = Colors.transparent,
    this.backgroundColor = Colors.blueGrey,
    List<Color>? progressColors,
    this.backgroundWidth = -1,
    this.linearGradient,
    this.animation = true,
    this.animationDuration = 500,
    this.header,
    this.footer,
    this.center,
    this.addAutomaticKeepAlive = true,
    this.circularStrokeCap = CircularStrokeCap.butt,
    this.animateFromLastPercent = true,
    this.reverse = false,
    this.curve = Curves.linear,
    this.restartAnimation = false,
    this.onAnimationEnd,
    this.widgetIndicator,
    this.rotateLinearGradient = false,

  }) : super(key: key) {

    _progressColors = progressColors ?? [Colors.blue];

    if(_progressColors.length != parts.length) {
      throw Exception("Amount of different colors and amount of different parts are not matching.");
    }

    assert(startAngle >= 0.0);

    if (parts != null) {
      double sum = 0.0;
      for (double d in parts!) {
        if (d < 0.0 || d > 1.0) {
          throw Exception("Percent value must be a double between 0.0 and 1.0, but it's $d");
        } else {
          sum += d;
        }
      }
      if (sum != 1.0) {
        throw Exception("Invalid percentage.");
      }
    }

  }

  @override
  _CalorieIndicatorState createState() => _CalorieIndicatorState();
}

class _CalorieIndicatorState extends State<CalorieIndicator>
  with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  AnimationController? _animationController;
  Animation? _animation;
  double _percent = 0.0;
  List<double>? parts;
  double _diameter = 0.0;

  @override
  void dispose() {
    if (_animationController != null) {
      _animationController!.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    if (widget.animation) {
      _animationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: widget.animationDuration),
      );
      _animation = Tween(begin: 0.0, end: widget.percent).animate(
        CurvedAnimation(
            parent: _animationController!, curve: widget.curve),)
        ..addListener(() {
          setState(() {
            _percent = _animation!.value;
          });
          if (widget.restartAnimation && _percent == 1.0) {
            _animationController!.repeat(min: 0, max: 1.0);
          }
        });
      _animationController!.addStatusListener((status) {
        if (widget.onAnimationEnd != null &&
            status == AnimationStatus.completed) {
          widget.onAnimationEnd!();
        }
      });
      _animationController!.forward();
    } else {
      _updateProgress();
    }
    _diameter = widget.radius * 2;
    super.initState();
  }

  void _checkIfNeedCancelAnimation(CalorieIndicator oldWidget) {
    if (oldWidget.animation &&
        !widget.animation &&
        _animationController != null) {
      _animationController!.stop();
    }
  }

  @override
  void didUpdateWidget(CalorieIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percent != widget.percent ||
      oldWidget.startAngle != widget.startAngle) {
      if (_animationController != null) {
        _animationController!.duration =
            Duration(milliseconds: widget.animationDuration);
        _animation = Tween(
          begin: widget.animateFromLastPercent ? oldWidget.percent : 0.0,
          end: widget.percent,
        ).animate(
          CurvedAnimation(
            parent: _animationController!, curve: widget.curve
          ),
        );
        _animationController!.forward(from: 0.0);
      } else {
        _updateProgress();
      }

    }
    _checkIfNeedCancelAnimation(oldWidget);
  }

  _updateProgress() {
    setState(() => _percent = widget.percent);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var items = List<Widget>.empty(growable: true);
    if (widget.header != null) {
      items.add(widget.header!);
    }
    items.add(
        Container(
          height: _diameter,
          width: _diameter,
            child: Stack(
              children: [
              CustomPaint(
                painter: _CirclePainter(
                  progress: _percent * 360,
                  lineWidth: widget.lineWidth,
                  backgroundWidth: widget.backgroundWidth >= 0.0
                    ? (widget.backgroundWidth) : widget.lineWidth,
                  radius: widget.radius - widget.lineWidth / 2,
                  progressColors: widget.progressColors,
                  backgroundColor: widget.backgroundColor,
                  circularStrokeCap: widget.circularStrokeCap,
                  startAngle: widget.startAngle,
                  linearGradient: widget.linearGradient,
                  reverse: widget.reverse,
                  parts: widget.parts,
                ),
                child: (widget.center != null)
                ? Center(child: widget.center)
                : const SizedBox.expand(),
              ),
              if (widget.widgetIndicator != null && widget.animation)
                Positioned.fill(
                  child: Transform.rotate(
                    angle: radians(
                      (widget.circularStrokeCap != CircularStrokeCap.butt && widget.reverse)
                        ? -15
                        : 0)
                    .toDouble(),
                child: Transform.rotate(
                  angle: getCurrentPercent(_percent),
                  child: Transform.translate(
                    offset: Offset(
                      (widget.circularStrokeCap != CircularStrokeCap.butt)
                          ? widget.lineWidth / 2
                          : 0,
                      (-widget.radius + widget.lineWidth / 2),
                    ),
                    child: widget.widgetIndicator,
                  ),
                ),
              ),
            ),
        ],
      ),
    ));
    if (widget.footer != null) {
      items.add(widget.footer!);
    }

    return Material(
      color: widget.fillColor,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: items,
        ),
      ),
    );
  }

  double getCurrentPercent(double percent) {
    const angle = 360;
    return radians((widget.reverse ? -angle : angle) * _percent).toDouble();
  }

  @override
  bool get wantKeepAlive => widget.addAutomaticKeepAlive;
}

class _CirclePainter extends CustomPainter {
  final Paint _paintBackground = Paint();
  final Paint _paintLine = Paint();
  //final Paint _paintBackgroundStartAngle = Paint();
  final double lineWidth;
  final double backgroundWidth;
  final double progress;
  final List<double> parts;
  final double radius;
  final List<Color> progressColors;
  final Color backgroundColor;
  final CircularStrokeCap circularStrokeCap;
  final double startAngle;
  final LinearGradient? linearGradient;
  final bool reverse;

  _CirclePainter({
    required this.lineWidth,
    required this.backgroundWidth,
    required this.progress,
    required this.radius,
    required this.progressColors,
    required this.backgroundColor,
    this.startAngle = 0.0,
    this.circularStrokeCap = CircularStrokeCap.butt,
    this.linearGradient,
    this.reverse = false,
    required this.parts,
}) {
    _paintBackground.color = backgroundColor;
    _paintBackground.style = PaintingStyle.stroke;
    _paintBackground.strokeWidth = backgroundWidth;
    _paintBackground.strokeCap = circularStrokeCap.strokeCap;

    if(progressColors.length == 1) {
      _paintLine.color = progressColors[0];
    }
    _paintLine.style = PaintingStyle.stroke;
    _paintLine.strokeWidth = lineWidth;
    _paintLine.strokeCap = circularStrokeCap.strokeCap;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final count = progressColors.length;
    final center = Offset(size.width / 2, size.height / 2);
    double fixedStartAngle = startAngle;
    double startAngleFixedMargin = 1.0;
    canvas.drawCircle(center, radius, _paintBackground);

    if (reverse) {
      if (count == 1) {
        final start = radians(360 * startAngleFixedMargin - 90.0 + fixedStartAngle).toDouble();
        final end = radians(-progress*startAngleFixedMargin).toDouble();
        canvas.drawArc(
          Rect.fromCircle(
            center: center,
            radius: radius,
          ),
          start,
          end,
          false,
          _paintLine,
        );
      } else {

      }

    } else {
      if (count == 1) {
        final start = radians(-90.0 + fixedStartAngle).toDouble();
        final end = radians(progress * startAngleFixedMargin).toDouble();
        canvas.drawArc(
          Rect.fromCircle(
            center: center,
            radius: radius,
          ),
          start,
          end,
          false,
          _paintLine,
        );
      } else {
        assert(parts != null);
        var already = 0.0;
        for (int i = 0; i < count; i++) {
          _paintLine.color = progressColors[i];
          _paintLine.style = PaintingStyle.stroke;
          _paintLine.strokeWidth = lineWidth;
          _paintLine.strokeCap = circularStrokeCap.strokeCap;
            var start = radians(-90.0 + fixedStartAngle).toDouble() + already;
            var part = progress * parts![i];
            var end = radians(part * startAngleFixedMargin).toDouble();
            canvas.drawArc(
              Rect.fromCircle(
                center: center,
                radius: radius,
              ),
              start,
              end,
              false,
              _paintLine,
            );
            already += end;
        }
      }
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

}