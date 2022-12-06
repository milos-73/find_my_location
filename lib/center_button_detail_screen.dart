import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';



class CenterMapButtonOnMarkerDetailScreen extends StatefulWidget {

  final bool mini;
  final double padding;
  final Alignment alignment;
  final Color? centerColor;
  final Color? centerColorIcon;
  final IconData centerIcon;
  final MapController mapControler;
  final double? latitude;
  final double? longitude;


  const CenterMapButtonOnMarkerDetailScreen({
    super.key,

    this.mini = true,
    this.padding = 2.0,
    this.alignment = Alignment.topRight,
    this.centerColor,
    this.centerColorIcon,
    this.centerIcon = Icons.center_focus_strong_outlined,
    required this.mapControler,
    this.latitude,
    this.longitude,   });

  @override
  State<CenterMapButtonOnMarkerDetailScreen> createState() => _CenterMapButtonOnMarkerDetailScreenState();
}

class _CenterMapButtonOnMarkerDetailScreenState extends State<CenterMapButtonOnMarkerDetailScreen> {
  final FitBoundsOptions options = const FitBoundsOptions(padding: EdgeInsets.all(12));

  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    LatLng? markerLatLng = LatLng(widget.latitude ?? 0, widget.longitude ?? 0);
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
              backgroundColor: widget.centerColor ?? Theme.of(context).primaryColor,
              onPressed: () {
                widget.mapControler.move(LatLng(widget.latitude ?? 0,widget.longitude ?? 0),widget.mapControler.zoom);
              },
              child: FaIcon(FontAwesomeIcons.arrowsToDot,
                  color: widget.centerColorIcon ?? IconTheme.of(context).color),
            ),
          ),
        ],
      ),
    );
  }
}

