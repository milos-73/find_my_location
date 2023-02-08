import 'dart:ui';

import 'package:find_me/markers_category_model.dart';
import 'package:find_me/markers_model.dart';
import 'package:find_me/widgets/dialog_category_list_edit_marker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import 'ad_helper.dart';
import 'category_provider.dart';

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

const int maxFailedLoadAttempts = 3;

class _EditRecordState extends State<EditRecord> {

  bool isLoading = false;
  late Box<MyMarkers> myMarkersBox;
  late Box<MyMarkersCategory> myMarkersCategoryBox;
  late final MapController _mapController3;
  String? markerCategory;
  String? myMarkerCategoryKey;
  String? myCategoryTitle;

  // TODO: Add _interstitialAd
  InterstitialAd? _interstitialAd;
  int _interstitialLoadAttempts = 0;

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
  TextEditingController markerCategoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
   setState((){isLoading = true;});
    myMarkersBox = Hive.box('myMarkersBox');
    myMarkersCategoryBox = Hive.box('myMarkersCategoryBox');
    _mapController3 = MapController();
    categoryTitle();
    categoryKey();
    _createInterstitialAdCancel();
    _createInterstitialAdSave();

    //setState((){markerCategory = widget.marker.markerCategory!;});
    setState((){nameController.text = widget.marker.name!;});
    setState((){latitudeController.text = '${widget.marker.lat}';});
    setState((){longitudeController.text = '${widget.marker.long}';});
    setState((){accuracyController.text = '${widget.marker.accuracy}';});
    setState((){altitudeController.text = '${widget.marker.altitude}';});
    setState((){streetController.text = widget.marker.street ?? '';});
    setState((){townController.text = widget.marker.city ?? '';});
    setState((){countyController.text = widget.marker.county ?? '';});
    setState((){stateController.text = widget.marker.state ?? '';});
    setState((){zipController.text = widget.marker.zip ?? '';});
    setState((){descriptionController.text = widget.marker.description ?? '';});

    setState((){subLocalityController.text = widget.marker.subLocality ?? '';});
    setState((){administrativeAreaController.text = widget.marker.administrativeArea ?? '';});
    setState((){countryCodeController.text = widget.marker.countryCode ?? '';});
    setState((){markerCategoryController.text = myCategoryTitle ?? 'uncategorized';});
  }

//TODO: put all to separate file
  String? categoryTitle(){

    //print('CATEGORY KEY to edit: ${widget.marker.markerCategoryKey}');


    if (widget.marker.markerCategoryKey == '000'){myCategoryTitle = 'uncategorized';}
    else if (widget.marker.markerCategoryKey == null){myCategoryTitle = 'uncategorized';}
    else{myCategoryTitle = myMarkersCategoryBox.get(int.parse(widget.marker.markerCategoryKey!))?.markerCategoryTitle!;}



    // widget.marker.markerCategoryKey != null || widget.marker.markerCategoryKey != '000'  ? myCategoryTitle = myMarkersCategoryBox.get(int.parse(widget.marker.markerCategoryKey!))?.markerCategoryTitle! : myCategoryTitle = 'uncategorized';
    //print('CATEGORY TITLE: $myCategoryTitle');

    return myCategoryTitle;

  }

  //TODO: put all to separate file
  String? categoryKey(){

   myMarkerCategoryKey = myMarkersBox.get(widget.marker.key)?.markerCategoryKey;



    // widget.marker.markerCategoryKey != null || widget.marker.markerCategoryKey != '000'  ? myCategoryTitle = myMarkersCategoryBox.get(int.parse(widget.marker.markerCategoryKey!))?.markerCategoryTitle! : myCategoryTitle = 'uncategorized';
    // print('CATEGORY TITLE: $myCategoryTitle');

   //print('CATEGORY KEY: $myMarkerCategoryKey');

    return myMarkerCategoryKey;

  }


  void _createInterstitialAdSave() {
    InterstitialAd.load(
      adUnitId: AdHelper.editSave,
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
            _createInterstitialAdSave();
          }
        },
      ),
    );
  }

  void _createInterstitialAdCancel() {
    InterstitialAd.load(
      adUnitId: AdHelper.editSave,
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
            _createInterstitialAdCancel();
          }
        },
      ),
    );
  }

  void _showInterstitialAdSave() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          _createInterstitialAdSave();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          _createInterstitialAdSave();
        },
      );
      _interstitialAd!.show();
    }
  }

  void _showInterstitialAdCancel() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          _createInterstitialAdCancel();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          _createInterstitialAdCancel();
        },
      );
      _interstitialAd!.show();
    }
  }

@override
  Widget build(BuildContext context) {

  var categoryItemList = context.watch<CategoryProvider>().myCategoryList;

    return Scaffold(backgroundColor: HexColor('#d8ded5'),
      floatingActionButton: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 45),
            child: FloatingActionButton.extended(onPressed: () {
              _showInterstitialAdCancel();
               Navigator.pop(context);
     }, label: Row(children: const [FaIcon(FontAwesomeIcons.x), SizedBox(width: 5,),Text('Cancel')],),backgroundColor: Colors.red,splashColor: HexColor('#D99E6A'),heroTag: 'cancelButton',),
          ),
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FloatingActionButton.extended(onPressed: () {

              //print('Category: ${myMarkerCategoryKey.runtimeType}');
              //print('KEY: ${myMarkerCategoryKey}');


              final newMarker = MyMarkers(dateTime: DateTime.now(), name: nameController.text, description: descriptionController.text, lat: double.parse(latitudeController.text) , long: double.parse(longitudeController.text), altitude: double.parse(altitudeController.text), accuracy: double.parse(accuracyController.text), street: streetController.text, city: townController.text, county: countyController.text, state: stateController.text,zip: zipController.text, countryCode: countryCodeController.text, subLocality: subLocalityController.text, administrativeArea: administrativeAreaController.text, markerCategory:markerCategoryController.text, markerCategoryKey: myMarkerCategoryKey);
              myMarkersBox.putAt(widget.index, newMarker);
              _showInterstitialAdSave();
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
                  padding: const EdgeInsets.only(top: 30, bottom: 50),
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
                      child: TextFormField(decoration: InputDecoration(filled: true,fillColor: HexColor('#b1bdab').withOpacity(0.4),focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20),borderSide: BorderSide(color: HexColor('#D99E6A'))),border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),labelText: 'City area', labelStyle: TextStyle(color: HexColor('#8C4332'),fontSize: 20,fontWeight: FontWeight.w600),hintStyle: const TextStyle(color: Colors.white70)),controller: subLocalityController,),
                    ),


                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(decoration: InputDecoration(filled: true,fillColor: HexColor('#b1bdab').withOpacity(0.4),focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20),borderSide: BorderSide(color: HexColor('#D99E6A'))),border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),labelText: 'District', labelStyle: TextStyle(color: HexColor('#8C4332'),fontSize: 20,fontWeight: FontWeight.w600),hintStyle: const TextStyle(color: Colors.white70)),controller: countyController,),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(decoration: InputDecoration(filled: true,fillColor: HexColor('#b1bdab').withOpacity(0.4),focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20),borderSide: BorderSide(color: HexColor('#D99E6A'))),border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),labelText: 'County/State', labelStyle: TextStyle(color: HexColor('#8C4332'),fontSize: 20,fontWeight: FontWeight.w600),hintStyle: const TextStyle(color: Colors.white70)),controller: administrativeAreaController,),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(decoration: InputDecoration(filled: true,fillColor: HexColor('#b1bdab').withOpacity(0.4),focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20),borderSide: BorderSide(color: HexColor('#D99E6A'))),border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),labelText: 'Postal Code', labelStyle: TextStyle(color: HexColor('#8C4332'),fontSize: 20,fontWeight: FontWeight.w600),hintStyle: const TextStyle(color: Colors.white70)),controller: zipController,),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(decoration: InputDecoration(filled: true,fillColor: HexColor('#b1bdab').withOpacity(0.4),focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20),borderSide: BorderSide(color: HexColor('#D99E6A'))),border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),labelText: 'State', labelStyle: TextStyle(color: HexColor('#8C4332'),fontSize: 20,fontWeight: FontWeight.w600),hintStyle: const TextStyle(color: Colors.white70)),controller: stateController,),
                    ),


                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(decoration: InputDecoration(filled: true,fillColor: HexColor('#b1bdab').withOpacity(0.4),focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20),borderSide: BorderSide(color: HexColor('#D99E6A'))),border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),labelText: 'Country Code', labelStyle: TextStyle(color: HexColor('#8C4332'),fontSize: 20,fontWeight: FontWeight.w600),hintStyle: const TextStyle(color: Colors.white70)),controller: countryCodeController,),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(decoration: InputDecoration(filled: true,fillColor: HexColor('#b1bdab').withOpacity(0.4),focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20),borderSide: BorderSide(color: HexColor('#D99E6A'))),border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),labelText: 'Category', labelStyle: TextStyle(color: HexColor('#8C4332'),fontSize: 20,fontWeight: FontWeight.w600),hintStyle: const TextStyle(color: Colors.white70)),
                          controller:markerCategoryController, readOnly: true, onTap: () async {String? markerCategoryKey = await showDialog(context: context, builder: (BuildContext context) { return CategoryPickerDialogEditMarker(markerIndex: widget.index, marker: widget.marker, mapController: widget.mapController,markerLat: widget.markerLat,markerLong: widget.markerLong  ); }); setState(() {

                        // print('CATEGORY KEY: $markerCategoryKey');
                        // print('CATEGORY KEY: $markerCategoryKey'.runtimeType);
                        //print( 'KEY FROM BOX: ${myMarkersCategoryBox.get(int.parse('$markerCategoryKey'))?.markerCategoryTitle}');

                            if (markerCategoryKey == null) {myMarkerCategoryKey = '${widget.marker.markerCategoryKey}';
                              //print('My null CATEGORY KEY: $myMarkerCategoryKey');print('CATEGORY null KEY: $markerCategoryKey')
                            ;}
                            else if (markerCategoryKey == '000') {myMarkerCategoryKey = '000';
                              //print('My 000 CATEGORY KEY: $myMarkerCategoryKey'); print('CATEGORY 000 KEY: $markerCategoryKey')
                            ;}
                            else {myMarkerCategoryKey = markerCategoryKey;
                              //print('CATEGORY KEY: $myMarkerCategoryKey')
                            ;}

                            if (markerCategoryKey == null) {markerCategoryController.text = myMarkersCategoryBox.get(int.parse(widget.marker.markerCategoryKey!))!.markerCategoryTitle!;
                              //print('My null CATEGORY TITLE: ${markerCategoryController.text}');print('CATEGORY null KEY: $markerCategoryKey')
                            ;}
                            if (markerCategoryKey == '000') {markerCategoryController.text = 'uncategorized';
                              //print('My 000 CATEGORY TITLE: ${markerCategoryController.text}');print('CATEGORY 000 KEY: $markerCategoryKey')
                            ;}
                            else {markerCategoryController.text = myMarkersCategoryBox.get(int.parse(markerCategoryKey!))!.markerCategoryTitle!;
                              //print('CATEGORY Title: ${myMarkersCategoryBox.get(int.parse(markerCategoryKey))!.markerCategoryTitle!}')
                            ;}





                        //     if (markerCategoryKey != null || markerCategoryKey != '000'){myMarkerCategoryKey = markerCategoryKey;}
                        // else {myMarkerCategoryKey = '000';}
                        //
                        // if (markerCategoryKey != null || markerCategoryKey != '000'){markerCategoryController.text = myMarkersCategoryBox.get(int.parse(markerCategoryKey!))!.markerCategoryTitle!;}
                        // else{markerCategoryController.text = 'uncategorized';}

                        // markerCategoryKey != null
                        //     ? myMarkerCategoryKey = markerCategoryKey
                        //     : markerCategoryKey != '000'
                        //     ? myMarkerCategoryKey = markerCategoryKey
                        //     : myMarkerCategoryKey = '000';
                        // markerCategoryKey != null
                        //     ? markerCategoryController.text = myMarkersCategoryBox.get(int.parse(markerCategoryKey))!.markerCategoryTitle!
                        //     : markerCategoryKey != '000'
                        //     ? markerCategoryController.text = myMarkersCategoryBox.get(int.parse(markerCategoryKey!))!.markerCategoryTitle!
                        //
                        //     : markerCategoryController.text = 'uncategorized';


                        //print('CATEGORY KEY: $myMarkerCategoryKey');

                      });}),
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

  @override
  void dispose() {
    super.dispose();
    _interstitialAd?.dispose();
  }

}
