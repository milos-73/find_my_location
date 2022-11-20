import 'dart:async';
import 'dart:ui';

import 'package:find_me/marker_provider.dart';
import 'package:find_me/widgets/drawer.dart';
import 'package:find_me/zoombuttons_plugin_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';
import 'package:latlong_to_osgrid/latlong_to_osgrid.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';


import 'center_button.dart';
import 'current_location.dart';
import 'geo_location.dart';
import 'location_provider.dart';
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
  late Box<MyMarkers> myMarkersBox;
  Position? currentLocation;
  String? currentAddress;
  String? currentStreet;
  String? currentTown;
  String? currentCounty;
  String? currentPostalCode;
  String? currentState;
  List<num>? latDms;
  List<num>? longDms;

  bool isLoading = false;

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

      int interActiveFlags = InteractiveFlag.all;


  //final Location _locationService = Location();

  LatLongConverter converter = LatLongConverter();
  GeoLocations geolocations = GeoLocations();

  @override
  void initState() {
    super.initState();
    myMarkersBox = Hive.box('myMarkersBox');
        setState((){isLoading = true;});

    _mapController = MapController();
    _mapController2 = MapController();
    geolocations.getCurrentPosition()
    //getCurrentLocationGlobal(context)
        .then((value) => setState((){currentLocation = value;}))
        .then((value) => Provider.of<MarkerProvider>(context,listen: false).SetMarker(currentLocation))
        .then((value) => _getAddressFromLatLng(currentLocation!))
        .then((value) => setState((){latDms = converter.getDegreeFromDecimal(currentLocation!.latitude);}))
        .then((value) => setState((){longDms = converter.getDegreeFromDecimal(currentLocation!.longitude);}))
    .then((value) =>  initLocationService()).then((value) => setState((){isLoading = false;}))
        .then((value) => setState((){nameController.text = currentTown!;}))
        .then((value) => setState((){latitudeController.text = '${currentLocation?.latitude}';}))
        .then((value) => setState((){longitudeController.text = '${currentLocation?.longitude}';}))
        .then((value) => setState((){accuracyController.text = '${currentLocation?.accuracy}';}))
        .then((value) => setState((){altitudeController.text = '${currentLocation?.altitude}';}))
        .then((value) => setState((){streetController.text = currentStreet!;}))
        .then((value) => setState((){townController.text = currentTown!;}))
        .then((value) => setState((){countyController.text = currentCounty!;}))
        .then((value) => setState((){stateController.text = currentState!;}))
        .then((value) => setState((){zipController.text = currentPostalCode!;}))
        .then((value) => setState((){descriptionController.text = '';}));
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    nameController.dispose();
    super.dispose();
  }

  void locationUpdate(){

    StreamSubscription<ServiceStatus> serviceStatusStream = Geolocator.getServiceStatusStream().listen(
            (ServiceStatus status) {
          print(status);
        });
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


                    Consumer<LocationProvider>(builder: (context,value,child) {return
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
                                    title: const Text('add the Point to My List'),
                                    content: SingleChildScrollView(
                                      child: Column(children: [
                                        TextFormField(decoration: const InputDecoration(labelText: 'Name',),controller: nameController,),
                                        TextFormField(decoration: const InputDecoration(labelText: 'Latitude',),controller: latitudeController),
                                        TextFormField(decoration: const InputDecoration(labelText: 'Longitude',),controller:longitudeController),
                                        TextFormField(decoration: const InputDecoration(labelText: 'Altitude',),controller:altitudeController),
                                        TextFormField(decoration: const InputDecoration(labelText: 'Accuracy',),controller:accuracyController),
                                        TextFormField(decoration: const InputDecoration(labelText: 'Street',),controller: streetController),
                                        TextFormField(decoration: const InputDecoration(labelText: 'Town',),controller:townController),
                                        TextFormField(decoration: const InputDecoration(labelText: 'County',),controller:countyController),
                                        TextFormField(decoration: const InputDecoration(labelText: 'State',),controller:stateController),
                                        TextFormField(decoration: const InputDecoration(labelText: 'Postal Code',),controller:zipController),
                                        TextFormField(decoration: const InputDecoration(labelText: 'Notes',),controller:descriptionController,minLines: 1,maxLines: 3,),



                                      ],),
                                    ),
                                    actions: <Widget>[
                                      TextButton(onPressed: (){
                                        final newMarker = MyMarkers(dateTime: DateTime.now(), name: nameController.text, description: descriptionController.text, lat: double.parse(latitudeController.text) , long: double.parse(longitudeController.text), altitude: double.parse(altitudeController.text), accuracy: double.parse(accuracyController.text), street: streetController.text, city: townController.text, county: countyController.text, state: stateController.text,zip: zipController.text);
                                        addMyMarker(newMarker);
                                        Navigator.of(ctx).pop();
                                        }, child: Container(color: Colors.green, padding: const EdgeInsets.all(14), child: const Text('OK'),)),
                                    ],
                                  ),
                                  );
                                    }, child: Column(children: [FaIcon(FontAwesomeIcons.heartCirclePlus, color: HexColor('#8C4332'),size: 30,), Text('Save', style: TextStyle(color: HexColor('#0468BF')),)],)),
                                  TextButton(onPressed: (){}, child: Column(children: [FaIcon(FontAwesomeIcons.shareNodes, color: HexColor('#8C4332'),size: 30,), Text('Share', style: TextStyle(color: HexColor('#0468BF')))],)),
                                  TextButton(onPressed: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => MyMarkersList(currentLat: currentLocation?.latitude, currentLong: currentLocation?.longitude, mapController: _mapController,)));


                                  }, child: Column(children: [FaIcon(FontAwesomeIcons.solidBookmark, color: HexColor('#8C4332'),size: 30,), Text('My List', style: TextStyle(color: HexColor('#0468BF')))],)),
                                  ],
                              ),
                            ),
                          ),

                          Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(width: MediaQuery.of(context).size.width*0.85, alignment: Alignment.center, height: 65, margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(color: HexColor('#D99E6A').withOpacity(0.3),border: Border.all(color:HexColor('#3B592D'),width: 2, style: BorderStyle.solid),
                                    borderRadius: BorderRadius.circular(15),
                                    //boxShadow: [BoxShadow (color: Colors.black45, offset: const Offset(1, 1), blurRadius: 2, spreadRadius: 1)]
                                ),
                                child: SingleChildScrollView(scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width*0.7),
                                    child: Stack(children: [Padding(
                                      padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
                                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [const SizedBox(width: 45,child: Text('Lat', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),)),
                                          const Padding(
                                            padding: EdgeInsets.only(left: 3, right: 3),
                                            child: VerticalDivider(color: Colors.black, thickness: 1,),
                                          ),

                                          ConstrainedBox(
                                            constraints: const BoxConstraints(minWidth: 180),
                                            child: Column (mainAxisAlignment: MainAxisAlignment.spaceAround, crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                isLoading == true
                                                    ? const SizedBox(width: 10, height: 10,child: CircularProgressIndicator())

                                                    : latDms![0] > 0
                                                    ? Text("${latDms?[0]}° ${latDms?[1]}' ${latDms?[2].toString().substring(0,7)}\" ${currentLocation!.latitude < 0 ? 'S' : 'N'}",style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),)
                                                    : Text("${latDms?[0].toString().substring(1)}° ${latDms?[1]}' ${latDms?[2].toString().substring(0,7)}\" ${currentLocation!.latitude < 0 ? 'S' : 'N'}",style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),),
                                                Text('DD: ${(currentLocation?.latitude)?.abs().toStringAsFixed(9)}',style: const TextStyle(fontSize: 14),),

                                              ],
                                            ),
                                          ),

                                          Padding(
                                            padding: const EdgeInsets.only(left: 5, right: 10),
                                            child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end,  children: [
                                              const Center(child: FaIcon(FontAwesomeIcons.mountainSun)),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 4),
                                                child: Text('${currentLocation?.altitude.toStringAsFixed(2)}'),
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
                              )],
                          ),
                          Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(width: MediaQuery.of(context).size.width*0.85, alignment: Alignment.center, height: 65, margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(color: HexColor('#D99E6A').withOpacity(0.3),border: Border.all(color: HexColor('#3B592D'),width: 2, style: BorderStyle.solid),
                                    borderRadius: BorderRadius.circular(15),
                                    //boxShadow:const [BoxShadow (color: Colors.black54, offset: Offset(3, 3), blurRadius: 4, spreadRadius: 2)]
                                ),
                                child: SingleChildScrollView(scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width*0.7),
                                    child: Stack(children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
                                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [const SizedBox(width: 45,child: Text('Long', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),)),
                                            const Padding(
                                              padding: EdgeInsets.only(left: 3, right: 3),
                                              child: VerticalDivider(color: Colors.black, thickness: 1,),
                                            ),

                                            ConstrainedBox(
                                              constraints: const BoxConstraints(minWidth: 180),
                                              child: Column (mainAxisAlignment: MainAxisAlignment.spaceAround, crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  isLoading == true
                                                      ? const SizedBox(width: 10, height: 10,child: CircularProgressIndicator())

                                                      : longDms![0] > 0
                                                      ? Text("${longDms?[0]}° ${longDms?[1]}' ${longDms?[2].toString().substring(0,7)}\" ${currentLocation!.longitude < 0 ? 'W' : 'E'}",style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),)
                                                      : Text("${longDms?[0].toString().substring(1)}° ${longDms?[1]}' ${longDms?[2].toString().substring(0,7)}\" ${currentLocation!.longitude < 0 ? 'W' : 'E'}",style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),),
                                                  Text('DD: ${(currentLocation?.longitude)?.abs().toStringAsFixed(9)}',style: const TextStyle(fontSize: 14),),
                                                ],
                                              ),
                                            ),

                                            Padding(
                                              padding: const EdgeInsets.only(left: 5,right: 10),
                                              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                                                const Center(child: FaIcon(FontAwesomeIcons.ruler)),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 4),
                                                  child: Text('${currentLocation?.accuracy.toStringAsFixed(2)}'),
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
                                          FlutterMapZoomButtons(minZoom: 4, maxZoom: 19, mini: true, padding: 10, alignment: Alignment.bottomLeft,zoomInColor: HexColor('#049DBF'),zoomOutColor:  HexColor('#049DBF'),),
                                          CenterMapButtons(mini: true, padding: 10, alignment: Alignment.bottomRight, mapControler: _mapController2, currentLocation: currentLocation, centerColor: HexColor('#0468BF'),),
                                          Consumer<MarkerProvider>(builder: (context,value,child){ return MarkerLayer(markers: [Marker(width: 150, height: 150,point: Provider.of<MarkerProvider>(context).currentLatLng!, builder: (ctx) => Icon(Icons.location_pin, color: Colors.red,))]);}),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                         Row(mainAxisAlignment: MainAxisAlignment.center, children: [

                           Container(margin: const EdgeInsets.only(bottom: 25),
                           child:
                            Column(
                             children: [
                               Text('$currentStreet',style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w400),),
                               Text('$currentPostalCode $currentTown',style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                               Text('$currentCounty, $currentState ',style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w300),),
                               // Text('$currentCounty',style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w300)),
                               // Text('$currentState',style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w300)),

                             ],
                           ),
                           ),

                         ],),
                          Container(width: MediaQuery.of(context).size.width, height: 110, child:

                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Column(mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 70,height: 70,
                                      child:TextButton(onPressed: () {
                                        geolocations.getCurrentPosition()
                                            .then((value) => setState((){currentLocation = value;})).then((value) => print(currentLocation?.altitude))
                                            .then((value) => Provider.of<LocationProvider>(context,listen: false).setLocation(currentLocation)).then((value) => _getAddressFromLatLng(currentLocation!))
                                            .then((value) => Provider.of<MarkerProvider>(context,listen: false).SetMarker(currentLocation))
                                            .then((value) => _mapController2.move(LatLng(currentLocation!.latitude,currentLocation!.longitude),_mapController2.zoom))
                                            .then((value) => setState((){latDms = converter.getDegreeFromDecimal(currentLocation!.latitude);}))
                                            .then((value) => setState((){longDms = converter.getDegreeFromDecimal(currentLocation!.longitude);}));},
                              child: Column(
                                children: [
                            FaIcon(FontAwesomeIcons.arrowRotateLeft, color: HexColor('#8C4332'),size: 30,), Text('Refresh', style: TextStyle(color: HexColor('#0468BF'),fontSize: 15,height: 1.4))
                          ],),),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                           OutlinedButton(onPressed: () async {

                            Uri smsLaunchUri = Uri(
                                 scheme: 'sms',
                                 path: '+412911962817',
                                 queryParameters: {'body': Uri.encodeFull('http://maps.google.com/maps?z=12&t=m&q=loc:${currentLocation?.latitude}+${currentLocation?.longitude}')});
                            launchUrl(smsLaunchUri);
                            },



                           style: OutlinedButton.styleFrom(backgroundColor: HexColor('#D99E6A'),elevation: 15,side: BorderSide(color: HexColor('#3B592D'),width: 7),shape: const CircleBorder(),padding: const EdgeInsets.all(15) ), child:

                              Stack(alignment: Alignment.center, children: [
                                Column(mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Padding(
                                      padding: EdgeInsets.only(left: 6,right: 6,top: 6),
                                      child: Text('SEND',style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),),
                                    ),
                                    Text('sms',style: TextStyle(color: Colors.black45),),
                                  ],
                                ),],),

                           )
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [
                                  SizedBox(height: 70,  width: 70,child:
                                  Column(
                                  children: [
                                    Switch(value: false, activeColor: HexColor('#8C4332'),onChanged: (bool value) {  },),
                                  Text('Follow', style: TextStyle(color: HexColor('#0468BF'),height: 0.5,fontSize: 15))
                                  ],
                                ),)],),
                              )
                            ],),
                          ),
                          ),

                        ],
                      );}
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
