import 'package:flutter/material.dart';

import 'package:sugar/sugar.dart';
import 'package:hive/hive.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'networking.dart';
import 'location.dart';
import 'conversions.dart';
import 'models.dart';

final apiKey = dotenv.env['API_KEY'];
const baseUrl = 'https://api.openweathermap.org/';
const NetworkingService networkingService = NetworkingService(baseUrl);
late Box _box;
late String _unit;
List<CityWeather?> savedWeather = [];
late CityWeather myLocWeather;
late int dIndex;
late dynamic dLoc;
late CityWeather dCity;
bool nullify = false;

class WeatherService {
  WeatherService(this.context) : _locationService = LocationService(context);

  final BuildContext context;
  LocationService _locationService;
  double? _latitude;
  double? _longitude;
  late Weather weatherData;
  DateTime? _lastRequestTime;

  set ctx(BuildContext newContext) {
    if (newContext.mounted) {
      _locationService = LocationService(newContext);
    }
  }

  Future<void> initializeBox() async {
    _box = await Hive.openBox('weather');
    if (!_box.containsKey('unit')) _box.put('unit', 'metric');
    if (!_box.containsKey('saved')) _box.put('saved', []);
  }

  Future<void> initializePosition() async {
    final Map lastKnownLoc = _box.get(
      'lastloc',
      defaultValue: {'lat': null, 'lon': null},
    );
    final position = await _locationService.getCurrentPosition();
    _latitude = position?.latitude ?? lastKnownLoc['lat'];
    _longitude = position?.longitude ?? lastKnownLoc['lon'];
    _box.put('lastloc', {'lat': _latitude, 'lon': _longitude});
  }

  Future<Map<String, dynamic>?> _getWeatherData() async {
    if (_latitude != null && _longitude != null) {
      final String endpoint =
          'data/3.0/onecall?lat=$_latitude&lon=$_longitude&appid=$apiKey&exclude=minutely,alerts&units=$_unit';
      final data = await networkingService.fetchData(endpoint);
      if (!data.containsKey('error')) {
        _lastRequestTime = DateTime.now();
      }
      return data;
    }
    return null;
  }

  Future<Map<String, dynamic>?> _getCurrentCity() async {
    if (_latitude != null && _longitude != null) {
      final String endpoint =
          'data/2.5/forecast/hourly?lat=$_latitude&lon=$_longitude&appid=$apiKey&units=$_unit';
      return await networkingService.fetchData(endpoint);
    }
    return null;
  }

  Future<void> updateWeatherData({City? location}) async {
    final lon = roundNum(_longitude, precision: 4);
    final lat = roundNum(_latitude, precision: 4);
    if (location == null) {
      await initializePosition();
    } else {
      _latitude = location.lat.toDouble();
      _longitude = location.lon.toDouble();
    }

    final DateTime now = DateTime.now();
    if (nullify ||
        lon != roundNum(_longitude, precision: 4) ||
        lat != roundNum(_latitude, precision: 4) ||
        _lastRequestTime == null ||
        now.minute < 5 ||
        _unit != _box.get('unit') ||
        now.difference(_lastRequestTime!).inMinutes > 10) {
      _unit = await _box.get('unit');
      kUnit = _unit == 'metric' ? TempUnits.metric : TempUnits.imperial;
      nullify = false;
      final weather =
          await (
            _getCurrentCity(),
            _getWeatherData(),
            getSavedLoc(),
            getcurrentloc(),
          ).wait;

      if (weather.$1 == null && weather.$2 == null) {
        weatherData = Weather(queryState: QueryState.invalid, unit: kUnit);
      } else if (weather.$1!.containsKey('error') ||
          weather.$2!.containsKey('error') ||
          weather.$3.contains(null) ||
          weather.$4 == null) {
        weatherData = Weather(queryState: QueryState.error, unit: kUnit);
      } else {
        savedWeather = weather.$3;
        myLocWeather = weather.$4!;
        kTimezone = Timezone(weather.$2!['timezone']);
        kOffset = weather.$2!['timezone_offset'];
        final Map<String, dynamic> todayCurrent = weather.$2!['current'];
        final List todayHourly = weather.$2!['hourly'].sublist(0, 25);
        final List daily = weather.$2!['daily'];
        final List w = weather.$1!['list'];
        final index =
            24 -
            ZonedDateTime.fromEpochMilliseconds(
              kTimezone,
              w[0]['dt'] * 1000,
            ).hour;
        final List<List> hourly = [
          w.sublist(0, 24),
          w.sublist(index, index + 24),
          w.sublist(index + 24, index + 48),
          w.sublist(index + 48, index + 72),
        ];
        final String? cityName = await getCityName(_latitude!, _longitude!);

        weatherData = Weather(
          currentForecast: CurrentForecast(
            temp: formatTemperature(todayCurrent['temp']),
            max: formatTemperature(daily[0]['temp']['max']),
            min: formatTemperature(daily[0]['temp']['min']),
            icon: getIconImage(todayCurrent['weather'][0]['icon']),
            description: capitalize(todayCurrent['weather'][0]['description']),
            feelsLike: formatTemperature(todayCurrent['feels_like']),
            color: backgroundColor(todayCurrent['weather'][0]['id']),
            image: forecastImage(todayCurrent['weather'][0]['id']),
          ),
          hourlyForecasts:
              todayHourly
                  .map(
                    (e) => HourlyForecast(
                      temp: formatTemperature(e['temp']),
                      pop: e['pop'],
                      icon: getIconImage(e['weather'][0]['icon']),
                      time: unixToUtc(e['dt']),
                    ),
                  )
                  .toList(),
          condition: Condition(
            windSpeed: formatWindSpeed(todayCurrent['wind_speed']),
            speedDescription: windSpeedComment(todayCurrent['wind_speed']),
            windDirection: getWindDirection(todayCurrent['wind_deg']),
            windIllustration: getWindIllustration(todayCurrent['wind_speed']),
            degrees: todayCurrent['wind_deg'],
            humidity: todayCurrent['humidity'],
            dewPoint: formatTemperature(todayCurrent['dew_point']),
            uvi: todayCurrent['uvi'].toStringAsFixed(0),
            uvDescription: uvDescription(todayCurrent['uvi'].round()),
            uvColor: uvColor(todayCurrent['uvi'].round()),
            pressure: formatPressure(todayCurrent['pressure']),
            sunrise: unixToUtc(todayCurrent['sunrise'], false),
            sunset: unixToUtc(todayCurrent['sunset'], false),
          ),
          dailyForecasts:
              daily.map((e) {
                final int i = daily.indexOf(e);

                return DailyForecast(
                  abbrdate: formatDay(e['dt']),
                  pop: e['pop'],
                  date: formatDay(e['dt'], abbr: false),
                  day: formatDayAbbr(e['dt']),
                  tempDetails: CurrentForecast(
                    max: formatTemperature(e['temp']['max']),
                    min: formatTemperature(e['temp']['min']),
                    icon: getIconImage(e['weather'][0]['icon']),
                    description: capitalize(e['weather'][0]['description']),
                    color: backgroundColor(e['weather'][0]['id']),
                  ),
                  summary: capitalize(e['summary']),
                  condition: Condition(
                    windSpeed: formatWindSpeed(e['wind_speed']),
                    speedDescription: windSpeedComment(e['wind_speed']),
                    windDirection: getWindDirection(e['wind_deg']),
                    windIllustration: getWindIllustration(e['wind_speed']),
                    degrees: e['wind_deg'],
                    humidity: e['humidity'],
                    dewPoint: formatTemperature(e['dew_point']),
                    uvi: e['uvi'].toStringAsFixed(0),
                    uvDescription: uvDescription(e['uvi'].round()),
                    uvColor: uvColor(e['uvi'].round()),
                    sunrise: unixToUtc(e['sunrise'], false),
                    sunset: unixToUtc(e['sunset'], false),
                  ),
                  hourly:
                      i < 4
                          ? hourly[i]
                              .map(
                                (x) => HourlyForecast(
                                  temp: formatTemperature(x['main']['temp']),
                                  pop: x['pop'],
                                  icon: getIconImage(x['weather'][0]['icon']),
                                  time: unixToUtc(x['dt']),
                                ),
                              )
                              .toList()
                          : null,
                  details:
                      i < 4
                          ? HourlyDetails(
                            amount: formatPrecipitation(
                              e.containsKey('rain') ? e['rain'] : 0,
                            ),
                            high: formatWindSpeed(e['wind_speed']),
                            description: windSpeedComment(e['wind_speed']),
                            average: e['humidity'],
                            conditionDetails:
                                hourly[i]
                                    .map(
                                      (x) => ConditionDetails(
                                        time: unixToUtc(x['dt']),
                                        volume:
                                            x.containsKey('rain')
                                                ? x['rain']['1h']
                                                : 0,
                                        pop: x['pop'],
                                        degrees: x['wind']['deg'],
                                        speed: formatWindSpeed(
                                          x['wind']['speed'],
                                        ),
                                        illustration: getWindIllustration(
                                          x['wind']['speed'],
                                        ),
                                        percent: x['main']['humidity'],
                                      ),
                                    )
                                    .toList(),
                          )
                          : null,
                );
              }).toList(),
          hourlyDetails: HourlyDetails(
            amount: formatPrecipitation(
              daily[0].containsKey('rain') ? daily[0]['rain'] : 0,
            ),
            high: formatWindSpeed(daily[0]['wind_speed']),
            description: windSpeedComment(daily[0]['wind_speed']),
            average: daily[0]['humidity'],
            conditionDetails:
                todayHourly
                    .map(
                      (e) => ConditionDetails(
                        time: unixToUtc(e['dt']),
                        volume: e.containsKey('rain') ? e['rain']['1h'] : 0,
                        pop: e['pop'],
                        degrees: e['wind_deg'],
                        speed: formatWindSpeed(e['wind_speed']),
                        illustration: getWindIllustration(e['wind_speed']),
                        percent: e['humidity'],
                      ),
                    )
                    .toList(),
          ),
          city: cityName ?? weather.$1!['city']['name'],
          queryState: QueryState.success,
          unit: kUnit,
        );
      }
    }
  }
}

Future<String?> getCityName(double? lat, double? lon) async {
  if (lat != null && lon != null) {
    final String endpoint =
        'geo/1.0/reverse?lat=$lat&lon=$lon&limit=1&appid=$apiKey';
    final data = await networkingService.fetchData(endpoint);
    if (data.runtimeType == List) {
      if (data[0]['state'] == null) return data[0]['name'];
      return '${data[0]['name']}, ${data[0]['state']}';
    }
  }
  return null;
}

Future<Iterable<City>> getCities(String text) async {
  final String endpoint = 'geo/1.0/direct?q=$text&limit=3&appid=$apiKey';
  final data = await networkingService.fetchData(endpoint);
  if (data.runtimeType == List<dynamic>) {
    data as List<dynamic>;
    return data.map(
      (city) => City(
        name:
            city['state'] != null
                ? '${city['name']}, ${city['state']}'
                : '${data[0]['name']}, ${data[0]['country']}',
        lat: city['lat'],
        lon: city['lon'],
      ),
    );
  }
  return [];
}

Future<CityWeather> getCityWeather(dynamic city) async {
  final String endpoint =
      'data/3.0/onecall?lat=${city['lat']}&lon=${city['lon']}&appid=$apiKey&exclude=hourly,daily,minutely,alerts&units=$_unit';
  final data = await networkingService.fetchData(endpoint);
  return CityWeather(
    icon: getIconImage(data['current']['weather'][0]['icon']),
    temp: formatTemperature(data['current']['temp']),
    name: city['id'].split(',')[0],
    description: capitalize(data['current']['weather'][0]['description']),
    city: City(name: city['id'], lat: city['lat'], lon: city['lon']),
  );
}

Future<CityWeather?> getcurrentloc() async {
  final Map myLoc = _box.get('lastloc');
  final name = await getCityName(myLoc['lat'], myLoc['lon']);
  if (name != null) {
    try {
      return await getCityWeather({
        'id': name,
        'lat': myLoc['lat'],
        'lon': myLoc['lon'],
      });
      // ignore: empty_catches
    } catch (e) {}
  }
  return null;
}

Future<List<CityWeather?>> getSavedLoc() async {
  final List saved = _box.get('saved');
  try {
    return await saved.map((c) => getCityWeather(c)).toList().wait;
  } on ParallelWaitError catch (e) {
    return e.values;
  }
}

Future<void> saveLocation(City city) async {
  final List saved = _box.get('saved');
  saved.add({'id': city.name, 'lat': city.lat, 'lon': city.lon});
  _box.put('saved', saved);
  final locations = await getSavedLoc();
  if (!locations.contains(null)) {
    savedWeather = locations;
  }
}

bool isSaved(City city) {
  final List saved = _box.get('saved');
  for (var i in saved) {
    if (city.name == i['id']) return true;
  }
  return false;
}

void deleteLocation(int index) {
  final List saved = _box.get('saved');
  dIndex = index;
  dLoc = saved.removeAt(index);
  _box.put('saved', saved);
  dCity = savedWeather.removeAt(index)!;
}

void undoDelete() {
  final List saved = _box.get('saved');
  saved.insert(dIndex, dLoc);
  _box.put('saved', saved);
  savedWeather.insert(dIndex, dCity);
}
