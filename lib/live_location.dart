import 'dart:async';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:find_me/marker_provider.dart';
import 'package:find_me/zoombuttons_plugin_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:latlong2/latlong.dart';
import 'package:latlong_to_osgrid/latlong_to_osgrid.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ad_helper_test.dart';
import 'ad_helper.dart';
import 'center_button.dart';
import 'geo_location.dart';
import 'get_address.dart';
import 'location_provider.dart';
import 'markers_model.dart';
import 'my_markers_list.dart';


class LiveLocationPage extends StatefulWidget {
  static const String route = '/live_location';

  const LiveLocationPage({Key? key}) : super(key: key);

  @override
  LiveLocationPageState createState() => LiveLocationPageState();
}

class LiveLocationPageState extends State<LiveLocationPage> {

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



  String? name;
  String? subLocality;
  String? administrativeArea;
  String? countryCode;

  double? accuracy;
  double? altitude;
  List<num>? latDms;
  List<num>? longDms;


  String? latDmsLocation;
  String? longDmsLocation;

  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  var currentLatLng = LatLng(0, 0);

  bool isLoading = false;
  bool isAddressLoading = false;
  bool wakelockEnable = false;
  bool isDeviceConnected = false;
  bool streamConnectionCheck = false;
  bool addressLookupError = false;
  bool showAddress = false;

  Future<void>? _launched;


  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusStreamSubscription;
  bool positionStreamStarted = false;


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

  TextEditingController subLocalityController = TextEditingController();
  TextEditingController administrativeAreaController = TextEditingController();
  TextEditingController countryCodeController = TextEditingController();

  int interActiveFlags = InteractiveFlag.all;

  //final Location _locationService = Location();

  LatLongConverter converter = LatLongConverter();
  GeoLocations geolocations = GeoLocations();
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  MarkerAddress markerAddress = MarkerAddress();

  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.mainScreen,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          //print(_isBannerAdReady);
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );

    _bannerAd.load();
  }

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    myMarkersBox = Hive.box('myMarkersBox');
    _toggleServiceStatusStream();
    setState((){isLoading = true;});
    setState((){isAddressLoading = true;});



    _mapController = MapController();
    _mapController2 = MapController();

    internetConnectivity().then((value) => setState((){isDeviceConnected = value;}))
        .then((value) => geolocations.getCurrentPosition(context))

        .then((value) => setState((){currentLocation = value;}))
        .then((value) => setState((){accuracy = currentLocation?.accuracy;}))
        .then((value) => setState((){altitude = currentLocation?.altitude;}))
        .then((value) => Provider.of<MarkerProvider>(context,listen: false).SetMarker(currentLocation))
        .then((value) => setState((){latDms = converter.getDegreeFromDecimal(currentLocation!.latitude);}))
        .then((value) => setState((){longDms = converter.getDegreeFromDecimal(currentLocation!.longitude);}))
        .then((value) => setState((){isLoading = false;})).then((value) => setState((){isAddressLoading = true;}))
        //.then((value) => setState((){isAddressLoading = true;}))

        //.then((value) => getDmsLat(latDms)).then((value) => getDmslon(longDms))
        .then((value) => setState((){isAddressLoading = false;}))
        .then((value) => isDeviceConnected == true ? _getAddressFromLatLng(currentLocation!) : setState((){addressLookupError = false;}))

        //.then((value) =>  internetConnectionError == false ? initLocationService() : print('Adress not loaded'))
        .then((value) =>   initLocationService())

        .then((value) => setState((){nameController.text = currentTown ?? '';}))
        .then((value) => setState((){latitudeController.text = '${currentLocation?.latitude}';}))
        .then((value) => setState((){longitudeController.text = '${currentLocation?.longitude}';}))
        .then((value) => setState((){accuracyController.text = '${currentLocation?.accuracy}';}))
        .then((value) => setState((){altitudeController.text = '${currentLocation?.altitude}';}))
        .then((value) => setState((){streetController.text = currentStreet ?? '';}))
        .then((value) => setState((){townController.text = currentTown ?? '';}))
        .then((value) => setState((){countyController.text = currentCounty ?? '';}))
        .then((value) => setState((){stateController.text = currentState ?? '';}))
        .then((value) => setState((){zipController.text = currentPostalCode ?? '';}))
        .then((value) => setState((){descriptionController.text = '';}))
        .then((value) => setState((){subLocalityController.text = subLocality ?? '';}))
        .then((value) => setState((){administrativeAreaController.text = administrativeArea ?? '';}))
        .then((value) => setState((){countryCodeController.text = countryCode ?? '';}))
    ;
  }

  Future<bool> internetConnectivity() async {

    var connectivityResult = await (Connectivity().checkConnectivity());
     var deviceConnection = true;

      if(connectivityResult == ConnectivityResult.mobile){
        deviceConnection = await InternetConnectionChecker().hasConnection;
      //print('Connected to Mobile');
        //print('$deviceConnection');
      //await alertDialogs.showconnectionStatusMessage(context,'mobile');

    }else if(connectivityResult == ConnectivityResult.wifi){
      //print('Connected to Wifi');
      //await alertDialogs.showconnectionStatusMessage(context,'wifi');
    }else{
      //print('no connection');
      await alertDialogs.showconnectionStatusMessage(context,'No internet connection. Please make sure you are connected to internet to load map and get the address of your location. Other application functionality is not affected by this.');
      return false;
    }
    return true;
  }

  // Future<void> internetConnectivity() async {
  //   var connectivityResult = await (Connectivity().checkConnectivity());
  //    print('Connected to Mobile');
  //     await alertDialogs.showconnectionStatusMessage(context,connectivityResult.toString() );
  // }

  void _toggleServiceStatusStream() {
    if (_serviceStatusStreamSubscription == null) {
      final serviceStatusStream = _geolocatorPlatform.getServiceStatusStream();
      _serviceStatusStreamSubscription = serviceStatusStream.handleError((error) {
        _serviceStatusStreamSubscription?.cancel();
        _serviceStatusStreamSubscription = null; }).listen((serviceStatus) {
        String serviceStatusValue;
        if (serviceStatus == ServiceStatus.enabled) {
          if (positionStreamStarted) {_toggleListening();}
          //print('enabled');
        } else {
          if (_positionStreamSubscription != null) {
            setState(() { _positionStreamSubscription?.cancel();
            _positionStreamSubscription = null;
              //_updatePositionList(_PositionItemType.log, 'Position Stream has been canceled');
            });
          }
          //print('disabled');
        }
        // _updatePositionList(
        //   _PositionItemType.log,
        //   'Location service has been $serviceStatusValue',
        // );
      });
    }
  }

  void _updatePositionList(Position displayValue) {
print('STREAM CONNECTION STate: ${isDeviceConnected}');
    streamConnectionCheck == false ? internetConnectivity().then((value) => setState((){isDeviceConnected = value;})).then((value) => setState((){streamConnectionCheck = true;})) : null;
print('STREAM CONNECTION STate2: ${isDeviceConnected}');
    currentLocation = displayValue;
    latDms = converter.getDegreeFromDecimal(displayValue.latitude);
    longDms = converter.getDegreeFromDecimal(displayValue.longitude);
    accuracy = displayValue.accuracy;
    altitude = displayValue.altitude;
    latitudeController.text = '${displayValue.latitude}';
    longitudeController.text= '${displayValue.longitude}';
    accuracyController.text= '${displayValue.accuracy}';
    altitudeController.text= '${displayValue.altitude}';
    currentLatLng = LatLng(displayValue.latitude, displayValue.longitude);

    _mapController2.move(LatLng(displayValue.latitude,displayValue.longitude),_mapController2.zoom);
    _mapController.move(LatLng(displayValue.latitude,displayValue.longitude),_mapController.zoom);
    markerAddress.getStreet(displayValue).then((value) => currentStreet = value).then((value) =>streetController.text = value!);
    markerAddress.getTown(displayValue).then((value) => currentTown = value).then((value) =>townController.text = value!).then((value) =>nameController.text = value);
    markerAddress.getCounty(displayValue).then((value) => currentCounty = value).then((value) =>countyController.text = value!);
    markerAddress.getState(displayValue).then((value) => currentState = value).then((value) =>stateController.text = value!);
    markerAddress.getZip(displayValue).then((value) => currentPostalCode = value).then((value) =>zipController.text = value!);

markerAddress.getSubLocality(displayValue).then((value) => subLocality = value).then((value) =>subLocalityController.text = value!);
markerAddress.getAdministrativeArea(displayValue).then((value) => administrativeArea = value).then((value) =>administrativeAreaController.text = value!);
markerAddress.getCountryCode(displayValue).then((value) => countryCode = value).then((value) =>countryCodeController.text = value!);





    setState(() {});
  }

  void _toggleListening() {
    if (_positionStreamSubscription == null) {final positionStream = _geolocatorPlatform.getPositionStream();
    _positionStreamSubscription = positionStream.handleError((error) {_positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;}).listen((position) => _updatePositionList(position));
    _positionStreamSubscription?.pause();
    }

    setState(() {
      if (_positionStreamSubscription == null) {
        return;
      }

      String statusDisplayValue;
      if (_positionStreamSubscription!.isPaused) {
        _positionStreamSubscription!.resume();
        statusDisplayValue = 'resumed';
      } else {
        _positionStreamSubscription!.pause();
        statusDisplayValue = 'paused';
      }

      // _updatePositionList(
      //   _PositionItemType.log,
      //   'Listening for position updates $statusDisplayValue',
      // );
    });
  }
  // void locationUpdate(){
  //
  //   StreamSubscription<ServiceStatus> serviceStatusStream = Geolocator.getServiceStatusStream().listen(
  //           (ServiceStatus status) {
  //         print(status);
  //       });
  // }


  void initLocationService() async {

 if (currentLocation != null) { try {_mapController2.move(LatLng(currentLocation!.latitude,currentLocation!.longitude),_mapController2.zoom);} catch (e){(print('ERROR - ERROR'));}; try {_mapController.move(LatLng(currentLocation!.latitude,currentLocation!.longitude),_mapController.zoom);} catch(e) {(print('ERROR2 - ERROR2'));}};
  }

  Future <void> getDmsLat(List<num>? latitideList) async {

    String? dmsLatitude;

    //print('LIST: ${latitideList}');

    if (latitideList![0] > 0){
      dmsLatitude = "${latitideList[0]}° ${latitideList[1]}' ${latitideList[2].toString().substring(0,7)}\" ${currentLocation!.latitude < 0 ? 'S' : 'N'}";
    } else {
      dmsLatitude = "${latitideList[0].toString().substring(1)}° ${latitideList[1]}' ${latitideList[2].toString().substring(0,7)}\" ${currentLocation!.latitude < 0 ? 'S' : 'N'}";
    }
    //print('LIST: ${latitideList}')
    ;
    setState(() {
      latDmsLocation = dmsLatitude;
    });
  }

  Future <void> getDmslon(List<num>? longitudeList) async {

    String? dmsLongitude;

    if (longitudeList![0] > 0){
      dmsLongitude = "${longitudeList[0]}° ${longitudeList[1]}' ${longitudeList[2].toString().substring(0,7)}\" ${currentLocation!.longitude < 0 ? 'W' : 'E'}";
    }else{
      dmsLongitude = "${longitudeList[0].toString().substring(1)}° ${longitudeList[1]}' ${longitudeList[2].toString().substring(0,7)}\" ${currentLocation!.longitude < 0 ? 'W' : 'E'}";

    } setState(() {longDmsLocation = dmsLongitude;});
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    //print('GETTING ADDRESS...');

    setState(() {

    });

    await placemarkFromCoordinates(currentLocation!.latitude, currentLocation!.longitude).then((List<Placemark> placemarks) {

      Placemark place = placemarks[0];
      setState(() { currentAddress = '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
      currentStreet = '${place.street}';
      currentTown = '${place.locality}';
      currentCounty = '${place.subAdministrativeArea}';
      currentPostalCode = '${place.postalCode}';
      currentState = '${place.country}';
      name = '${place.name}';
      subLocality = '${place.subLocality}';
      administrativeArea = '${place.administrativeArea}';
      countryCode = '${place.isoCountryCode}';

      //internetConnectionError = false;
      });
    })
       .catchError((e) {
         setState(() {
           addressLookupError = true;  });
         //isAddressLoading = false;

      setState(() { currentAddress = '';
      currentStreet = ''; currentTown = '';currentCounty = '';currentPostalCode = '';currentState = '';
      });
         print('ADRESS CATCh ERROR: ${e.toString()}');

           })
    ;
  }

  void addMyMarker(MyMarkers myMarker) {
       myMarkersBox.add(myMarker);
  }

  @override
  Widget build(BuildContext context) {
 //print('Address LookUp Error: ${addressLookupError}');
 //print('Is Device Connected: ${isDeviceConnected}');
 //print('STREET: ${currentStreet}');



    // if (currentLocation != null) {
    //   currentLatLng = LatLng(currentLocation!.latitude, currentLocation!.longitude);
    // } else {
    //   currentLatLng = LatLng(0, 0);
    // }

      return Scaffold(backgroundColor: Colors.white30,
      resizeToAvoidBottomInset: false,
      //appBar: AppBar(title: const Text('Home')),
      //drawer: buildDrawer(context, LiveLocationPage.route),
      body: SizedBox(height: MediaQuery.of(context).size.height, width: MediaQuery.of(context).size.width,
            child:FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: currentLatLng,
                zoom: 12,
                interactiveFlags: InteractiveFlag.none,
              ),
              nonRotatedChildren: [
                ClipRect(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(color: Colors.white.withOpacity(0.3), height: MediaQuery.of(context).size.height, width: MediaQuery.of(context).size.width,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 25),
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
                                padding: const EdgeInsets.only(left: 10,right: 10),
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    positionStreamStarted == true ?  TextButton(onPressed: (){
                                      setState(() => positionStreamStarted = false); _toggleListening();
                                         //print('STREAM start: $positionStreamStarted');
                                         showDialog(barrierDismissible: false,context: context, builder: (ctx) => WillPopScope(onWillPop: () => Future.value(false),
                                           child: saveAndEditLocationAlertDialogStreamOn(ctx),
                                         ),
                                    );
                                      }, child: Column(
                                      children: [
                                        FaIcon(FontAwesomeIcons.heartCirclePlus, color: HexColor('#8C4332'),size: 30,), Text('Save', style: TextStyle(color: HexColor('#0468BF'), height: 1.5),)],))
                                    : TextButton(onPressed: (){
                                      //print('STREAM start: $positionStreamStarted');
                                      showDialog(barrierDismissible: false,context: context, builder: (ctx) => WillPopScope(onWillPop: () => Future.value(false),
                                        child: saveAndEditLocationAlertDialogStreamOff(ctx),
                                      ),
                                      );
                                    }, child: Column(children: [FaIcon(FontAwesomeIcons.heartCirclePlus, color: HexColor('#8C4332'),size: 30,), Text('Save', style: TextStyle(color: HexColor('#0468BF'), height: 1.5),)],)),


                                    Flexible(
                                      child:
                                      Text('My Location',softWrap: true,overflow: TextOverflow.fade,style: GoogleFonts.indieFlower(fontSize: 35, fontWeight: FontWeight.w600),),
                                      //Text('My Location', softWrap: false, maxLines: 1,overflow: TextOverflow.fade,style: TextStyle(fontSize: 35, fontWeight: FontWeight.w600),),
                                    ),
                                    TextButton(onPressed: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => MyMarkersList(currentLat: currentLocation?.latitude, currentLong: currentLocation?.longitude, mapController: _mapController,)));


                                    }, child: Column(children: [FaIcon(FontAwesomeIcons.bookBookmark, color: HexColor('#8C4332'),size: 30,), Text('My List', style: TextStyle(color: HexColor('#0468BF'),height: 1.5))],)),
                                    ],
                                ),
                              ),
                            ),

                            Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(width: MediaQuery.of(context).size.width*0.85, alignment: Alignment.center, height: 65, margin: const EdgeInsets.only(bottom: 7),
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
                                                  Text('DD: ${(currentLocation?.latitude)?.toStringAsFixed(9)}',style: const TextStyle(fontSize: 14),),

                                                ],
                                              ),
                                            ),

                                            Padding(
                                              padding: const EdgeInsets.only(left: 5, right: 10),
                                              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end,  children: [
                                                const Center(child: FaIcon(FontAwesomeIcons.mountainSun)),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 4),
                                                  child: positionStreamStarted == true ? Text('${altitude?.toStringAsFixed(2)}') : Text('${currentLocation?.altitude.toStringAsFixed(2)}'),
                                                ),
                                              ],
                                              ),
                                            ),
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
                                Container(width: MediaQuery.of(context).size.width*0.85, alignment: Alignment.center, height: 65, margin: const EdgeInsets.only(bottom: 20, top: 7),
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
                                            children: [const SizedBox(width: 45,child: Text('Lon', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),)),
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
                                                    Text('DD: ${(currentLocation?.longitude)?.toStringAsFixed(9)}',style: const TextStyle(fontSize: 14),),
                                                  ],
                                                ),
                                              ),

                                              Padding(
                                                padding: const EdgeInsets.only(left: 5,right: 10),
                                                child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                                                  const Center(child: FaIcon(FontAwesomeIcons.ruler)),
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 4),
                                                    child: positionStreamStarted == true ? Text('${accuracy?.toStringAsFixed(2)}') : Text('${currentLocation?.accuracy.toStringAsFixed(2)}'),
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

                            if (_isBannerAdReady)
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  width: _bannerAd.size.width.toDouble(),
                                  height: _bannerAd.size.height.toDouble(),
                                  child: AdWidget(ad: _bannerAd),
                                ),
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
                                            center: currentLatLng,
                                            zoom: 15,
                                            interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag | InteractiveFlag.flingAnimation,
                                          ),
                                          children: [


                                            TileLayer(
                                              urlTemplate:
                                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                              userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                                              errorImage: Image(image: AssetImage('assets/images/nointernet.png')).image
                                            ),
                                            FlutterMapZoomButtons(minZoom: 4, maxZoom: 19, mini: true, padding: 10, alignment: Alignment.bottomLeft,zoomInColor: HexColor('#049DBF'),zoomOutColor:  HexColor('#049DBF'),),
                                            CenterMapButtons(mini: true, padding: 10, alignment: Alignment.bottomRight, mapControler: _mapController2, currentLocation: currentLocation, centerColor: HexColor('#0468BF'),),
                                            Consumer<MarkerProvider>(builder: (context,value,child){
                                              return MarkerLayer(rotate: true, rotateAlignment: Alignment.center,markers: [positionStreamStarted == false
                                                ? Marker(width: 150, height: 150,point: Provider.of<MarkerProvider>(context).currentLatLng!, builder: (ctx) => const Icon(Icons.location_pin, color: Colors.red,))
                                              : Marker(width: 150, height: 150,point: currentLatLng, builder: (ctx) => const Icon(Icons.location_pin, color: Colors.red,))
                                              ]);}),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                           SingleChildScrollView(
                             scrollDirection: Axis.horizontal,child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [

                      isAddressLoading == true ? Container (
                      margin: const EdgeInsets.only(bottom: 25),
                      child: Text('${'Loading address details...'}',style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w400),)
                      )

                      : Container(margin: const EdgeInsets.only(bottom: 25),
                               child:


                      Column(
                                 children: [

                                   //AddressLookUp(),

                                   addressLookupError == false && currentAddress == null && isDeviceConnected == true
                                       ? Column(
                                         children: [
                                           Text('Connection Error.',style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w400),),
                                           Text('Still trying...',style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w400),),
                                         ],
                                       ):
                                       isDeviceConnected == false || addressLookupError == true
                                       ?
                       Column(
                        children: [
                          Text('Address Loading ERROR', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w400),),
                          Text('Slow or missing internet connection', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w400),),
                        ],
                      ) :
                                       Column(
                                     children: [
                                       Text('${currentStreet ?? '' }',style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
                                       Text('${currentPostalCode ?? ''} ${currentTown ?? ''}',style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
                                       Text('${subLocality ?? ''}, ${currentCounty ?? ''}',style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w300),),
                                       Text('${administrativeArea ?? ''}, ${currentState ?? '' }',style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w300)),


                                     ],
                                   ) ,
                                   //     Column(
                                   //       children: [
                                   //         Text('street: ${currentStreet ?? 'currentStreet' }',style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
                                   //         //Text('${addressField2 ?? 'currentPostalCode'} ${addressField1 ?? 'currentTown'}',style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
                                   //
                                   //         Text('currentPostalCode: ${currentPostalCode ?? 'currentPostalCode'}',style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
                                   //         Text('locality: ${currentTown ?? 'currentTown'}',style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
                                   //         Text('subAdministrativeArea: ${currentCounty ?? 'currentCounty'}',style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w300),),
                                   //         Text('country: ${currentState ?? 'currentState'}',style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w300),),
                                   //         Text('name: ${name ?? 'name' }',style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
                                   //         Text('subLocality: ${subLocality ?? 'subLocality' }',style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
                                   //         Text('administrativeArea: ${administrativeArea ?? 'administrativeArea' }',style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
                                   //         Text('countryCode: ${countryCode ?? 'countryCode' }',style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
                                   //
                                   //       ],
                                   //     )




                                 ],
                               )
                                 ,
                               ),

                             ],),
                           ),
                            SizedBox(width: MediaQuery.of(context).size.width, height: 110, child:

                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Column(mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(width: 70,height: 70,
                                        child:TextButton(onPressed: () {
                                          setState((){isLoading = true;});
                                          setState((){isAddressLoading = true;});
                                          internetConnectivity().then((value) => setState((){isDeviceConnected = value;}));
                                          geolocations.getCurrentPosition(context)
                                              .then((value) => setState((){currentLocation = value;}))
                                              .then((value) => Provider.of<LocationProvider>(context,listen: false).setLocation(currentLocation))
                                              .then((value) => setState((){latDms = converter.getDegreeFromDecimal(currentLocation!.latitude);}))
                                              .then((value) => setState((){longDms = converter.getDegreeFromDecimal(currentLocation!.longitude);}))
                                              .then((value) => Provider.of<MarkerProvider>(context,listen: false).SetMarker(currentLocation))
                                              .then((value) => _mapController2.move(LatLng(currentLocation!.latitude,currentLocation!.longitude),_mapController2.zoom))
                                              .then((value) => _mapController.move(LatLng(currentLocation!.latitude,currentLocation!.longitude),_mapController.zoom))
                                              .then((value) => isDeviceConnected == true ? _getAddressFromLatLng(currentLocation!) : null)
                                              .then((value) => setState((){isAddressLoading = false;}))
                                              .then((value) => setState((){nameController.text = currentTown ?? '';}))
                                              .then((value) => setState((){latitudeController.text = '${currentLocation?.latitude}';}))
                                              .then((value) => setState((){longitudeController.text = '${currentLocation?.longitude}';}))
                                              .then((value) => setState((){accuracyController.text = '${currentLocation?.accuracy}';}))
                                              .then((value) => setState((){altitudeController.text = '${currentLocation?.altitude}';}))
                                              .then((value) => setState((){streetController.text = currentStreet ?? '';}))
                                              .then((value) => setState((){townController.text = currentTown ?? '';}))
                                              .then((value) => setState((){countyController.text = currentCounty ?? '';}))
                                              .then((value) => setState((){stateController.text = currentState ?? '';}))
                                              .then((value) => setState((){zipController.text = currentPostalCode ?? '';}))
                                              .then((value) => setState((){subLocalityController.text = subLocality ??'';}))
                                              .then((value) => setState((){administrativeAreaController.text = administrativeArea ?? '';}))
                                              .then((value) => setState((){countryCodeController.text = countryCode ?? '';}))
                                              .then((value) => setState((){descriptionController.text = '';}))
                                              .then((value) => setState((){isLoading = false;}))
                                          ;},

                                child: Column(
                                  children: [
                              FaIcon(FontAwesomeIcons.arrowRotateLeft, color: HexColor('#8C4332'),size: 30,), Text('Refresh', style: TextStyle(color: HexColor('#0468BF'),fontSize: 14,height: 1.4))
                            ],),),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    OutlinedButton(onPressed: () async {

                                      await getDmsLat(latDms);
                                      await getDmslon(longDms);

                                      //print('DMS: ${latDmsLocation}');


                                      final locationUrl = 'You can find me here.\n\n Android: http://www.google.com/maps/search/?api=1&query=${currentLocation?.latitude ?? ''},${currentLocation?.longitude ?? ''}\n\niOS/Android: http://maps.apple.com/?11=${currentLocation?.latitude ?? ''},${currentLocation?.longitude ?? ''}\n\n'
'DMS:\n${latDmsLocation ?? ''}\n${longDmsLocation ?? ''}\n\nDD:\n${currentLocation?.latitude ?? ''}, ${currentLocation?.longitude ?? ''}\n\n'
                                          'Address:\n'
                                          '${currentStreet ?? ''}\n'
                                          '${currentPostalCode ?? ''} ${currentTown ?? ''}\n'
                                          '${currentCounty ?? ''}'
                                          '${currentState ?? ''}'

                                          ;
                                      await Share.share(locationUrl);



                              // Uri smsLaunchUri = Uri(
                              //      scheme: 'sms',
                              //       path: '',
                              //      queryParameters: {'body': Uri.encodeFull('http://maps.google.com/maps?z=12&t=m&q=loc:${currentLocation?.latitude}+${currentLocation?.longitude}')});
                              // launchUrl(smsLaunchUri);
                              },
                             style: OutlinedButton.styleFrom(backgroundColor: HexColor('#D99E6A'),elevation: 15,side: BorderSide(color: HexColor('#3B592D'),width: 7),shape: const CircleBorder(),padding: const EdgeInsets.only(top: 18,left: 18,right: 18,bottom: 14) ), child:

                                Stack(alignment: Alignment.center, children: [
                                  Column(mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('SEND',style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: FaIcon(FontAwesomeIcons.shareNodes, size: 25,color: Colors.black.withOpacity(0.5),),
                                      ),
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
                                      //IconButton(onPressed: () {}, icon: FaIcon(FontAwesomeIcons.circleInfo, size: 30, color: HexColor('#8C4332'),)),
                                      // Switch(value: positionStreamStarted, activeColor: HexColor('#8C4332'),onChanged: (value) {
                                      //
                                      //    value == false ? setState((){streamConnectionCheck = false; }): setState((){streamConnectionCheck = true; });setState(() => positionStreamStarted = value); _toggleListening();
                                      //   print('STREAM VALUE: ${value}');
                                      //   print('CONNECTION check: ${streamConnectionCheck}');
                                      //
                                      //   //positionStreamStarted = !positionStreamStarted;
                                      // },),

                                      TextButton(onPressed: (){
                                         showDialog(barrierDismissible: false,context: context, builder: (ctx) => WillPopScope(onWillPop: () => Future.value(false),
                                          child: aboutInfo(ctx),
                                        ),
                                        );
                                      }, child: Column(children: [FaIcon(FontAwesomeIcons.circleInfo, color: HexColor('#8C4332'),size: 30,), Text('About', style: TextStyle(color: HexColor('#0468BF'), height: 1.5),)],)),


                                    //Text('About', style: TextStyle(color: HexColor('#0468BF'),height: 0.5,fontSize: 14))
                                    ],
                                  ),
                                    ),
                                  ],
                                  ),
                                )
                              ],
                              ),

                            ),
                            ),
//                             Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,children: [
// Column(
//   children: [Switch(value: wakelockEnable, activeColor: HexColor('#8C4332'),onChanged: (value) {
//
//     setState(() => wakelockEnable = value); _toggleListening();
//     print(value);
//
//     //positionStreamStarted = !positionStreamStarted;
//   },)
//         ,Center(child: Padding(
//           padding: const EdgeInsets.only(bottom: 10),
//           child: Text('Screen',style: TextStyle(fontSize: 15,height: 0.5),),
//         )),
//   ],
// )
//                             ],),
                          ],
                        );}
                      ),
                  ) ,
                      ],),
            ),
          ),
        ),
                  ),
                ),
                )
              ],
              children: [
                 TileLayer(
                  urlTemplate:'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                  //errorImage: Image(image: AssetImage('assets/images/nointernetPlain.png')).image
                )

                //MarkerLayer(markers: markers),
              ],
            ),
          ),
    );
  }

  AlertDialog saveAndEditLocationAlertDialogStreamOn(BuildContext ctx) {
    return AlertDialog(
                                    title: const Text('Add this point to My List'),
                                    content: SingleChildScrollView(
                                      child: Column(children: [
                                        TextFormField(decoration: const InputDecoration(labelText: 'Name',),controller: nameController,),
                                        TextFormField(decoration: const InputDecoration(labelText: 'Latitude',),controller: latitudeController),
                                        TextFormField(decoration: const InputDecoration(labelText: 'Longitude',),controller:longitudeController),
                                        TextFormField(decoration: const InputDecoration(labelText: 'Altitude',),controller:altitudeController),
                                        TextFormField(decoration: const InputDecoration(labelText: 'Accuracy',),controller:accuracyController),
                                        TextFormField(decoration: const InputDecoration(labelText: 'Street',),controller: streetController),
                                        TextFormField(decoration: const InputDecoration(labelText: 'Town',),controller:townController),
                                        TextFormField(decoration: const InputDecoration(labelText: 'City area',),controller:subLocalityController),
                                        TextFormField(decoration: const InputDecoration(labelText: 'District',),controller:countyController),
                                        TextFormField(decoration: const InputDecoration(labelText: 'County/State',),controller:administrativeAreaController),
                                        TextFormField(decoration: const InputDecoration(labelText: 'Postal Code',),controller:zipController),
                                        TextFormField(decoration: const InputDecoration(labelText: 'Country',),controller:stateController),
                                        TextFormField(decoration: const InputDecoration(labelText: 'Country Code',),controller:countryCodeController),
                                        TextFormField(decoration: const InputDecoration(labelText: 'Notes',),controller:descriptionController,minLines: 1,maxLines: 3,),

                                      ],),
                                    ),
                                    actions: <Widget>[Row(mainAxisAlignment: MainAxisAlignment.spaceBetween ,children: [
                                      TextButton(onPressed: (){
                                          setState(() => positionStreamStarted = true); _toggleListening();
                                          print('STREAM: $positionStreamStarted');
                                          Navigator.of(ctx).pop();
                                      }, child: Container(color: Colors.red, padding: const EdgeInsets.all(14), child: Text('Cancel',style: TextStyle(color: Colors.white),),)),

                                      TextButton(onPressed: (){
                                          final newMarker = MyMarkers(dateTime: DateTime.now(), name: nameController.text, description: descriptionController.text, lat: double.parse(latitudeController.text) , long: double.parse(longitudeController.text), altitude: double.parse(altitudeController.text), accuracy: double.parse(accuracyController.text), street: streetController.text, city: townController.text, county: countyController.text, state: stateController.text,zip: zipController.text, countryCode: countryCodeController.text, subLocality: subLocalityController.text, administrativeArea: administrativeAreaController.text);
                                          addMyMarker(newMarker);
                                          setState(() => positionStreamStarted = true); _toggleListening();
                                          print('STREAM: $positionStreamStarted');
                                          Navigator.of(ctx).pop();
                                      }, child: Container(color: HexColor('#3B592D'), padding: const EdgeInsets.all(14), child: Text('SAVE',style: TextStyle(color: Colors.white),),)),

                                    ],)

                                    ],
                                  );
  }

  AlertDialog saveAndEditLocationAlertDialogStreamOff(BuildContext ctx) {
    return AlertDialog(
      title: const Text('Add this location to My List'),
      content: SingleChildScrollView(
        child: Column(children: [
          TextFormField(decoration: const InputDecoration(labelText: 'Name',),controller: nameController,),
          TextFormField(decoration: const InputDecoration(labelText: 'Latitude',),controller: latitudeController),
          TextFormField(decoration: const InputDecoration(labelText: 'Longitude',),controller:longitudeController),
          TextFormField(decoration: const InputDecoration(labelText: 'Altitude',),controller:altitudeController),
          TextFormField(decoration: const InputDecoration(labelText: 'Accuracy',),controller:accuracyController),
          TextFormField(decoration: const InputDecoration(labelText: 'Street',),controller: streetController),
          TextFormField(decoration: const InputDecoration(labelText: 'Town',),controller:townController),
          TextFormField(decoration: const InputDecoration(labelText: 'City area',),controller:subLocalityController),
          TextFormField(decoration: const InputDecoration(labelText: 'District',),controller:countyController),
          TextFormField(decoration: const InputDecoration(labelText: 'County/State',),controller:administrativeAreaController),
          TextFormField(decoration: const InputDecoration(labelText: 'Postal Code',),controller:zipController),
          TextFormField(decoration: const InputDecoration(labelText: 'Country',),controller:stateController),
          TextFormField(decoration: const InputDecoration(labelText: 'Country Code',),controller:countryCodeController),
          TextFormField(decoration: const InputDecoration(labelText: 'Notes',),controller:descriptionController,minLines: 1,maxLines: 3,),

        ],),
      ),
      actions: <Widget>[Row(mainAxisAlignment: MainAxisAlignment.spaceBetween ,children: [
        TextButton(onPressed: (){
          print('STREAM: $positionStreamStarted');
          Navigator.of(ctx).pop();
        }, child: Container(color: Colors.red, padding: const EdgeInsets.all(14), child: Text('Cancel',style: TextStyle(color: Colors.white),),)),

        TextButton(onPressed: (){
          final newMarker = MyMarkers(dateTime: DateTime.now(), name: nameController.text, description: descriptionController.text, lat: double.parse(latitudeController.text) , long: double.parse(longitudeController.text), altitude: double.parse(altitudeController.text), accuracy: double.parse(accuracyController.text), street: streetController.text, city: townController.text, county: countyController.text, state: stateController.text,zip: zipController.text,  countryCode: countryCodeController.text, subLocality: subLocalityController.text, administrativeArea: administrativeAreaController.text);
          addMyMarker(newMarker);
          print('STREAM: $positionStreamStarted');
          Navigator.of(ctx).pop();
        }, child: Container(color: HexColor('#3B592D'), padding: const EdgeInsets.all(14), child: Text('SAVE',style: TextStyle(color: Colors.white),),)),

      ],)

      ],
    );
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }



  AlertDialog aboutInfo(BuildContext ctx) {

    final Uri _url = Uri.parse('https://findme.salus-apps.eu');
    final Uri _url2 = Uri.parse('https://findme.salus-apps.eu/privacy-policy');
   // final Uri _url3 = Uri.parse('https://help.salus-apps.eu');
    final Uri _url3 = Uri.parse('mailto:findme@salus-apps.eu');

    return AlertDialog(
      title: Center(child: const Text('')),
      content: SingleChildScrollView(
        child: Column(children: [
          Icon(FontAwesomeIcons.locationDot, size: 50, color: HexColor('#3B592D'),),
          SizedBox(height: 20,),
          Text('FindMe', style: TextStyle(fontSize: 40,fontWeight: FontWeight.w600),),
          Text('Find My Location', style: TextStyle(fontSize: 20,fontWeight: FontWeight.w400),),
          SizedBox(height: 5,),
          Text('verzia 1.0.9', style: TextStyle(fontSize: 15,fontWeight: FontWeight.w300),),
          SizedBox(height: 20,),
          TextButton(onPressed: () => setState(() {_launched = _launchInBrowser(_url);}), child: const Text('findme.salus-apps.eu'),style: TextButton.styleFrom(minimumSize: Size.zero, padding: EdgeInsets.zero,tapTargetSize: MaterialTapTargetSize.shrinkWrap ),),
          Text('support@salus-apps.eu', style: TextStyle(fontSize: 15,fontWeight: FontWeight.w300),),
          TextButton(onPressed: () => setState(() {_launched = _launchInBrowser(_url2);}), child: const Text('Privacy Policy'),style: TextButton.styleFrom(minimumSize: Size.zero, padding: EdgeInsets.zero,tapTargetSize: MaterialTapTargetSize.shrinkWrap ),),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 2),
            child: Text('Development', style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),),
          ),
          Text('Miloš Sálus', style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500),),
          Text('Pivo SALUS s.r.o.', style: TextStyle(fontSize: 13,fontWeight: FontWeight.w400),),
          SizedBox(height: 15,),
          Center(
            child: Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [FaIcon(FontAwesomeIcons.envelope, size: 20,),
                SizedBox(width: 8,),
                TextButton(onPressed: () => setState(() {_launched = _launchInBrowser(_url3);}), child: const Text('Report an issue', style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600),),style: TextButton.styleFrom(minimumSize: Size.zero, padding: EdgeInsets.zero,tapTargetSize: MaterialTapTargetSize.shrinkWrap ),),
              ],
            ),
          ),

        ],),
      ),
      actions: <Widget>[Row(mainAxisAlignment: MainAxisAlignment.center ,children: [
        TextButton(onPressed: (){
          print('STREAM: $positionStreamStarted');
          Navigator.of(ctx).pop();
        }, child: Container(color: Colors.red, width: 100,padding: const EdgeInsets.all(14), child: Center(child: Text('OK',style: TextStyle(color: Colors.white),)),)),


      ],)

      ],
    );
  }


 @override
  void dispose() {
    if (_positionStreamSubscription != null) {
      _positionStreamSubscription!.cancel();
      _positionStreamSubscription = null;
    }
    // Clean up the controller when the widget is removed from the
    // widget tree.
    nameController.dispose();
    super.dispose();
   _bannerAd.dispose();
  }

}


