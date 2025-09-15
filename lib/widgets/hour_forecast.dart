import 'package:flutter/material.dart';

import 'package:climax/services/conversions.dart' show formatPerRain;
import 'package:climax/services/models.dart' show HourlyForecast;

class HourForecast extends StatefulWidget {
  const HourForecast(this.forecasts, {this.notToday = false, super.key});

  final List<HourlyForecast> forecasts;
  final bool notToday;

  @override
  State<HourForecast> createState() => _HourForecastState();
}

class _HourForecastState extends State<HourForecast> {
  late final ScrollController _controller;
  late bool _darkMode;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.notToday) {
        _controller.jumpTo(450.5);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _darkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12.0,
        children: [
          Text(
            'Hourly forecast',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: _darkMode ? const Color(0xffcde5ff) : const Color(0xff001d33),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: _darkMode ? const Color(0xff0d1d2a) : const Color(0xfffcfcfe),
              borderRadius: BorderRadius.circular(12.0),
            ),
            height: 132,
            child: ListView.builder(
              // prototypeItem: ,
              itemCount: widget.forecasts.length,
              scrollDirection: Axis.horizontal,
              controller: _controller,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    top: 18.0,
                    bottom: 18.0,
                    right: index == widget.forecasts.length - 1 ? 24.0 : 9.0,
                    left: index == 0 ? 24.0 : 9.0,
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.forecasts[index].temp,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        formatPerRain(widget.forecasts[index].pop),
                        style: TextStyle(
                          color:
                              widget.forecasts[index].pop >= 0.1
                                  ? _darkMode
                                      ? const Color(0xff86c1fc)
                                      : const Color(0xff226daa)
                                  : Colors.transparent,
                          fontSize: 12.0,
                          height: -0.2,
                        ),
                      ),
                      Image.asset(widget.forecasts[index].icon, scale: 2.2),
                      SizedBox(height: 2.0),
                      Text(
                        widget.forecasts[index].time,
                        style: DefaultTextStyle.of(context).style.copyWith(
                          fontSize: 12.0,
                          height: -0.1,
                          color:
                              _darkMode
                                  ? const Color(0xffb9c9d9)
                                  : Colors.blueGrey.shade700,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
