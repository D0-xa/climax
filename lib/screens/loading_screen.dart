import 'dart:async';
import 'package:flutter/material.dart';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'weather_screen.dart';
import 'package:climax/services/weather.dart' hide getCities;
import 'package:climax/services/models.dart' show QueryState;
import 'package:climax/services/conversions.dart' show darkMode;

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  Widget? _widget;
  late final StreamSubscription<InternetStatus> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = InternetConnection().onStatusChange.listen((status) {
      setState(() {
        if (status == InternetStatus.connected) {
          _widget = null;
          getLocationData();
        } else {
          _widget = displayWidget(true);
        }
      });
    });
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
          color: darkMode ? const Color(0xff464646) : Color(0xf0c8c8c8),
        ),
        if (loadingState)
          Text(
            "Can't reach the Internet",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: darkMode ? const Color(0xffe6e6e6) : null,
            ),
          ),
        Text(
          loadingState
              ? 'Weather data is currently unavailable. Check your connection and try again'
              : "Unable to show weather for your current location.\nPlease check your device's location settings",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.0,
            color: darkMode ? const Color(0xffdcdcdc) : null,
          ),
        ),
        const SizedBox(),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                setState(() {
                  _widget = null;
                });
                final bool isConnected =
                    await InternetConnection().hasInternetAccess;
                if (isConnected) {
                  getLocationData();
                } else {
                  setState(() {
                    _widget = displayWidget(true);
                  });
                }
              },
              icon: Transform.flip(
                flipX: true,
                child: Icon(
                  Icons.replay_rounded,
                  color: darkMode ? const Color(0xff2f455e) : null,
                ),
              ),
              label: Text('Try again'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    darkMode
                        ? const Color(0xffa9cdff)
                        : const Color(0xff0050dc),
                foregroundColor:
                    darkMode ? const Color(0xff2f455e) : Colors.white,
                overlayColor: darkMode ? const Color(0xff00256a) : Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 28.0),
              ),
            ),
            if (!loadingState)
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      darkMode ? const Color(0xffdcdcdc) : Colors.black54,
                ),
                child: Text('Send feedback'),
              ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkMode ? const Color(0xff141414) : Colors.white,
      body: Center(
        child:
            _widget ??
            CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation<Color>(
                darkMode ? const Color(0xffa9cdff) : const Color(0xff0050dc),
              ),
            ),
      ),
    );
  }
}
