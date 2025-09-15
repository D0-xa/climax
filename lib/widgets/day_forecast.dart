import 'package:flutter/material.dart';

import 'package:climax/screens/forecast_screen.dart';

import 'package:climax/services/models.dart';
import 'package:climax/services/conversions.dart' show formatPerRain;

class DayForecast extends StatelessWidget {
  DayForecast(this.weather, {super.key}) : forecasts = weather.dailyForecasts;

  final Weather weather;
  final List<DailyForecast> forecasts;

  @override
  Widget build(BuildContext context) {
    final darkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12.0,
        children: [
          Text(
            '${forecasts.length}-day forecast',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: darkMode ? const Color(0xffcde5ff) : const Color(0xff001d33),
            ),
          ),
          ListView.builder(
            itemCount: forecasts.length,
            shrinkWrap: true,
            primary: false,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final BorderRadius borderRadius = BorderRadius.only(
                topLeft:
                    index == 0 ? Radius.circular(12.0) : Radius.circular(5.0),
                topRight:
                    index == 0 ? Radius.circular(12.0) : Radius.circular(5.0),
                bottomLeft:
                    index == forecasts.length - 1
                        ? Radius.circular(12.0)
                        : Radius.circular(5.0),
                bottomRight:
                    index == forecasts.length - 1
                        ? Radius.circular(12.0)
                        : Radius.circular(5.0),
              );

              return Container(
                margin:
                    index != forecasts.length - 1
                        ? const EdgeInsets.only(bottom: 4.0)
                        : null,
                decoration: BoxDecoration(
                  color: darkMode ? const Color(0xff0d1d2a) : const Color(0xfffcfcfe),
                  borderRadius: borderRadius,
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    highlightColor: Colors.transparent,
                    borderRadius: borderRadius,
                    onTap: () {
                      Future.delayed(
                        Durations.short3,
                        () => Navigator.push(
                          // ignore: use_build_context_synchronously
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ForecastScreen(
                                  weather: weather,
                                  initialIndex: index,
                                ),
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 1.2,
                        horizontal: 12.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(forecasts[index].abbrdate),
                          Spacer(),
                          Text(
                            formatPerRain(forecasts[index].pop),
                            style: DefaultTextStyle.of(context).style.copyWith(
                              color:
                                  forecasts[index].pop >= 0.1
                                      ? darkMode
                                          ? const Color(0xff86c1fc)
                                          : const Color(0xff226daa)
                                      : Colors.transparent,
                              fontSize: 13.0,
                            ),
                          ),
                          Image.asset(
                            forecasts[index].tempDetails.icon,
                            scale: 2.2,
                          ),
                          const SizedBox(width: 80),
                          RichText(
                            text: TextSpan(
                              text: forecasts[index].tempDetails.max,
                              style: DefaultTextStyle.of(context).style,
                              children: [
                                TextSpan(
                                  text: '/${forecasts[index].tempDetails.min}',
                                  style: DefaultTextStyle.of(
                                    context,
                                  ).style.copyWith(
                                    color:
                                        darkMode
                                            ? const Color(0xffb9c9d9)
                                            : Colors.blueGrey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
