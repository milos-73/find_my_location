import 'package:find_me/zoombuttons_plugin_option.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:latlong2/latlong.dart';
import 'center_button_detail_screen.dart';

class MarkerDetails extends StatefulWidget {

  final double? latitude;
  final double? longitude;
  final MapController mapControler;

  MarkerDetails({Key? key, this.latitude, this.longitude, required this.mapControler}) : super(key: key);

  @override
  State<MarkerDetails> createState() => _MarkerDetailsState();
}

class _MarkerDetailsState extends State<MarkerDetails> {
  late final MapController _mapController3;

  @override
  void initState() {
    super.initState();

    _mapController3 = MapController();
      }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(child: Column(
          children: [
            Container(width: MediaQuery.of(context).size.width, height: 400,
              child: FlutterMap(mapController:_mapController3, options: MapOptions( center: LatLng(widget.latitude ?? 0, widget.longitude ?? 0),zoom: 10,interactiveFlags: InteractiveFlag.drag,),children: [
                TileLayer(
                  urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                ),
                FlutterMapZoomButtons(minZoom: 4, maxZoom: 19, mini: true, padding: 10, alignment: Alignment.bottomLeft,zoomInColor: HexColor('#049DBF'),zoomOutColor:  HexColor('#049DBF'),),
                CenterMapButtonOnMarkerDetailScreen(mini: true, padding: 10, alignment: Alignment.bottomRight, mapControler: _mapController3, latitude: widget.latitude, longitude: widget.longitude, centerColor: HexColor('#0468BF'),),
                MarkerLayer(rotate: true, rotateAlignment: Alignment.bottomCenter, markers: [
                  Marker(width: 150,height: 150,point: LatLng(widget.latitude ?? 0, widget.longitude ?? 0), builder: (ctx) => const Icon(Icons.location_pin, color: Colors.red,))
                ],)
              ],

              ),)
          ],
        ),));
  }
}
