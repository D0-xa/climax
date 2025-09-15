import 'package:flutter/material.dart';

import 'package:visibility_detector/visibility_detector.dart';

double _frac = 0.0;

class HumidityCondition extends StatefulWidget {
  const HumidityCondition({
    required this.value,
    required this.dewPoint,
    this.parameter = 'Humidity',
    this.vKey = -1,
    super.key,
  });

  final String parameter;
  final num value;
  final String dewPoint;
  final int vKey;

  @override
  State<HumidityCondition> createState() => _HumidityConditionState();
}

class _HumidityConditionState extends State<HumidityCondition> {
  bool _hasAnimated = false;
  late bool _darkMode;

  @override
  void didUpdateWidget(covariant HumidityCondition oldWidget) {
    if (oldWidget.vKey == -1) {
      _frac = 0.0;
      _hasAnimated = false;
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
        spacing: 3.0,
        children: [
          Text(widget.parameter, style: TextStyle(fontSize: 14.0)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 42.0,
            children: [
              RichText(
                text: TextSpan(
                  text: '${widget.value}',
                  style: Theme.of(context).textTheme.titleMedium,
                  children: [
                    TextSpan(
                      text: '%\n\n',
                      style: DefaultTextStyle.of(
                        context,
                      ).style.copyWith(height: -0.2),
                    ),
                    TextSpan(
                      text: 'Dew point ${widget.dewPoint}\n',
                      style: DefaultTextStyle.of(context).style.copyWith(
                        color:
                            _darkMode
                                ? const Color(0xffb9c9d9)
                                : Colors.blueGrey.shade700,
                        fontSize: 12.0,
                        height: 0.0,
                      ),
                    ),
                  ],
                ),
                textHeightBehavior: TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    children: [
                      Icon(
                        Icons.arrow_right_rounded,
                        size: 18.0,
                        fontWeight: FontWeight.w900,
                        color: _darkMode ? const Color(0xffb9c9d9) : null,
                      ),
                      AnimatedContainer(
                        duration:
                            widget.vKey == -1
                                ? Durations.extralong4
                                : Durations.long2,
                        alignment: Alignment.bottomCenter,
                        curve: Curves.easeInOut,
                        height: 58.0 * _frac,
                      ),
                      SizedBox(height: 12.0),
                    ],
                  ),
                  Column(
                    spacing: 3.0,
                    children: [
                      Text(
                        '100',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      VisibilityDetector(
                        key: Key('humidity${widget.vKey}'),
                        onVisibilityChanged: (info) {
                          if (info.visibleFraction > 0 && !_hasAnimated) {
                            setState(() {
                              _hasAnimated = true;
                              _frac = (widget.value / 100).clamp(0, 1);
                            });
                          }
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24.0),
                          child: Stack(
                            alignment: AlignmentDirectional.bottomCenter,
                            clipBehavior: Clip.hardEdge,
                            children: [
                              Container(
                                height: 60.0,
                                width: 30.0,
                                color: const Color(0xfffde5aa),
                              ),
                              AnimatedContainer(
                                duration:
                                    widget.vKey == -1
                                        ? Durations.extralong4
                                        : Durations.long2,
                                alignment: Alignment.bottomCenter,
                                curve: Curves.easeInOut,
                                height: 60.0 * _frac,
                                width: 30.0,
                                color:
                                    HSVColor.lerp(
                                      HSVColor.fromColor(Colors.yellowAccent),
                                      HSVColor.fromColor(
                                        Colors.orange.shade700,
                                      ),
                                      _frac,
                                    )?.toColor(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text('0', style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
