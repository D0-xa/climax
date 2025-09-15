import 'package:flutter/material.dart';

import 'package:climax/screens/weather_screen.dart';

import 'package:climax/services/weather.dart' hide getCities;
import 'package:climax/services/models.dart' show QueryState;

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  Widget? _widget;
  late bool _darkMode;

  @override
  void initState() {
    super.initState();
    getLocationData();
  }

  Future<void> getLocationData() async {
    final weatherService = WeatherService(context);
    await weatherService.initializeBox();
    await weatherService.updateWeatherData();

    if (weatherService.weatherData.queryState == QueryState.invalid) {
      setState(() {
        _widget = displayWidget(false);
      });
    } else if (weatherService.weatherData.queryState == QueryState.error) {
      setState(() {
        _widget = displayWidget(true);
      });
    } else if (mounted) {
      await precacheImage(AssetImage('assets/images/avatar.jpeg'), context);
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WeatherScreen(weatherService: weatherService),
          ),
        ),
      );
    }
  }

  Widget displayWidget(bool loadingState) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 12.0,
      children: [
        Icon(
          Icons.error_outline,
          size: 48,
          color: _darkMode ? const Color(0xff464646) : Color(0xf0c8c8c8),
        ),
        if (loadingState)
          Text(
            "Can't reach the Internet",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: _darkMode ? const Color(0xffe6e6e6) : null,
            ),
          ),
        Text(
          loadingState
              ? 'Weather data is currently unavailable. Check your connection and try again'
              : "Unable to show weather for your current location.\nPlease check your device's location settings",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.0,
            color: _darkMode ? const Color(0xffdcdcdc) : null,
          ),
        ),
        const SizedBox(),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _widget = null;
                  getLocationData();
                });
              },
              icon: Transform.flip(
                flipX: true,
                child: Icon(
                  Icons.replay_rounded,
                  color: _darkMode ? const Color(0xff2f455e) : null,
                ),
              ),
              label: Text('Try again'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _darkMode
                        ? const Color(0xffa9cdff)
                        : const Color(0xff0050dc),
                foregroundColor:
                    _darkMode ? const Color(0xff2f455e) : Colors.white,
                overlayColor:
                    _darkMode ? const Color(0xff00256a) : Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 28.0),
              ),
            ),
            if (!loadingState)
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      _darkMode ? const Color(0xffdcdcdc) : Colors.black54,
                ),
                child: Text('Send feedback'),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _darkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: _darkMode ? const Color(0xff141414) : Colors.white,
      body: Center(
        child:
            _widget ??
            CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation<Color>(
                _darkMode ? const Color(0xffa9cdff) : const Color(0xff0050dc),
              ),
            ),
      ),
    );
  }
}
