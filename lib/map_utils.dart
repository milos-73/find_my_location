import 'package:url_launcher/url_launcher.dart';

class MapUtils {

  //MapUtils._();
  Future<void> openMap(double? currentLat, double? currentLng, double? latitude, double? longitude) async {

    double currentPositionLat = currentLat ?? 49.1645;
    double currentPositionLng = currentLng ?? 20.2823;

    //String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    ///Opens direction screen
    var uri = Uri.parse("https://www.google.com/maps/dir/?api=1&origin=$currentPositionLat,$currentPositionLng&destination=$latitude,$longitude&mode=w},");

    ///Opens Navigation screen by car
    //var uri = Uri.parse("google.navigation:q=$latitude,$longitude&mode=d");

    if (await canLaunch(uri.toString())) {
      await launch(uri.toString());
    } else {
      throw 'Could not open the map.';
    }
  }
}