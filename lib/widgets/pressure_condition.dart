import 'package:flutter/material.dart';

import 'package:visibility_detector/visibility_detector.dart';

import 'custom_shapes.dart';
import 'package:climax/services/conversions.dart'
    show darkMode, deviceWidth, fontScale, pressureLevel;

class PressureCondition extends StatefulWidget {
  const PressureCondition({
    required this.value,
    required this.unit,
    required this.u,
    super.key,
  });

  final String value;
  final String unit;
  final bool u;

  @override
  State<PressureCondition> createState() => _PressureConditionState();
}

class _PressureConditionState extends State<PressureCondition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _level;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _level = Tween<double>(
      begin: 0.0,
      end: pressureLevel,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(covariant PressureCondition oldWidget) {
    _level = Tween<double>(
      begin: 0.0,
      end: pressureLevel,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.reset();
    _hasAnimated = false;
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: darkMode ? Color(0xff091a2a) : const Color(0xfffcfcfe),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pressure', style: TextStyle(fontSize: 14.0)),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 4,
                  child: RichText(
                    textScaler: TextScaler.linear(fontScale.clamp(0.7, 1.3)),
                    text: TextSpan(
                      text:
                          widget.u
                              ? widget.value.substring(0, 2)
                              : widget.value,
                      style: Theme.of(context).textTheme.titleMedium,
                      children: [
                        TextSpan(
                          text:
                              widget.u
                                  ? '${widget.value.substring(2)}\n\n'
                                  : '\n\n',
                          style: TextStyle(fontSize: 14.0, height: -0.1),
                        ),
                        TextSpan(
                          text: widget.unit,
                          style: DefaultTextStyle.of(context).style.copyWith(
                            color:
                                darkMode
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
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: 6.0,
                    children: [
                      VisibilityDetector(
                        key: Key('pressure'),
                        onVisibilityChanged: (info) {
                          if (info.visibleFraction > 0 && !_hasAnimated) {
                            setState(() {
                              _hasAnimated = true;
                            });
                            _controller.forward();
                          }
                        },
                        child: AnimatedBuilder(
                          animation: _level,
                          builder:
                              (context, _) => CustomPaint(
                                size: const Size.square(54),
                                painter: DialPainter(
                                  level: _level.value,
                                  needleColor:
                                      darkMode
                                          ? const Color(0xffb9c9d9)
                                          : Colors.black,
                                ),
                              ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment:
                            fontScale <= 1 || deviceWidth < 450
                                ? MainAxisAlignment.spaceEvenly
                                : MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            'Low',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          Text(
                            'High',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
