import 'package:flutter/material.dart';

enum TempUnits { metric, imperial }

enum QueryState { invalid, error, success }

class CurrentForecast {
  const CurrentForecast({
    this.temp,
    required this.max,
    required this.min,
    required this.icon,
    required this.description,
    this.feelsLike,
    required this.color,
    this.image,
  });

  final String? temp;
  final String max;
  final String min;
  final String icon;
  final String description;
  final String? feelsLike;
  final List<Color> color;
  final List<String>? image;
}

class HourlyForecast {
  const HourlyForecast({
    required this.temp,
    required this.pop,
    required this.icon,
    required this.time,
  });

  final String temp;
  final num pop;
  final String icon;
  final String time;
}

class Condition {
  const Condition({
    required this.windSpeed,
    required this.speedDescription,
    required this.windDirection,
    required this.windIllustration,
    required this.degrees,
    required this.humidity,
    required this.dewPoint,
    required this.uvi,
    required this.uvDescription,
    required this.uvColor,
    this.pressure,
    required this.sunrise,
    required this.sunset,
  });

  final String windSpeed;
  final String speedDescription;
  final String windDirection;
  final List<String> windIllustration;
  final num degrees;
  final num humidity;
  final String dewPoint;
  final String uvi;
  final String uvDescription;
  final Color uvColor;
  final String? pressure;
  final String sunrise;
  final String sunset;
}

class ConditionDetails {
  const ConditionDetails({
    required this.time,
    required this.volume,
    required this.pop,
    required this.degrees,
    required this.speed,
    required this.illustration,
    required this.percent,
  });

  final String time;
  final num volume;
  final num pop;
  final num degrees;
  final String speed;
  final List<String> illustration;
  final num percent;
}

class HourlyDetails {
  const HourlyDetails({
    required this.amount,
    required this.high,
    required this.description,
    required this.average,
    required this.conditionDetails,
  });

  final String amount;
  final String high;
  final String description;
  final num average;
  final List<ConditionDetails> conditionDetails;
}

class DailyForecast {
  const DailyForecast({
    required this.abbrdate,
    required this.pop,
    required this.date,
    required this.day,
    required this.tempDetails,
    required this.summary,
    this.hourly,
    required this.condition,
    this.details,
  });

  final String abbrdate;
  final num pop;
  final String day;
  final String date;
  final CurrentForecast tempDetails;
  final String summary;
  final List<HourlyForecast>? hourly;
  final Condition condition;
  final HourlyDetails? details;
}

class Weather {
  const Weather({
    this.currentForecast,
    this.hourlyForecasts = const [],
    this.dailyForecasts = const [],
    this.condition,
    this.hourlyDetails,
    this.city = 'Unknown City',
    required this.queryState,
    required this.unit,
  });

  final CurrentForecast? currentForecast;
  final List<HourlyForecast> hourlyForecasts;
  final List<DailyForecast> dailyForecasts;
  final Condition? condition;
  final HourlyDetails? hourlyDetails;
  final String city;
  final QueryState queryState;
  final TempUnits unit;

  String get speedUnit {
    if (unit == TempUnits.metric) return 'km/h';
    return 'mph';
  }

  String get pressureUnit {
    if (unit == TempUnits.metric) return 'mBar';
    return 'inHg';
  }

  String get precipitationUnit {
    if (unit == TempUnits.metric) return 'mm';
    return 'in';
  }
}

class City {
  const City({required this.name, required this.lat, required this.lon});

  final String name;
  final num lat;
  final num lon;
}

class CityWeather {
  const CityWeather({
    required this.icon,
    required this.temp,
    required this.name,
    required this.city,
    required this.description,
  });

  final String icon;
  final String temp;
  final String name;
  final String description;
  final City city;
}
