import 'package:flutter/material.dart';

import 'package:visibility_detector/visibility_detector.dart';

double _turns = 0.5;

class WindCondition extends StatefulWidget {
  const WindCondition({
    required this.value,
    required this.description,
    required this.direction,
    required this.unit,
    required this.degrees,
    this.parameter,
    this.vKey = -1,
    super.key,
  });

  final String? parameter;
  final String value;
  final String unit;
  final String description;
  final String direction;
  final double degrees;
  final int vKey;

  @override
  State<WindCondition> createState() => _WindConditionState();
}

class _WindConditionState extends State<WindCondition> {
  bool _hasAnimated = false;
  late bool _darkMode;

  @override
  void didUpdateWidget(covariant WindCondition oldWidget) {
    if (oldWidget.vKey == -1) {
      _hasAnimated = false;
      _turns = 0.5;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    _darkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: _darkMode ? Color(0xff0d1d2a) : const Color(0xfffcfcfe),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6.0,
        children: [
          Text(widget.parameter ?? 'Wind', style: TextStyle(fontSize: 14.0)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: RichText(
                  text: TextSpan(
                    text: widget.value,
                    style: Theme.of(context).textTheme.titleMedium,
                    children: [
                      TextSpan(
                        text: ' ${widget.unit}\n\n',
                        style: DefaultTextStyle.of(
                          context,
                        ).style.copyWith(height: -0.2),
                      ),
                      TextSpan(
                        text: '${widget.description} • ${widget.direction}',
                        style: DefaultTextStyle.of(context).style.copyWith(
                          color:
                              _darkMode
                                  ? const Color(0xffb9c9d9)
                                  : Colors.blueGrey.shade700,
                          fontSize: 12.0,
                          height: 1.28,
                        ),
                      ),
                    ],
                  ),
                  textHeightBehavior: TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  spacing: 3.0,
                  children: [
                    Text('N', style: Theme.of(context).textTheme.labelSmall),
                    VisibilityDetector(
                      key: Key('wind${widget.vKey}'),
                      onVisibilityChanged: (info) {
                        if (info.visibleFraction > 0 && !_hasAnimated) {
                          setState(() {
                            _hasAnimated = true;
                            _turns = widget.degrees.clamp(0, 1);
                          });
                        }
                      },
                      child: AnimatedRotation(
                        turns: _turns,
                        duration:
                            widget.vKey == -1
                                ? Durations.extralong4
                                : Durations.long4,
                        curve: Curves.easeInOut,
                        child: Image.asset(
                          _darkMode
                              ? 'assets/images/wind_dark.png'
                              : 'assets/images/wind_light.png',
                          scale: 2.0,
                          opacity: AlwaysStoppedAnimation(
                            widget.description == 'Calm'
                                ? _darkMode
                                    ? 1.0
                                    : 0.8
                                : _darkMode
                                ? 0.9
                                : 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
