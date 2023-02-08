import 'dart:ui';
import 'package:find_me/markers_category_model.dart';
import 'package:find_me/widgets/dialog_category_list_filter.dart';
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
import 'categories.dart';
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
  late Box<MyMarkersCategory> markersCategoryList;
  String? selectedCategory;
  String? categoryTitle;

  const int maxFailedLoadAttempts = 3;

class _MyMarkersListState extends State<MyMarkersList> {

  // TODO: Add _bannerAd
  late BannerAd _bannerAd;
  late BannerAd _bannerAd2;
  bool _isBannerAdReady = false;
  bool _isBannerAdReady2 = false;


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

  void _loadBannerAd2() {
    _bannerAd2 = BannerAd(
      adUnitId: AdHelper.markerList2,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          //print(_isBannerAdReady);
          setState(() {
            _isBannerAdReady2 = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          _isBannerAdReady2 = false;
          ad.dispose();
        },
      ),
    );

    _bannerAd2.load();
  }

  // TODO: Add _interstitialAd
  InterstitialAd? _interstitialAd;
  int _interstitialLoadAttempts = 1;



  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _loadBannerAd2();
    _createInterstitialAd();
    markersList = Hive.box('myMarkersBox');
    markersCategoryList = Hive.box('myMarkersCategoryBox');
    selectedCategory = '';
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

    //print('MENU ITEMS: ${context.watch<CategoryProvider>().myCategoryList}');
    //var categoryItemList = context.watch<CategoryProvider>().myCategoryList;


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

              // if (_isBannerAdReady)
              //   Padding(
              //     padding: const EdgeInsets.only(top: 40, bottom: 10),
              //     child: Align(
              //       alignment: Alignment.center,
              //       child: Container(
              //         width: _bannerAd.size.width.toDouble(),
              //         height: _bannerAd.size.height.toDouble(),
              //         child: AdWidget(ad: _bannerAd),
              //       ),
              //     ),
              //   ),

// PopupMenuButton<String>(
//
//     onSelected: (value) {
//
//     },
//     itemBuilder: (BuildContext context){
//
//       return context.watch<CategoryProvider>().myCategoryList.map((e) {
//         return PopupMenuItem(
//           value: e,
//           child: Text(e),);
//       }).toList();
//     }),



    //          Padding(
    //            padding: const EdgeInsets.all(20.0),
    //            child: Center(
    //              child: Consumer<CategoryProvider>(builder: (context, value, child) {
    //                return DropdownButtonHideUnderline(
    //                  child: DropdownButton2(
    //                    hint: Text('Select your category'),
    //                   items: categoryItemList.map((item) => DropdownMenuItem<String>(value: item.markerCategoryTitle,child: Text(item.markerCategoryTitle!, style: const TextStyle(
    //                      fontSize: 14,
    //                    ),),)).toList(),
    //                    value: 'Show All',
    //                    onChanged: (value) {
    //                      setState(() {
    //                        selectedCategory = value;
    //                      });
    //                    },
    //                    buttonHeight: 20,
    //                    buttonWidth: 200,
    //                    itemHeight: 20,),
    //
    //                );
    //
    //
    // }
    //
    //              )
    //            ),
    //          ),



              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 5, left: 15,right: 15),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(style: ElevatedButton.styleFrom(foregroundColor: HexColor('#f0d8c3'), backgroundColor: HexColor('#3B592D') ),onPressed: () async {String? markerCategoryTitle = await showDialog(context: context, builder: (BuildContext context) { return CategoryPickerDialogFilter(); }); setState(() {
                      markerCategoryTitle != null ?
                      selectedCategory = markerCategoryTitle : null;
                    });}, child: Text('Filter by category')),

                    ElevatedButton(style: ElevatedButton.styleFrom(foregroundColor: HexColor('#f0d8c3'), backgroundColor: HexColor('#8C4332') ),onPressed: () async {await Navigator.push(context, MaterialPageRoute(builder: (context) => const MarkerCategories()));setState(() {

                    }); }, child: Text('Category List'))
                  ],
                ),
              ),





              Container(
                child: Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: markersList.listenable(),
                    builder: (BuildContext context, Box<MyMarkers> myMarkers, Widget? child) {

                    List<int> markerKeys;

                      if (selectedCategory == '') { markerKeys = myMarkers.keys.cast<int>().toList();} else if (selectedCategory == '000') {
                      markerKeys = myMarkers.keys.cast<int>().where((item) => myMarkers.get(item)?.markerCategoryKey == '000' || myMarkers.get(item)?.markerCategory == '').toList();} else {

                      markerKeys = myMarkers.keys.cast<int>().where((item) => myMarkers.get(item)?.markerCategoryKey == selectedCategory).toList();}



                      ///Remove ListView Top padding with MediaQuery.removePadding
                      return MediaQuery.removePadding(removeTop: true,
                      context: context,



                        child:  markerKeys.length > 0 ?

                        ListView.builder(



                          itemCount: markerKeys.length,
                          itemBuilder: (BuildContext context, int index) {

                              final int key = markerKeys[index];
                              final MyMarkers? markers = myMarkers.get(key);


                            final latDms = converter.getDegreeFromDecimal(markers!.lat!);
                            final longDms = converter.getDegreeFromDecimal(markers.long!);
                             // print('KEY 10: ${markers.markerCategoryKey}');
                             //  print('TITLE 10: ${markers.markerCategory}');
                             //  print('CATEGORY TITLE 10: ${markersCategoryList.get(int.parse(markers.markerCategoryKey!))?.markerCategoryTitle!}');
                              //print('MARKER KEY: ${markers.key}');
                             //print('KEY TYPE1: ${markers.markerCategoryKey}'.runtimeType);




                              if (markers.markerCategoryKey == null) {categoryTitle = 'uncategorized';}
                              else if (markers.markerCategoryKey == '000'){categoryTitle = 'uncategorized';}
                              else {categoryTitle =  markersCategoryList.get(int.parse(markers.markerCategoryKey!))?.markerCategoryTitle;}

                              // var kategoria = markersCategoryList.get(int.parse(markers.markerCategoryKey!))?.markerCategoryTitle!;
                              //
                              // print('KATEGORIA: $kategoria');
                              //print('categoryTitle: $categoryTitle');

                              if (categoryTitle == null) {
                                final markerCategoryKeyUpdate = MyMarkers(dateTime: markers.dateTime, name: markers.name, description: markers.description, lat: double.parse('${markers.lat}') , long: double.parse('${markers.long}'), altitude: double.parse('${markers.altitude}'), accuracy: double.parse('${markers.accuracy}'), street: markers.street, city: markers.city, county: markers.county, state: markers.state,zip: markers.zip,  countryCode: markers.countryCode, subLocality: markers.subLocality, administrativeArea: markers.administrativeArea, markerCategory: 'uncategorized',markerCategoryKey: '000');
                                markersList.put(markers.key, markerCategoryKeyUpdate);
                              }


                              print('MARKER CATEGORY TITLE: ${categoryTitle}');
                              // print('TITLE 1: ${markers.markerCategory}');
                              // print('CATEGORY TITLE 1: ${markersList.get(markers.markerCategory)}');



                              // markers.markerCategoryKey != null
                              //     ? categoryTitle =  markersCategoryList.get(int.parse(markers.markerCategoryKey!))?.markerCategoryTitle
                              //     : markers.markerCategoryKey != '000' ?
                              // categoryTitle =  markersCategoryList.get(int.parse(markers.markerCategoryKey!))?.markerCategoryTitle
                              //     : categoryTitle = 'uncategorized';


                             //markersCategoryList.get(int.parse('${markers.markerCategoryKey}'))?.markerCategoryTitle


                            //final categoryTitle = markersCategoryList.get(18)?.markerCategoryTitle;
                            // print('Category: ${categoryTitle}');
                            // print('KEY: ${markers.markerCategoryKey}');
                            //   print('KEY TYPE: ${markers.markerCategoryKey}'.runtimeType);


                            return Column(
                              children: [
                                ClipRect(
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
                                                        //Text('${markers.markerCategoryKey}',style: TextStyle(fontSize: 20,color: HexColor('#0468BF'),fontWeight: FontWeight.w500,shadows: [Shadow(color: Colors.black54.withOpacity(0.4),offset: const Offset(0,1),blurRadius: 0)]),),
                                                        Text('${markers.name}',style: TextStyle(fontSize: 20,color: HexColor('#0468BF'),fontWeight: FontWeight.w500,shadows: [Shadow(color: Colors.black54.withOpacity(0.4),offset: const Offset(0,1),blurRadius: 0)]),),
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
                                                                      ? Text("Lat: ${latDms?[0]}° ${latDms?[1]}' ${latDms?[2].toString().substring(0,7)}\" ${markers.lat! > 0 ? 'N' : 'S'}",style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: HexColor('#8C4332'), shadows: [Shadow(color: Colors.black54.withOpacity(0.3),offset: const Offset(0,1),blurRadius: 0)]),)
                                                                      : Text("Lat: ${latDms?[0].toString().substring(1)}° ${latDms?[1]}' ${latDms?[2].toString().substring(0,7)}\" ${markers.lat! > 0 ? 'N' : 'S'}",style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: HexColor('#8C4332'), shadows: [Shadow(color: Colors.black54.withOpacity(0.3),offset: const Offset(0,1),blurRadius: 0)]),),
                                                                  Text('DD: ${markers.lat?.toStringAsFixed(9)}',style: TextStyle(fontSize: 13,color: HexColor('#8C4332').withAlpha(180)),),
                                                                ],),],
                                                            ),
                                                            const SizedBox(height: 10,),
                                                            Column(crossAxisAlignment:CrossAxisAlignment.start ,children: [
                                                              longDms?[0] > 0
                                                                  ? Text("Long: ${longDms?[0]}° ${longDms?[1]}' ${longDms?[2].toString().substring(0,7)}\" ${markers.long! > 0 ? 'E' : 'W'}",style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: HexColor('#8C4332'), shadows: [Shadow(color: Colors.black54.withOpacity(0.4),offset: const Offset(0,1),blurRadius: 0)]),)
                                                                  : Text("Long: ${longDms?[0].toString().substring(1)}° ${longDms?[1]}' ${longDms?[2].toString().substring(0,7)}\" ${markers.long! > 0 ? 'E' : 'W'}",style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: HexColor('#8C4332'), shadows: [Shadow(color: Colors.black54.withOpacity(0.4),offset: const Offset(0,1),blurRadius: 0)]),),
                                                              Padding(
                                                                padding: const EdgeInsets.only(top: 3),
                                                                child: Text('DD: ${markers.long?.toStringAsFixed(9)}',style: TextStyle(fontSize: 13,color: HexColor('#8C4332').withAlpha(180)),),
                                                              ),
                                                            ],),

                                                                                                    ],
                                                        ),
                                                        Column(
                                                          children: [
                                                            Column(crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                IconButton(highlightColor: Colors.green,color: Colors.black54, onPressed: () {
                                                                  //Provider.of<CategoryProvider>(context, listen: false).removeFromList(markers.markerCategory!);
                                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => EditRecord(index: index, marker: markers, markerLat: markers.lat,markerLong: markers.long, mapController: widget.mapController))); }, icon: const FaIcon(FontAwesomeIcons.pencil),),
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
                                                            Text('${markers.altitude?.toStringAsFixed(2)} m', style: TextStyle(color: HexColor('#3B592D'),
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
                                                            Text('${markers.accuracy?.toStringAsFixed(2)} m', style: TextStyle(color: HexColor('#3B592D'),
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
                                                          Text('${markers.street}', style: TextStyle(color: HexColor('#049DBF'),
                                                              shadows: [Shadow(color: Colors.black54.withOpacity(0.4),offset: const Offset(0,1),blurRadius: 0)]
                                                          ))
                                                        ],
                                                        ),
                                                      ),

                                                      markers.city !='' ?

                                                      Row(children: [Text('${markers.zip} ${markers.city}', style: TextStyle(color: HexColor('#049DBF'),
                                                         shadows: [Shadow(color: Colors.black54.withOpacity(0.4),offset: const Offset(0,1),blurRadius: 0)]
                                                        ),)
                                                      ],
                                                      ) :

                                                      Row(children: [Text('${markers.zip}', style: TextStyle(color: HexColor('#049DBF'),
                                                          shadows: [Shadow(color: Colors.black54.withOpacity(0.4),offset: const Offset(0,1),blurRadius: 0)]
                                                      ),),
                                                        Text(' City Name', style: TextStyle(color: HexColor('#0468BF'),
                                                            shadows: [Shadow(color: Colors.black54.withOpacity(0.4),offset: const Offset(0,1),blurRadius: 0)]),)
                                                      ],
                                                      ),
                                                      Row(children: [Text('${markers.state}', style: TextStyle(color: HexColor('#049DBF'),
                                                          shadows: [Shadow(color: Colors.black54.withOpacity(0.4),offset: const Offset(0,1),blurRadius: 0)]
                                                      )),
                                                       ],
                                                      ),
                                                    ],
                                                    ),
                                                  ],
                                                  ),
                                                  SizedBox(height: 5,),

                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 20, right: 20),
                                                    child: FittedBox(fit: BoxFit.scaleDown,
                                                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.only(right: 5),
                                                            child: Column(mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Container(padding: EdgeInsets.all(0.0), width: 40,child: IconButton(highlightColor: Colors.blue, padding: EdgeInsets.only(bottom: 10, right: 15),onPressed: (){
                                                                 // _showInterstitialAd();
                                                                  print('MARKER CATEGORY TITLE2: ${categoryTitle}');
                                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => MarkerDetails(latitude: markers.lat , longitude: markers.long, marker: markers, latDms: latDms, longDms: longDms, categoryTitle: categoryTitle)));}, icon: FaIcon(FontAwesomeIcons.circleInfo,size: 30, color: HexColor('#592d3b'),))),
                                                              ],
                                                            ),
                                                          ),
                                                          Column(
                                                            children: [

                                                              Text(DateFormat().format(markers.dateTime!),style: TextStyle(fontSize: 15,color: Colors.white, shadows: [Shadow(color: Colors.black54.withOpacity(0.4),offset: const Offset(0,1),blurRadius: 3)]),),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.only(left: 5),
                                                            child: Column(
                                                              children: [
                                                                Container(padding: EdgeInsets.all(0.0), width: 40,child: IconButton(highlightColor: Colors.blue,padding: EdgeInsets.only(bottom: 10, left: 15),onPressed: (){
                                                                  //buttons.openDirectionOnGoogleMap(widget.currentLat, widget.currentLong, marker.lat, marker.long);
                                                                  MapsLauncher.launchCoordinates(markers.lat!, markers.long!);
                                                                  }, icon: FaIcon(FontAwesomeIcons.mapLocation,size: 30, color: HexColor('#592d3b'),))),



                                                              ],
                                                                                                                      ),
                                                          ),


                                                        ],
                                                      ),
                                                    ),
                                                  ),

                                                  Padding(
                                                    padding: const EdgeInsets.only(bottom: 7),
                                                    child:

                                                     categoryTitle == null ?
                                                    Text('uncategorized', style: TextStyle(color: HexColor('#8C4332'),fontSize: 15,
                                                        shadows: [Shadow(color: Colors.black54.withOpacity(0.4),offset: const Offset(0,1),blurRadius: 0)]
                                                     )) :
                                                    Text('${categoryTitle}', style: TextStyle(color: HexColor('#8C4332'),fontSize: 15,
                                                        shadows: [Shadow(color: Colors.black54.withOpacity(0.4),offset: const Offset(0,1),blurRadius: 0)]
                                                    )),

                                                  ),
                                                  //Text('${markers.markerCategoryKey}')
                                                ],
                                              )





                                            ],),

                                          ],) ,
// title: Text('${marker.name}'),
// subtitle: Text('${marker.dateTime}'),
                                    ),


                                  ),
                                ),
                            //     index == 0 && _isBannerAdReady
                            //  ?
                            //  Padding(
                            // padding: const EdgeInsets.only(top: 10, bottom: 5),
                            // child: Align(
                            // alignment: Alignment.center,
                            // child: Container(
                            // width: _bannerAd.size.width.toDouble(),
                            // height: _bannerAd.size.height.toDouble(),
                            // child: AdWidget(ad: _bannerAd),
                            // ),
                            // ),
                            // )
                            //         :
                                index == 0 && _isBannerAdReady2
                              ?

                            Padding(
                                padding: const EdgeInsets.only(top: 10, bottom: 5),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: _bannerAd2.size.width.toDouble(),
                                    height: _bannerAd2.size.height.toDouble(),
                                    child: AdWidget(ad: _bannerAd2),
                                  ),
                                ),
                              )
                                    : SizedBox(height: 0,),

                              ],
                            );



                          }) :

                        Text('No location markers saved')


                        ,
                    );


                      },

                  ),
                ),
              ),
              Container(height: 70, child: Column(children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 5),
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: _bannerAd.size.width.toDouble(),
                      height: _bannerAd.size.height.toDouble(),
                      child: AdWidget(ad: _bannerAd),
                    ),
                  ),
                )
              ],),)
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


