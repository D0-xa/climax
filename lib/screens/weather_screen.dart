import 'package:flutter/material.dart';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'package:climax/widgets/forecast.dart';
import 'package:climax/widgets/day_forecast.dart';
import 'package:climax/widgets/hour_forecast.dart';
import 'package:climax/widgets/conditions.dart';
import 'package:climax/widgets/hour_details.dart';
import 'package:climax/services/weather.dart' hide getCities;
import 'package:climax/services/location.dart' hide LocationService;
import 'package:climax/services/conversions.dart' show darkMode;
import 'package:climax/services/models.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({required this.weatherService, super.key});

  final WeatherService weatherService;

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Weather _weatherData;
  City? _displayedLoc;
  bool loading = false;
  late SearchController _searchController;

  @override
  void initState() {
    super.initState();
    widget.weatherService.ctx = context;
    _weatherData = widget.weatherService.weatherData;
    _searchController = SearchController();
    _searchController.text = _weatherData.city;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> getWeather({City? selectedCity, bool isRefresh = false}) async {
    if (!isRefresh) {
      setState(() => loading = true);
      serviceActive = await isServiceEnabled();
    }

    final isConnected = await InternetConnection().hasInternetAccess;
    if (!isConnected) {
      showSnackbar(text: "Can't reach the Internet");
      if (loading) setState(() => loading = false);
      return;
    }

    await widget.weatherService.updateWeatherData(location: selectedCity);
    final weatherData = widget.weatherService.weatherData;

    if (!mounted || weatherData.queryState == QueryState.invalid) {
      if (loading) setState(() => loading = false);
      return;
    }

    if (weatherData.queryState == QueryState.error) {
      showSnackbar(text: "Can't reach the Internet");
    } else {
      setState(() {
        _weatherData = weatherData;
        _displayedLoc = selectedCity;
        _searchController.text = weatherData.city;
      });

      if (!isRefresh && selectedCity != null && !isSaved(selectedCity)) {
        showSnackbar(city: selectedCity);
      }
    }

    if (loading) setState(() => loading = false);
  }

  Future<bool> updatePosition() async {
    final bool isConnected = await InternetConnection().hasInternetAccess;
    if (isConnected) {
      await widget.weatherService.initializePosition();
    } else {
      showSnackbar(
        text: "Can't update your location. You appear to be offline",
      );
    }
    return isConnected;
  }

  void showSnackbar({String? text, City? city}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text ?? 'Save this location to your list?'),
        margin: EdgeInsets.all(20),
        action:
            text == null
                ? SnackBarAction(
                  label: 'Save',
                  onPressed: () async {
                    await saveLocation(city!);
                    showSnackbar(text: 'Location saved');
                  },
                )
                : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = darkMode ? const Color(0xffb9c9d9) : Colors.blueGrey;
    final int i = darkMode ? 1 : 0;

    return Scaffold(
      backgroundColor: _weatherData.currentForecast!.color[i],
      body: RefreshIndicator.adaptive(
        color: darkMode ? const Color(0xff9ac4ff) : const Color(0xff2371f8),
        backgroundColor: darkMode ? const Color(0xff3c3c3c) : null,
        onRefresh:
            () => getWeather(selectedCity: _displayedLoc, isRefresh: true),
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 24.0),
              primary: true,
              child: Column(
                spacing: 16.0,
                children: [
                  Forecast(
                    location: _weatherData.city,
                    forecast: _weatherData.currentForecast!,
                    handleSelection: getWeather,
                    currentCity: _displayedLoc,
                    usePrecise: updatePosition,
                    controller: _searchController,
                  ),
                  const SizedBox(height: 2.0),
                  HourForecast(_weatherData.hourlyForecasts),
                  DayForecast(_weatherData),
                  Conditions(_weatherData),
                  HourDetails(
                    hourDetails: _weatherData.hourlyDetails!,
                    pUnit: _weatherData.precipitationUnit,
                    sUnit: _weatherData.speedUnit,
                  ),
                  Text(
                    "OpenWeather",
                    style: TextStyle(
                      shadows: [Shadow(color: color, offset: Offset(0, -1.5))],
                      color: Colors.transparent,
                      fontSize: 12.0,
                      decoration: TextDecoration.underline,
                      decorationColor: color,
                      decorationThickness: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            if (loading)
              CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation<Color>(
                  darkMode ? const Color(0xffa9cdff) : const Color(0xff0050dc),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
