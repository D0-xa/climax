import 'package:flutter/material.dart';

import 'package:climax/services/conversions.dart' show ratioOfDay;

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
    final darkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final Color textColor =
        darkMode ? const Color(0xffb9c9d9) : Colors.blueGrey.shade700;
    final Color color =
        darkMode ? const Color(0xff00639c) : const Color(0xff010842);
    final borderColor = darkMode ? Colors.blueGrey.shade700 : Colors.grey;

    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: darkMode ? Color(0xff0d1d2a) : const Color(0xfffcfcfe),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sunrise & Sunset', style: TextStyle(fontSize: 14.0)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: 'Sunrise',
                        style: DefaultTextStyle.of(context).style.copyWith(
                          color: textColor,
                          fontSize: 12.0,
                          height: 3.2,
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
                    SizedBox(height: isGrouped ? 9.0 : 40.0),
                    RichText(
                      text: TextSpan(
                        text: 'Sunset',
                        style: DefaultTextStyle.of(context).style.copyWith(
                          color: textColor,
                          fontSize: 12.0,
                          height: 3.2,
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
              ),
              if (!isGrouped)
                Expanded(
                  child: Column(
                    spacing: 12.0,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 50.0,
                            height: 24.0,
                            clipBehavior: Clip.hardEdge,
                            padding: EdgeInsets.only(
                              right: 50 * (1 - ratios[0]),
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: borderColor,
                                width: 0.7,
                              ),
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.elliptical(30, 24),
                              ),
                            ),
                            child: Container(color: color),
                          ),
                          Container(
                            width: 108.0,
                            height: 54.0,
                            margin: EdgeInsets.only(bottom: 23.0),
                            clipBehavior: Clip.hardEdge,
                            padding: EdgeInsets.only(
                              right: 108 * (1 - ratios[1]),
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.blue,
                                width: 0.7,
                              ),
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(54.0),
                              ),
                            ),
                            child: Container(color: const Color(0xffb4d3ff)),
                          ),
                          Container(
                            width: 50.0,
                            height: 24.0,
                            clipBehavior: Clip.hardEdge,
                            padding: EdgeInsets.only(
                              right: 50 * (1 - ratios[2]),
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: borderColor,
                                width: 0.7,
                              ),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.elliptical(30, 24),
                              ),
                            ),
                            child: Container(color: color),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ' Dawn',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          Text(
                            'Dusk ',
                            style: Theme.of(context).textTheme.labelSmall,
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
