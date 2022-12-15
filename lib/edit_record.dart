import 'dart:ui';

import 'package:find_me/markers_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';

class EditRecord extends StatefulWidget {
   final int index;
   final MyMarkers marker;
   final double? markerLat;
   final double? markerLong;
   MapController mapController;

  EditRecord({Key? key, required this.index, required this.marker, required this.mapController,this.markerLong,this.markerLat}) : super(key: key);

  @override
  State<EditRecord> createState() => _EditRecordState();
}

class _EditRecordState extends State<EditRecord> {

  bool isLoading = false;
  late Box<MyMarkers> myMarkersBox;
  late final MapController _mapController3;

  TextEditingController nameController = TextEditingController();
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  TextEditingController altitudeController = TextEditingController();
  TextEditingController accuracyController = TextEditingController();
  TextEditingController streetController = TextEditingController();
  TextEditingController townController = TextEditingController();
  TextEditingController countyController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController zipController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();


  @override
  void initState() {
    super.initState();
   setState((){isLoading = true;});
    myMarkersBox = Hive.box('myMarkersBox');
    _mapController3 = MapController();

    setState((){nameController.text = widget.marker.name!;});
    setState((){latitudeController.text = '${widget.marker.lat}';});
    setState((){longitudeController.text = '${widget.marker.long}';});
    setState((){accuracyController.text = '${widget.marker.accuracy}';});
    setState((){altitudeController.text = '${widget.marker.altitude}';});
    setState((){streetController.text = widget.marker.street!;});
    setState((){townController.text = widget.marker.city!;});
    setState((){countyController.text = widget.marker.county!;});
    setState((){stateController.text = widget.marker.state!;});
    setState((){zipController.text = widget.marker.zip!;});
    setState((){descriptionController.text = widget.marker.description!;});
  }

@override
  Widget build(BuildContext context) {

    return Scaffold(backgroundColor: HexColor('#d8ded5'),
      floatingActionButton: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: FloatingActionButton.extended(onPressed: () {
               Navigator.pop(context);
     }, label: Row(children: const [FaIcon(FontAwesomeIcons.x), SizedBox(width: 5,),Text('Cancel')],),backgroundColor: Colors.red,splashColor: HexColor('#D99E6A'),heroTag: 'cancelButton',),
          ),
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FloatingActionButton.extended(onPressed: () {
              final newMarker = MyMarkers(dateTime: DateTime.now(), name: nameController.text, description: descriptionController.text, lat: double.parse(latitudeController.text) , long: double.parse(longitudeController.text), altitude: double.parse(altitudeController.text), accuracy: double.parse(accuracyController.text), street: streetController.text, city: townController.text, county: countyController.text, state: stateController.text,zip: zipController.text);
              myMarkersBox.putAt(widget.index, newMarker);
              Navigator.pop(context);
            }, label: Row(children: const [FaIcon(FontAwesomeIcons.floppyDisk), SizedBox(width: 5,),Text('Save')],),backgroundColor: HexColor('#0468BF'),splashColor: HexColor('#D99E6A'),heroTag: 'saveButton',),
          ),

        ],
      ),
      body: FlutterMap(
          mapController: _mapController3,
          options: MapOptions(
            center: LatLng(widget.markerLat!, widget.markerLong!),
            zoom: 12,
            interactiveFlags: InteractiveFlag.none,
          ),
          nonRotatedChildren: [
        ClipRect(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(color: Colors.white.withOpacity(0.3), height: MediaQuery.of(context).size.height, width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(decoration: InputDecoration(filled: true,fillColor: HexColor('#b1bdab').withOpacity(0.4),focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20),borderSide: BorderSide(color: HexColor('#D99E6A'))),border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),labelText: 'Name', labelStyle: TextStyle(color: HexColor('#8C4332'),fontSize: 20,fontWeight: FontWeight.w600),hintStyle: const TextStyle(color: Colors.white70)),controller: nameController,),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(decoration: InputDecoration(filled: true,fillColor: HexColor('#b1bdab').withOpacity(0.4),focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20),borderSide: BorderSide(color: HexColor('#D99E6A'))),border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),labelText: 'Latitude', labelStyle: TextStyle(color: HexColor('#8C4332'),fontSize: 20,fontWeight: FontWeight.w600),hintStyle: const TextStyle(color: Colors.white70)),controller: latitudeController,),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(decoration: InputDecoration(filled: true,fillColor: HexColor('#b1bdab').withOpacity(0.4),focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20),borderSide: BorderSide(color: HexColor('#D99E6A'))),border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),labelText: 'Longitude', labelStyle: TextStyle(color: HexColor('#8C4332'),fontSize: 20,fontWeight: FontWeight.w600),hintStyle: const TextStyle(color: Colors.white70)),controller: longitudeController,),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(decoration: InputDecoration(filled: true,fillColor: HexColor('#b1bdab').withOpacity(0.4),focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20),borderSide: BorderSide(color: HexColor('#D99E6A'))),border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),labelText: 'Altitude', labelStyle: TextStyle(color: HexColor('#8C4332'),fontSize: 20,fontWeight: FontWeight.w600),hintStyle: const TextStyle(color: Colors.white70)),controller: altitudeController,),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(decoration: InputDecoration(filled: true,fillColor: HexColor('#b1bdab').withOpacity(0.4),focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20),borderSide: BorderSide(color: HexColor('#D99E6A'))),border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),labelText: 'Accuracy', labelStyle: TextStyle(color: HexColor('#8C4332'),fontSize: 20,fontWeight: FontWeight.w600),hintStyle: const TextStyle(color: Colors.white70)),controller: accuracyController,),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(decoration: InputDecoration(filled: true,fillColor: HexColor('#b1bdab').withOpacity(0.4),focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20),borderSide: BorderSide(color: HexColor('#D99E6A'))),border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),labelText: 'Street', labelStyle: TextStyle(color: HexColor('#8C4332'),fontSize: 20,fontWeight: FontWeight.w600),hintStyle: const TextStyle(color: Colors.white70)),controller: streetController,),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(decoration: InputDecoration(filled: true,fillColor: HexColor('#b1bdab').withOpacity(0.4),focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20),borderSide: BorderSide(color: HexColor('#D99E6A'))),border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),labelText: 'Town', labelStyle: TextStyle(color: HexColor('#8C4332'),fontSize: 20,fontWeight: FontWeight.w600),hintStyle: const TextStyle(color: Colors.white70)),controller: townController,),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(decoration: InputDecoration(filled: true,fillColor: HexColor('#b1bdab').withOpacity(0.4),focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20),borderSide: BorderSide(color: HexColor('#D99E6A'))),border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),labelText: 'County', labelStyle: TextStyle(color: HexColor('#8C4332'),fontSize: 20,fontWeight: FontWeight.w600),hintStyle: const TextStyle(color: Colors.white70)),controller: countyController,),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(decoration: InputDecoration(filled: true,fillColor: HexColor('#b1bdab').withOpacity(0.4),focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20),borderSide: BorderSide(color: HexColor('#D99E6A'))),border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),labelText: 'State', labelStyle: TextStyle(color: HexColor('#8C4332'),fontSize: 20,fontWeight: FontWeight.w600),hintStyle: const TextStyle(color: Colors.white70)),controller: stateController,),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(decoration: InputDecoration(filled: true,fillColor: HexColor('#b1bdab').withOpacity(0.4),focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20),borderSide: BorderSide(color: HexColor('#D99E6A'))),border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),labelText: 'Postal Code', labelStyle: TextStyle(color: HexColor('#8C4332'),fontSize: 20,fontWeight: FontWeight.w600),hintStyle: const TextStyle(color: Colors.white70)),controller: zipController,),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(decoration: InputDecoration(filled: true,fillColor: HexColor('#b1bdab').withOpacity(0.4),focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20),borderSide: BorderSide(color: HexColor('#D99E6A'))),border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),labelText: 'Notes', labelStyle: TextStyle(color: HexColor('#8C4332'),fontSize: 20,fontWeight: FontWeight.w600),hintStyle: const TextStyle(color: Colors.white70)),controller:descriptionController,minLines: 1,maxLines: 3,),
                    ),
                                   ],),
                ),
              ),
            ),
          ),
        ),
    ),
      ],children: [
        TileLayer(
          urlTemplate:
          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'dev.fleaflet.flutter_map.example',
        ),
      ],
      ),
    );
  }
}
