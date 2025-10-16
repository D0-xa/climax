import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:climax/services/models.dart'
    show ConditionDetails, HourlyDetails;
import 'package:climax/services/conversions.dart'
    show darkMode, formatPerRain, fontScale;

const Color _color = Color(0xff012a4b);
const Color _darkColor = Color(0xffb9c9d9);
final ButtonStyle _style = OutlinedButton.styleFrom(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
  side: BorderSide(color: Colors.blueGrey.shade100, width: 0.8),
  padding: EdgeInsets.only(left: 10.0, right: 16.0),
  foregroundColor: _color,
);
final ButtonStyle _styleDark = OutlinedButton.styleFrom(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
  side: BorderSide(color: Colors.grey.shade700, width: 0.8),
  padding: EdgeInsets.only(left: 10.0, right: 16.0),
  foregroundColor: _darkColor,
);
const TextStyle headingStyle = TextStyle(
  fontSize: 12.0,
  color: Color(0xff4b575c),
);
final TextStyle valueStyle = TextStyle(
  fontSize: 11.0,
  color: Colors.blueGrey.shade700,
  height: 2.0,
);

enum CurrentDetails { precipitation, wind, humidity }

class HourDetails extends StatefulWidget {
  const HourDetails({
    required this.hourDetails,
    required this.pUnit,
    required this.sUnit,
    this.notToday = false,
    super.key,
  });

  final HourlyDetails hourDetails;
  final String pUnit;
  final String sUnit;
  final bool notToday;

  @override
  State<HourDetails> createState() => _HourDetailsState();
}

class _HourDetailsState extends State<HourDetails> {
  CurrentDetails selectedButton = CurrentDetails.precipitation;
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.notToday) {
        _controller.jumpTo(310);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final int index = darkMode ? 1 : 0;
    final List<ConditionDetails> conditionDetails =
        widget.hourDetails.conditionDetails;
    final bool noPrecip = conditionDetails.every(
      (x) => x.volume == 0 && x.pop == 0,
    );
    final buttonStyle = darkMode ? _styleDark : _style;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12.0,
        children: [
          Text(
            'Hourly details',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: darkMode ? Color(0xffcde5ff) : const Color(0xff001d33),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 24.0),
            width: double.infinity,
            decoration: BoxDecoration(
              color:
                  darkMode ? const Color(0xff091a2a) : const Color(0xfffcfcfe),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12.0,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 8.0,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            selectedButton = CurrentDetails.precipitation;
                          });
                        },
                        label: Text('Precipitation'),
                        icon: Icon(
                          Icons.cloudy_snowing,
                          color: darkMode ? _darkColor : _color,
                        ),
                        style:
                            selectedButton == CurrentDetails.precipitation
                                ? buttonStyle.copyWith(
                                  side: WidgetStatePropertyAll(BorderSide.none),
                                  backgroundColor: WidgetStatePropertyAll(
                                    darkMode
                                        ? Color(0xff3b4858)
                                        : Color(0xffe0edff),
                                  ),
                                )
                                : buttonStyle,
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            selectedButton = CurrentDetails.wind;
                          });
                        },
                        label: Text('Wind'),
                        icon: Transform.rotate(
                          angle: math.pi / 4,
                          child: Icon(
                            Icons.navigation,
                            color: darkMode ? _darkColor : _color,
                          ),
                        ),
                        style:
                            selectedButton == CurrentDetails.wind
                                ? buttonStyle.copyWith(
                                  side: WidgetStatePropertyAll(BorderSide.none),
                                  backgroundColor: WidgetStatePropertyAll(
                                    darkMode
                                        ? Color(0xff3b4858)
                                        : Color(0xffe0edff),
                                  ),
                                )
                                : buttonStyle,
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            selectedButton = CurrentDetails.humidity;
                          });
                        },
                        label: Text('Humidity'),
                        icon: Icon(
                          Icons.water_drop,
                          color: darkMode ? _darkColor : _color,
                        ),
                        style:
                            selectedButton == CurrentDetails.humidity
                                ? buttonStyle.copyWith(
                                  side: WidgetStatePropertyAll(BorderSide.none),
                                  backgroundColor: WidgetStatePropertyAll(
                                    darkMode
                                        ? Color(0xff3b4858)
                                        : Color(0xffe0edff),
                                  ),
                                )
                                : buttonStyle,
                      ),
                    ],
                  ),
                ),
                if (selectedButton == CurrentDetails.precipitation)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.notToday ? 'Day amount' : "Today's amount",
                        style:
                            darkMode
                                ? headingStyle.copyWith(color: _darkColor)
                                : headingStyle,
                      ),
                      Text(
                        '${widget.hourDetails.amount} ${widget.pUnit}',
                        style: TextStyle(fontSize: 24),
                      ),
                      if (noPrecip)
                        Center(
                          heightFactor: 1.8,
                          child: Text(
                            'No precipitation expected',
                            style: TextStyle(
                              fontSize: 16.0,
                              color:
                                  darkMode
                                      ? _darkColor
                                      : Colors.blueGrey.shade800,
                            ),
                          ),
                        ),
                      SizedBox(
                        height:
                            noPrecip
                                ? 118 * fontScale.clamp(1, 1.3)
                                : 136 * fontScale.clamp(1, 1.48),
                        child: ListView.builder(
                          itemCount: conditionDetails.length,
                          scrollDirection: Axis.horizontal,
                          controller: _controller,
                          itemBuilder: (context, i) {
                            final num v = conditionDetails[i].volume;
                            final double p = conditionDetails[i].pop.toDouble();

                            return Padding(
                              padding: EdgeInsets.only(right: 6.0, left: 6.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                spacing: 4.0,
                                children: [
                                  Text(
                                    v < 0.25 ? '<0.25' : v.toStringAsFixed(1),
                                    style:
                                        v == 0
                                            ? valueStyle.copyWith(
                                              color: Colors.transparent,
                                            )
                                            : darkMode
                                            ? valueStyle.copyWith(
                                              color: _darkColor,
                                            )
                                            : valueStyle,
                                  ),
                                  Container(
                                    height: 8.0 + (v.clamp(0, 8) * 6),
                                    width: 32.0,
                                    decoration: BoxDecoration(
                                      color:
                                          p <= 0.19
                                              ? Colors.transparent
                                              : HSVColor.lerp(
                                                darkMode
                                                    ? HSVColor.fromColor(
                                                      Color(0xffecf2fe),
                                                    )
                                                    : null,
                                                HSVColor.fromColor(
                                                  const Color(0xff5c9afe),
                                                ),
                                                (p - 0.19).clamp(0, 1),
                                              )?.toColor(),
                                      border:
                                          darkMode && p > 0.19
                                              ? null
                                              : Border.all(
                                                width: p <= 0.19 ? 0.6 : 0.8,
                                                color:
                                                    p <= 0.19
                                                        ? darkMode
                                                            ? Colors.white70
                                                            : Colors.black
                                                        : const Color(
                                                          0xff0362b0,
                                                        ),
                                              ),
                                      borderRadius: BorderRadius.circular(
                                        (5.0 + v * 1.5).clamp(5.0, 10.0),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    p == 0.05 ? '5%' : formatPerRain(p),
                                    style:
                                        darkMode
                                            ? valueStyle.copyWith(
                                              color: Colors.white,
                                            )
                                            : valueStyle.copyWith(
                                              color: Colors.black87,
                                            ),
                                  ),
                                  Text(
                                    conditionDetails[i].time,
                                    style:
                                        darkMode
                                            ? valueStyle.copyWith(
                                              color: _darkColor,
                                            )
                                            : valueStyle,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                if (selectedButton == CurrentDetails.wind)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.notToday ? 'Day high' : "Today's high",
                        style:
                            darkMode
                                ? headingStyle.copyWith(color: _darkColor)
                                : headingStyle,
                      ),
                      RichText(
                        textScaler: TextScaler.linear(fontScale),
                        text: TextSpan(
                          text: widget.hourDetails.high,
                          style: DefaultTextStyle.of(
                            context,
                          ).style.copyWith(fontSize: 24.0),
                          children: [
                            TextSpan(
                              text:
                                  ' ${widget.sUnit} • ${widget.hourDetails.description}',
                              style: DefaultTextStyle.of(
                                context,
                              ).style.copyWith(fontSize: 16.0),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 136 * fontScale.clamp(1, 1.15),
                        child: ListView.builder(
                          itemCount: conditionDetails.length,
                          scrollDirection: Axis.horizontal,
                          controller: _controller,
                          itemBuilder:
                              (context, i) => Padding(
                                padding: EdgeInsets.only(
                                  top: 24.0,
                                  right:
                                      i == conditionDetails.length - 1
                                          ? 4.0
                                          : 10.0,
                                  left: i == 0 ? 4.0 : 10.0,
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Transform.rotate(
                                      angle:
                                          (math.pi *
                                              conditionDetails[i].degrees) /
                                          180,
                                      child: Image.asset(
                                        conditionDetails[i].illustration[index],
                                        scale: 3.2,
                                      ),
                                    ),
                                    Text(
                                      '${conditionDetails[i].speed}\n${conditionDetails[i].time}',
                                      style:
                                          darkMode
                                              ? valueStyle.copyWith(
                                                color: _darkColor,
                                              )
                                              : valueStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                        ),
                      ),
                    ],
                  ),
                if (selectedButton == CurrentDetails.humidity)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.notToday ? 'Day average' : "Today's average",
                        style:
                            darkMode
                                ? headingStyle.copyWith(color: _darkColor)
                                : headingStyle,
                      ),
                      RichText(
                        textScaler: TextScaler.linear(fontScale),
                        text: TextSpan(
                          text: '${widget.hourDetails.average}',
                          style: DefaultTextStyle.of(
                            context,
                          ).style.copyWith(fontSize: 24.0),
                          children: [
                            TextSpan(
                              text: '%',
                              style: DefaultTextStyle.of(
                                context,
                              ).style.copyWith(fontSize: 16.0),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 136 * fontScale.clamp(1, 1.35),
                        child: ListView.builder(
                          itemCount: conditionDetails.length,
                          scrollDirection: Axis.horizontal,
                          controller: _controller,
                          itemBuilder: (context, i) {
                            final double frac =
                                conditionDetails[i].percent / 100;

                            return Padding(
                              padding: EdgeInsets.only(right: 6.0, left: 6.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                spacing: 5.0,
                                children: [
                                  Text(
                                    '${conditionDetails[i].percent}%',
                                    style:
                                        darkMode
                                            ? valueStyle.copyWith(
                                              color: Colors.white,
                                            )
                                            : valueStyle.copyWith(
                                              color: Colors.black87,
                                            ),
                                  ),
                                  Container(
                                    width: 32.0,
                                    height: 82.0 * frac,
                                    decoration: BoxDecoration(
                                      color:
                                          HSVColor.lerp(
                                            HSVColor.fromColor(
                                              Colors.yellowAccent,
                                            ),
                                            HSVColor.fromColor(
                                              Colors.orange.shade700,
                                            ),
                                            frac,
                                          )?.toColor(),
                                      border: Border.all(
                                        color: Colors.orange.shade700,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        24.0 * frac,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    conditionDetails[i].time,
                                    style:
                                        darkMode
                                            ? valueStyle.copyWith(
                                              color: _darkColor,
                                            )
                                            : valueStyle,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
