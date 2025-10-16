import 'package:flutter/material.dart';

import 'package:climax/widgets/hour_forecast.dart';
import 'package:climax/widgets/wind_condition.dart';
import 'package:climax/widgets/humidity_condition.dart';
import 'package:climax/widgets/uv_condition.dart';
import 'package:climax/widgets/sunrise_set_card.dart';
import 'package:climax/widgets/hour_details.dart';
import 'package:climax/services/models.dart';
import 'package:climax/services/conversions.dart'
    show darkMode, deviceWidth, fontScale;

class ForecastScreen extends StatefulWidget {
  const ForecastScreen({
    required this.weather,
    required this.initialIndex,
    super.key,
  });

  final int initialIndex;
  final Weather weather;

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  late int currentIndex;
  late List<DailyForecast> _forecasts;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _forecasts = widget.weather.dailyForecasts;
  }

  @override
  Widget build(BuildContext context) {
    final int index = darkMode ? 1 : 0;
    final ratio = deviceWidth < 380 && fontScale > 1.4 ? 2.15 : 2.2;

    return DefaultTabController(
      length: _forecasts.length,
      initialIndex: currentIndex,
      animationDuration: Durations.long2,
      child: Scaffold(
        backgroundColor: _forecasts[currentIndex].tempDetails.color[index],
        appBar: AppBar(
          backgroundColor: _forecasts[currentIndex].tempDetails.color[index],
          scrolledUnderElevation: 2.0,
          title: Text('8-day forecast'),
          bottom: TabBar(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            labelPadding: EdgeInsets.symmetric(horizontal: 4.0),
            isScrollable: true,
            labelColor: Colors.black,
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
            indicatorColor:
                darkMode ? const Color(0xff9accff) : const Color(0xff2a5c7e),
            indicatorPadding: EdgeInsets.symmetric(
              horizontal: fontScale < 1.1 ? 8.0 : 12.0,
            ),
            tabAlignment: TabAlignment.start,
            physics: BouncingScrollPhysics(),
            dividerHeight: 0.8,
            dividerColor:
                darkMode ? Colors.blueGrey.shade700 : Colors.grey.shade400,
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStatePropertyAll(Colors.transparent),
            onTap: (value) {
              setState(() {
                currentIndex = value;
              });
            },
            tabs: List.generate(
              _forecasts.length,
              (i) => Tab(
                height: 120,
                child: AnimatedContainer(
                  duration: Durations.long2,
                  curve: Curves.easeIn,
                  padding: EdgeInsets.all(
                    fontScale < 1.1 && deviceWidth > 450 ? 11.0 : 8.0,
                  ),
                  decoration: BoxDecoration(
                    color:
                        currentIndex == i
                            ? darkMode
                                ? Color(0xff011d33)
                                : Colors.white
                            : darkMode
                            ? Color(0x4d011d33)
                            : Colors.white30,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _forecasts[i].day,
                        style: darkMode ? TextStyle(color: Colors.white) : null,
                      ),
                      Image.asset(_forecasts[i].tempDetails.icon, scale: 2.5),
                      RichText(
                        textScaler: TextScaler.linear(
                          fontScale.clamp(0.7, 1.3),
                        ),
                        text: TextSpan(
                          text: _forecasts[i].tempDetails.max,
                          style: TextStyle(
                            fontSize: 12.0,
                            color: darkMode ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: '/${_forecasts[i].tempDetails.max}',
                              style: TextStyle(
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
          ),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: List.generate(
            _forecasts.length,
            (i) => SingleChildScrollView(
              padding: EdgeInsets.only(top: 25.0, bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16.0,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _forecasts[i].date,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Row(
                          children: [
                            RichText(
                              textScaler: TextScaler.linear(
                                fontScale.clamp(
                                  0.7,
                                  (1.5 * deviceWidth / 420).clamp(1.0, 2.0),
                                ),
                              ),
                              text: TextSpan(
                                text: _forecasts[i].tempDetails.max,
                                style: TextStyle(
                                  fontSize: 56.0,
                                  color: darkMode ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                                children: [
                                  TextSpan(
                                    text: '/${_forecasts[i].tempDetails.min}',
                                    style: TextStyle(
                                      color:
                                          darkMode
                                              ? const Color(0xffb9c9d9)
                                              : Colors.blueGrey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Image.asset(
                              _forecasts[i].tempDetails.icon,
                              scale: fontScale > 1 ? 1.35 : 1.45,
                            ),
                          ],
                        ),
                        Text(
                          '${_forecasts[i].tempDetails.description}\n${_forecasts[i].summary}\n',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall!.copyWith(
                            color:
                                darkMode
                                    ? const Color(0xff9accff)
                                    : const Color(0xff2e6987),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i < 4)
                    HourForecast(_forecasts[i].hourly!, notToday: i > 0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 12.0,
                      children: [
                        Text(
                          'Daily conditions',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall!.copyWith(
                            color:
                                darkMode
                                    ? Color(0xffcde5ff)
                                    : const Color(0xff001d33),
                          ),
                        ),
                        GridView.count(
                          crossAxisCount: deviceWidth < 450 ? 1 : 2,
                          shrinkWrap: true,
                          primary: false,
                          childAspectRatio:
                              deviceWidth < 450
                                  ? ratio * (deviceWidth / 430)
                                  : fontScale <= 1
                                  ? 16 / 11
                                  : 4 / 3,
                          mainAxisSpacing: 12.0,
                          crossAxisSpacing: 12.0,
                          children: [
                            WindCondition(
                              parameter: 'Max wind',
                              value: _forecasts[i].condition.windSpeed,
                              description:
                                  _forecasts[i].condition.speedDescription,
                              direction: _forecasts[i].condition.windDirection,
                              unit: widget.weather.speedUnit,
                              degrees: _forecasts[i].condition.degrees / 360,
                              illustration:
                                  _forecasts[i]
                                      .condition
                                      .windIllustration[index],
                              vKey: i,
                            ),
                            HumidityCondition(
                              parameter: 'Average humidity',
                              value: _forecasts[i].condition.humidity,
                              dewPoint: _forecasts[i].condition.dewPoint,
                              vKey: i,
                            ),
                            UVCondition(
                              parameter: 'Max UV index',
                              value: _forecasts[i].condition.uvi,
                              description:
                                  _forecasts[i].condition.uvDescription,
                              color: _forecasts[i].condition.uvColor,
                              vKey: i,
                            ),
                            SunriseSetCard(
                              sunrise: _forecasts[i].condition.sunrise,
                              sunset: _forecasts[i].condition.sunset,
                              isGrouped: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (i < 4)
                    HourDetails(
                      hourDetails: _forecasts[i].details!,
                      pUnit: widget.weather.precipitationUnit,
                      sUnit: widget.weather.speedUnit,
                      notToday: i > 0,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
