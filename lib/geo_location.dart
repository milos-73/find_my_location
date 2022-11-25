import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'alert_gps_permition_massage.dart';

final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
AlertDialogs alertDialogs = AlertDialogs();

class GeoLocations {


  Future<Position?> getCurrentPosition(BuildContext context) async {
    final hasPermission = await handlePermission(context);

    if (!hasPermission) {
      return null;
    }

    try {
      final position = await _geolocatorPlatform.getCurrentPosition();
         print(position);
         return position;
    } on Exception catch (e) {
      await alertDialogs.showLocationAlertDialogGPSNotWorking(context);
      return null;
    }

  }

  Future<bool> handlePermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      print('Location services are disabled.');
      await alertDialogs.showLocationAlertDialogToAnableLocationServices(context);

      return false;
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        print('Permission denied.');

        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      print('Permission denied forever.');


      return false;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    print('Permission granted.');
    return true;
  }


}