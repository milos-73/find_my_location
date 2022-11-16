import 'dart:ui';

import 'package:find_me/marker_provider.dart';
import 'package:find_me/widgets/drawer.dart';
import 'package:find_me/zoombuttons_plugin_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';
import 'package:latlong_to_osgrid/latlong_to_osgrid.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';


import 'center_button.dart';
import 'current_location.dart';
import 'markers_model.dart';
import 'my_markers_list.dart';


class LiveLocationPage extends StatefulWidget {
  static const String route = '/live_location';

  const LiveLocationPage({Key? key}) : super(key: key);

  @override
  _LiveLocationPageState createState() => _LiveLocationPageState();
}

class _LiveLocationPageState extends State<LiveLocationPage> {

  //LocationData? _currentLocation;
  late final MapController _mapController;
  late final MapController _mapController2;
  Position? currentLocation;
  String? currentAddress;
  String? currentStreet;
  String? currentTown;
  String? currentCounty;
  String? currentPostalCode;
  String? currentState;
  List<num>? latDms;
  List<num>? longDms;


  int interActiveFlags = InteractiveFlag.all;


  //final Location _locationService = Location();
  LatLongConverter converter = LatLongConverter();


  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _mapController2 = MapController();
    getCurrentLocationGlobal(context)
        .then((value) => setState((){currentLocation = value;}))
        .then((value) => Provider.of<MarkerProvider>(context,listen: false).SetMarker(currentLocation))
        .then((value) => _getAddressFromLatLng(currentLocation!))
        .then((value) => setState((){latDms = converter.getDegreeFromDecimal(currentLocation!.latitude);}))
        .then((value) => setState((){longDms = converter.getDegreeFromDecimal(currentLocation!.longitude);}))
    .then((value) =>  initLocationService());

  }

  void initLocationService() async {

 if (currentLocation != null) {_mapController2.move(LatLng(currentLocation!.latitude,currentLocation!.longitude),_mapController2.zoom); _mapController.move(LatLng(currentLocation!.latitude,currentLocation!.longitude),_mapController.zoom);}

  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
        currentLocation!.latitude, currentLocation!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() { currentAddress = '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
      currentStreet = '${place.street}'; currentTown = '${place.locality}';currentCounty = '${place.subAdministrativeArea}';currentPostalCode = '${place.postalCode}';currentState = '${place.country}';
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }


  void addMyMarker(MyMarkers myMarker) {
    final myMarkersBox = Hive.box('myMarkersBox');
    myMarkersBox.add(myMarker);

  }


  @override
  Widget build(BuildContext context) {
    LatLng currentLatLng;

    if (currentLocation != null) {
      currentLatLng = LatLng(currentLocation!.latitude, currentLocation!.longitude);
    } else {
      currentLatLng = LatLng(0, 0);
    }


    return Scaffold(
      resizeToAvoidBottomInset: false,
      //appBar: AppBar(title: const Text('Home')),
      drawer: buildDrawer(context, LiveLocationPage.route),
      body: Container(height: MediaQuery.of(context).size.height, width: MediaQuery.of(context).size.width,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: LatLng(currentLatLng.latitude, currentLatLng.longitude),
                zoom: 12,
                interactiveFlags: InteractiveFlag.none,
              ),
              nonRotatedChildren: [
                ClipRect(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(color: Colors.white.withOpacity(0.3), height: MediaQuery.of(context).size.height, width: MediaQuery.of(context).size.width,
        child: Center(
          child: SingleChildScrollView(
            child: Stack(alignment: Alignment.topCenter,children: [


              Container(
                alignment: const Alignment(0,1),
                child:


                    Column(mainAxisSize: MainAxisSize.min
                      ,
                      children: [

                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20,right: 20),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(onPressed: (){showDialog(context: context, builder: (ctx) => AlertDialog(
                                  title: Text('add the Point to My List'),
                                  content: Column(children: [
                                    Text('${currentLocation?.latitude}'),
                                    Text('${currentLocation?.longitude}'),
                                    Text('${currentLocation?.altitude}'),
                                    Text('${currentLocation?.accuracy}'),
                                    Text('$currentStreet'),
                                    Text('$currentTown'),
                                    Text('$currentCounty'),
                                    Text('$currentState'),
                                    Text('$currentPostalCode'),
                                    Text('$latDms'),
                                    Text('$longDms'),
                                    Text('${latDms![0]}'),
                                    Text('${longDms![0]}'),
                                  ],),
                                  actions: <Widget>[
                                    TextButton(onPressed: (){
                                      final newMarker = MyMarkers(dateTime: DateTime.now(), name: '$currentTown', description: 'description', lat: currentLocation?.latitude, long: currentLocation?.longitude, altitude: currentLocation?.altitude, accuracy: currentLocation?.accuracy, street: '$currentStreet', city: '$currentTown', county: '$currentCounty', state: '$currentState',zip: '$currentPostalCode');
                                      addMyMarker(newMarker);
                                      Navigator.of(ctx).pop();
                                      }, child: Container(color: Colors.green, padding: EdgeInsets.all(14), child: Text('OK'),)),

                                    
                                  ],
                                ));

                                  








                                }, child: Column(children: const [FaIcon(FontAwesomeIcons.heartCirclePlus, color: Colors.red,size: 40,), Text('Save Position')],)),
                                TextButton(onPressed: (){}, child: Column(children: const [FaIcon(FontAwesomeIcons.shareNodes, color: Colors.red,size: 40,), Text('Share Current')],)),
                                TextButton(onPressed: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => MyMarkersList()));


                                }, child: Column(children: const [FaIcon(FontAwesomeIcons.bars, color: Colors.red,size: 40,), Text('My List')],)),
                                //ElevatedButton.icon(  label: const Text('Uložiť polohu'), icon: const FaIcon(FontAwesomeIcons.plus, size: 30,), onPressed: () {  }, style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent ) ,),
                                //ElevatedButton.icon(  label: const Text('Uložiť polohu'), icon: const FaIcon(FontAwesomeIcons.heartCirclePlus,color: Colors.red, size: 25,), onPressed: () {  }, style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent ))



                            ],),
                          ),
                        ),

                        Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(width: MediaQuery.of(context).size.width*0.8, alignment: Alignment.topLeft, height: 65, margin: EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(color: Colors.amber,border: Border.all(color: Colors.green,width: 4, style: BorderStyle.solid),
                                  borderRadius: BorderRadius.circular(15),boxShadow: const [BoxShadow (color: Colors.black54, offset: Offset(3, 3), blurRadius: 4, spreadRadius: 2)]),
                              child: SingleChildScrollView(scrollDirection: Axis.horizontal,
                                child: Stack(children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
                                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        const Text('Lat', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),),
                                        const Padding(
                                          padding: EdgeInsets.only(left: 3, right: 3),
                                          child: VerticalDivider(color: Colors.black, thickness: 1,),
                                        ),
                                        Column (mainAxisAlignment: MainAxisAlignment.spaceAround, crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("${latDms?[0]}° ${latDms?[1]}' ${latDms?[2].toString().substring(0,7)}\"",style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),),
                                            Text('${currentLocation?.latitude ?? 0.0}',style: const TextStyle(fontSize: 14),),
                                          ],
                                        ),
                                        const SizedBox(width: 20,),
                                        Padding(
                                          padding: const EdgeInsets.only(right: 12),
                                          child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,  children: [
                                            const Center(child: FaIcon(FontAwesomeIcons.mountainSun)),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4),
                                              child: Text('${currentLocation?.altitude}'),
                                            )],),
                                        )
                                      ],
                                    ),
                                  ),]),
                              ),),
                          ],
                        ),



                        Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(width: MediaQuery.of(context).size.width*0.8, alignment: Alignment.topLeft, height: 65, margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(color: Colors.amber,border: Border.all(color: Colors.green,width: 4, style: BorderStyle.solid),
                                  borderRadius: BorderRadius.circular(15),boxShadow: const [BoxShadow (color: Colors.black54, offset: Offset(3, 3), blurRadius: 4, spreadRadius: 2)]),
                              child: SingleChildScrollView(scrollDirection: Axis.horizontal,
                                child: Stack(children: [Padding(
                                  padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
                                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [const Text('Long', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),),
                                      const Padding(
                                        padding: EdgeInsets.only(left: 3, right: 3),
                                        child: VerticalDivider(color: Colors.black, thickness: 1,),
                                      ),
                                      Column (mainAxisAlignment: MainAxisAlignment.spaceAround, crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("${longDms?[0]}° ${longDms?[1]}' ${longDms?[2].toString().substring(0,7)}\"",style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),),
                                          Text('${currentLocation?.longitude ?? 0.0}',style: const TextStyle(fontSize: 14),),

                                        ],
                                      ),
                                      const SizedBox(width: 20,),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 12),
                                        child: Column(mainAxisAlignment: MainAxisAlignment.center,  children: [
                                          const Center(child: FaIcon(FontAwesomeIcons.rulerHorizontal)),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Text('${currentLocation?.accuracy}'),
                                          ),
                                        ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                ],
                                ),
                              ),
                            ),
                          ],
                        ),



                        Row(
                          children: [
                            Container(height: 300 ,width: MediaQuery.of(context).size.width, alignment: Alignment.center, margin: const EdgeInsets.only(bottom: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(elevation: 3, color: Colors.black.withAlpha(140), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: FlutterMap(
                                      mapController: _mapController2,
                                      options: MapOptions(
                                        center: LatLng(currentLatLng.latitude, currentLatLng.longitude),
                                        zoom: 12,
                                        interactiveFlags: InteractiveFlag.all,
                                      ),
                                      children: [
                                        TileLayer(
                                          urlTemplate:
                                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                          userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                                        ),
                                        const FlutterMapZoomButtons(minZoom: 4, maxZoom: 19, mini: true, padding: 10, alignment: Alignment.bottomLeft,),
                                        CenterMapButtons(mini: true, padding: 10, alignment: Alignment.bottomRight, mapControler: _mapController2, currentLocation: currentLocation),
                                        Consumer<MarkerProvider>(builder: (context,value,child){ return MarkerLayer(markers: [Marker(width: 150, height: 150,point: Provider.of<MarkerProvider>(context).currentLatLng!, builder: (ctx) => Icon(Icons.location_pin, color: Colors.red,))]);}),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                       Row(mainAxisAlignment: MainAxisAlignment.center, children: [ Container(margin: const EdgeInsets.only(bottom: 25),
                         child:
                          Column(
                           children: [
                             Text('$currentStreet',style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w400),),
                             Text('$currentPostalCode ${currentTown}',style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                             Text('$currentCounty, $currentState ',style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w300),),
                             // Text('$currentCounty',style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w300)),
                             // Text('$currentState',style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w300)),

                           ],
                         ),
                         )],),



                        Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(width: MediaQuery.of(context).size.width,alignment: Alignment.center, height: 80, margin: const EdgeInsets.only(bottom: 25),
                                decoration: const ShapeDecoration(
                                    shadows: [
                                      BoxShadow (color: Colors.black54, offset: Offset(2, 0), blurRadius: 3, spreadRadius: 2)
                                    ],
                                    shape: CircleBorder(
                                        side: BorderSide(width: 7, color: Colors.lightGreen)),
                                    color: Colors.red),
                                child: Stack(alignment: Alignment.center, children: [
                                  Column(mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text('SEND',style: TextStyle(color: Colors.white, fontSize: 20),),
                                    Text('sms',style: TextStyle(color: Colors.white70),),
                                  ],
                                ),],)),
                          ],
                        ),
                      ],
                    ),



                ) ,










                    ],),
          ),
        ),
                  ),
                ),
                )



              ],
              children: [
                TileLayer(
                  urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                ),
                //MarkerLayer(markers: markers),
              ],
            ),
          ),

    );
  }
}
