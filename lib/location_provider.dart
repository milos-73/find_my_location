import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider with ChangeNotifier{

  Position? currentPosition;

  void setLocation(Position? value){
    currentPosition = value;

    notifyListeners();
  }
}