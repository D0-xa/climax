import 'package:flutter/material.dart';

import 'package:visibility_detector/visibility_detector.dart';

import 'custom_shapes.dart';
import 'package:climax/services/conversions.dart' show darkMode, fontScale;

double _frac = 0.0;
Color? _color;

class UVCondition extends StatefulWidget {
  const UVCondition({
    required this.value,
    required this.description,
    required this.color,
    this.parameter,
    this.vKey = -1,
    super.key,
  });

  final String? parameter;
  final String value;
  final String description;
  final Color color;
  final int vKey;

  @override
  State<UVCondition> createState() => _UVConditionState();
}

class _UVConditionState extends State<UVCondition> {
  bool _hasAnimated = false;

  @override
  void didUpdateWidget(covariant UVCondition oldWidget) {
    if (oldWidget.vKey == -1) {
      _frac = 0.0;
      _color = null;
      _hasAnimated = false;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final Duration duration =
        widget.vKey == -1 ? Durations.extralong4 : Durations.long2;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: darkMode ? Color(0xff091a2a) : const Color(0xfffcfcfe),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.parameter ?? 'UV Index',
            style: TextStyle(fontSize: 14.0),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: RichText(
                  textScaler: TextScaler.linear(fontScale.clamp(0.7, 1.4)),
                  text: TextSpan(
                    text: widget.value,
                    style: Theme.of(context).textTheme.titleMedium,
                    children: [
                      TextSpan(text: '\n\n', style: TextStyle(height: -0.1)),
                      TextSpan(
                        text: '${widget.description}\n',
                        style: DefaultTextStyle.of(context).style.copyWith(
                          color:
                              darkMode
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      children: [
                        Icon(
                          Icons.arrow_right_rounded,
                          size: 18.0,
                          fontWeight: FontWeight.w900,
                          color: darkMode ? const Color(0xffb9c9d9) : null,
                        ),
                        AnimatedContainer(
                          duration:
                              widget.vKey == -1
                                  ? Durations.extralong4
                                  : Durations.long2,
                          alignment: Alignment.bottomCenter,
                          curve: Curves.easeInOut,
                          height: 54.0 * _frac.clamp(0, 1.1),
                        ),
                        SizedBox(
                          height:
                              fontScale <= 1
                                  ? 14.0 * fontScale
                                  : 11.0 * fontScale.clamp(1, 1.4),
                        ),
                      ],
                    ),
                    Column(
                      spacing: fontScale > 1.1 ? 1.0 : 5.0,
                      children: [
                        Text(
                          '11+',
                          style: Theme.of(context).textTheme.labelSmall,
                          textScaler: TextScaler.linear(
                            fontScale.clamp(0.7, 1.4),
                          ),
                        ),
                        VisibilityDetector(
                          key: Key('uv${widget.vKey}'),
                          onVisibilityChanged: (info) {
                            if (info.visibleFraction > 0 && !_hasAnimated) {
                              setState(() {
                                _hasAnimated = true;
                                _frac = num.parse(widget.value) / 11;
                                _color = widget.color;
                              });
                            }
                          },
                          child: ClipPath(
                            clipper: ScallopedClipper(),
                            child: Stack(
                              alignment: AlignmentDirectional.bottomCenter,
                              clipBehavior: Clip.hardEdge,
                              children: [
                                AnimatedContainer(
                                  duration: duration,
                                  alignment: Alignment.bottomCenter,
                                  curve: Curves.easeInOut,
                                  height: 56.0,
                                  width: 56.0,
                                  color:
                                      _color?.withValues(alpha: 0.5) ??
                                      Colors.lightGreen.shade100,
                                ),
                                AnimatedContainer(
                                  duration: duration,
                                  alignment: Alignment.bottomCenter,
                                  curve: Curves.easeInOut,
                                  height: 56.0 * _frac.clamp(0, 1),
                                  width: 56.0,
                                  color: _color,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Text(
                          '0',
                          style: Theme.of(context).textTheme.labelSmall,
                          textScaler: TextScaler.linear(
                            fontScale.clamp(0.7, 1.4),
                          ),
                        ),
                      ],
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
