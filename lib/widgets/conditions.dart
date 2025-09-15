import 'package:flutter/material.dart';

import 'package:climax/widgets/wind_condition.dart';
import 'package:climax/widgets/humidity_condition.dart';
import 'package:climax/widgets/pressure_condition.dart';
import 'package:climax/widgets/uv_condition.dart';
import 'package:climax/widgets/sunrise_set_card.dart';
import 'package:climax/services/models.dart' show Weather, Condition, TempUnits;

class Conditions extends StatelessWidget {
  Conditions(this.weather, {super.key}) : condition = weather.condition!;

  final Weather weather;
  final Condition condition;

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
            'Current conditions',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: darkMode ? Color(0xffcde5ff) : const Color(0xff001d33),
            ),
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            primary: false,
            childAspectRatio: 16 / 11,
            mainAxisSpacing: 12.0,
            crossAxisSpacing: 12.0,
            padding: EdgeInsets.zero,
            // physics: NeverScrollableScrollPhysics(),  // Achieves the same functionality.
            children: [
              WindCondition(
                value: condition.windSpeed,
                description: condition.speedDescription,
                direction: condition.windDirection,
                unit: weather.speedUnit,
                degrees: condition.degrees / 360,
              ),
              HumidityCondition(
                value: condition.humidity,
                dewPoint: condition.dewPoint,
              ),
              UVCondition(
                value: condition.uvi,
                description: condition.uvDescription,
                color: condition.uvColor,
              ),
              PressureCondition(
                value: condition.pressure!,
                unit: weather.pressureUnit,
                u: weather.unit == TempUnits.imperial,
              ),
            ],
          ),
          SunriseSetCard(sunrise: condition.sunrise, sunset: condition.sunset),
        ],
      ),
    );
  }
}
