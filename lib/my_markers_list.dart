import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:latlong2/latlong.dart';
import 'package:latlong_to_osgrid/latlong_to_osgrid.dart';
import 'package:maps_launcher/maps_launcher.dart';

import 'ad_helper.dart';
import 'buttons.dart';
import 'edit_record.dart';
import 'marker_details.dart';
import 'markers_model.dart';
import 'package:intl/intl.dart';

class MyMarkersList extends StatefulWidget {

  final double? currentLat;
  final double? currentLong;
  MapController mapController;

MyMarkersList({Key? key, this.currentLat, this.currentLong, required this.mapController}) : super(key: key);

  @override
  State<MyMarkersList> createState() => _MyMarkersListState();
}

  LatLongConverter converter = LatLongConverter();
  Buttons buttons = Buttons();
  late Box<MyMarkers> markersList;
  const int maxFailedLoadAttempts = 3;

class _MyMarkersListState extends State<MyMarkersList> {

  // TODO: Add _bannerAd
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

 //TODO: put to a separate file
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.markerList,
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

  // TODO: Add _interstitialAd
  InterstitialAd? _interstitialAd;
  int _interstitialLoadAttempts = 0;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _createInterstitialAd();
    markersList = Hive.box('myMarkersBox');
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.detailedScreenEnter,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _interstitialLoadAttempts = 0;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialLoadAttempts += 1;
          _interstitialAd = null;
          if (_interstitialLoadAttempts <= maxFailedLoadAttempts) {
            _createInterstitialAd();
          }
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          _createInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          _createInterstitialAd();
        },
      );
      _interstitialAd!.show();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(backgroundColor: HexColor('#C1D96C'),
      body: FlutterMap(
          mapController: widget.mapController,
          options: MapOptions(
            center: LatLng(widget.currentLat!, widget.currentLong!),
            zoom: 12,
            interactiveFlags: InteractiveFlag.none,
          ),
          nonRotatedChildren: [
            ClipRect(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(color: Colors.white.withOpacity(0.3), height: MediaQuery.of(context).size.height, width: MediaQuery.of(context).size.width,
          child:
          Column(
            children: [

              if (_isBannerAdReady)
                Padding(
                  padding: const EdgeInsets.only(top: 40, bottom: 10),
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: _bannerAd.size.width.toDouble(),
                      height: _bannerAd.size.height.toDouble(),
                      child: AdWidget(ad: _bannerAd),
                    ),
                  ),
                ),


              Container(
                child: Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: markersList.listenable(),
                    builder: (BuildContext context, Box<MyMarkers> myMarkers, Widget? child) {
                      markersList = myMarkers;
                    ///Remove ListView Top padding with MediaQuery.removePadding
                      return MediaQuery.removePadding(removeTop: true,
                      context: context,
                      child: ListView.builder(
                          itemCount: myMarkers.values.length,
                          itemBuilder: (BuildContext context, int index){

                            final marker = markersList.getAt(index) as MyMarkers;
                            final latDms = converter.getDegreeFromDecimal(marker.lat!);
                            final longDms = converter.getDegreeFromDecimal(marker.long!);

                            return ClipRect(
                              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 7,sigmaY: 7),
                                child: Card(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 4,
                                  margin: const EdgeInsets.only(bottom: 10,left: 10,right: 10,top: 10),
                                  color: Colors.white.withOpacity(0.3),
                                  child: Column(
                                    children: <Widget>[
                                      Stack(
                                        children: [
                                          Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(top: 12),
                                                child: Column(mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text('${marker.name}',style: TextStyle(fontSize: 20,color: HexColor('#0468BF'),fontWeight: FontWeight.w500,shadows: [Shadow(color: Colors.black54.withOpacity(0.4),offset: const Offset(0,1),blurRadius: 0)]),),
                                                    const Padding(
                                                      padding: EdgeInsets.only(top: 5, bottom: 4, left: 15, right: 15),
                                                      child: Divider(height: 1,color: Colors.black,),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 10, right: 10),
                                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  children: [
                                                    Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Column(
                                                          children: [
                                                            Column(crossAxisAlignment:CrossAxisAlignment.start ,children: [
                                                              latDms?[0] > 0
                                                                  ? Text("Lat: ${latDms?[0]}?? ${latDms?[1]}' ${latDms?[2].toString().substring(0,7)}\" ${marker.lat! > 0 ? 'N' : 'S'}",style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: HexColor('#8C4332'), shadows: [Shadow(color: Colors.black54.withOpacity(0.3),offset: const Offset(0,1),blurRadius: 0)]),)
                                                                  : Text("Lat: ${latDms?[0].toString().substring(1)}?? ${latDms?[1]}' ${latDms?[2].toString().substring(0,7)}\" ${marker.lat! > 0 ? 'N' : 'S'}",style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: HexColor('#8C4332'), shadows: [Shadow(color: Colors.black54.withOpacity(0.3),offset: const Offset(0,1),blurRadius: 0)]),),
                                                              Text('DD: ${marker.lat?.abs().toStringAsFixed(9)}',style: TextStyle(fontSize: 13,color: HexColor('#8C4332').withAlpha(180)),),
                                                            ],),],
                                                        ),
                                                        const SizedBox(height: 10,),
                                                        Column(crossAxisAlignment:CrossAxisAlignment.start ,children: [
                                                          longDms?[0] > 0
                                                              ? Text("Long: ${longDms?[0]}?? ${longDms?[1]}' ${longDms?[2].toString().substring(0,7)}\" ${marker.long! > 0 ? 'E' : 'W'}",style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: HexColor('#8C4332'), shadows: [Shadow(color: Colors.black54.withOpacity(0.4),offset: const Offset(0,1),blurRadius: 0)]),)
                                                              : Text("Long: ${longDms?[0].toString().substring(1)}?? ${longDms?[1]}' ${longDms?[2].toString().substring(0,7)}\" ${marker.long! > 0 ? 'E' : 'W'}",style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: HexColor('#8C4332'), shadows: [Shadow(color: Colors.black54.withOpacity(0.4),offset: const Offset(0,1),blurRadius: 0)]),),
                                                          Padding(
                                                            padding: const EdgeInsets.only(top: 3),
                                                            child: Text('DD: ${marker.long?.abs().toStringAsFixed(9)}',style: TextStyle(fontSize: 13,color: HexColor('#8C4332').withAlpha(180)),),
                                                          ),
                                                        ],),

                                                                                                ],
                                                    ),
                                                    Column(
                                                      children: [
                                                        Column(crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            IconButton(highlightColor: Colors.green,color: Colors.black54, onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => EditRecord(index: index, marker: marker, markerLat: marker.lat,markerLong: marker.long, mapController: widget.mapController))); }, icon: const FaIcon(FontAwesomeIcons.pencil),),
                                                          ],
                                                        ),
                                                        Column(crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            IconButton(highlightColor: Colors.red,color: Colors.black54, onPressed: () {markersList.deleteAt(index); }, icon: const FaIcon(FontAwesomeIcons.trashCan),),
                                                          ],
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                              //const SizedBox(height: 5,),

                                              const Padding(
                                                padding: EdgeInsets.only(top: 4, bottom: 7, left: 15, right: 15),
                                                child: Divider(height: 1,color: Colors.black,),
                                              ),

                                              Padding(
                                                padding: const EdgeInsets.only(left: 60, bottom: 8, right: 60),
                                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                  Column(
                                                    children: [
                                                      Row(children: [
                                                        FaIcon(FontAwesomeIcons.mountainSun,color: HexColor('#3B592D'),size: 18,),
                                                        const SizedBox(width: 10,),
                                                        Text('${marker.altitude?.toStringAsFixed(2)} m', style: TextStyle(color: HexColor('#3B592D'),
                                                            shadows: [Shadow(color: Colors.black54.withOpacity(0.4),offset: const Offset(0,1),blurRadius: 0)]
                                                        ),)
                                                      ],),
                                                    ],
                                                  ),

                                                  Column(
                                                    children: [
                                                      Row(children: [
                                                        FaIcon(FontAwesomeIcons.ruler,color: HexColor('#3B592D'),size: 18,),
                                                        const SizedBox(width: 10,),
                                                        Text('${marker.accuracy?.toStringAsFixed(2)} m', style: TextStyle(color: HexColor('#3B592D'),
                                                            shadows: [Shadow(color: Colors.black54.withOpacity(0.4),offset: const Offset(0,1),blurRadius: 0)]
                                                        ),)
                                                      ],),
                                                    ],
                                                  ),
                                                ],
                                                ),
                                              ),

                                              const Padding(
                                                padding: EdgeInsets.only(bottom: 8, left: 30, right: 30),
                                                child: Divider(height: 1,color: Colors.black,),
                                              ),

                                              Row( mainAxisAlignment: MainAxisAlignment.center,children: [
                                                Column(children: [
                                                  Container(
                                                    child: Row(children: [
                                                      Text('${marker.street}', style: TextStyle(color: HexColor('#049DBF'),
                                                          shadows: [Shadow(color: Colors.black54.withOpacity(0.4),offset: const Offset(0,1),blurRadius: 0)]
                                                      ))
                                                    ],
                                                    ),
                                                  ),
                                                  marker.city !='' ?

                                                  Row(children: [Text('${marker.zip} ${marker.city}', style: TextStyle(color: HexColor('#049DBF'),
                                                     shadows: [Shadow(color: Colors.black54.withOpacity(0.4),offset: const Offset(0,1),blurRadius: 0)]
                                                    ),)
                                                  ],
                                                  ) :

                                                  Row(children: [Text('${marker.zip}', style: TextStyle(color: HexColor('#049DBF'),
                                                      shadows: [Shadow(color: Colors.black54.withOpacity(0.4),offset: const Offset(0,1),blurRadius: 0)]
                                                  ),),
                                                    Text(' City Name', style: TextStyle(color: HexColor('#0468BF'),
                                                        shadows: [Shadow(color: Colors.black54.withOpacity(0.4),offset: const Offset(0,1),blurRadius: 0)]),)
                                                  ],
                                                  ),
                                                  Row(children: [Text('${marker.state}', style: TextStyle(color: HexColor('#049DBF'),
                                                      shadows: [Shadow(color: Colors.black54.withOpacity(0.4),offset: const Offset(0,1),blurRadius: 0)]
                                                  ))
                                                  ],
                                                  ),

                                                ],







                                                ),
                                              ],
                                              ),

                                              Padding(
                                                padding: const EdgeInsets.only(left: 20, right: 20),
                                                child: FittedBox(fit: BoxFit.scaleDown,
                                                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.only(right: 5),
                                                        child: Container(padding: EdgeInsets.all(0.0), width: 40,child: IconButton(padding: EdgeInsets.only(bottom: 10),onPressed: (){_showInterstitialAd(); Navigator.push(context, MaterialPageRoute(builder: (context) => MarkerDetails(latitude: marker.lat , longitude: marker.long, marker: marker, latDms: latDms, longDms: longDms)));}, icon: FaIcon(FontAwesomeIcons.circleInfo,size: 30, color: HexColor('#592d3b'),))),
                                                      ),
                                                      Text(DateFormat().format(marker.dateTime!),style: TextStyle(fontSize: 15,color: Colors.white, shadows: [Shadow(color: Colors.black54.withOpacity(0.4),offset: const Offset(0,1),blurRadius: 3)]),),
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: 5),
                                                        child: Container(padding: EdgeInsets.all(0.0), width: 40,child: IconButton(padding: EdgeInsets.only(bottom: 10),onPressed: (){
                                                          //buttons.openDirectionOnGoogleMap(widget.currentLat, widget.currentLong, marker.lat, marker.long);
                                                          MapsLauncher.launchCoordinates(marker.lat!, marker.long!);
                                                          }, icon: FaIcon(FontAwesomeIcons.mapLocation,size: 30, color: HexColor('#592d3b'),))),
                                                      )

                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          )





                                        ],),

                                    ],) ,
// title: Text('${marker.name}'),
// subtitle: Text('${marker.dateTime}'),
                                ),

                              ),
                            );

                          }),
                    );


                      },

                  ),
                ),
              ),
            ],
          )
        ,),),),
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

  @override
  void dispose() {
    super.dispose();
   _interstitialAd?.dispose();
   _bannerAd.dispose();
  }

}


