import 'package:flutter/material.dart';

import 'package:climax/services/conversions.dart'
    show darkMode, deviceWidth, fontScale, ratioOfDay;

class SunriseSetCard extends StatelessWidget {
  const SunriseSetCard({
    required this.sunrise,
    required this.sunset,
    this.isGrouped = false,
    super.key,
  });

  final String sunrise;
  final String sunset;
  final bool isGrouped;

  @override
  Widget build(BuildContext context) {
    final ratios = ratioOfDay(sunrise, sunset);
    final Color textColor =
        darkMode ? const Color(0xffb9c9d9) : Colors.blueGrey.shade700;
    final Color color =
        darkMode ? const Color(0xff00639c) : const Color(0xff010842);
    final borderColor = darkMode ? Colors.grey.shade600 : Colors.grey;
    final coloredBorder = darkMode ? Colors.blue.shade800 : Colors.blue;
    final shrink = deviceWidth < 450;
    final sWidth = shrink ? 36.0 : 50.0;
    final mWidth = shrink ? 80.0 : 108.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: darkMode ? Color(0xff091a2a) : const Color(0xfffcfcfe),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Sunrise & Sunset', style: TextStyle(fontSize: 14.0)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  RichText(
                    textScaler: TextScaler.linear(fontScale.clamp(0.7, 1.26)),
                    text: TextSpan(
                      text: 'Sunrise',
                      style: DefaultTextStyle.of(context).style.copyWith(
                        color: textColor,
                        fontSize: 12.0,
                        height: fontScale <= 1 ? 3.2 : 2.8,
                      ),
                      children: [
                        TextSpan(
                          text: '\n\n$sunrise',
                          style: DefaultTextStyle.of(
                            context,
                          ).style.copyWith(fontSize: 20.0, height: -0.01),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height:
                        isGrouped
                            ? 9.0 / fontScale
                            : 40.0 / fontScale.clamp(0.7, 1.5),
                  ),
                  RichText(
                    textScaler: TextScaler.linear(fontScale.clamp(0.7, 1.26)),
                    text: TextSpan(
                      text: 'Sunset',
                      style: DefaultTextStyle.of(context).style.copyWith(
                        color: textColor,
                        fontSize: 12.0,
                        height: fontScale <= 1 ? 3.2 : 2.8,
                      ),
                      children: [
                        TextSpan(
                          text: '\n\n$sunset',
                          style: DefaultTextStyle.of(
                            context,
                          ).style.copyWith(fontSize: 20.0, height: -0.01),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!isGrouped || deviceWidth < 450)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment:
                          fontScale > 1.2
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                      spacing: deviceWidth < 450 ? 10.0 / fontScale : 12.0,
                      children: [
                        Container(
                          width: sWidth,
                          height: shrink ? 18.0 : 24.0,
                          margin: EdgeInsets.only(top: shrink ? 39.4 : 53.4),
                          clipBehavior: Clip.hardEdge,
                          padding: EdgeInsets.only(
                            right: sWidth * (1 - ratios[0]),
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:
                                  ratios[0] == 0.0
                                      ? borderColor
                                      : ratios[0] != 1.0
                                      ? coloredBorder
                                      : color,
                              width: 0.7,
                            ),
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.elliptical(30, 24),
                            ),
                          ),
                          child: Container(color: color),
                        ),
                        Text(
                          'Dawn',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                    Container(
                      width: mWidth,
                      height: shrink ? 40.0 : 54.0,
                      clipBehavior: Clip.hardEdge,
                      padding: EdgeInsets.only(right: mWidth * (1 - ratios[1])),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              ratios[1] == 0.0
                                  ? borderColor
                                  : ratios[1] != 1.0
                                  ? coloredBorder
                                  : const Color(0xffb4d3ff),
                          width: 0.7,
                        ),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(54.0),
                        ),
                      ),
                      child: Container(color: const Color(0xffb4d3ff)),
                    ),
                    Column(
                      crossAxisAlignment:
                          fontScale > 1.2
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.end,
                      spacing: deviceWidth < 450 ? 10.0 / fontScale : 12.0,
                      children: [
                        Container(
                          width: sWidth,
                          height: shrink ? 18.0 : 24.0,
                          margin: EdgeInsets.only(top: shrink ? 39.4 : 53.4),
                          clipBehavior: Clip.hardEdge,
                          padding: EdgeInsets.only(
                            right: sWidth * (1 - ratios[2]),
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:
                                  ratios[2] == 0.0
                                      ? borderColor
                                      : ratios[2] != 1.0
                                      ? coloredBorder
                                      : color,
                              width: 0.7,
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.elliptical(30, 24),
                            ),
                          ),
                          child: Container(color: color),
                        ),
                        Text(
                          'Dusk ',
                          style: Theme.of(context).textTheme.labelSmall,
                          textAlign: TextAlign.end,
                        ),
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
