import 'package:flutter/material.dart';

double _progress() {
  return 0.3;
  int steps = 0; //get total steps
  int goal = 0; //goal
  double progress = steps / goal;
  if (progress < 1) {
    return progress;
  } else if (progress >= 1) {
    return 1.0;
  }
  else {
    throw Exception("Unknown error in creating step counter");
  }
}


class StepCounter extends StatefulWidget {
  final double height;
  final double width;

  const StepCounter({
    super.key,
    required this.height,
    required this.width
  });

  @override
  State<StepCounter> createState() => _StepCounterState();
}

class _StepCounterState extends State<StepCounter> {

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          left: _progress() * widget.width,
          right: widget.width - _progress() * widget.width,
          top: widget.height / 2 - 10,
          child: const Icon(
            Icons.directions_run,
            size: 20,
            color: Colors.black,
          ),
        ),
        /*
        Center(
          child: Positioned(
            top: widget.height / 2 - 20,
            child: const SizedBox(height: 16.0),
          ),
        ),

         */
        Center(
          child: SizedBox(
            width: widget.width,
            child: LinearProgressIndicator(
              value: _progress(),
              backgroundColor: Colors.greenAccent,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
        ),
        /*
        Positioned(
            top: widget.height / 2,
            child: Center (
              child: SizedBox(
                width: widget.width,
                child: LinearProgressIndicator(
                  value: _progress(),
                  backgroundColor: Colors.greenAccent,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
            ),
        ),
        */
      ],
    );
  }
}

