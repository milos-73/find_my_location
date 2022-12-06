import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MarkerProvider with ChangeNotifier{

  //Position? currentLocation;
 LatLng? currentLatLng = LatLng(0,0);

  void SetMarker(Position? currentLocation){
    currentLatLng = LatLng(currentLocation!.latitude, currentLocation.longitude);
    notifyListeners();
  }
}