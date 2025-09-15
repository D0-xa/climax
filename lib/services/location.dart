import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';

bool serviceActive = true;

class LocationService {
  LocationService(this.context);

  final BuildContext context;

  Future<Position?> getCurrentPosition() async {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.medium,
      distanceFilter: 100,
      timeLimit: Duration(seconds: 15),
    );

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      ).then((value) async {
        serviceActive = await isServiceEnabled();
        return value;
      });
    } on PermissionDeniedException {
      await Future.delayed(Duration(seconds: 1));
      _grantAccess();
    } on LocationServiceDisabledException {
      _showSnackbar("Can't update your location");
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(e.toString());
        debugPrintStack(stackTrace: stackTrace, label: 'Stack trace');
      }
    }
    serviceActive = false;
    return null;
  }

  Future<void> _grantAccess() {
    return showAdaptiveDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog.adaptive(
          title: Text('Grant "Climax" Location access'),
          content: Text(
            'Your current approximate location will be displayed and used to get weather conditions.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await Geolocator.openAppSettings();
              },
              child: Text("Turn on"),
            ),
          ],
        );
      },
    );
  }

  void _showSnackbar(String text) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        margin: EdgeInsets.all(20),
        action: SnackBarAction(
          label: 'Turn on',
          onPressed: () async {
            await Geolocator.openLocationSettings();
          },
        ),
      ),
    );
  }
}

Future<bool> isServiceEnabled() async {
  return await Geolocator.isLocationServiceEnabled();
}
