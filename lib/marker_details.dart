import 'dart:ui';

import 'package:find_me/markers_model.dart';
import 'package:find_me/zoombuttons_plugin_option.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:latlong2/latlong.dart';
import 'ad_helper.dart';
import 'center_button_detail_screen.dart';
import 'package:intl/intl.dart';

class MarkerDetails extends StatefulWidget {

  final double? latitude;
  final double? longitude;
  final MyMarkers marker;
  final List<num>? latDms;
  final List<num>? longDms;

    MarkerDetails({Key? key, this.latitude, this.longitude, required this.marker, this.latDms, this.longDms}) : super(key: key);

  @override
  State<MarkerDetails> createState() => _MarkerDetailsState();
}

class _MarkerDetailsState extends State<MarkerDetails> {

  late final MapController _mapController3;

  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;


  ///TO-DO move to separate file
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
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
   _mapController3 = MapController();
      }

  @override
  Widget build(BuildContext context) {

    return Scaffold(backgroundColor: HexColor('#d8ded5'),
      body: FlutterMap(
        mapController: _mapController3,
        options: MapOptions(
          center: LatLng(widget.latitude ?? 0, widget.longitude ?? 0),
          zoom: 12,
          interactiveFlags: InteractiveFlag.none,
        ),
        nonRotatedChildren: [
          ClipRect(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.white.withOpacity(0.3), height: MediaQuery.of(context).size.height, width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Center(child: Column(
                  children: [


                    Container(width: MediaQuery.of(context).size.width, height: 400,
                      child: FlutterMap(mapController:_mapController3, options: MapOptions( center: LatLng(widget.latitude ?? 0, widget.longitude ?? 0),zoom: 17,interactiveFlags: InteractiveFlag.drag,),children: [
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

                      ),),
                    SizedBox(height: 20,),
                    if (_isBannerAdReady)
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: _bannerAd.size.width.toDouble(),
                          height: _bannerAd.size.height.toDouble(),
                          child: AdWidget(ad: _bannerAd),
                        ),
                      ),


                    SizedBox(height: 20,),
                    Center(child: Text('${widget.marker.name}',style: TextStyle(fontSize: 25, color: HexColor('#8C4332'),fontWeight: FontWeight.w500),)),
                    Padding(
                      padding: const EdgeInsets.only(top: 8,bottom: 15,left: 20,right: 20),
                      child: Center(child: Text('${widget.marker.description}',style: TextStyle(fontSize: 18),)),
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


                                              widget.latDms![0] > 0
                                              ? Text("${widget.latDms?[0]}° ${widget.latDms?[1]}' ${widget.latDms?[2].toString().substring(0,7)}\" ${widget.latitude! < 0 ? 'S' : 'N'}",style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),)
                                              : Text("${widget.latDms?[0].toString().substring(1)}° ${widget.latDms?[1]}' ${widget.latDms?[2].toString().substring(0,7)}\" ${widget.latitude! < 0 ? 'S' : 'N'}",style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),),
                                          Text('DD: ${(widget.latitude)?.abs().toStringAsFixed(9)}',style: const TextStyle(fontSize: 14),),

                                        ],
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.only(left: 5, right: 10),
                                      child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end,  children: [
                                        const Center(child: FaIcon(FontAwesomeIcons.mountainSun)),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text('${widget.marker.altitude?.toStringAsFixed(2)}'),
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
                                  children: [const SizedBox(width: 45,child: Text('Lon', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),)),
                                    const Padding(
                                      padding: EdgeInsets.only(left: 3, right: 3),
                                      child: VerticalDivider(color: Colors.black, thickness: 1,),
                                    ),

                                    ConstrainedBox(
                                      constraints: const BoxConstraints(minWidth: 180),
                                      child: Column (mainAxisAlignment: MainAxisAlignment.spaceAround, crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [


                                          widget.longDms![0] > 0
                                              ? Text("${widget.longDms?[0]}° ${widget.longDms?[1]}' ${widget.longDms?[2].toString().substring(0,7)}\" ${widget.longitude! < 0 ? 'W' : 'E'}",style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),)
                                              : Text("${widget.longDms?[0].toString().substring(1)}° ${widget.latDms?[1]}' ${widget.longDms?[2].toString().substring(0,7)}\" ${widget.longitude! < 0 ? 'W' : 'E'}",style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),),
                                          Text('DD: ${(widget.longitude)?.abs().toStringAsFixed(9)}',style: const TextStyle(fontSize: 14),),

                                        ],
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.only(left: 5, right: 10),
                                      child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end,  children: [
                                        const Center(child: FaIcon(FontAwesomeIcons.ruler)),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text('${widget.marker.accuracy?.toStringAsFixed(2)}'),
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

                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [

                      Container(margin: const EdgeInsets.only(bottom: 25),
                        child:
                        Column(
                          children: [
                            Text('${widget.marker.street}',style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w400),),
                            Text('${widget.marker.zip} ${widget.marker.city}',style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                            Text('${widget.marker.county}, ${widget.marker.state} ',style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w300),),
                            SizedBox(height: 15,),
                            Text(DateFormat().format(widget.marker.dateTime!),style: TextStyle(fontSize: 15,color: HexColor('#0468BF'), shadows: [Shadow(color: Colors.black54.withOpacity(0.4),offset: const Offset(0,1),blurRadius: 3)]),),

                          ],
                        ),
                      ),

                    ],),



                  ],
                ),
                ),
              ),
            ),
          ),
          ),],children: [
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

