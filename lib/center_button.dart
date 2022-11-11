import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator_platform_interface/src/models/position.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import 'current_location.dart';
import 'live_location.dart';
import 'marker_provider.dart';

class CenterMapButtons extends StatefulWidget {

  final bool mini;
  final double padding;
  final Alignment alignment;
  final Color? zoomInColor;
  final Color? zoomInColorIcon;
  final Color? zoomOutColor;
  final Color? zoomOutColorIcon;
  final IconData zoomInIcon;
  final IconData zoomOutIcon;
  final MapController mapControler;
  final Position? currentLocation;


  const CenterMapButtons({
    super.key,

    this.mini = true,
    this.padding = 2.0,
    this.alignment = Alignment.topRight,
    this.zoomInColor,
    this.zoomInColorIcon,
    this.zoomInIcon = Icons.center_focus_strong_outlined,
    this.zoomOutColor,
    this.zoomOutColorIcon,
    this.zoomOutIcon = Icons.zoom_out,
    required this.mapControler,
    this.currentLocation,
  });

  @override
  State<CenterMapButtons> createState() => _CenterMapButtonsState();
}

class _CenterMapButtonsState extends State<CenterMapButtons> {
  final FitBoundsOptions options = const FitBoundsOptions(padding: EdgeInsets.all(12));
  Position? currentLocation;




  @override
  void initState() {
    super.initState();
                 }


  @override
  Widget build(BuildContext context) {
    //final map = FlutterMapState.maybeOf(context)!;
    return Align(
      alignment: widget.alignment,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(widget.padding),
            child: FloatingActionButton(
              heroTag: 'centerButton',
              mini: widget.mini,
              backgroundColor: widget.zoomOutColor ?? Theme.of(context).primaryColor,
              onPressed: () {
                getCurrentLocationGlobal(context)
                    .then((value) => setState((){currentLocation = value;}))
                    .then((value) => Provider.of<MarkerProvider>(context,listen: false).SetMarker(currentLocation))
                    .then((value) => widget.mapControler.move(LatLng(currentLocation!.latitude,currentLocation!.longitude),widget.mapControler.zoom));
                //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  LiveLocationPage()),);
               },
              child: FaIcon(FontAwesomeIcons.arrowsToDot,
                  color: widget.zoomOutColorIcon ?? IconTheme.of(context).color),
            ),
          ),
        ],
      ),
    );
  }
}
