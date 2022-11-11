import 'package:flutter/src/widgets/framework.dart';
import 'package:geolocator/geolocator.dart';

import 'alert_gps_permition_massage.dart';


AlertDialogs alertDialogs = AlertDialogs();

///Get current location and return it in position variable.
///In case of error (gps not awailable or indors) return null.

Future<Position?> getCurrentLocationGlobal(BuildContext context) async {
  bool serviceEnabled;
  LocationPermission permission;
  print('in current location');

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    print('Location services are disabled.');
    await alertDialogs.showLocationAlertDialogToAnableLocationServices(context);
    //return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      print('Location permissions are denied');
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    print('Location permissions are permanently denied, we cannot request permissions.');
    await alertDialogs.showLocationAlertDialogForLocationPermitions(context);
    // return Future.error(
    //     'Location permissions are permanently denied, we cannot request permissions.');

  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  try {
    Position? position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        forceAndroidLocationManager: true,
        timeLimit: Duration(seconds: 10));
    print('POZÍCIA: ${position}');
    return position;
  } on Exception catch (e) {
    await alertDialogs.showLocationAlertDialogGPSNotWorking(context);
    return null;
  }
}
