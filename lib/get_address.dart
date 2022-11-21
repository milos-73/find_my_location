import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class MarkerAddress {


  Future<String?> getStreet(Position currentLocation) async {
    String? streetName;
    await placemarkFromCoordinates(currentLocation.latitude, currentLocation.longitude).then((List<Placemark> placemarks) {Placemark place = placemarks[0];
    streetName = place.street;
         });return streetName;
  }

  Future<String?> getTown(Position currentLocation) async {
    String? townName;
    await placemarkFromCoordinates(currentLocation.latitude, currentLocation.longitude).then((List<Placemark> placemarks) {Placemark place = placemarks[0];
    townName = place.locality;
    });return townName;
  }

  Future<String?> getCounty(Position currentLocation) async {
    String? countyName;
    await placemarkFromCoordinates(currentLocation.latitude, currentLocation.longitude).then((List<Placemark> placemarks) {Placemark place = placemarks[0];
    countyName = place.subLocality;
    });return countyName;
  }

  Future<String?> getState(Position currentLocation) async {
    String? stateName;
    await placemarkFromCoordinates(currentLocation.latitude, currentLocation.longitude).then((List<Placemark> placemarks) {Placemark place = placemarks[0];
    stateName = place.subAdministrativeArea;
    });return stateName;
  }

  Future<String?> getZip(Position currentLocation) async {
    String? zipName;
    await placemarkFromCoordinates(currentLocation.latitude, currentLocation.longitude).then((List<Placemark> placemarks) {Placemark place = placemarks[0];
    zipName = place.postalCode;
    });return zipName;
  }


}
