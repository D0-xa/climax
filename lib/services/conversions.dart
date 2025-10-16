import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:sugar/sugar.dart';

import 'models.dart' show TempUnits;

late Timezone kTimezone;
late int kOffset;
late TempUnits kUnit;
late double pressureLevel;
late bool darkMode;
late double fontScale;
late double deviceWidth;

num? roundNum(num? value, {int precision = 0}) {
  return num.tryParse(value?.toStringAsFixed(precision) ?? '');
}

String formatTemperature(num temp) {
  return '${temp.round()}°';
}

String capitalize(String text) {
  return text[0].toUpperCase() + text.substring(1);
}

String getIconImage(String name) {
  final code = name.substring(0, 2);
  if (['03', '04', '09', '11', '13', '50'].contains(code)) {
    return 'assets/icons/$code.png';
  }
  return 'assets/icons/$name.png';
}

String formatPerRain(num probOfRain) {
  return '${((probOfRain * 10).floor() * 10).clamp(0, 100)}%';
}

int msecs(int secs) {
  return (secs + kOffset) * 1000;
}

String unixToUtc(int unix, [bool doIsNow = true]) {
  final utc = DateTime.fromMillisecondsSinceEpoch(msecs(unix), isUtc: true);
  final time = ZonedDateTime.now(kTimezone);
  if (time.hour == utc.hour && time.day == utc.day && doIsNow) return 'Now';
  return DateFormat('HH:mm').format(utc);
}

String formatDay(int unix, {bool abbr = true}) {
  final utc = DateTime.fromMillisecondsSinceEpoch(msecs(unix), isUtc: true);
  if (ZonedDateTime.now(kTimezone).day == utc.day) return 'Today';
  return DateFormat(
    abbr
        ? fontScale <= 1.5 && deviceWidth > 420 ||
                fontScale <= 1.8 && deviceWidth > 480
            ? 'EEEE d MMM'
            : 'E d MMM'
        : 'EEEE d MMMM',
  ).format(utc);
}

String formatDayAbbr(int unix) {
  final utc = DateTime.fromMillisecondsSinceEpoch(msecs(unix), isUtc: true);
  if (ZonedDateTime.now(kTimezone).day == utc.day) return 'Today';
  return DateFormat('E').format(utc);
}

String formatWindSpeed(num windSpeed) {
  if (kUnit == TempUnits.imperial) return '${windSpeed.floor()}';
  return '${(windSpeed * 3.6).floor()}';
}

String windSpeedComment(num windSpeed) {
  final kmPerHour =
      kUnit == TempUnits.metric ? windSpeed * 3.6 : windSpeed * 1.609344;

  if (kmPerHour < 6) return 'Calm';
  if (kmPerHour < 20) return 'Light';
  if (kmPerHour < 39) return 'Moderate';
  if (kmPerHour < 62) return 'Strong';
  if (kmPerHour < 101) return 'Storm';
  return 'Severe';
}

String getWindDirection(num deg) {
  if (deg < 11 || deg > 349) return 'From north';
  if (deg < 80) return 'From northeast';
  if (deg < 101) return 'From east';
  if (deg < 170) return 'From southeast';
  if (deg < 191) return 'From south';
  if (deg < 260) return 'From southwest';
  if (deg < 281) return 'From west';
  return 'From northwest';
}

List<String> getWindIllustration(num windspeed) {
  final kmPerHour =
      kUnit == TempUnits.metric ? windspeed * 3.6 : windspeed * 1.609344;

  if (kmPerHour < 6) {
    return ['assets/images/calm.png', 'assets/images/calm_dark.png'];
  }
  if (kmPerHour < 20) {
    return ['assets/images/light.png', 'assets/images/light_dark.png'];
  }
  if (kmPerHour < 62) {
    return ['assets/images/moderate.png', 'assets/images/moderate_dark.png'];
  }
  return ['assets/images/storm.png', 'assets/images/storm_dark.png'];
}

String uvDescription(num uvIndex) {
  if (uvIndex < 3) return 'Low'; // green
  if (uvIndex < 6) return 'Moderate'; // yellow
  if (uvIndex < 8) return 'High'; // orange
  if (uvIndex < 11) return 'Very high'; // red
  return 'Extreme'; // purple
}

Color uvColor(num uvIndex) {
  if (uvIndex < 2) return Colors.lime;
  if (uvIndex == 2) return Colors.lightGreen;
  if (uvIndex < 5) return Colors.yellow;
  if (uvIndex == 5) return Colors.orange;
  if (uvIndex < 8) return Colors.redAccent;
  if (uvIndex == 8) return Colors.deepOrange;
  if (uvIndex < 11) return Colors.purpleAccent;
  return Colors.deepPurpleAccent;
}

String formatPressure(int value) {
  pressureLevel = (value / 1800).clamp(0, 1);
  if (kUnit == TempUnits.metric) {
    final text = value.toString();
    if (value >= 1000) return '${text[0]},${text.substring(1)}';
    return text;
  }
  return (value * 0.02953).toStringAsFixed(2);
}

List<double> ratioOfDay(String rise, String set) {
  final rises = num.parse(rise.split(':')[0]);
  final sets = num.parse(set.split(':')[0]);
  final hour = ZonedDateTime.now(kTimezone).hour;

  if (hour <= rises) return [hour / rises, 0, 0];
  if (hour > rises && hour < sets) {
    return [1, (hour - rises) / (sets - rises), 0];
  }
  return [1, 1, (hour - sets) / (24 - sets)];
}

String formatPrecipitation(num amount) {
  if (kUnit == TempUnits.metric) {
    if (amount == 0) return '0.0';
    return amount.toStringAsFixed(1);
  }
  if (amount == 0) return '0.00';
  return (amount * 0.03937008).toStringAsFixed(2);
}

List<Color> backgroundColor(num id) {
  if (id < 300) return [const Color(0xffc0cde0), const Color(0xff29343d)];
  if (id < 500) return [const Color(0xffd7e3f4), const Color(0xff364451)];
  if (id < 600) return [const Color(0xffb9c7dc), const Color(0xff2d3944)];
  if (id < 700) return [const Color(0xffe7eef8), const Color(0xff313e4b)];
  if (id < 800) return [const Color(0xffc6cdd8), const Color(0xff3f4851)];
  if (id == 800) return [const Color(0xffcee3ff), const Color(0xff004b75)];
  return [const Color(0xffe0edff), const Color(0xff384351)];
}

List<String> forecastImage(num id) {
  final rain = ['assets/images/Storm.jpg', 'assets/images/Storm_dark.jpg'];
  final drizzle = ['assets/images/Rain.jpg', 'assets/images/Rain_dark.jpg'];
  final cloudy = ['assets/images/Cloudy.jpg', 'assets/images/Cloudy_dark.jpg'];
  final clearSky = ['assets/images/Clear.jpg', 'assets/images/Clear_dark.jpg'];

  if (id < 300) return rain;
  if (id < 500) return drizzle;
  if (id < 600) return rain;
  if (id < 700) return drizzle;
  if (id < 800) return cloudy;
  if (id < 802) return clearSky;
  return cloudy;
}
